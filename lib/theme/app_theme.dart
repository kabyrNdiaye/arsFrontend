import 'package:flutter/material.dart';
import '../utils/font_helper.dart';

ThemeData appTheme() {
  // Créer un TextTheme complet avec Source Serif 4
  final baseTextTheme = TextTheme(
    displayLarge: getSourceSerifProStyle(fontSize: 57, fontWeight: FontWeight.w400, color: Colors.black87),
    displayMedium: getSourceSerifProStyle(fontSize: 45, fontWeight: FontWeight.w400, color: Colors.black87),
    displaySmall: getSourceSerifProStyle(fontSize: 36, fontWeight: FontWeight.w400, color: Colors.black87),
    headlineLarge: getSourceSerifProStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.black87),
    headlineMedium: getSourceSerifProStyle(fontSize: 28, fontWeight: FontWeight.w400, color: Colors.black87),
    headlineSmall: getSourceSerifProStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Colors.black87),
    titleLarge: getSourceSerifProStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black87),
    titleMedium: getSourceSerifProStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
    titleSmall: getSourceSerifProStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
    bodyLarge: getSourceSerifProStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black87),
    bodyMedium: getSourceSerifProStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87),
    bodySmall: getSourceSerifProStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black87),
    labelLarge: getSourceSerifProStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
    labelMedium: getSourceSerifProStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
    labelSmall: getSourceSerifProStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
  );

  return ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    // Utiliser le TextTheme complet avec Source Serif 4
    textTheme: baseTextTheme,
    // Appliquer aussi aux textes primaires
    primaryTextTheme: baseTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0059AB),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: getSourceSerifProStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF0059AB),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0059AB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: getSourceSerifProStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: getSourceSerifProStyle(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF0059AB)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: getSourceSerifProStyle(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0059AB)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF0059AB)),
      ),
      labelStyle: getSourceSerifProStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
      hintStyle: getSourceSerifProStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
    ),
  );
}