import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1F4D9A);
  static const Color midnightNavy = Color(0xFF102A43);
  static const Color teal = Color(0xFF2BB3A9);
  static const Color warmGold = Color(0xFFE8B84B);
  static const Color coralRed = Color(0xFFE25A5A);
  static const Color charcoal = Color(0xFF1F2937);
  static const Color slate = Color(0xFF475569);
  static const Color muted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color successSurface = Color(0xFFEAFBF7);
  static const Color warningSurface = Color(0xFFFFF7E8);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: midnightNavy,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}
