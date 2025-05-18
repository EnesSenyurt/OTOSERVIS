import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0A0E21);
  static const Color accent = Color(0xFF1D47A1);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primary,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: Color(0xFF1E2230),
      background: primary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E2230),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: Colors.white54),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      labelLarge: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}
