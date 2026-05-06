// Web-specific Razorpay implementation using Razorpay's hosted checkout.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_interop';
import 'dart:async';
import 'package:flutter/material.dart';

/// Injects the Razorpay checkout.js script into the document head if not already present.
void addRazorpayScript() {
  if (html.document.querySelector('script[src*="checkout.razorpay.com"]') != null) {
    return; // Already injected
  }
  final script = html.ScriptElement()
    ..src = 'https://checkout.razorpay.com/v1/checkout.js'
    ..type = 'text/javascript';
  html.document.head!.append(script);
}

/// Opens the Razorpay payment window on web using the hosted checkout.
/// Returns a map with payment ID, signature, and order ID on success, null on failure/cancellation.
Future<Map<String, String>?> createWebOrder({
  required String keyId,
  required int amount,
  required String orderId,
  required String name,
  required String description,
  required BuildContext context,
}) {
  final completer = Completer<Map<String, String>?>();

  // Use JS eval to create a handler that stores the response values directly
  // This avoids all Dart-JS interop issues with property access
  js.context.callMethod('eval', ['''
    window._razorpayResult = null;
    window._razorpayDismissed = false;
  ''']);

  js.context['_razorpayHandler'] = ((JSAny? response) {
    try {
      // Store the response in a JS global so we can read properties via JsObject
      js.context['_razorpayResponse'] = response;

      // Read using JsObject bracket notation on the context
      final jsResponse = js.context['_razorpayResponse'] as js.JsObject;
      final paymentId = jsResponse['razorpay_payment_id']?.toString() ?? '';
      final razorpayOrderId = jsResponse['razorpay_order_id']?.toString() ?? '';
      final signature = jsResponse['razorpay_signature']?.toString() ?? '';

      debugPrint('Razorpay Success: paymentId=$paymentId, orderId=$razorpayOrderId');

      if (paymentId.isNotEmpty && !completer.isCompleted) {
        completer.complete({
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': signature,
        });
      } else if (!completer.isCompleted) {
        debugPrint('Razorpay handler: Empty paymentId, trying dynamic access');
        // Fallback: try dynamic access
        final dynRes = response as dynamic;
        final pid = dynRes?.razorpay_payment_id?.toString() ?? '';
        final oid = dynRes?.razorpay_order_id?.toString() ?? '';
        final sig = dynRes?.razorpay_signature?.toString() ?? '';
        debugPrint('Razorpay Fallback: paymentId=$pid, orderId=$oid');
        if (pid.isNotEmpty) {
          completer.complete({
            'razorpay_payment_id': pid,
            'razorpay_order_id': oid,
            'razorpay_signature': sig,
          });
        } else {
          completer.completeError('Could not extract payment details from response');
        }
      }
    } catch (e) {
      debugPrint('Error in Razorpay handler: $e');
      if (!completer.isCompleted) {
        completer.completeError('Payment response parsing failed: $e');
      }
    }
  }).toJS;

  // Dismiss handler
  js.context['_razorpayOnDismiss'] = (() {
    debugPrint('Razorpay modal dismissed by user');
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  }).toJS;

  // Build options using direct JS eval to avoid any Dart-JS conversion issues
  final optionsJson = '''
  {
    "key": "$keyId",
    "amount": $amount,
    "currency": "INR",
    "name": "$name",
    "description": "$description",
    "order_id": "$orderId",
    "handler": window._razorpayHandler,
    "modal": {
      "ondismiss": window._razorpayOnDismiss,
      "escape": false
    },
    "prefill": {
      "contact": "9876543210",
      "email": "user@example.com"
    },
    "theme": {
      "color": "#3B82F6"
    }
  }
  ''';

  try {
    // Create and open Razorpay using eval to stay fully in JS-land
    js.context.callMethod('eval', ['''
      try {
        var opts = $optionsJson;
        var rzp = new Razorpay(opts);
        rzp.on("payment.failed", function(resp) {
          console.error("Razorpay payment failed:", JSON.stringify(resp.error));
        });
        rzp.open();
      } catch(e) {
        console.error("Razorpay open error:", e);
        throw e;
      }
    ''']);
  } catch (e) {
    debugPrint('Error opening Razorpay: $e');
    if (!completer.isCompleted) {
      completer.completeError('Failed to open Razorpay checkout: $e');
    }
  }

  // Timeout after 5 min
  Future<void>.delayed(const Duration(minutes: 5)).then((_) {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  });

  return completer.future;
}
