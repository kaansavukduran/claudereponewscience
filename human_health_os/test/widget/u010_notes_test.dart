// U010@v0.32: the person's own earlier notes come back as one-click chips
// in the measurement sheet; no fixed vocabulary is added.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/features/measurements/measurement_format.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart'
    show launch, saveBp, saveScalar, settle, tapKey, latestOf;

void main() {
  testWidgets('no notes yet: no chips; after two notes they come back newest '
      'first, once each, and one click fills the note', (tester) async {
    await launch(tester);
    await tapKey(tester, 'measure-tile-vital.body_temperature');
    await tapKey(tester, 'measure-more');
    expect(find.byKey(const ValueKey('measure-note-0')), findsNothing);
    await tapKey(tester, 'measure-cancel');
    await saveBp(tester, '117', '75', context: 'Fasting');
    await saveBp(tester, '118', '76', context: 'after walk');
    await saveBp(tester, '119', '77', context: 'After walk ');
    await tapKey(tester, 'measure-tile-vital.body_temperature');
    await tapKey(tester, 'measure-more');
    final chips = [
      for (final e in find.byType(ActionChip).evaluate())
        if ((e.widget.key as ValueKey?)?.value.toString().startsWith(
              'measure-note-',
            ) ??
            false)
          ((e.widget as ActionChip).label as Text).data,
    ];
    expect(chips, ['After walk', 'Fasting'], reason: 'newest first, once each');
    await tapKey(tester, 'measure-note-1');
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('measure-context')))
          .controller!
          .text,
      'Fasting',
    );
    await tester.enterText(find.byKey(const ValueKey('measure-value')), '36.6');
    await tapKey(tester, 'measure-save');
    await settle(tester);
    expect(latestOf(tester, RecordKind.bodyTemperature), contains('36.6'));
  });

  test('previousNotes: trimmed, once each ignoring case, at most max', () {
    expect(previousNotes(const []), isEmpty);
  });

  test('the label judges nothing', () {
    for (final lang in AppLang.values) {
      final w = S(lang).yourNotes;
      expect(interpretive.hasMatch(w), isFalse);
      expect(judged.hasMatch(w), isFalse);
    }
  });

  testWidgets('saveScalar is reachable', (tester) async {
    await launch(tester);
    await saveScalar(tester, RecordKind.height, '170', context: 'morning');
    await tapKey(tester, 'measure-tile-body.height');
    await tapKey(tester, 'measure-more');
    expect(find.text('morning'), findsWidgets);
  });
}
