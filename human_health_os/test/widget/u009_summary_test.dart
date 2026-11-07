// U009@v0.32: a summary for a visit: what the person recorded, as typed,
// newest first, with dates; saved as a self-contained, escaped page where
// open files are allowed; nothing scored or judged.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/features/report/doctor_summary.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart'
    show launch, saveBp, saveScalar, settle, tapKey;
import 'u002_guide_test.dart' show reveal;

void main() {
  testWidgets('the summary lists readings as typed, newest first, with the '
      'note; the saved page is escaped and has no script or link', (
    tester,
  ) async {
    final files = MemoryDataFiles();
    await launch(tester, files: files);
    await saveBp(tester, '118', '76', context: '<b>after walk</b>');
    await saveScalar(tester, RecordKind.height, '172.5');
    await reveal(tester, 'screen-today', 'tool-summary');
    await tapKey(tester, 'tool-summary');
    expect(find.byKey(const ValueKey('screen-summary')), findsOneWidget);
    expect(find.textContaining('118/76'), findsOneWidget);
    expect(find.textContaining('172.5'), findsOneWidget);
    expect(find.textContaining('<b>after walk</b>'), findsOneWidget);
    await tapKey(tester, 'summary-save');
    expect(find.byKey(const ValueKey('summary-message')), findsOneWidget);
    // The first measurement also kept a checkpoint backup; the summary is
    // the one page.
    final saved = files.files.entries
        .where((e) => e.key.endsWith('.html'))
        .single;
    final html = saved.value;
    expect(html, contains('118/76'));
    expect(html, contains('&lt;b&gt;after walk&lt;/b&gt;'));
    expect(html, isNot(contains('<b>after walk')));
    expect(html.toLowerCase(), isNot(contains('<script')));
    expect(html.toLowerCase(), isNot(contains('http')));
  });

  testWidgets('nothing recorded: says so and offers no empty page', (
    tester,
  ) async {
    await launch(tester, files: MemoryDataFiles());
    await reveal(tester, 'screen-today', 'tool-summary');
    await tapKey(tester, 'tool-summary');
    expect(find.byKey(const ValueKey('summary-empty')), findsOneWidget);
    final save = tester.widget<ButtonStyleButton>(
      find.byKey(const ValueKey('summary-save')),
    );
    expect(save.onPressed, isNull);
    await settle(tester);
  });

  test('summary words judge nothing and score nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.summaryTitle,
        s.summaryTileHint,
        s.summaryFooterTyped,
        s.summaryFooterNotDiagnosis,
        s.summaryEmpty,
        s.summarySave,
        s.summarySaveNotHere,
        s.summaryMore(20, 31),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });

  test('the page title and every cell are escaped', () {
    const d = DoctorSummary(
      title: 'A & <B>',
      createdAt: '"now"',
      sections: [
        SummarySection('<s>', [SummaryRow('<w>', '<v>', '<n>')], 1),
      ],
      footer: ['<f>'],
    );
    final html = d.toHtml('en');
    expect(html, contains('A &amp; &lt;B&gt;'));
    expect(html, contains('&quot;now&quot;'));
    for (final x in ['<s>', '<w>', '<v>', '<n>', '<f>']) {
      expect(html, isNot(contains(x)));
    }
  });
}
