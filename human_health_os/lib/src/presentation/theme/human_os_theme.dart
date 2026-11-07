/// Design tokens shared in meaning with the Build Lab (packages/ui/src/tokens.css):
/// protection / burden / function / confidence roles. Meaning never relies on
/// colour alone; widgets pair every role colour with an icon and a text label.
library;

import 'package:flutter/material.dart';

@immutable
class HealthRoleColors extends ThemeExtension<HealthRoleColors> {
  const HealthRoleColors({
    required this.protection,
    required this.burden,
    required this.function,
    required this.confidence,
    required this.synthetic,
  });

  final Color protection;
  final Color burden;
  final Color function;
  final Color confidence;
  final Color synthetic;

  static const light = HealthRoleColors(
    protection: Color(0xFF0F7F74),
    burden: Color(0xFFB4541A),
    function: Color(0xFF6A4BC4),
    confidence: Color(0xFF2F5BD3),
    synthetic: Color(0xFF8A5A00),
  );

  static const dark = HealthRoleColors(
    protection: Color(0xFF3FD1BF),
    burden: Color(0xFFF59A5B),
    function: Color(0xFFB49CFF),
    confidence: Color(0xFF7AA2FF),
    synthetic: Color(0xFFF3C35B),
  );

  @override
  HealthRoleColors copyWith({
    Color? protection,
    Color? burden,
    Color? function,
    Color? confidence,
    Color? synthetic,
  }) {
    return HealthRoleColors(
      protection: protection ?? this.protection,
      burden: burden ?? this.burden,
      function: function ?? this.function,
      confidence: confidence ?? this.confidence,
      synthetic: synthetic ?? this.synthetic,
    );
  }

  @override
  HealthRoleColors lerp(ThemeExtension<HealthRoleColors>? other, double t) {
    if (other is! HealthRoleColors) return this;
    return HealthRoleColors(
      protection: Color.lerp(protection, other.protection, t)!,
      burden: Color.lerp(burden, other.burden, t)!,
      function: Color.lerp(function, other.function, t)!,
      confidence: Color.lerp(confidence, other.confidence, t)!,
      synthetic: Color.lerp(synthetic, other.synthetic, t)!,
    );
  }
}

/// Calm clinical look (docs/DESIGN.md): one muted teal accent, near-white
/// surfaces, hairline borders instead of shadows. Colour never judges a value.
ThemeData buildHumanOsTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final accent = dark ? const Color(0xFF7FC4CB) : const Color(0xFF1F6F78);
  final surface = dark ? const Color(0xFF101819) : const Color(0xFFF6F8F8);
  final card = dark ? const Color(0xFF172224) : const Color(0xFFFFFFFF);
  final hairline = dark ? const Color(0xFF2B3A3D) : const Color(0xFFDDE4E4);
  final ink = dark ? const Color(0xFFE6EEEE) : const Color(0xFF1B2B2E);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F6F78),
        brightness: brightness,
      ).copyWith(
        primary: accent,
        onPrimary: dark ? const Color(0xFF06292D) : Colors.white,
        primaryContainer: dark
            ? const Color(0xFF1C3A3E)
            : const Color(0xFFD9ECEE),
        onPrimaryContainer: dark
            ? const Color(0xFFCDEBEE)
            : const Color(0xFF0E3A40),
        surface: surface,
        onSurface: ink,
        surfaceContainerLowest: card,
        surfaceContainerLow: card,
        surfaceContainer: card,
        surfaceContainerHigh: dark
            ? const Color(0xFF1D2B2D)
            : const Color(0xFFEEF2F2),
        surfaceContainerHighest: dark
            ? const Color(0xFF223234)
            : const Color(0xFFE8EDED),
        outline: dark ? const Color(0xFF8AA0A3) : const Color(0xFF5E7275),
        outlineVariant: hairline,
        tertiaryContainer: dark
            ? const Color(0xFF223234)
            : const Color(0xFFE8EDED),
        onTertiaryContainer: ink,
      );
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final text = base.textTheme
      .apply(bodyColor: ink, displayColor: ink)
      .copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: ink,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      );
  final radius = BorderRadius.circular(12);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    scaffoldBackgroundColor: surface,
    textTheme: text,
    extensions: [dark ? HealthRoleColors.dark : HealthRoleColors.light],
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: card,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: hairline),
      ),
    ),
    dividerTheme: DividerThemeData(color: hairline, space: 1, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accent, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: BorderSide(color: hairline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: surface,
      indicatorColor: scheme.primaryContainer,
      selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
