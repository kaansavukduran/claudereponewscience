// G006@v0.32: reading ClinVar's summary pauses every clinVarYieldEvery
// lines so the app can draw (the progress bar moves), even when the whole
// file arrives as one burst of lines (G-67), and reports the count.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/genetics/clinvar.dart';

const header =
    '#AlleleID\tType\tName\tGeneSymbol\tClinicalSignificance\t'
    'RS# (dbSNP)\tVariationID\tAssembly';

void main() {
  test('a timer set before reading fires while a burst is read', () async {
    final n = clinVarYieldEvery * 3 + 5;
    final lines = Stream<String>.fromIterable([
      header,
      for (var i = 0; i < n; i++)
        '$i\tsingle nucleotide variant\t-\tG\tBenign\t$i\t$i\tGRCh37',
    ]);
    final progress = <int>[];
    var timerFiredAt = -1;
    Timer.run(() => timerFiredAt = progress.isEmpty ? 0 : progress.last);
    final r = await readClinVar(lines, {'rs7'}, progress: progress.add);
    expect(r.linesRead, n + 1);
    expect(r.records.single.rsid, 'rs7');
    expect(progress, [
      clinVarYieldEvery,
      clinVarYieldEvery * 2,
      clinVarYieldEvery * 3,
    ]);
    expect(
      timerFiredAt,
      clinVarYieldEvery,
      reason: 'the first pause lets other work run',
    );
  });
}
