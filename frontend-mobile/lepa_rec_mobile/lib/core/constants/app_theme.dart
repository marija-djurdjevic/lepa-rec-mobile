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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: _MeditativePageTransitionsBuilder(),
          TargetPlatform.iOS: _MeditativePageTransitionsBuilder(),
          TargetPlatform.linux: _MeditativePageTransitionsBuilder(),
          TargetPlatform.macOS: _MeditativePageTransitionsBuilder(),
          TargetPlatform.windows: _MeditativePageTransitionsBuilder(),
        },
      ),
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

class _MeditativePageTransitionsBuilder extends PageTransitionsBuilder {
  const _MeditativePageTransitionsBuilder();

  static const Curve _curve = Curves.easeInOutQuart;
  static const Duration _duration = Duration(milliseconds: 950);
  static const Duration _settleDelay = Duration(milliseconds: 200);
  static const Color _fadeThroughColor = Color(0xFFF5F9F3);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(
        _settleDelay.inMilliseconds / _duration.inMilliseconds,
        1.0,
        curve: _curve,
      ),
      reverseCurve: _curve,
    );

    return Stack(
      children: [
        const ColoredBox(color: _fadeThroughColor),
        FadeTransition(
          opacity: curved,
          child: child,
        ),
      ],
    );
  }
}
