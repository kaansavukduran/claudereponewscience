// G004: ClinVar's variant_summary is streamed once and filtered by the
// rsIDs of the person's file; GRCh37 rows win; rows without an rsID are
// skipped; a .gz is read as a stream.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/data/local/gzip_stream_io.dart';
import 'package:human_health_os/src/domain/genetics/clinvar.dart';

const path = 'test/fixtures/clinvar/variant_summary_synthetic.txt';

Stream<String> linesOf(String text) =>
    Stream.fromIterable(const LineSplitter().convert(text));

void main() {
  final text = File(path).readAsStringSync();

  test(
    'keeps only wanted rsIDs, one row per variant, GRCh37 preferred',
    () async {
      final r = await readClinVar(linesOf(text), {
        'rs9000101',
        'rs20317',
        'rs1',
      });
      expect(r.linesRead, 6);
      expect(r.capped, isFalse);
      final byId = {for (final x in r.records) x.rsid: x};
      expect(byId.keys.toSet(), {'rs9000101', 'rs20317'});
      final a = byId['rs9000101']!;
      expect(a.assembly, 'GRCh37');
      expect(a.position, '27045000');
      expect(a.significance, 'Pathogenic');
      expect(a.reviewStatus, 'criteria provided, single submitter');
      expect(a.conditions, 'Synthetic condition A');
      expect((a.reference, a.alternate), ('C', 'T'));
      expect(byId['rs20317']!.significance, 'Benign');
    },
  );

  test('a file without the ClinVar header is refused', () async {
    expect(
      () => readClinVar(linesOf('rsid\tchromosome\nrs1\t1\n'), {'rs1'}),
      throwsA(isA<ClinVarFormatError>()),
    );
    expect(
      () => readClinVar(linesOf(''), {'rs1'}),
      throwsA(isA<ClinVarFormatError>()),
    );
  });

  test('a gzip file is read as a stream with the same result', () async {
    final gz = gzip.encode(utf8.encode(text));
    final lines = gunzipStream(Stream.value(gz))
        .transform(utf8.decoder)
        .transform(const LineSplitter());
    final r = await readClinVar(lines, {'rs20317'});
    expect(r.records.single.gene, 'GENEB');
  });

  test('GRCh37 is kept whichever row comes first', () async {
    final lines = const LineSplitter().convert(text);
    final header = lines.first;
    final rows = lines.skip(1).where((l) => l.contains('9000101')).toList();
    final reversed = [header, ...rows.reversed].join('\n');
    final r = await readClinVar(linesOf(reversed), {'rs9000101'});
    expect(r.records.single.assembly, 'GRCh37');
  });
}
