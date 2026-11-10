// F007 slice 3: the Sleep card on Today, in English and Turkish words that
// score nothing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('add a night: an error in words, then the night with time in '
      'bed and the feeling given', (tester) async {
    await launchWith(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('sleep-add')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('screen-today')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.byKey(const ValueKey('sleep-none')), findsOneWidget);
    await tapKey(tester, 'sleep-add');
    await tapKey(tester, 'sleep-save');
    // The error is shown on the field it is about.
    expect(find.text(S(AppLang.en).inputError('EMPTY')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('sleep-bed')), '23:00');
    await tester.enterText(find.byKey(const ValueKey('sleep-woke')), '7 am');
    await tapKey(tester, 'sleep-save');
    expect(find.text(S(AppLang.en).inputError('TIME_FORMAT')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('sleep-bed')),
      '2026-11-01 23:10',
    );
    await tester.enterText(
      find.byKey(const ValueKey('sleep-woke')),
      '2026-11-02 07:00',
    );
    await tapKey(tester, 'sleep-feeling-rested');
    await tapKey(tester, 'sleep-save');
    await settle(tester);
    expect(find.byKey(const ValueKey('sleep-none')), findsNothing);
    expect(find.textContaining('7 h 50 min in bed · Rested'), findsOneWidget);

    // Correct it: the sheet opens with the typed times; a new version shows.
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('sleep-correct-'),
      ),
    );
    await settle(tester);
    expect(find.text('Correct this night'), findsOneWidget);
    expect(find.text('2026-11-01 23:10'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('sleep-woke')),
      '2026-11-02 06:40',
    );
    await tapKey(tester, 'sleep-save');
    await settle(tester);
    expect(find.textContaining('7 h 30 min in bed · Rested'), findsOneWidget);
    expect(find.textContaining('7 h 50 min'), findsNothing);
  });

  test('the sleep words score and judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.sleepTitle,
        s.sleepIntro,
        s.sleepNone,
        s.sleepFeeling,
        s.sleepBedHelp,
        s.sleepWokeHelp,
        s.sleepSaveFailed,
        s.sleepLine('23:00', '07:00', const Duration(hours: 8), null),
        for (final f in WakeFeeling.values) s.sleepFeelingLabel(f),
        s.sleepSpan(const Duration(hours: 7, minutes: 5)),
        s.inputError('SLEEP_WAKE_NOT_AFTER_BED'),
        s.inputError('SLEEP_TOO_LONG'),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
