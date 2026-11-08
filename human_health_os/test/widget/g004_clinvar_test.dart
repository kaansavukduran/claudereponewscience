// G004@v0.32: load DNA, then ClinVar's summary (plain or .gz): matching
// entries with ClinVar's label, review status and conditions; filter by
// ClinVar's own labels; refusal for another file.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'g001_genetics_test.dart' show FakePicker, open, tap, reveal;
import 'g002_dbsnp_test.dart' show genome;

void main() {
  final summary = File('test/fixtures/clinvar/variant_summary_synthetic.txt')
      .readAsBytesSync();

  for (final gz in [false, true]) {
    testWidgets('ClinVar ${gz ? '.gz' : 'text'}: counts, cards, label filter', (
      tester,
    ) async {
      await open(
        tester,
        FakePicker([
          ('dna.txt', utf8.encode(genome)),
          (
            gz ? 'variant_summary.txt.gz' : 'variant_summary.txt',
            gz ? gzip.encode(summary) : summary,
          ),
        ]),
      );
      await tap(tester, 'genetics-choose');
      await tap(tester, 'clinvar-load');
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pumpAndSettle();
      await reveal(tester, find.byKey(const ValueKey('clinvar-counts')));
      expect(
        find.text(
          '6 lines read; 2 ClinVar entries match variants in your DNA file.',
        ),
        findsOneWidget,
      );
      await reveal(tester, find.byKey(const ValueKey('clinvar-rs9000101-111')));
      expect(find.text('ClinVar label: Pathogenic'), findsOneWidget);
      expect(
        find.text('Your file lists the alternate allele T'),
        findsOneWidget,
      );
      expect(find.textContaining('Synthetic condition A'), findsOneWidget);
      await tap(tester, 'clinvar-label-Benign');
      expect(find.byKey(const ValueKey('clinvar-rs9000101-111')), findsNothing);
      await reveal(tester, find.byKey(const ValueKey('clinvar-rs20317-222')));
      expect(find.byKey(const ValueKey('clinvar-rs20317-222')), findsOneWidget);
    });
  }

  testWidgets('another file is refused with a reason', (tester) async {
    await open(
      tester,
      FakePicker([
        ('dna.txt', utf8.encode(genome)),
        ('x.txt', utf8.encode('a\tb\nc\td\ne\tf\ng\th\ni\tj\nk\tl\n')),
      ]),
    );
    await tap(tester, 'genetics-choose');
    await tap(tester, 'clinvar-load');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('clinvar-refusal')));
    expect(find.textContaining('variant_summary'), findsWidgets);
  });

  test('the app\'s own ClinVar words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.clinvarTitle,
        s.clinvarHow,
        s.clinvarLoad,
        s.clinvarCounts(6, 2),
        s.clinvarCapped(20000),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
