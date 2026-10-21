import 'package:flutter/material.dart';

class AppTheme {
  static const Color maroon = Color(0xFF842B2D);
  static const Color blue = Color(0xFF2457E6);
  static const Color navy = Color(0xFF101828);
  static const Color darkMaroon = Color(0xFF702225);
  static const Color paleRose = Color(0xFFF8EEEE);
  static const Color border = Color(0xFFCBD7E7);
  static const Color surfaceGrey = Color(0xFFF1F5F9);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(seedColor: maroon).copyWith(
      primary: maroon,
      secondary: const Color(0xFFB85C60),
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      appBarTheme: const AppBarTheme(
        backgroundColor: maroon,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shadowColor: maroon,
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: maroon.withOpacity(.04),
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: border),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 13, color: Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF999999))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFAAAAAA))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: maroon, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: maroon,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 46),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: maroon)),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
    );
  }
}
