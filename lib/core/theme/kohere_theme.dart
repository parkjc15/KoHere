import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KohereTheme {
  // KDS 1.0 — 1-Bit Optimized Colors
  static const Color espressoBlack = Color(0xFF1A1A1A);
  static const Color latteBeige = Color(0xFFD2C5B1);
  static const Color mochaBrown = Color(0xFF5D4037);
  static const Color cream = Color(0xFFF5F5F0);
  static const Color creamDark = Color(0xFFE8E4DB);
  static const Color highlight = Color(0xFF8B6F47);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: latteBeige,
      colorScheme: ColorScheme.light(
        primary: espressoBlack,
        secondary: mochaBrown,
        surface: cream,
        onPrimary: cream,
        onSecondary: cream,
        onSurface: espressoBlack,
      ),
      textTheme: GoogleFonts.pixelifySansTextTheme().copyWith(
        displayLarge: TextStyle(color: espressoBlack, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: espressoBlack, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: espressoBlack),
        bodyMedium: TextStyle(color: espressoBlack),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: mochaBrown,
        foregroundColor: cream,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: espressoBlack,
        thickness: 1,
      ),
    );
  }
}
