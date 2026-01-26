import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(ClenzyAdminApp());
}

class ClenzyAdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clenzy Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF1A1A2E),
      ),
      home: LoginScreen(),
    );
  }
}
