// F007 slice 4: the "How you feel" card on Today.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/features/timeline/timeline_screen.dart'
    show fmtValue;
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('pick levels, clear one, save; nothing picked is said in words', (
    tester,
  ) async {
    await launchWith(tester);
    expect(find.byKey(const ValueKey('feel-none')), findsOneWidget);
    await tapKey(tester, 'feel-open');
    await tapKey(tester, 'feel-save');
    expect(find.byKey(const ValueKey('feel-error')), findsOneWidget);
    await tapKey(tester, 'feel-energy-low');
    await tapKey(tester, 'feel-mood-high');
    await tapKey(tester, 'feel-mood-high'); // tapped again: not given
    await tapKey(tester, 'feel-stress-medium');
    await tapKey(tester, 'feel-save');
    await settle(tester);
    expect(find.byKey(const ValueKey('feel-none')), findsNothing);
    expect(
      find.textContaining('Energy: drained · Stress: tense'),
      findsOneWidget,
    );
    expect(find.textContaining('Mood'), findsNothing); // not given
  });

  testWidgets('the card can be hidden from Today', (tester) async {
    await launchWith(
      tester,
      initial: const AppearanceSettings(hiddenSections: {TodaySection.feeling}),
    );
    expect(find.byKey(const ValueKey('feel-card')), findsNothing);
  });

  test('every word, in English and Turkish, per question and level', () {
    String words(AppLang lang) {
      final s = S(lang);
      return [
        for (final q in FeelingQuestion.values)
          [for (final l in SelfLevel.values) s.feelWord(q, l)].join('/'),
      ].join(' | ');
    }

    expect(
      words(AppLang.en),
      'drained/steady/lively | down/even/bright | calm/tense/overwhelmed',
    );
    expect(
      words(AppLang.tr),
      'bitkin/dengeli/dinç | keyifsiz/idare eder/keyifli | '
      'sakin/gergin/çok gergin',
    );
  });

  test('the Timeline line names only the questions answered', () {
    final r = HealthRecord(
      id: 'x',
      profileId: 'p',
      kind: RecordKind.feelingCheckIn,
      state: RecordState.reported,
      valueStatus: ValueStatus.present,
      quantity: null,
      originalText: null,
      provenance: const Provenance.manual(),
      observedAt: DateTime.utc(2026, 11, 10, 9),
      recordedAt: DateTime.utc(2026, 11, 10, 9),
      details: const FeelingCheckInDetails(mood: SelfLevel.high),
      schemaVersion: 8,
    );
    expect(fmtValue(S(AppLang.en), r), 'Mood: bright');
    expect(fmtValue(S(AppLang.tr), r), 'Ruh hâli: keyifli');
  });

  test('Sleep and How you feel hidden survive the saved settings', () {
    const hidden = AppearanceSettings(
      hiddenSections: {TodaySection.sleep, TodaySection.feeling},
    );
    expect(AppearanceSettings.fromJson(hidden.toJson()), hidden);
  });

  test('the words score and judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.feelTitle,
        s.feelIntro,
        s.feelNone,
        s.feelLine(SelfLevel.low, SelfLevel.medium, SelfLevel.high),
        for (final q in FeelingQuestion.values)
          for (final l in SelfLevel.values) s.feelWord(q, l),
        s.inputError('CHECKIN_EMPTY'),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
