// Stub for mobile platforms – actual web implementation is in payment_service_web.dart
import 'package:flutter/material.dart';

void addRazorpayScript() {}

Future<Map<String, String>?> createWebOrder({
  required String keyId,
  required int amount,
  required String orderId,
  required String name,
  required String description,
  required BuildContext context,
}) async {
  return null;
}
