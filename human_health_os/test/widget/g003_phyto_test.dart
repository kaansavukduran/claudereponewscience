// G003@v0.32: the plant-chemicals tool loads a CSV export offline, searches
// it, explains dose abbreviations and refuses an XLSX with a reason.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'g001_genetics_test.dart' show FakePicker, settle;
import 'f007_measurements_test.dart' show tapKey;
import 'u002_guide_test.dart' show reveal;
import 'u005_settings_test.dart' show launchWith;

void main() {
  final csv = File('test/fixtures/phyto/curcumin_activities_synthetic.csv')
      .readAsBytesSync();

  testWidgets('load, search, dose words explained; an XLSX is refused', (
    tester,
  ) async {
    await launchWith(
      tester,
      picker: FakePicker([
        ('curcumin.csv', csv),
        ('curcumin.xlsx', [0x50, 0x4B, 3, 4, 0]),
      ]),
    );
    await reveal(tester, 'screen-today', 'tool-phyto');
    await tapKey(tester, 'tool-phyto');
    await tapKey(tester, 'phyto-load');
    await settle(tester);
    expect(find.text('curcumin.csv: 5 rows'), findsOneWidget);
    expect(
      find.textContaining('ipr = injected into the belly cavity'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const ValueKey('phyto-search')),
      'AFLATOX',
    );
    await settle(tester);
    expect(find.text('Antiaflatoxin'), findsOneWidget);
    expect(find.text('5-HETE-Inhibitor'), findsNothing);
    await tapKey(tester, 'phyto-load');
    await settle(tester);
    expect(find.textContaining('Excel (XLSX)'), findsOneWidget);
    expect(find.text('curcumin.csv: 5 rows'), findsOneWidget, reason: 'kept');
  });

  test('the app\'s own words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.phytoTitle,
        s.phytoTileHint,
        s.phytoHow,
        s.phytoNote,
        s.phytoSearch,
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
