// U020@v0.32: a Today layout choice puts Measurements above the weight card;
// Reset Today clears it; it is saved with the other display choices.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

double top(WidgetTester tester, String key) =>
    tester.getTopLeft(find.byKey(ValueKey(key))).dy;

void main() {
  testWidgets('weight first by default; the switch puts Measurements first '
      'at once; Reset Today brings the weight back up', (tester) async {
    final c = await launchWith(tester);
    final firstTile = 'measure-tile-vital.blood_pressure';
    expect(top(tester, 'weight-card'), lessThan(top(tester, firstTile)));

    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-measurements-first');
    expect(c.value.measurementsFirst, isTrue);
    await tester.pageBack();
    await settle(tester);
    expect(top(tester, firstTile), lessThan(top(tester, 'weight-card')));

    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-reset-today');
    expect(c.value.measurementsFirst, isFalse);
  });

  test('saved and compared like the other choices', () {
    const on = AppearanceSettings(measurementsFirst: true);
    expect(AppearanceSettings.fromJson(on.toJson()).measurementsFirst, isTrue);
    expect(AppearanceSettings.fromJson(const {}).measurementsFirst, isFalse);
    expect(on == const AppearanceSettings(), isFalse);
    expect(on.resetToday().measurementsFirst, isFalse);
  });

  test('the words judge nothing', () {
    for (final lang in AppLang.values) {
      final w = S(lang).settingsMeasurementsFirst;
      expect(interpretive.hasMatch(w), isFalse, reason: w);
      expect(judged.hasMatch(w), isFalse, reason: w);
    }
  });
}
