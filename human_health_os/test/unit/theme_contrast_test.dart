// Calm clinical theme (docs/DESIGN.md): the edge of an input field must be
// visible (3:1 against the surface it sits on, WCAG 1.4.11) and text must
// read (4.5:1), in the light and the dark theme.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/presentation/theme/human_os_theme.dart';

double _lum(Color c) {
  double f(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
}

double contrast(Color a, Color b) {
  final la = _lum(a);
  final lb = _lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final brightness in Brightness.values) {
    test('${brightness.name}: field edges, text and accent have enough '
        'contrast', () {
      final theme = buildHumanOsTheme(brightness);
      final scheme = theme.colorScheme;
      final border =
          (theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder)
              .borderSide
              .color;
      final card = theme.cardTheme.color!;
      expect(
        contrast(border, card),
        greaterThanOrEqualTo(3.0),
        reason: 'field edge on card',
      );
      expect(
        contrast(border, scheme.surface),
        greaterThanOrEqualTo(3.0),
        reason: 'field edge on surface',
      );
      expect(
        contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(7.0),
      );
      expect(
        contrast(scheme.outline, card),
        greaterThanOrEqualTo(4.5),
        reason: 'muted text on card',
      );
      expect(
        contrast(scheme.outline, scheme.surface),
        greaterThanOrEqualTo(4.5),
        reason: 'muted text on surface',
      );
      expect(
        contrast(scheme.primary, card),
        greaterThanOrEqualTo(4.5),
        reason: 'accent on card',
      );
      expect(
        contrast(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
        reason: 'button text',
      );
      expect(
        theme.cardTheme.shape,
        isA<RoundedRectangleBorder>(),
        reason: 'one container style',
      );
    });
  }
}
