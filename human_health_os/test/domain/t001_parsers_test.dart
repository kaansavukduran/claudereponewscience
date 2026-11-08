// T001@v0.32: direct tests for the dbSNP and plant-chemicals readers,
// written from the test-adequacy review's mutation survivors.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/genetics/dbsnp_summary.dart';
import 'package:human_health_os/src/domain/phyto/phyto_table.dart';

DbSnpVariant one(String body) => parseDbSnpSummary(body).single;

void main() {
  group('dbSNP Summary reader', () {
    test('an upper-case RS entry is read and its id lower-cased', () {
      final v = one('1. RS123 [Homo sapiens]\nAlleles:\tg>a,c\n');
      expect(v.rsid, 'rs123');
      expect(v.reference, 'G');
      expect(v.alternates, ['A', 'C'], reason: 'alleles upper-cased');
    });

    test('a gene annotation in brackets is stripped', () {
      expect(one('1. rs1 [x]\nGene:\tTP53 (7157), WRAP53 (Varview)\n').genes, [
        'TP53',
        'WRAP53',
      ]);
    });

    test('a key continued on the next line keeps every part', () {
      final v = one(
        '1. rs1 [x]\n'
        'Chromosome:\t17:7675088 (GRCh38)\n'
        '17:7578406 (GRCh37)\n'
        'Functional Consequence:\tmissense_variant,\n'
        'coding_sequence_variant\n'
        'Clinical significance:\tlikely-benign,\n'
        'uncertain-significance\n',
      );
      expect(v.positions, ['17:7675088 (GRCh38)', '17:7578406 (GRCh37)']);
      expect(v.consequences, ['missense_variant', 'coding_sequence_variant']);
      expect(v.clinical, ['likely-benign', 'uncertain-significance']);
    });

    test('two positions on one line separated by wide space are split', () {
      expect(
        one('1. rs1 [x]\nChromosome:\t1:100 (GRCh38)    1:90 (GRCh37)\n')
            .positions,
        ['1:100 (GRCh38)', '1:90 (GRCh37)'],
      );
    });

    DbSnpVariant alleles(String a) => one('1. rs1 [x]\nAlleles:\t$a\n');
    test('A/T and C/G pairs are not compared; a trio is', () {
      expect(
        compareWithDbSnp(alleles('A>T'), 'AA').call,
        DbSnpCall.notComparable,
      );
      expect(
        compareWithDbSnp(alleles('C>G'), 'CG').call,
        DbSnpCall.notComparable,
      );
      final trio = compareWithDbSnp(alleles('A>C,T'), 'AT');
      expect(trio.call, DbSnpCall.listsAlternate);
      expect(trio.alternatesListed, ['T']);
    });

    test('an indel allele or a non-base genotype is not compared', () {
      expect(
        compareWithDbSnp(alleles('AT>A'), 'AA').call,
        DbSnpCall.notComparable,
      );
      expect(
        compareWithDbSnp(alleles('G>A'), '--').call,
        DbSnpCall.notComparable,
      );
      expect(
        compareWithDbSnp(alleles('G>A'), 'II').call,
        DbSnpCall.notComparable,
      );
    });
  });

  group('plant-chemicals CSV reader', () {
    PhytoTable csv(String s) => parsePhytoCsv(s);
    Matcher code(String c) =>
        throwsA(isA<PhytoFormatError>().having((e) => e.code, 'code', c));

    test('doubled quotes and a line break inside quotes stay in one cell', () {
      final t = csv('Name,Note\n"a ""b"", c","line one\nline two"\n');
      expect(t.rows.single, ['a "b", c', 'line one line two']);
    });

    test('a BOM before the header is dropped', () {
      expect(csv('﻿Activity,Dosage\nx,y\n').headers.first, 'Activity');
    });

    test('one column, or a header only, is not a table', () {
      expect(() => csv('Only\nx\ny\n'), code('NOT_TABLE'));
      expect(() => csv('A,B\n'), code('NOT_TABLE'));
    });

    test('rows too short and too long are both counted, not shown', () {
      final t = csv('A,B,C\n1,2,3\n1,2\n1,2,3,4\n');
      expect(t.rows, hasLength(1));
      expect(t.skipped, 2);
    });

    test('a header longer than 80 characters is cut', () {
      final t = csv('${'h' * 200},B\nx,y\n');
      expect(t.headers.first.runes.length, 80);
    });

    test('bytes: empty, exactly at the limit read, one over refused', () {
      String decode(List<int> b) => 'A,B\nx,y\n';
      expect(() => parsePhytoBytes([], decode), code('EMPTY'));
      expect(
        parsePhytoBytes(List.filled(maxPhytoBytes, 0x41), decode).rows,
        hasLength(1),
      );
      expect(
        () => parsePhytoBytes(List.filled(maxPhytoBytes + 1, 0x41), decode),
        code('TOO_LARGE'),
      );
      expect(
        parsePhytoBytes(utf8.encode('A,B\nx,y\n'), utf8.decode).rows,
        hasLength(1),
      );
    });

    test('dose terms match whole words only, with the exact case', () {
      expect(doseTermsIn('rate'), isEmpty);
      expect(doseTermsIn('ppmx'), isEmpty);
      expect(doseTermsIn('ORL'), isEmpty);
      expect(doseTermsIn('12 ppm'), ['ppm']);
      for (final k in doseTerms.keys) {
        expect(doseTermsIn('x $k y'), contains(k), reason: k);
      }
    });
  });
}
