// G005@v0.32: a ClinVar card is one item for a screen reader, the genotype
// has its own label, and the card counts how many letters of the file show
// ClinVar's alternate allele (G-66), never more than the letters say.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/genetics/dbsnp_summary.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'g001_genetics_test.dart' show FakePicker, open, tap, reveal;
import 'g002_dbsnp_test.dart' show genome;

DbSnpMatch cmp(String? g, {String ref = 'C', String alt = 'T'}) =>
    compareWithDbSnp(
      DbSnpVariant(rsid: 'rs1', reference: ref, alternates: [alt]),
      g,
    );

void main() {
  group('lettersShowing', () {
    test('one, two and a single letter', () {
      expect(lettersShowing(cmp('CT'), 'T'), (showing: 1, letters: 2));
      expect(lettersShowing(cmp('TC'), 'T'), (showing: 1, letters: 2));
      expect(lettersShowing(cmp('TT'), 'T'), (showing: 2, letters: 2));
      expect(lettersShowing(cmp('tt'), 'T'), (showing: 2, letters: 2));
      expect(lettersShowing(cmp('T'), 'T'), (showing: 1, letters: 1));
    });
    test('no count without a listed alternate', () {
      expect(lettersShowing(cmp('CC'), 'T'), isNull);
      expect(lettersShowing(cmp('C'), 'T'), isNull);
      expect(lettersShowing(cmp(null), 'T'), isNull);
      expect(lettersShowing(cmp('--'), 'T'), isNull);
      expect(lettersShowing(cmp('AT', ref: 'A', alt: 'T'), 'T'), isNull);
      expect(lettersShowing(cmp('CT'), 'G'), isNull);
    });
  });

  testWidgets('the card: labelled genotype, letters counted, read as one', (
    tester,
  ) async {
    final summary = File('test/fixtures/clinvar/variant_summary_synthetic.txt')
        .readAsBytesSync();
    await open(
      tester,
      FakePicker([
        ('dna.txt', utf8.encode(genome)),
        ('variant_summary.txt', summary),
      ]),
    );
    await tap(tester, 'genetics-choose');
    await tap(tester, 'clinvar-load');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    const card = ValueKey('clinvar-rs9000101-111');
    await reveal(tester, find.byKey(card));
    expect(find.text('Genotype in your file: CT'), findsOneWidget);
    expect(find.text('Letters showing T: 1 of 2'), findsOneWidget);
    await reveal(tester, find.byKey(const ValueKey('clinvar-rs20317-222')));
    expect(find.text('Letters showing A: 1 of 2'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    final node = tester.getSemantics(
      find.byKey(const ValueKey('clinvar-genotype-rs9000101-111')),
    );
    expect(node.label, contains('Genotype in your file: CT'));
    expect(node.label, contains('Letters showing T: 1 of 2'));
    expect(node.label, contains('ClinVar label: Pathogenic'));
    semantics.dispose();
  });

  test('the new words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [s.clinvarGenotype('CT'), s.clinvarLetters('T', 1, 2)]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
    expect(
      S(AppLang.tr).clinvarLetters('T', 1, 2),
      'T gösteren harf: 2 harften 1',
    );
  });
}
