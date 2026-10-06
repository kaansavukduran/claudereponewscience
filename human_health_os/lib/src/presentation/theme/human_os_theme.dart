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

ThemeData buildHumanOsTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2F5BD3),
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    visualDensity: VisualDensity.standard,
    extensions: [
      brightness == Brightness.dark
          ? HealthRoleColors.dark
          : HealthRoleColors.light,
    ],
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
  );
}
