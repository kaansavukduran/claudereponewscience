/// Design tokens shared in meaning with the Build Lab (packages/ui/src/tokens.css):
/// protection / burden / function / confidence roles. Meaning never relies on
/// colour alone; widgets pair every role colour with an icon and a text label.
library;

import 'package:flutter/material.dart';

import '../../domain/settings/appearance.dart';

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
/// Light and dark tones of each accent (AccentChoice). The light tone is
/// at least 4.5:1 on white, the dark tone at least 4.5:1 on the dark surface.
const Map<AccentChoice, (Color, Color)> accentTones = {
  AccentChoice.teal: (Color(0xFF1F6F78), Color(0xFF7FC4CB)),
  AccentChoice.blue: (Color(0xFF1F5FA8), Color(0xFF8DB8F0)),
  AccentChoice.purple: (Color(0xFF6A4BA8), Color(0xFFC2AEF2)),
  AccentChoice.green: (Color(0xFF2E6B3A), Color(0xFF8FCB9B)),
  AccentChoice.graphite: (Color(0xFF3F4A55), Color(0xFFB5C0CA)),
};

ThemeData buildHumanOsTheme(
  Brightness brightness, {
  AccentChoice accentChoice = AccentChoice.teal,
  bool highContrast = false,
  bool compact = false,
  String? fontFamily,
  bool wideSpacing = false,
}) {
  final dark = brightness == Brightness.dark;
  final tones = accentTones[accentChoice]!;
  final teal = accentChoice == AccentChoice.teal;
  final accent = dark ? tones.$2 : tones.$1;
  final seeded = ColorScheme.fromSeed(
    seedColor: tones.$1,
    brightness: brightness,
  );
  final surface = dark ? const Color(0xFF101819) : const Color(0xFFF6F8F8);
  final card = dark ? const Color(0xFF172224) : const Color(0xFFFFFFFF);
  // High contrast: pure ink, and edges as dark as the outline text.
  final hairline = highContrast
      ? (dark ? const Color(0xFFB8C8CA) : const Color(0xFF3E4F52))
      : (dark ? const Color(0xFF2B3A3D) : const Color(0xFFDDE4E4));
  final ink = highContrast
      ? (dark ? Colors.white : Colors.black)
      : (dark ? const Color(0xFFE6EEEE) : const Color(0xFF1B2B2E));
  final scheme =
      ColorScheme.fromSeed(
        seedColor: tones.$1,
        brightness: brightness,
      ).copyWith(
        primary: accent,
        onPrimary: dark ? const Color(0xFF06292D) : Colors.white,
        primaryContainer: !teal
            ? seeded.primaryContainer
            : dark
            ? const Color(0xFF1C3A3E)
            : const Color(0xFFD9ECEE),
        onPrimaryContainer: !teal
            ? seeded.onPrimaryContainer
            : dark
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
        outline: highContrast
            ? (dark ? const Color(0xFFD5E0E1) : const Color(0xFF2C3A3C))
            : (dark ? const Color(0xFF8AA0A3) : const Color(0xFF5E7275)),
        outlineVariant: hairline,
        tertiaryContainer: dark
            ? const Color(0xFF223234)
            : const Color(0xFFE8EDED),
        onTertiaryContainer: ink,
      );
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final styled = base.textTheme
      .apply(bodyColor: ink, displayColor: ink, fontFamily: fontFamily)
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
          fontFamily: fontFamily,
        ),
      );
  // Wide spacing: more room between letters, words and lines (WCAG 1.4.12
  // text-spacing values as a guide).
  // The base theme carries colours only; sizes come from the Material type
  // scale, so spacing is measured against each style's real size.
  final scale = Typography.material2021().englishLike;
  TextStyle? spaced(TextStyle? s, TextStyle? size) {
    final px = s?.fontSize ?? size?.fontSize ?? 14;
    return s?.copyWith(
      letterSpacing: px * 0.12,
      wordSpacing: px * 0.16,
      height: 1.5,
    );
  }

  final text = !wideSpacing
      ? styled
      : styled.copyWith(
          displayLarge: spaced(styled.displayLarge, scale.displayLarge),
          displayMedium: spaced(styled.displayMedium, scale.displayMedium),
          displaySmall: spaced(styled.displaySmall, scale.displaySmall),
          headlineLarge: spaced(styled.headlineLarge, scale.headlineLarge),
          headlineMedium: spaced(styled.headlineMedium, scale.headlineMedium),
          headlineSmall: spaced(styled.headlineSmall, scale.headlineSmall),
          titleLarge: spaced(styled.titleLarge, scale.titleLarge),
          titleMedium: spaced(styled.titleMedium, scale.titleMedium),
          titleSmall: spaced(styled.titleSmall, scale.titleSmall),
          bodyLarge: spaced(styled.bodyLarge, scale.bodyLarge),
          bodyMedium: spaced(styled.bodyMedium, scale.bodyMedium),
          bodySmall: spaced(styled.bodySmall, scale.bodySmall),
          labelLarge: spaced(styled.labelLarge, scale.labelLarge),
          labelMedium: spaced(styled.labelMedium, scale.labelMedium),
          labelSmall: spaced(styled.labelSmall, scale.labelSmall),
        );
  // Field boundaries need 3:1 against the surface (WCAG 1.4.11); card
  // outlines stay hairline.
  final fieldEdge = dark ? const Color(0xFF6C8386) : const Color(0xFF7B8E90);
  final navIndicator = !teal
      ? seeded.secondaryContainer
      : dark
      ? const Color(0xFF2E5F66)
      : const Color(0xFFBFE0E3);
  final radius = BorderRadius.circular(12);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
    scaffoldBackgroundColor: surface,
    textTheme: text,
    fontFamily: fontFamily,
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
        borderSide: BorderSide(color: fieldEdge),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: fieldEdge),
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
      indicatorColor: navIndicator,
      selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
      selectedLabelTextStyle: TextStyle(
        color: ink,
        fontWeight: FontWeight.w700,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: card,
      indicatorColor: navIndicator,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          color: ink,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
        ),
      ),
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
