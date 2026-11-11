// F007 slice 6: the Activity screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('add an activity: an error on its field, then the entry; '
      'correct it', (tester) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-activity')));
    await settle(tester);
    expect(find.byKey(const ValueKey('act-none')), findsOneWidget);
    await tapKey(tester, 'act-add');
    // Nothing typed: the error is shown once, on its field.
    await tapKey(tester, 'act-save');
    expect(find.text(S(AppLang.en).inputError('EMPTY')), findsOneWidget);
    expect(find.byKey(const ValueKey('act-error')), findsNothing);
    await tester.enterText(find.byKey(const ValueKey('act-what')), 'Walk');
    await tester.pump();
    expect(find.text(S(AppLang.en).inputError('EMPTY')), findsNothing);
    // Only digits reach the minutes field.
    await tester.enterText(find.byKey(const ValueKey('act-minutes')), '2a0');
    expect(find.text('20'), findsOneWidget);
    await tapKey(tester, 'act-save');
    await settle(tester);
    expect(find.text('Walk · 20 min'), findsOneWidget);
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('act-correct-'),
      ),
    );
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('act-steps')), '2400');
    await tapKey(tester, 'act-save');
    await settle(tester);
    expect(find.text('Walk · 20 min · 2400 steps'), findsOneWidget);
    expect(find.text('Walk · 20 min'), findsNothing);
  });

  test('the words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.actTitle,
        s.actIntro,
        s.actNone,
        s.actWhat,
        s.inputError('ACTIVITY_MINUTES_RANGE'),
        s.inputError('ACTIVITY_STEPS_RANGE'),
        s.inputError('NOT_A_WHOLE_NUMBER'),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
