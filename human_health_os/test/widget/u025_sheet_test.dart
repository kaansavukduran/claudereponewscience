// U025 (G-74): sheet buttons stay in view; times can be picked by clicking.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('on a short window the long food sheet keeps Save and Cancel '
      'in view without scrolling', (tester) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-nutrition')));
    await settle(tester);
    await tapKey(tester, 'food-add');
    // Shrink the window under the open sheet.
    tester.view.physicalSize = const Size(1280, 520);
    await settle(tester);
    for (final k in ['food-save', 'food-cancel']) {
      final box = tester.getRect(find.byKey(ValueKey(k)));
      expect(box.bottom, lessThanOrEqualTo(520), reason: k);
      expect(box.top, greaterThanOrEqualTo(0), reason: k);
    }
    // The last label field is below the fold: the fields scroll, the
    // buttons do not.
    final last = tester.getRect(find.byKey(const ValueKey('food-n-salt')));
    expect(last.top, greaterThan(520));
    await tapKey(tester, 'food-cancel');
  });

  testWidgets('sleep: pick 23:00 and now by clicking, save', (tester) async {
    await launchWith(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('sleep-add')));
    await tapKey(tester, 'sleep-add');
    await tapKey(tester, 'sleep-bed-pick-23:00');
    expect(find.text('23:00'), findsWidgets);
    await tapKey(tester, 'sleep-woke-pick-Now');
    await tapKey(tester, 'sleep-save');
    await settle(tester);
    expect(find.textContaining(' min in bed'), findsOneWidget);
  });

  testWidgets('activity: "1 hour ago" fills the time field', (tester) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-activity')));
    await settle(tester);
    await tapKey(tester, 'act-add');
    await tapKey(tester, 'act-when-pick-1 hour ago');
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('act-when')),
    );
    expect(
      field.controller!.text,
      matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$')),
    );
  });
}
