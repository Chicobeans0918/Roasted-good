import 'package:flutter/material.dart';

/// Brand system for Roasted — classic serif headlines, cream grounds,
/// espresso accents. Matches the user's original app design.
///
/// [AppColors] holds the canonical light-theme values (kept for the login
/// screen and tasting form, which stay light by design). All theme-aware
/// widgets should use [RoastedPalette] via `context.palette` instead.
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

/// Theme-aware brand palette, resolved from the active [ThemeData].
/// Light keeps the classic cream look; dark is a designed deep-espresso
/// theme (not an OS inversion).
@immutable
class RoastedPalette extends ThemeExtension<RoastedPalette> {
  const RoastedPalette({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.line,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.identityCard,
    required this.onIdentityCard,
    required this.star,
    required this.sage,
  });

  /// Scaffold / app background.
  final Color background;

  /// Card surfaces.
  final Color surface;

  /// Subtle fills (chips, badges, bars).
  final Color surfaceVariant;

  /// Hairline borders and dividers.
  final Color line;

  /// Primary text and icons.
  final Color ink;

  /// Secondary text.
  final Color muted;

  /// Primary buttons and highlights.
  final Color accent;

  /// Text/icons on [accent].
  final Color onAccent;

  /// Taste-identity card background (espresso in light, cream in dark).
  final Color identityCard;

  /// Text on the taste-identity card.
  final Color onIdentityCard;

  /// Rating stars.
  final Color star;

  /// Flavour affinity bars.
  final Color sage;

  static const RoastedPalette light = RoastedPalette(
    background: Color(0xFFECE0D1),
    surface: Color(0xFFECE0D1),
    surfaceVariant: Color(0xFFE0D2B8),
    line: Color(0xFFDDD0BC),
    ink: Color(0xFF967259),
    muted: Color(0xFFA98F6F),
    accent: Color(0xFF3E2A1E),
    onAccent: Color(0xFFECE0D1),
    identityCard: Color(0xFF3E2A1E),
    onIdentityCard: Color(0xFFECE0D1),
    star: Color(0xFFE8930C),
    sage: Color(0xFFB7D3A8),
  );

  static const RoastedPalette dark = RoastedPalette(
    background: Color(0xFF1C130C),
    surface: Color(0xFF2A1D12),
    surfaceVariant: Color(0xFF3A2A18),
    line: Color(0xFF4A3524),
    ink: Color(0xFFECE0D1),
    muted: Color(0xFFA98F6F),
    accent: Color(0xFF4A3220),
    onAccent: Color(0xFFECE0D1),
    identityCard: Color(0xFFECE0D1),
    onIdentityCard: Color(0xFF3E2A1E),
    star: Color(0xFFE8930C),
    sage: Color(0xFFB7D3A8),
  );

  @override
  RoastedPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? line,
    Color? ink,
    Color? muted,
    Color? accent,
    Color? onAccent,
    Color? identityCard,
    Color? onIdentityCard,
    Color? star,
    Color? sage,
  }) {
    return RoastedPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      line: line ?? this.line,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      identityCard: identityCard ?? this.identityCard,
      onIdentityCard: onIdentityCard ?? this.onIdentityCard,
      star: star ?? this.star,
      sage: sage ?? this.sage,
    );
  }

  @override
  RoastedPalette lerp(RoastedPalette? other, double t) {
    if (other is! RoastedPalette) return this;
    return RoastedPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant:
          Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      line: Color.lerp(line, other.line, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      identityCard: Color.lerp(identityCard, other.identityCard, t)!,
      onIdentityCard:
          Color.lerp(onIdentityCard, other.onIdentityCard, t)!,
      star: Color.lerp(star, other.star, t)!,
      sage: Color.lerp(sage, other.sage, t)!,
    );
  }
}

/// Shortcut: `context.palette`.
extension RoastedContext on BuildContext {
  RoastedPalette get palette =>
      Theme.of(this).extension<RoastedPalette>()!;
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

  /// Serif headline in the theme's primary text color.
  static TextStyle serifFor(
    BuildContext context, {
    double size = 16,
    FontWeight weight = FontWeight.w600,
    double? height,
  }) =>
      serifStyle(
        size: size,
        weight: weight,
        color: context.palette.ink,
        height: height,
      );
}

abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [RoastedPalette.light],
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

  /// Designed dark theme: deep espresso surfaces, cream text, same
  /// Playfair serif. Not an OS inversion — every surface is deliberate.
  static ThemeData dark() {
    const p = RoastedPalette.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [RoastedPalette.dark],
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFECE0D1),
        onPrimary: Color(0xFF1C130C),
        secondary: Color(0xFFA98F6F),
        onSecondary: Color(0xFF1C130C),
        surface: Color(0xFF2A1D12),
        onSurface: Color(0xFFECE0D1),
        surfaceContainerHighest: Color(0xFF3A2A18),
      ),
      scaffoldBackgroundColor: p.background,
      dividerColor: p.line,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C130C),
        foregroundColor: Color(0xFFECE0D1),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2A1D12),
        selectedItemColor: Color(0xFFECE0D1),
        unselectedItemColor: Color(0xFFA98F6F),
        elevation: 0,
      ),
      textTheme: TextTheme(
        displayLarge: AppType.serifStyle(size: 40, color: p.ink),
        displayMedium: AppType.serifStyle(size: 34, color: p.ink),
        displaySmall: AppType.serifStyle(size: 28, color: p.ink),
        headlineLarge: AppType.serifStyle(size: 26, color: p.ink),
        headlineMedium: AppType.serifStyle(size: 22, color: p.ink),
        headlineSmall: AppType.serifStyle(size: 19, color: p.ink),
        titleLarge: AppType.serifStyle(size: 18, color: p.ink),
        titleMedium: AppType.serifStyle(size: 16, color: p.ink),
        titleSmall: AppType.serifStyle(size: 14, color: p.ink),
        bodyLarge: const TextStyle(color: Color(0xFFECE0D1)),
        bodyMedium: const TextStyle(color: Color(0xFFECE0D1)),
        bodySmall: const TextStyle(color: Color(0xFFA98F6F)),
        labelLarge: const TextStyle(color: Color(0xFFECE0D1)),
        labelSmall: const TextStyle(
          color: Color(0xFFA98F6F),
          letterSpacing: 1.2,
        ),
      ),
      iconTheme: const IconThemeData(color: Color(0xFFECE0D1)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          side: BorderSide(color: p.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Color(0xFFA98F6F)),
        hintStyle: TextStyle(color: Color(0xFFA98F6F)),
        prefixIconColor: Color(0xFFA98F6F),
        filled: false,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4A3524)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFECE0D1), width: 1.5),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Color(0xFF2A1D12),
        selectedColor: Color(0xFFECE0D1),
        side: BorderSide(color: Color(0xFF4A3524)),
        shape: StadiumBorder(),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor:
              const WidgetStatePropertyAll(Color(0xFFECE0D1)),
          side: WidgetStatePropertyAll(
            BorderSide(color: p.line),
          ),
        ),
      ),
    );
  }
}
