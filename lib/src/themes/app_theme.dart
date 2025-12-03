import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData mainTheme = ThemeData(
    brightness: Brightness.dark, // โทนแบบเข้ม (ดำ)
    scaffoldBackgroundColor: Colors.black,
    primaryColor: const Color(0xFFFFD700), // สีทอง
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFD700), // Gold
      secondary: Color(0xFFB71C1C), // Red deep
      onPrimary: Color.fromARGB(255, 185, 178, 178),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 71, 71, 71),
      foregroundColor: Color(0xFFFFD700),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}
