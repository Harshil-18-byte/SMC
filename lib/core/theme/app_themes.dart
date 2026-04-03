import 'package:flutter/material.dart';

/// Medical-grade theme for the Smart City Health Portal
/// Design philosophy: Solid, matte, trustworthy, warm yet professional.
/// Less glossy/glassmorphism, more organic and human.
class AppThemes {
  // ─── Medical Color Palette (Solid & Matte) ──────────────────────────────
  // Primary: Clinical Teal — trust, health, clarity
  static const Color primaryTeal = Color(0xFF2E7D6F);
  static const Color primaryTealDark = Color(0xFF4DB6A0);

  // Accent: Warm Amber — attention, warmth, care
  static const Color accentAmber = Color(0xFFD68A27);

  // Semantic
  static const Color errorRose = Color(0xFFC62828);
  static const Color successEmerald = Color(0xFF2E7D32);
  static const Color warningAmber = Color(0xFFF57F17);
  static const Color infoSky = Color(0xFF1565C0);

  // Surface palette — Light (Warm, like paper/clipboard)
  static const Color _lightScaffold = Color(0xFFF5F0EB); // Warm cream
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightAppBar = Color(0xFFF5F0EB);

  // Surface palette — Dark (Deep Charcoal, solid)
  static const Color _darkScaffold = Color(0xFF141618);
  static const Color _darkSurface = Color(0xFF1C1F22);
  static const Color _darkCard = Color(0xFF1C1F22);
  static const Color _darkAppBar = Color(0xFF141618);

  // ─── Corner Radii (Less rounded, more solid) ────────────
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;

