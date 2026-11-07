// G003: a table exported from Dr. Duke's phytochemical database is read
// offline; cells stay as the source wrote them.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/phyto/phyto_table.dart';

void main() {
  final bytes = File('test/fixtures/phyto/curcumin_activities_synthetic.csv')
      .readAsBytesSync();
  PhytoTable read(List<int> b) => parsePhytoBytes(b, utf8.decode);

  test('header and rows as written; quoted commas kept; a short row is '
      'counted, not guessed', () {
    final t = read(bytes);
    expect(t.headers, ['Activity', 'Dosage', 'Reference']);
    expect(t.rows, hasLength(5));
    expect(t.rows[3], ['Antiadenomacarcinogenic', '50-200 mg/kg ipr rat', '*']);
    expect(t.rows[4].first, 'Antialzheimeran, synthetic test row');
    expect(t.rows[1][1], '', reason: 'an empty dose stays empty, never 0');
    expect(t.skipped, 1);
    expect(t.column('dosage'), 1);
  });

  test('refusals: empty, an XLSX workbook, no table, too large', () {
    Matcher code(String c) =>
        throwsA(isA<PhytoFormatError>().having((e) => e.code, 'code', c));
    expect(() => read([]), code('EMPTY'));
    expect(() => read([0x50, 0x4B, 3, 4]), code('XLSX'));
    expect(() => read(utf8.encode('just one line')), code('NOT_TABLE'));
    expect(() => read(List.filled(maxPhytoBytes + 1, 0x41)), code('TOO_LARGE'));
  });

  test('dose abbreviations are found as whole words', () {
    expect(doseTermsIn('50-200 mg/kg ipr rat'), ['ipr', 'rat']);
    expect(doseTermsIn('IC50=81 uM'), ['IC50', 'uM']);
    expect(doseTermsIn('LDlo=>2,000 mg/kg (orl mus)'), ['orl', 'mus', 'LDlo']);
    expect(doseTermsIn('pirate'), isEmpty);
  });
}
