// G002@v0.32: a dbSNP Summary file is loaded beside a raw DNA file and the
// shared variants are listed with dbSNP's own words; missense and clinical
// filters; nothing predicted, nothing judged by the app.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'g001_genetics_test.dart' show FakePicker, open, tap, reveal;

const genome =
    '# rsid\tchromosome\tposition\tgenotype\n'
    'rs20317\t15\t27018937\tAG\n'
    'rs9000101\t15\t27045000\tCT\n'
    'rs9000102\t15\t27055000\tAT\n'
    'rs9000103\t15\t27065000\tDI\n'
    'rs5\t1\t5\tGG\nrs6\t1\t6\tGG\nrs7\t1\t7\tGG\nrs8\t1\t8\tGG\n';

void main() {
  final summary = File('test/fixtures/dbsnp/gabrb3_summary_synthetic.txt')
      .readAsBytesSync();

  testWidgets('load DNA, then dbSNP: counts, cards with dbSNP words, filters', (
    tester,
  ) async {
    await open(
      tester,
      FakePicker([
        ('dna.txt', utf8.encode(genome)),
        ('snp_result.txt', summary),
      ]),
    );
    await tap(tester, 'genetics-choose');
    await tap(tester, 'dbsnp-load');
    await reveal(tester, find.byKey(const ValueKey('dbsnp-counts')));
    expect(
      find.text(
        '4 variants in the dbSNP file; 4 of them are in your DNA file.',
      ),
      findsOneWidget,
    );
    await reveal(tester, find.byKey(const ValueKey('dbsnp-rs9000101')));
    expect(find.text('Your file lists the alternate allele T'), findsOneWidget);
    expect(
      find.text(
        'dbSNP clinical significance (for the rsID, not one allele): uncertain-significance',
      ),
      findsOneWidget,
    );
    await tap(tester, 'dbsnp-only-missense');
    expect(find.byKey(const ValueKey('dbsnp-rs20317')), findsNothing);
    await reveal(tester, find.byKey(const ValueKey('dbsnp-rs9000101')));
    expect(find.byKey(const ValueKey('dbsnp-rs9000101')), findsOneWidget);
    await tap(tester, 'dbsnp-only-clinical');
    expect(
      find.byKey(const ValueKey('dbsnp-rs9000102')),
      findsNothing,
      reason: '"not provided" is no clinical label',
    );
  });

  testWidgets('a file that is not a Summary is refused with a reason', (
    tester,
  ) async {
    await open(
      tester,
      FakePicker([
        ('dna.txt', utf8.encode(genome)),
        ('x.csv', utf8.encode('rsid,chromosome\nrs1,1\n')),
      ]),
    );
    await tap(tester, 'genetics-choose');
    await tap(tester, 'dbsnp-load');
    await reveal(tester, find.byKey(const ValueKey('dbsnp-refusal')));
    expect(find.textContaining('Format: Summary'), findsWidgets);
  });

  test('the app\'s own dbSNP words judge nothing (dbSNP labels are shown as '
      'dbSNP\'s and are not scanned)', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.dbsnpTitle,
        s.dbsnpHow,
        s.dbsnpLoad,
        s.dbsnpOnlyMissense,
        s.dbsnpOnlyClinical,
        s.dbsnpNone,
        s.dbsnpNoClinical,
        for (final c in [
          'listsAlternate',
          'referenceOnly',
          'noCall',
          'notComparable',
        ])
          s.dbsnpCall(c, 'T'),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