  // ─── Light Theme ────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryTeal,
    scaffoldBackgroundColor: _lightScaffold,
    colorScheme: const ColorScheme.light(
      primary: primaryTeal,
      primaryContainer: Color(0xFFB0DFD6),
      secondary: accentAmber,
      secondaryContainer: Color(0xFFF3D0A3),
      tertiary: Color(0xFF5C6BC0),
      tertiaryContainer: Color(0xFFC5CAE9),
      surface: _lightSurface,
      error: errorRose,
      errorContainer: Color(0xFFFFCDD2),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: Color(0xFF2C2825),
      onError: Colors.white,
      outline: Color(0xFFD6CFC7),
      outlineVariant: Color(0xFFEBE5DF),
      shadow: Color(0x1F000000),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightAppBar,
      foregroundColor: const Color(0xFF2C2825),
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0x0A000000),
      iconTheme: const IconThemeData(color: Color(0xFF4A4440), size: 22),
      titleTextStyle: const TextStyle(
        color: Color(0xFF2C2825),
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),
    cardTheme: CardThemeData(
      color: _lightCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: const BorderSide(
          color: Color(0xFFD6CFC7),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTeal,
        side: const BorderSide(color: primaryTeal, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryTeal,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryTeal,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFD6CFC7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFD6CFC7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: primaryTeal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: errorRose),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: errorRose, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        color: Color(0xFF9A938C),
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF6B6560),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF5F0EB),
      selectedColor: primaryTeal.withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      side: const BorderSide(color: Color(0xFFD6CFC7)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: primaryTeal,
      unselectedItemColor: Color(0xFF9A938C),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: primaryTeal.withValues(alpha: 0.15),
      backgroundColor: _lightSurface,
      elevation: 0,
      height: 70,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFD6CFC7),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2C2825),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      elevation: 4,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      showDragHandle: true,
      dragHandleColor: Color(0xFFD6CFC7),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF4A4440),
      size: 22,
    ),
    listTileTheme: ListTileThemeData(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryTeal;
        return const Color(0xFF9A938C);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryTeal.withValues(alpha: 0.3);
        }
        return const Color(0xFFD6CFC7);
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryTeal,
      linearMinHeight: 4,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2825),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 13),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          color: Color(0xFF2C2825),
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5),
      displayMedium: TextStyle(
          color: Color(0xFF2C2825),
          fontWeight: FontWeight.w700,
          letterSpacing: -1),
      displaySmall: TextStyle(
          color: Color(0xFF2C2825),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5),
      headlineLarge:
          TextStyle(color: Color(0xFF2C2825), fontWeight: FontWeight.w700),
      headlineMedium:
          TextStyle(color: Color(0xFF2C2825), fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(color: Color(0xFF2C2825), fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          color: Color(0xFF2C2825),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2),
      titleMedium: TextStyle(
          color: Color(0xFF4A4440),
          fontWeight: FontWeight.w600,
          letterSpacing: 0),
      titleSmall: TextStyle(
          color: Color(0xFF6B6560),
          fontWeight: FontWeight.w600,
          letterSpacing: 0),
      bodyLarge: TextStyle(color: Color(0xFF4A4440), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF6B6560), fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFF9A938C), fontSize: 12),
      labelLarge: TextStyle(
          color: Color(0xFF4A4440),
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1),
      labelMedium: TextStyle(
          color: Color(0xFF9A938C), fontWeight: FontWeight.w500, fontSize: 12),
      labelSmall: TextStyle(
          color: Color(0xFFB5B0AA),
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.5),
    ),
  );

  // ─── Dark Theme ─────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryTealDark,
    scaffoldBackgroundColor: _darkScaffold,
    colorScheme: const ColorScheme.dark(
      primary: primaryTealDark,
      primaryContainer: Color(0xFF2E7D6F),
      secondary: accentAmber,
      secondaryContainer: Color(0xFF8A5A19),
      tertiary: Color(0xFF7986CB),
      tertiaryContainer: Color(0xFF3F51B5),
      surface: _darkSurface,
      error: Color(0xFFEF5350),
      errorContainer: Color(0xFF8E0000),
      onPrimary: Color(0xFF141618),
      onSecondary: Color(0xFF141618),
      onTertiary: Color(0xFF141618),
      onSurface: Color(0xFFE8E4DF),
      onError: Color(0xFF141618),
      outline: Color(0xFF4A4440),
      outlineVariant: Color(0xFF2A2D31),
      shadow: Color(0x40000000),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkAppBar,
      foregroundColor: const Color(0xFFE8E4DF),
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      iconTheme: const IconThemeData(color: Color(0xFFD6CFC7), size: 22),
      titleTextStyle: const TextStyle(
        color: Color(0xFFE8E4DF),
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
    ),
    cardTheme: CardThemeData(
      color: _darkCard,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        side: const BorderSide(
          color: Color(0xFF2A2D31),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTealDark,
        foregroundColor: const Color(0xFF141618),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTealDark,
        side: const BorderSide(color: primaryTealDark, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryTealDark,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryTealDark,
      foregroundColor: Color(0xFF141618),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1F22),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFF2A2D31)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFF2A2D31)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: primaryTealDark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFEF5350)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusSm),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        color: Color(0xFF6B6560),
        fontSize: 14,
      ),
      labelStyle: const TextStyle(
        color: Color(0xFF9A938C),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF1C1F22),
      selectedColor: primaryTealDark.withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      side: const BorderSide(color: Color(0xFF2A2D31)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: primaryTealDark,
      unselectedItemColor: Color(0xFF6B6560),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: primaryTealDark.withValues(alpha: 0.15),
      backgroundColor: _darkSurface,
      elevation: 0,
      height: 70,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2D31),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFFD6CFC7),
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      contentTextStyle: const TextStyle(color: Color(0xFF141618), fontSize: 14),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      elevation: 4,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      showDragHandle: true,
      dragHandleColor: Color(0xFF4A4440),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFFD6CFC7),
      size: 22,
    ),
    listTileTheme: ListTileThemeData(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryTealDark;
        return const Color(0xFF6B6560);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryTealDark.withValues(alpha: 0.3);
        }
        return const Color(0xFF2A2D31);
      }),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryTealDark,
      linearMinHeight: 4,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xFF4A4440),
        borderRadius: BorderRadius.circular(4),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 13),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          color: Color(0xFFE8E4DF),
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5),
      displayMedium: TextStyle(
          color: Color(0xFFE8E4DF),
          fontWeight: FontWeight.w700,
          letterSpacing: -1),
      displaySmall: TextStyle(
          color: Color(0xFFE8E4DF),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5),
      headlineLarge:
          TextStyle(color: Color(0xFFE8E4DF), fontWeight: FontWeight.w700),
      headlineMedium:
          TextStyle(color: Color(0xFFE8E4DF), fontWeight: FontWeight.w600),
      headlineSmall:
          TextStyle(color: Color(0xFFE8E4DF), fontWeight: FontWeight.w600),
      titleLarge: TextStyle(
          color: Color(0xFFE8E4DF),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2),
      titleMedium: TextStyle(
          color: Color(0xFFD6CFC7),
          fontWeight: FontWeight.w600,
          letterSpacing: 0),
      titleSmall: TextStyle(
          color: Color(0xFF9A938C),
          fontWeight: FontWeight.w600,
          letterSpacing: 0),
      bodyLarge: TextStyle(color: Color(0xFFD6CFC7), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF9A938C), fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFF6B6560), fontSize: 12),
      labelLarge: TextStyle(
          color: Color(0xFFD6CFC7),
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1),
      labelMedium: TextStyle(
          color: Color(0xFF6B6560), fontWeight: FontWeight.w500, fontSize: 12),
      labelSmall: TextStyle(
          color: Color(0xFF4A4440),
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.5),
    ),
  );

  // ─── Legacy alias for backward compatibility ────────────
  static const Color primaryBlue = primaryTeal;
  static const Color primaryDark = primaryTealDark;
  static const Color accentOrange = accentAmber;
  static const Color errorRed = errorRose;
  static const Color successGreen = successEmerald;
}
