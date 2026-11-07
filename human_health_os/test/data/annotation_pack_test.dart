// G001: a pack states what its source says; the match never becomes a
// meaning for the person.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/genetics/annotation_pack.dart';
import 'package:human_health_os/src/domain/genetics/raw_genome.dart';
import 'package:human_health_os/src/domain/genetics/sample_data.dart';

String pack({
  String build = '37',
  String strand = 'plus',
  String extra = '',
  List<String> rows = const [],
}) =>
    '#name: Test pack\n#licence: test licence\n#build: $build\n#strand: $strand\n$extra'
    'rsid\tgene\tallele\tstatement\tsource\tsource_id\tsource_date\tevidence\n'
    '${rows.join('\n')}\n';

String row(String rsid, String allele) =>
    '$rsid\tG\t$allele\tsays X\tSrc\tID-1\t2026\tlevel 2';

GenomeFile genome(String body, {String header = '# build 37\n'}) =>
    parseRawGenome('$header$body');

void main() {
  group('reading a pack', () {
    test('the header names the source, licence, build and the plus strand', () {
      final p = parsePack(pack(rows: [row('rs1', 'G')]));
      expect(
        (p.name, p.licence, p.build, p.synthetic),
        ('Test pack', 'test licence', '37', false),
      );
      expect(p.entries.single.statement, 'says X', reason: 'verbatim');
      expect(p.entries.single.evidence, 'level 2');
      expect(
        parsePack(pack(extra: '#synthetic: yes\n', rows: [row('rs1', 'G')]))
            .synthetic,
        isTrue,
      );
    });

    test('a pack without its header, on another strand or with no rows is '
        'refused with a code', () {
      void refused(String text, String code) => expect(
        () => parsePack(text),
        throwsA(isA<PackFormatError>().having((e) => e.code, 'code', code)),
        reason: code,
      );
      refused('', 'EMPTY');
      refused('rsid\tgene\n', 'HEADER');
      refused('#name: x\nrsid\n', 'HEADER');
      refused(pack(strand: 'minus', rows: [row('rs1', 'G')]), 'STRAND');
      refused(pack(strand: 'gene', rows: [row('rs1', 'G')]), 'STRAND');
      refused(pack(), 'NO_ROWS');
      refused(
        '#name: a\n#licence: b\n#build: 37\n#strand: plus\nnotcolumns\nx\n',
        'HEADER',
      );
    });

    test('bad rows are counted, never half-read', () {
      final p = parsePack(
        pack(
          rows: [
            row('rs1', 'G'),
            'rs2\tG\tX\tbad allele\tS\ti\td\te',
            'short',
            row('rs3', 'a'),
          ],
        ),
      );
      expect(p.entries.map((e) => (e.rsid, e.allele)), [
        ('rs1', 'G'),
        ('rs3', 'A'),
      ]);
      expect(p.invalidCount, 2);
    });
  });

  group('matching', () {
    final p = parsePack(
      pack(
        rows: [
          row('rs1', 'G'),
          row('rs2', 'T'),
          row('rs3', 'A'),
          row('rs4', 'C'),
        ],
      ),
    );

    test('the genotype is compared with the named allele, order does not '
        'matter, absent variants are not mentioned', () {
      final g = genome(
        'rs1\t1\t10\tAG\nrs2\t1\t20\tAA\nrs3\t1\t30\t--\nrs9\t1\t40\tGG\n',
      );
      final m = matchPack(g, p);
      expect(
        [for (final x in m) (x.entry.rsid, x.kind)],
        [
          ('rs1', MatchKind.containsAllele),
          ('rs2', MatchKind.strandUndecidable), // A against T: A/T pair
          ('rs3', MatchKind.notRead),
        ],
      );
      expect(
        matchPack(genome('rs1\t1\t10\tGA\n'), p).single.kind,
        MatchKind.containsAllele,
        reason: 'GA is AG',
      );
      expect(
        matchPack(genome('rs1\t1\t10\tTT\n'), p).single.kind,
        MatchKind.doesNotMatch,
        reason: 'not "no variant": the entry does not match',
      );
    });

    test('A/T and C/G cannot be told apart by strand: nothing is claimed', () {
      final pa = parsePack(pack(rows: [row('rs1', 'A'), row('rs2', 'C')]));
      final g = genome('rs1\t1\t10\tAT\nrs2\t1\t20\tCG\n');
      expect(
        [for (final x in matchPack(g, pa)) x.kind],
        [MatchKind.strandUndecidable, MatchKind.strandUndecidable],
      );
    });

    test(
      'C against G (a C/G pair) is undecidable too, not "does not match"',
      () {
        expect(
          matchPack(genome('rs1\t1\t10\tCC\n'), p).single.kind,
          MatchKind.strandUndecidable,
        );
      },
    );

    test('a call that is not a base (an indel) does not match', () {
      expect(
        matchPack(genome('rs1\t1\t10\tDD\n'), p).single.kind,
        MatchKind.doesNotMatch,
      );
    });

    test('ids match without regard to case; duplicates are all reported', () {
      final g = genome('RS1\t1\t10\tGG\nrs1\t1\t10\tAA\n');
      final m = matchPack(g, p);
      expect(m, hasLength(2));
      expect([for (final x in m) x.variant.call], ['GG', 'AA']);
    });

    test('the build note says same, differs, or not stated by the file', () {
      final one = parsePack(pack(rows: [row('rs1', 'G')]));
      expect(
        matchPack(genome('rs1\t1\t10\tGG\n'), one).single.buildNote,
        'same',
      );
      expect(
        matchPack(
          genome('rs1\t1\t10\tGG\n', header: '# build 38\n'),
          one,
        ).single.buildNote,
        'differs',
      );
      expect(
        matchPack(genome('rs1\t1\t10\tGG\n', header: ''), one).single.buildNote,
        'fileNotStated',
      );
    });
  });

  group('the bundled sample', () {
    test(
      'the invented pack and file work together and say they are invented',
      () {
        final g = parseRawGenome(sampleGenomeText);
        final p = parsePack(samplePackText);
        expect(p.synthetic, isTrue);
        expect(p.licence, contains('CC0'));
        expect(g.total, 12);
        expect(g.build, '37');
        final m = matchPack(g, p);
        expect(
          [for (final x in m) (x.entry.rsid, x.kind)],
          [
            ('rs9000001', MatchKind.containsAllele),
            ('rs9000002', MatchKind.doesNotMatch),
            ('rs9000003', MatchKind.notRead),
            ('rs9000004', MatchKind.strandUndecidable),
            ('rs9000006', MatchKind.containsAllele),
          ],
        );
        for (final e in p.entries) {
          expect(e.statement, startsWith('INVENTED'));
          expect(e.source, contains('invented'));
        }
      },
    );
  });
}
