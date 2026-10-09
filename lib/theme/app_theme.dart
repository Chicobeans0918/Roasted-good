import 'package:flutter/material.dart';

/// Brand system for Roasted — classic serif headlines, cream grounds,
/// espresso accents. Matches the user's original app design.
abstract final class AppColors {
  /// Primary / text color.
  static const Color ink = Color(0xFF967259);

  /// Muted secondary text.
  static const Color muted = Color(0xFFA98F6F);

  /// App backgrounds.
  static const Color cream = Color(0xFFECE0D1);

  /// Slightly deeper cream for subtle fills.
  static const Color creamDark = Color(0xFFE0D2B8);

  /// Hairline dividers.
  static const Color line = Color(0xFFDDD0BC);

  /// Deep espresso brown — primary buttons, taste identity card.
  static const Color espresso = Color(0xFF3E2A1E);

  /// Warm amber for rating stars.
  static const Color starOrange = Color(0xFFE8930C);

  /// Soft sage for flavour bars.
  static const Color sage = Color(0xFFB7D3A8);

  static const Color white = Color(0xFFFFFFFF);
}

/// Bundled classic serif (Playfair Display) for the wordmark and headings.
abstract final class AppType {
  static const String serif = 'Playfair Display';

  static TextStyle serifStyle({
    double size = 16,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
  }) =>
      TextStyle(
        fontFamily: serif,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.ink,
        onPrimary: AppColors.white,
        secondary: AppColors.ink,
        onSecondary: AppColors.white,
        surface: AppColors.cream,
        onSurface: AppColors.ink,
        surfaceContainerHighest: AppColors.creamDark,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      dividerColor: AppColors.line,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cream,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.muted,
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: AppType.serifStyle(size: 40),
        displayMedium: AppType.serifStyle(size: 34),
        displaySmall: AppType.serifStyle(size: 28),
        headlineLarge: AppType.serifStyle(size: 26),
        headlineMedium: AppType.serifStyle(size: 22),
        headlineSmall: AppType.serifStyle(size: 19),
        titleLarge: AppType.serifStyle(size: 18),
        titleMedium: AppType.serifStyle(size: 16),
        titleSmall: AppType.serifStyle(size: 14),
        bodyLarge: const TextStyle(color: AppColors.ink),
        bodyMedium: const TextStyle(color: AppColors.ink),
        bodySmall: const TextStyle(color: AppColors.muted),
        labelLarge: const TextStyle(color: AppColors.ink),
        labelSmall: const TextStyle(
          color: AppColors.muted,
          letterSpacing: 1.2,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.ink),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.espresso,
          foregroundColor: AppColors.cream,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: AppColors.muted),
        hintStyle: TextStyle(color: AppColors.muted),
        prefixIconColor: AppColors.muted,
        filled: false,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.line),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.ink, width: 1.5),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.cream,
        selectedColor: AppColors.ink,
        side: BorderSide(color: AppColors.line),
        shape: StadiumBorder(),
      ),
    );
  }
}
