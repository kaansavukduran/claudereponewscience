// R002@v0.32: UI fixes from the independent review of U011-U014 and the
// genetics/plant screens.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/domain/settings/date_style.dart';
import 'package:human_health_os/src/features/report/doctor_summary.dart';

import 'f007_measurements_test.dart' show saveScalar, tapKey;
import 'g001_genetics_test.dart' show FakePicker, open, tap, reveal;
import 'g002_dbsnp_test.dart' show genome;
import 'u005_settings_test.dart' show launchWith;

void main() {
  tearDown(() {
    displayDateOrder = DateOrder.iso;
    displayClock = ClockStyle.h24;
  });

  test('a calendar day follows the date order', () {
    expect(formatDay(2026, 11, 8, DateOrder.dayMonth), '08.11.2026');
    expect(formatDay(2026, 11, 8, DateOrder.monthDay), '11/08/2026');
  });

  testWidgets('the weight card follows the date style; the visit summary '
      'stays 2026-11-08 20:05', (tester) async {
    final c = await launchWith(
      tester,
      initial: const AppearanceSettings(
        dateOrder: DateOrder.dayMonth,
        clock: ClockStyle.h12,
      ),
    );
    await tester.enterText(find.byKey(const ValueKey('weight-input')), '70');
    await tapKey(tester, 'weight-save');
    final shown = tester.allWidgets
        .whereType<Text>()
        .map((t) => t.data ?? '')
        .where((t) => RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}').hasMatch(t));
    expect(shown, isEmpty, reason: 'no ISO time left on Today: $shown');
    // The page for a clinician never follows the display style.
    expect(isoWhen(DateTime(2026, 11, 1, 20, 5).toUtc()), '2026-11-01 20:05');
    expect(c.value.dateOrder, DateOrder.dayMonth);
  });

  testWidgets('a screen reader hears the converted value too', (tester) async {
    final handle = tester.ensureSemantics();
    await launchWith(
      tester,
      initial: const AppearanceSettings(units: UnitSystem.us),
    );
    await saveScalar(tester, RecordKind.height, '172');
    expect(
      find.bySemanticsLabel(RegExp('172 centimetres, about 67.7 in')),
      findsWidgets,
    );
    handle.dispose();
  });

  testWidgets('ClinVar: entries where the file lists the alternate come first; '
      'a filter keeps only those', (tester) async {
    final summary = File('test/fixtures/clinvar/variant_summary_synthetic.txt')
        .readAsBytesSync();
    await open(
      tester,
      FakePicker([
        // rs20317 GG: only ClinVar's reference allele G (G>A).
        (
          'dna.txt',
          utf8.encode(genome.replaceFirst('27018937\tAG', '27018937\tGG')),
        ),
        ('variant_summary.txt', summary),
      ]),
    );
    await tap(tester, 'genetics-choose');
    await tap(tester, 'clinvar-load');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('clinvar-only-listed')));
    final a = tester
        .getTopLeft(find.byKey(const ValueKey('clinvar-rs9000101-111')))
        .dy;
    final b = tester
        .getTopLeft(find.byKey(const ValueKey('clinvar-rs20317-222')))
        .dy;
    expect(
      a,
      lessThan(b),
      reason: 'CT lists T; AG with G>A also lists A, Pathogenic sorts first',
    );
    await tap(tester, 'clinvar-only-listed');
    expect(find.byKey(const ValueKey('clinvar-rs9000101-111')), findsOneWidget);
  });
}
