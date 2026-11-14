import 'package:flutter/material.dart';

class AppTheme {
  static const Color navyPrimary = Color(0xFF0D254C);
  static const Color tealAccent = Color(0xFF00B894);
  static const Color bgLight = Color(0xFFF4F6F9);
  static const Color alertRed = Color(0xFFE53935);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navyPrimary,
          primary: navyPrimary,
          secondary: tealAccent,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: navyPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navyPrimary,
          primary: tealAccent,
          brightness: Brightness.dark,
        ),
      );
}