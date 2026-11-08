// R002@v0.32: fixes from the independent review of G002-G004.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/genetics/clinvar.dart';
import 'package:human_health_os/src/domain/genetics/dbsnp_summary.dart';
import 'package:human_health_os/src/domain/phyto/phyto_table.dart';

DbSnpVariant alleles(String a) =>
    parseDbSnpSummary('1. rs1 [x]\nAlleles:\t$a\n').single;

void main() {
  test('"reference only" needs every letter to be the reference', () {
    final ct = alleles('C>T');
    expect(compareWithDbSnp(ct, 'CC').call, DbSnpCall.referenceOnly);
    for (final g in ['GG', 'AG', 'CG', 'AA']) {
      expect(compareWithDbSnp(ct, g).call, DbSnpCall.otherAllele, reason: g);
    }
    expect(
      compareWithDbSnp(alleles('C>G,A'), 'TT').call,
      DbSnpCall.otherAllele,
    );
    expect(compareWithDbSnp(ct, 'CT').call, DbSnpCall.listsAlternate);
  });

  test('the ClinVar cap drops only Benign / Likely benign entries', () async {
    const header =
        '#AlleleID\tGeneSymbol\tClinicalSignificance\tRS# (dbSNP)\tAssembly\tVariationID';
    final rows = [
      for (var i = 0; i < maxClinVarMatches + 50; i++)
        '$i\tG\tBenign\t${100000 + i}\tGRCh37\t$i',
      '999999\tG\tPathogenic\t999999\tGRCh37\t999999',
      '999998\tG\tLikely benign/Benign\t999998\tGRCh37\t999998',
    ];
    final wanted = {
      for (var i = 0; i < maxClinVarMatches + 50; i++) 'rs${100000 + i}',
      'rs999999',
      'rs999998',
    };
    final r = await readClinVar(Stream.fromIterable([header, ...rows]), wanted);
    expect(r.capped, isTrue);
    expect(
      r.records.where((x) => x.significance == 'Pathogenic'),
      hasLength(1),
    );
    expect(
      r.records.where((x) => x.rsid == 'rs999998'),
      isEmpty,
      reason: 'a combined benign label counts as benign',
    );
  });

  test(
    'a ClinVar line longer than the limit is skipped, not buffered',
    () async {
      const header = '#AlleleID\tRS# (dbSNP)\tVariationID';
      final r = await readClinVar(
        Stream.fromIterable([
          header,
          '1\t1\t${'x' * (maxClinVarLine + 1)}',
          '2\t2\t2',
        ]),
        {'rs1', 'rs2'},
      );
      expect(r.records.map((x) => x.rsid), ['rs2']);
    },
  );

  test('a quote inside an unquoted cell is an ordinary character', () {
    final t = parsePhytoCsv('Name,Size\n5" rod,1\nnext,2\nlast,3\n');
    expect(t.rows, [
      ['5" rod', '1'],
      ['next', '2'],
      ['last', '3'],
    ]);
    expect(
      parsePhytoBytes(utf8.encode('A,B\nx,y\n'), utf8.decode).rows,
      hasLength(1),
    );
  });

  test('TDLo/TDlo, LDLo and human and other species codes are explained', () {
    expect(
      doseTermsIn('TDLo=100 mg/kg orl man'),
      containsAll(['TDLo', 'orl', 'man']),
    );
    expect(
      doseTermsIn('TDlo=5 mg/kg skn rbt'),
      containsAll(['TDlo', 'skn', 'rbt']),
    );
    expect(
      doseTermsIn('LDLo=10 mg/kg ims dog'),
      containsAll(['LDLo', 'ims', 'dog']),
    );
    expect(
      doseTermsIn('TD'),
      isEmpty,
      reason: 'the source writes TDLo, not TD',
    );
  });
}
