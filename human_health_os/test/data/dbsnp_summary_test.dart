// G002: a dbSNP "Summary" file is read offline and compared with a raw DNA
// file by rsID; dbSNP's words are kept, nothing is predicted.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/genetics/dbsnp_summary.dart';

void main() {
  final text = File('test/fixtures/dbsnp/gabrb3_summary_synthetic.txt')
      .readAsStringSync();

  test('every entry is read with its alleles, positions, gene, consequences '
      'and clinical labels as dbSNP states them', () {
    final v = parseDbSnpSummary(text);
    expect(
      [for (final x in v) x.rsid],
      ['rs20317', 'rs9000101', 'rs9000102', 'rs9000103'],
    );
    final a = v.first;
    expect(a.reference, 'G');
    expect(a.alternates, ['A', 'C', 'T']);
    expect(a.positions, ['15:26773789 (GRCh38)', '15:27018937 (GRCh37)']);
    expect(a.genes, ['GABRB3']);
    expect(a.consequences, [
      'upstream_transcript_variant',
      '2KB_upstream_variant',
    ]);
    expect(a.clinical, ['benign']);
    expect(a.isMissense, isFalse);
    expect(v[1].isMissense, isTrue);
    expect(v[1].clinical, ['uncertain-significance']);
    expect(v[2].hasClinical, isFalse, reason: '"not provided" is no label');
    expect(v[3].clinical, isEmpty, reason: 'missing stays missing');
  });

  test('refusals: empty and a file that is not a Summary', () {
    expect(
      () => parseDbSnpSummary('  '),
      throwsA(isA<DbSnpFormatError>().having((e) => e.code, 'code', 'EMPTY')),
    );
    expect(
      () => parseDbSnpSummary('rsid\tchromosome\nrs1\t1\n'),
      throwsA(
        isA<DbSnpFormatError>().having((e) => e.code, 'code', 'NOT_SUMMARY'),
      ),
    );
  });

  test('CRLF line endings read the same', () {
    expect(parseDbSnpSummary(text.replaceAll('\n', '\r\n')).first.alternates, [
      'A',
      'C',
      'T',
    ]);
  });

  group('comparing a genotype with dbSNP alleles', () {
    final v = parseDbSnpSummary(text);
    test('lists which alternate alleles the genotype has', () {
      final m = compareWithDbSnp(v[1], 'CT');
      expect(m.call, DbSnpCall.listsAlternate);
      expect(m.alternatesListed, ['T']);
      expect(compareWithDbSnp(v[1], 'CC').call, DbSnpCall.referenceOnly);
      expect(compareWithDbSnp(v[0], 'AG').alternatesListed, ['A']);
    });

    test('no call, A/T pairs and indels are not compared', () {
      expect(compareWithDbSnp(v[1], null).call, DbSnpCall.noCall);
      expect(compareWithDbSnp(v[2], 'AT').call, DbSnpCall.notComparable);
      expect(compareWithDbSnp(v[3], 'DI').call, DbSnpCall.notComparable);
      expect(compareWithDbSnp(v[1], 'DD').call, DbSnpCall.notComparable);
    });
  });
}
