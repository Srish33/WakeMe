import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF8B5CF6);

  // Dark Colors
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFFB3B3B3);

  // Light Colors
  static const Color lightBackgroundColor = Color(0xFFF3F4F6);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightPrimaryTextColor = Color(0xFF1F2937);
  static const Color lightSecondaryTextColor = Color(0xFF6B7280);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSurface: primaryTextColor,
      secondary: primaryPurple,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5D336C),
      elevation: 10,
      titleTextStyle: TextStyle(
        color: primaryTextColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: primaryTextColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF5D336C),
      selectedItemColor: Color(0xFFFFFFFF),
      unselectedItemColor:Color(0xFF959595),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: primaryTextColor),
      bodyMedium: TextStyle(color: secondaryTextColor),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryPurple,
    scaffoldBackgroundColor: lightBackgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      surface: lightSurfaceColor,
      onPrimary: Colors.white,
      onSurface: lightPrimaryTextColor,
      secondary: primaryPurple,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFEEDC82),
      elevation: 10,
      titleTextStyle: TextStyle(
        color: lightPrimaryTextColor,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: lightPrimaryTextColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:  Color(0xFFEEDC82),
      selectedItemColor: Color(0xFF330445),
      unselectedItemColor: lightSecondaryTextColor,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: lightPrimaryTextColor, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: lightPrimaryTextColor),
      bodyMedium: TextStyle(color: lightSecondaryTextColor),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: lightSurfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}