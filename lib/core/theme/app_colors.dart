import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF22D3EE);

  // Deep Tech Dark Palette
  static const Color backgroundColor = Color(0xFF0F172A);
  static const Color surfaceColor = Color(0xFF1E293B);
  static const Color primaryTextColor = Color(0xFFF8FAFC);
  static const Color secondaryTextColor = Color(0xFF94A3B8);

  static const List<Color> themeColors = [
    Color(0xFF8B5CF6), // Purple
    Color(0xFF22D3EE), // Cyan
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFF43F5E), // Rose
  ];

  static ThemeData getTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor.withValues(alpha: 0.7),
        surface: surfaceColor,
        onSurface: primaryTextColor,
        surfaceContainerHighest: const Color(0xFF334155),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold, letterSpacing: -1.5),
        displaySmall: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600, letterSpacing: -0.5),
        titleLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: primaryTextColor, letterSpacing: 0.15, fontSize: 16),
        bodyMedium: TextStyle(color: secondaryTextColor, letterSpacing: 0.25, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryTextColor),
        titleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Colors.white24),
      ),
    );
  }
}
