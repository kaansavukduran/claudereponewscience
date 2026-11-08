// G007@v0.32: after a DNA file and ClinVar, a UniProt file shows the
// proteins of the genes ClinVar named, UniProt's words as written; search
// finds others; another file is refused with a reason.
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
  final uniprot = File('test/fixtures/uniprot/uniprot_synthetic.tsv')
      .readAsBytesSync();
  final en = S(AppLang.en);

  testWidgets('ClinVar genes first, then search', (tester) async {
    await open(
      tester,
      FakePicker([
        ('dna.txt', utf8.encode(genome)),
        ('variant_summary.txt', summary),
        ('uniprot.tsv', uniprot),
      ]),
    );
    await tap(tester, 'genetics-choose');
    await tap(tester, 'clinvar-load');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    await tap(tester, 'uniprot-load');
    await reveal(tester, find.byKey(const ValueKey('uniprot-counts')));
    expect(find.text(en.uniprotCounts(2, 1)), findsOneWidget);
    await reveal(tester, find.byKey(const ValueKey('uniprot-Q9SYN1')));
    expect(find.text('Synthetic protein one (SP1)'), findsOneWidget);
    expect(
      find.text('FUNCTION: A synthetic description used only in tests.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('uniprot-Q9SYN2')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('uniprot-search')),
      'syna1',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('uniprot-Q9SYN1')), findsOneWidget);
    expect(find.byKey(const ValueKey('uniprot-Q9SYN2')), findsNothing);
  });

  testWidgets('without dbSNP or ClinVar: says how to see genes; another '
      'file is refused', (tester) async {
    await open(
      tester,
      FakePicker([
        ('dna.txt', utf8.encode(genome)),
        ('uniprot.tsv', uniprot),
        ('other.tsv', utf8.encode('rsid\tchromosome\nrs1\t1\n')),
      ]),
    );
    await tap(tester, 'genetics-choose');
    await tap(tester, 'uniprot-load');
    await reveal(tester, find.byKey(const ValueKey('uniprot-none')));
    expect(find.text(en.uniprotNoGenes), findsOneWidget);
    await tap(tester, 'uniprot-load');
    await reveal(tester, find.byKey(const ValueKey('uniprot-refusal')));
    expect(find.text(en.uniprotRefusal('NOT_UNIPROT')), findsOneWidget);
  });

  test('the app\'s own UniProt words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.uniprotTitle,
        s.uniprotHow,
        s.uniprotLoad,
        s.uniprotCounts(3, 1),
        s.uniprotNote,
        s.uniprotSearch,
        s.uniprotNone,
        s.uniprotNoGenes,
        s.uniprotRefusal('SPREADSHEET'),
        s.uniprotRefusal('NOT_UNIPROT'),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
