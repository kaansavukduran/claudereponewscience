// F008@v0.32: the Medications screen with the mouse: add a supplement,
// write its plan, record a dose; the counts come only from recorded doses;
// both languages; the words judge nothing and give no advice.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

Future<void> type(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(ValueKey(key)), text);
  await tester.pump();
}

void main() {
  final en = S(AppLang.en);

  testWidgets('add, plan, record a dose; a plan alone counts no dose', (
    tester,
  ) async {
    await launchWith(tester);
    await tester.tap(find.text('Medications').first);
    await settle(tester);
    expect(find.byKey(const ValueKey('meds-none')), findsOneWidget);

    await tapKey(tester, 'meds-add');
    await tapKey(tester, 'meds-item-save');
    expect(find.byKey(const ValueKey('meds-error')), findsOneWidget);
    await type(tester, 'meds-name', 'Vitamin D3');
    await type(tester, 'meds-strength', '1000 IU');
    await tapKey(tester, 'meds-item-save');
    expect(find.textContaining('Vitamin D3 · Supplement'), findsOneWidget);
    expect(find.text(en.medsNoPlan), findsOneWidget);
    expect(find.text(en.medsNoDoses), findsOneWidget);

    final plan = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('meds-plan-add-'),
    );
    await tester.tap(plan);
    await settle(tester);
    await type(tester, 'meds-schedule', '1 capsule every morning');
    await tapKey(tester, 'meds-source-ownChoice');
    await tapKey(tester, 'meds-plan-save');
    expect(
      find.text('Plan (active): 1 capsule every morning (My own choice)'),
      findsOneWidget,
    );
    expect(find.text(en.medsNoDoses), findsOneWidget, reason: 'plan ≠ dose');

    final dose = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('meds-dose-'),
    );
    await tester.tap(dose);
    await settle(tester);
    await type(tester, 'meds-amount', '1 capsule');
    await tapKey(tester, 'meds-dose-save');
    expect(find.text(en.medsDoseCounts(1, 0)), findsOneWidget);
    expect(find.textContaining('taken · 1 capsule'), findsOneWidget);

    // Pause, then follow again: each is a new plan record; doses stay.
    Finder byPrefix(String p) => find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith(p),
    );
    await tester.tap(byPrefix('meds-pause-'));
    await settle(tester);
    expect(
      find.text('Plan (paused): 1 capsule every morning (My own choice)'),
      findsOneWidget,
    );
    expect(byPrefix('meds-pause-'), findsNothing);
    expect(find.text(en.medsDoseCounts(1, 0)), findsOneWidget);
    await tester.tap(byPrefix('meds-resume-'));
    await settle(tester);
    expect(
      find.text('Plan (active): 1 capsule every morning (My own choice)'),
      findsOneWidget,
    );
    // Stopping is asked once more; Cancel changes nothing.
    await tester.tap(byPrefix('meds-stop-'));
    await settle(tester);
    await tapKey(tester, 'meds-stop-cancel');
    await settle(tester);
    expect(
      find.text('Plan (active): 1 capsule every morning (My own choice)'),
      findsOneWidget,
    );
    await tester.tap(byPrefix('meds-stop-'));
    await settle(tester);
    await tapKey(tester, 'meds-stop-confirm');
    await settle(tester);
    expect(
      find.text('Plan (stopped): 1 capsule every morning (My own choice)'),
      findsOneWidget,
    );
    expect(byPrefix('meds-stop-'), findsNothing);
    expect(byPrefix('meds-resume-'), findsOneWidget);

    // The Timeline shows each record in words, not as a bare status.
    await tester.tap(find.text('Timeline').first);
    await settle(tester);
    expect(find.textContaining('Vitamin D3 · Supplement'), findsWidgets);
    expect(find.textContaining('1 capsule every morning'), findsWidgets);
    expect(find.textContaining('Taken · 1 capsule'), findsWidgets);
  });

  test('the words judge nothing and promise no checking', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.medsTitle,
        s.medsIntro,
        s.medsNone,
        s.medsNoDoses,
        s.medsDoseCounts(2, 1),
        s.medsPlanSchedule,
        s.medsDoseAmount,
        for (final p in PlanState.values) s.medsPlanStateLabel(p),
        for (final p in PlanSource.values) s.medsPlanSourceLabel(p),
        s.medsPause,
        s.medsStop,
        s.medsResume,
        s.medsMoreDoses(3),
        s.medsPlanLineState('daily', 'x', 'y'),
        s.medsDoseLine('today', true, '1 tablet'),
        s.medsDoseLine('today', false, null),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
