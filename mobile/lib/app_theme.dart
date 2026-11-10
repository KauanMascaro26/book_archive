import 'package:flutter/material.dart';

/// Identidade visual única da Biblioteca dos Irmãos da Memphis.
abstract final class AppTheme {
  static const Color navy = Color(0xFF172B4D);
  static const Color navyDeep = Color(0xFF10213A);
  static const Color navyLight = Color(0xFF263F60);
  static const Color gold = Color(0xFFC6A15B);
  static const Color cream = Color(0xFFF7F4ED);
  static const Color paper = Color(0xFFFFFEFC);
  static const Color field = Color(0xFFFBFAF7);
  static const Color text = Color(0xFF263447);
  static const Color muted = Color(0xFF727B88);
  static const Color border = Color(0xFFE8E1D4);
  static const Color success = Color(0xFF356B48);
  static const Color danger = Color(0xFF9B4840);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.light,
      primary: navy,
      secondary: gold,
      surface: paper,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: const TextStyle(color: muted, fontSize: 13),
        labelStyle: const TextStyle(color: muted, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE5E0D7),
          disabledForegroundColor: muted,
          minimumSize: const Size(44, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          minimumSize: const Size(44, 44),
          side: const BorderSide(color: gold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: paper,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        titleTextStyle: const TextStyle(
          color: navy, fontSize: 18, fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(color: muted, fontSize: 13, height: 1.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: navy,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: navy,
        selectedItemColor: gold,
        unselectedItemColor: Color(0xFFCAD3DF),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
