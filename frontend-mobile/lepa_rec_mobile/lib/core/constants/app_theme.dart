import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF6B9B6E);
  static const Color secondaryWarm = Color(0xFFEDE4EC);
  static const Color background = Color(0xFFF5F9F3);
  static const Color surface = Colors.white;

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: Color.from(alpha: 1, red: 0.42, green: 0.608, blue: 0.431),
      secondary: secondaryWarm,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1C1C1C),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.quicksandTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryGreen,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Color(0xFF8E8E8E),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
