// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

final ThemeData collectionerDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF00C6FF), // Яскраво-блакитний для акценту
  scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Дуже темний фон
  cardColor: const Color(0xFF1C2128), // Колір для карток та контейнерів
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Color(0xFFC7C7C7)),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0A0A0A),
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00C6FF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1C2128),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Color(0xFF6C7B8F)),
  ),
  // Налаштування для нижньої навігаційної панелі
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1C2128),
    selectedItemColor: Color(0xFF00C6FF),
    unselectedItemColor: Color(0xFF6C7B8F),
    elevation: 0,
    type: BottomNavigationBarType.fixed,
  ),
);