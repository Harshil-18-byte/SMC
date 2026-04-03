import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bharat Infra Production-Grade Theme System
/// Implements Pure White (Light) and OLED Black (Dark) with maximum accessibility.
class AppThemes {
  // Industrial Color Palette
  static const Color primaryBlue = Color(0xFF1177BB);
  static const Color accentAmber = Color(0xFFD68A27);
  static const Color errorRed = Color(0xFFBA1A1A);
  static const Color successGreen = Color(0xFF2E7D32);

  // Surface Colors - Light (Pure White)
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightOnSurface = Color(0xFF111111);
  static const Color _lightScaffold = Color(0xFFFAFAFA);

  // Surface Colors - Dark (OLED Black)
  static const Color _darkSurface = Color(0xFF000000);
  static const Color _darkOnSurface = Color(0xFFFFFFFF);
  static const Color _darkScaffold = Color(0xFF000000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: _lightScaffold,
      colorScheme: ColorScheme.light(
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: accentAmber,
        onSecondary: Colors.white,
        error: errorRed,
        onError: Colors.white,
        outline: Color(0xFFCCCCCC),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: _lightOnSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: _lightOnSurface),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: _lightOnSurface,
        displayColor: _lightOnSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: _darkScaffold,
      colorScheme: ColorScheme.dark(
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: accentAmber,
        onSecondary: Colors.white,
        error: errorRed,
        onError: Colors.white,
        outline: Color(0xFF333333),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: _darkOnSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: _darkOnSurface),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF222222), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: _darkOnSurface,
        displayColor: _darkOnSurface,
      ),
    );
  }

  // Common Aliases
  static const Color accentOrange = accentAmber;
  static const Color successEmerald = successGreen;
}
