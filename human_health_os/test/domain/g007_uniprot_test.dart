// G007@v0.32: a UniProt TSV export read offline: columns by name, every
// field as written, rows without an accession counted, spreadsheets and
// other files refused.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/genetics/uniprot.dart';

void main() {
  final text = File('test/fixtures/uniprot/uniprot_synthetic.tsv')
      .readAsStringSync();

  test('entries, genes, function as written; a row without accession is '
      'counted', () {
    final f = parseUniProtTsv(text);
    expect(f.entries.map((e) => e.accession), ['Q9SYN1', 'Q9SYN2']);
    expect(f.skipped, 1);
    final a = f.entries.first;
    expect(a.genes, ['GENEA', 'SYNA1']);
    expect(a.reviewed, 'reviewed');
    expect(a.proteinNames, 'Synthetic protein one (SP1)');
    expect(a.function, startsWith('FUNCTION: A synthetic'));
    expect(a.organism, 'Homo sapiens (Human)');
    expect(f.byGene()['SYNA1']!.single.accession, 'Q9SYN1');
    expect(f.byGene()['GENEB']!.single.function, '');
  });

  test('columns in another order, primary gene column, CRLF, BOM', () {
    final f = parseUniProtTsv(
      '﻿Gene Names (primary)\tEntry\r\nTP53\tP04637\r\n',
    );
    expect(f.entries.single.accession, 'P04637');
    expect(f.entries.single.genes, ['TP53']);
    expect(f.entries.single.proteinNames, '');
  });

  test('refusals', () {
    expect(
      () => parseUniProtTsv('PK\u0003\u0004xlsx'),
      throwsA(
        isA<UniProtFormatError>().having((e) => e.code, 'code', 'SPREADSHEET'),
      ),
    );
    expect(
      () => parseUniProtTsv('rsid\tchromosome\nrs1\t1\n'),
      throwsA(
        isA<UniProtFormatError>().having((e) => e.code, 'code', 'NOT_UNIPROT'),
      ),
    );
    expect(
      () => parseUniProtTsv('  \n'),
      throwsA(isA<UniProtFormatError>().having((e) => e.code, 'code', 'EMPTY')),
    );
  });

  test('hidden characters are removed and long fields capped', () {
    final f = parseUniProtTsv(
      'Entry\tGene Names\tFunction [CC]\nQ1\tG​1\t${'x' * 5000}\n',
    );
    expect(f.entries.single.genes, ['G1']);
    expect(f.entries.single.function.runes.length, lessThanOrEqualTo(2001));
  });
}
