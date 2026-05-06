import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Conditional import: loads web implementation on web, stub on native
import 'razorpay_web_stub.dart' if (dart.library.html) 'razorpay_web.dart';

// Only import razorpay_flutter on non-web (it crashes on web)
// Native-only imports are handled via the platform check at runtime.

class PaymentService {


  // Backend URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  /// Call once during widget init to inject the Razorpay JS script on web.
  void initializeForWeb() {
    if (kIsWeb) {
      addRazorpayScript();
    }
  }

  /// Creates a Razorpay order via backend and triggers the payment UI.
  /// [context] is required for web-based payment dialog feedback.
  /// Returns payment ID on success, null on failure.
  Future<String?> makeWebPayment({
    required int amount,
    required String currency,
    required String jobId,
    required String userId,
    required dynamic context,
  }) async {
    try {
      // 1. Create order on backend (now requires jobId and userId)
      final orderData = await createOrder(amount, currency, jobId, userId);
      if (orderData == null) {
        throw Exception('Failed to create order: No response from server');
      }
      
      if (!orderData.containsKey('orderId')) {
        throw Exception('Failed to create order: Missing orderId in response');
      }
      
      if (!orderData.containsKey('key')) {
        throw Exception('Failed to create order: Missing API key in response');
      }
      
      if (orderData['orderId'] == null || orderData['orderId'].toString().isEmpty) {
        throw Exception('Failed to create order: Invalid orderId');
      }

      // 2. Open Razorpay web checkout
      final paymentResult = await createWebOrder(
        keyId: orderData['key'].toString(),
        amount: (orderData['amount'] is int) 
          ? (orderData['amount'] as int) * 100 
          : ((orderData['amount'] as double).toInt()) * 100,
        orderId: orderData['orderId'].toString(),
        name: 'Clenzy',
        description: 'Payment for Booking #$jobId',
        context: context,
      );

      if (paymentResult == null) {
        debugPrint('Payment was cancelled by user');
        return null;
      }

      // 3. Verify Payment
      debugPrint('Verify payload: orderId=${paymentResult['razorpay_order_id']}, paymentId=${paymentResult['razorpay_payment_id']}, signature=${paymentResult['razorpay_signature']}');
      final isVerified = await verifyPayment(
        razorpayOrderId: paymentResult['razorpay_order_id'] ?? '',
        razorpayPaymentId: paymentResult['razorpay_payment_id'] ?? '',
        razorpaySignature: paymentResult['razorpay_signature'] ?? '',
      );

      if (isVerified) {
        return paymentResult['razorpay_payment_id'];
      } else {
        throw Exception('Payment verification failed on the server.');
      }
    } catch (e) {
      debugPrint('Payment error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> createOrder(int amount, String currency, String jobId, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/payment/create-order');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount, 
          'currency': currency,
          'job_id': jobId,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to create order: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (err) {
      debugPrint('Error creating order: $err');
      return null;
    }
  }

  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/payment/verify-payment');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      } else {
        debugPrint('Verification failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (err) {
      debugPrint('Error verifying payment: $err');
      return false;
    }
  }
}
