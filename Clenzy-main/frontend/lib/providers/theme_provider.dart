import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();

  factory ThemeProvider() => _instance;

  ThemeProvider._internal();

  static ThemeProvider get instance => _instance;

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Luxury Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1E293B), // Deep slate
      scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Pearl white
      textTheme: GoogleFonts.outfitTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E293B), // Deep slate primary
        primary: const Color(0xFF1E293B),
        secondary: const Color(0xFFBC9A5C), // Champagne gold accent
        surface: Colors.white,
        onSurface: const Color(0xFF111827),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF111827),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: const Color(0xFFE5E7EB)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: Color(0xFF1E293B),
        unselectedItemColor: Color(0xFF9CA3AF),
        elevation: 0,
      ),
    );
  }

  // Luxury Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFFD4AF37), // Luxury Gold
      scaffoldBackgroundColor: const Color(0xFF090A0C), // Obsidian
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFBC9A5C), // Champagne gold
        primary: const Color(0xFFBC9A5C),
        surface: const Color(0xFF121418), // Matte black surface
        onSurface: const Color(0xFFF3F4F6),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF121418),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: Color(0xFFBC9A5C),
        unselectedItemColor: Color(0xFF6B7280),
        elevation: 0,
      ),
    );
  }
}
