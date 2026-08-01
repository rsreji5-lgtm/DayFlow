import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: scheme,

      scaffoldBackgroundColor:
          const Color(0xFFF7F8FC),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,

        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF818CF8),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: scheme,

      brightness: Brightness.dark,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,

        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}