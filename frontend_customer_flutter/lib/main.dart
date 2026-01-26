import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ClenzyCustomerApp());
}

class ClenzyCustomerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clenzy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF1A1A2E),
        scaffoldBackgroundColor: Color(0xFF1A1A2E),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFFE94560),
          secondary: Color(0xFF0F3460),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
