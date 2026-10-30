import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Spacing constants
// ---------------------------------------------------------------------------
const double kSpaceXS = 4.0;
const double kSpaceS = 8.0;
const double kSpaceM = 16.0;
const double kSpaceL = 24.0;
const double kSpaceXL = 32.0;

// ---------------------------------------------------------------------------
// App colour palette
// ---------------------------------------------------------------------------
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF1769D2);
  static const Color primaryDark = Color(0xFF0E3A66);
  static const Color primaryLight = Color(0xFFEAF2FF);

  // Semantic
  static const Color success = Color(0xFF16A36A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);

  // Neutral
  static const Color background = Color(0xFFF3F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF5A6A7A);
  static const Color divider = Color(0xFFE2E8F0);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF1C2333);
}

// ---------------------------------------------------------------------------
// Shared shape / style helpers
// ---------------------------------------------------------------------------
const _kCardRadius = BorderRadius.all(Radius.circular(12));
const _kButtonRadius = BorderRadius.all(Radius.circular(8));
const _kInputRadius = BorderRadius.all(Radius.circular(8));

// ---------------------------------------------------------------------------
// Light theme
// ---------------------------------------------------------------------------
ThemeData get lightTheme {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.primaryDark,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.primaryLight,
    onSecondaryContainer: AppColors.primaryDark,
    tertiary: AppColors.success,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerHighest: AppColors.background,
    outline: AppColors.divider,
    shadow: Color(0x1A000000),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Inter',

    // ── AppBar ──────────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.1,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),

    // ── Card ────────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      shape: const RoundedRectangleBorder(borderRadius: _kCardRadius),
      margin: EdgeInsets.zero,
    ),

    // ── Input ────────────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: kSpaceM,
        vertical: kSpaceS + 2,
      ),
      border: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
    ),

    // ── ElevatedButton ───────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: kSpaceL,
          vertical: kSpaceM,
        ),
        shape: const RoundedRectangleBorder(borderRadius: _kButtonRadius),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── FilledButton ──────────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: kSpaceL,
          vertical: kSpaceM,
        ),
        shape: const RoundedRectangleBorder(borderRadius: _kButtonRadius),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── OutlinedButton ────────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: kSpaceL,
          vertical: kSpaceM,
        ),
        shape: const RoundedRectangleBorder(borderRadius: _kButtonRadius),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── TextButton ───────────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── FloatingActionButton ─────────────────────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // ── BottomNavigationBar ──────────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
    ),

    // ── Divider ──────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // ── Chip ─────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryLight,
      labelStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      side: BorderSide.none,
    ),

    // ── Typography ───────────────────────────────────────────────────────────
    textTheme: _buildTextTheme(AppColors.textPrimary, AppColors.textSecondary),
  );
}

// ---------------------------------------------------------------------------
// Dark theme
// ---------------------------------------------------------------------------
ThemeData get darkTheme {
  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4E9BF5),
    onPrimary: Color(0xFF003063),
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: Color(0xFF8BB8F5),
    onSecondary: Color(0xFF003063),
    secondaryContainer: AppColors.primaryDark,
    onSecondaryContainer: AppColors.primaryLight,
    tertiary: Color(0xFF3ECA8B),
    onTertiary: Color(0xFF003828),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: AppColors.darkSurface,
    onSurface: Color(0xFFE1E7F0),
    onSurfaceVariant: Color(0xFF9BA8B4),
    surfaceContainerHighest: AppColors.darkBackground,
    outline: Color(0xFF2D3748),
    shadow: Color(0x33000000),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Color(0xFFE1E7F0),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE1E7F0),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: _kCardRadius),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: kSpaceM,
        vertical: kSpaceS + 2,
      ),
      border: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: Color(0xFF2D3748)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: Color(0xFF2D3748)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: Color(0xFF4E9BF5), width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: Color(0xFFFF6B6B)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: _kInputRadius,
        borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4E9BF5),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: kSpaceL,
          vertical: kSpaceM,
        ),
        shape: const RoundedRectangleBorder(borderRadius: _kButtonRadius),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF4E9BF5),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: kSpaceL,
          vertical: kSpaceM,
        ),
        shape: const RoundedRectangleBorder(borderRadius: _kButtonRadius),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF4E9BF5),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: Color(0xFF4E9BF5),
      unselectedItemColor: Color(0xFF9BA8B4),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2D3748),
      thickness: 1,
      space: 1,
    ),
    textTheme: _buildTextTheme(
      const Color(0xFFE1E7F0),
      const Color(0xFF9BA8B4),
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared text theme builder
// ---------------------------------------------------------------------------
TextTheme _buildTextTheme(Color primary, Color secondary) {
  return TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 57,
      fontWeight: FontWeight.w700,
      color: primary,
      letterSpacing: -0.25,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 45,
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: primary,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    headlineSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: primary,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: primary,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: primary,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: primary,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: primary,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: secondary,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: primary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: secondary,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: 'Inter',
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: secondary,
      letterSpacing: 0.5,
    ),
  );
}
