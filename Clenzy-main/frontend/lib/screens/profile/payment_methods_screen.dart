import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../services/payment_service.dart';
import '../../services/job_service_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late Razorpay _razorpay;
  final PaymentService _paymentService = PaymentService();
  final JobServiceClient _jobServiceClient = JobServiceClient();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      await _paymentService.verifyPayment(
        razorpayOrderId: response.orderId!,
        razorpayPaymentId: response.paymentId!,
        razorpaySignature: response.signature!,
      );
      if (mounted) {
        setState(() => _isProcessing = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Verification failed: $e')));
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${response.message}')),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) setState(() => _isProcessing = false);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Placed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'You can see your booking in the Bookings tab.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3366FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processCheckout(String methodName) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    final storage = const FlutterSecureStorage();
    final userId = await storage.read(key: 'userId') ?? '';

    try {
      // 1. Always create the job first so it shows up in Bookings
      String jobIdStr = await _jobServiceClient.createJob(
        serviceType: 'Deep Cleaning',
        price: 150.0,
        workersNeeded: 1,
        latitude: 0.0,
        longitude: 0.0,
        address: 'Home - Sector 3',
        description: 'New booking via $methodName',
      );

      final String jobId = jobIdStr;

      if (methodName == 'Cash on Delivery') {
        // Just show success
        setState(() => _isProcessing = false);
        _showSuccessDialog();
      } else {
        // Trigger Razorpay for cards/UPI
        final order = await _paymentService.createOrder(
          150, // amount
          'INR',
          jobId,
          userId, // dynamic userId
        );

        final options = {
          'key': order!['key'],
          'amount': (order['amount'] * 100).toInt(),
          'currency': order['currency'],
          'name': 'Clenzy Services',
          'description': 'Payment for Booking ID $jobIdStr',
          'order_id': order['orderId'],
          'prefill': {'contact': '9876543210', 'email': 'user@clenzy.com'},
        };
        _razorpay.open(options);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildPaymentOption(
                  context,
                  Icons.account_balance_wallet,
                  'Wallet',
                  'Balance: ₹120.00',
                ),
                _buildPaymentOption(
                  context,
                  Icons.credit_card,
                  'Credit/Debit Card',
                  'Add a new card',
                ),
                _buildPaymentOption(
                  context,
                  Icons.qr_code_scanner,
                  'UPI',
                  'Pay via UPI apps',
                ),
                _buildPaymentOption(
                  context,
                  Icons.money,
                  'Cash on Delivery',
                  'Pay with cash',
                ),
              ],
            ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3366FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF3366FF)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          _processCheckout(title);
        },
      ),
    );
  }
}
