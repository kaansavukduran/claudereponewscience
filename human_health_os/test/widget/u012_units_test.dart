// U012@v0.32: display units. Values stay as typed (kg, cm, °C); with US
// units a converted value is shown beside them, marked ≈; nothing stored
// changes.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/domain/units/display_units.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show latestOf, saveScalar, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  test('conversions are labelled ≈ and only for kg, cm and °C', () {
    expect(convertedFor(72.4, 'kg', UnitSystem.us), '≈ 159.6 lb');
    expect(convertedFor(172.5, 'cm', UnitSystem.us), '≈ 67.9 in');
    expect(convertedFor(36.6, '°C', UnitSystem.us), '≈ 97.9 °F');
    expect(convertedFor(118, 'mmHg', UnitSystem.us), isNull);
    expect(convertedFor(97, '%', UnitSystem.us), isNull);
    expect(convertedFor(72.4, 'kg', UnitSystem.metric), isNull);
  });

  testWidgets('US units add the converted value beside the typed one; the '
      'record keeps what was typed', (tester) async {
    final c = await launchWith(
      tester,
      initial: const AppearanceSettings(units: UnitSystem.us),
    );
    await saveScalar(tester, RecordKind.height, '172.5');
    expect(latestOf(tester, RecordKind.height), contains('172.5 cm'));
    expect(latestOf(tester, RecordKind.height), contains('(≈ 67.9 in)'));
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '72.4');
    await tapKey(tester, 'weight-save');
    expect(find.textContaining('72.4 kg (≈ 159.6 lb)'), findsWidgets);
    await c.update(c.value.copyWith(units: UnitSystem.metric));
    await tester.pumpAndSettle();
    expect(latestOf(tester, RecordKind.height), isNot(contains('≈')));
  });

  test('the round trip keeps the unit system; words judge nothing', () {
    const s = AppearanceSettings(units: UnitSystem.us);
    expect(AppearanceSettings.fromJson(s.toJson()), s);
    expect(s == const AppearanceSettings(), isFalse);
    for (final lang in AppLang.values) {
      final t = S(lang);
      for (final w in [
        t.settingsUnits,
        t.unitsMetric,
        t.unitsUs,
        t.unitsNote,
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
