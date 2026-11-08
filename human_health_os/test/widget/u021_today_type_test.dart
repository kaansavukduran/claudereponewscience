// U021@v0.32: Today uses the four type sizes of docs/DESIGN.md: page title,
// section title, value and body (status chips keep their own small label);
// numbers are the largest thing on a tile.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'f007_measurements_test.dart' show saveBp, settle;
import 'u005_settings_test.dart' show launchWith;

/// Font sizes of the words on Today (icons excluded), each with an example.
Map<double, String> textSizes(WidgetTester tester) {
  final out = <double, String>{};
  final today = find.byKey(const ValueKey('screen-today'));
  for (final e
      in find
          .descendant(of: today, matching: find.byType(RichText))
          .evaluate()) {
    final r = e.renderObject! as RenderParagraph;
    final plain = r.text.toPlainText().trim();
    // Icon glyphs are private-use characters.
    if (plain.isEmpty || plain.runes.every((c) => c >= 0xE000 && c <= 0xF8FF)) {
      continue;
    }
    final size = r.text.style?.fontSize;
    if (size != null) out.putIfAbsent(size, () => plain);
  }
  return out;
}

void main() {
  testWidgets('four sizes plus the chip label, with readings recorded', (
    tester,
  ) async {
    await launchWith(tester);
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '72,4');
    await tester.tap(find.byKey(const ValueKey('weight-save')));
    await settle(tester);
    await saveBp(tester, '120', '80');
    await settle(tester);
    final theme = Theme.of(
      tester.element(find.byKey(const ValueKey('screen-today'))),
    ).textTheme;
    final allowed = {
      theme.headlineSmall!.fontSize, // page title
      theme.titleMedium!.fontSize, // section title
      theme.titleLarge!.fontSize, // value
      theme.bodyMedium!.fontSize, // body and caption
      theme.labelSmall!.fontSize, // status chips (shared component)
    };
    final sizes = textSizes(tester);
    expect(
      sizes.keys.toSet().difference(allowed),
      isEmpty,
      reason: 'extra sizes: $sizes',
    );
    final latest = tester
        .renderObject<RenderParagraph>(
          find.descendant(
            of: find.byKey(const ValueKey('weight-latest')),
            matching: find.byType(RichText),
          ),
        )
        .text
        .style!
        .fontSize!;
    expect(latest, theme.titleLarge!.fontSize);
    final tileValue = tester
        .renderObject<RenderParagraph>(
          find.descendant(
            of: find.byKey(
              const ValueKey('measure-latest-value-vital.blood_pressure'),
            ),
            matching: find.byType(RichText),
          ),
        )
        .text
        .style!
        .fontSize!;
    expect(tileValue, theme.titleLarge!.fontSize);
    expect(latest, greaterThan(theme.titleMedium!.fontSize!));
  });
}
