// F009 slice 1: the Conditions screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('add a symptom with its source; correct it', (tester) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-conditions')));
    await settle(tester);
    expect(find.byKey(const ValueKey('cond-none')), findsOneWidget);
    await tapKey(tester, 'cond-add');
    await tapKey(tester, 'cond-save');
    expect(find.text(S(AppLang.en).inputError('EMPTY')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('cond-name')), 'Cough');
    await tapKey(tester, 'cond-nature-symptom');
    await tapKey(tester, 'cond-source-toldByClinician');
    await tapKey(tester, 'cond-save');
    await settle(tester);
    // Not chosen, so not sure: the sheet never picks "current" for them.
    expect(
      find.text('Cough · symptom · It is: not sure · what a clinician told me'),
      findsOneWidget,
    );
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('cond-correct-'),
      ),
    );
    await settle(tester);
    await tapKey(tester, 'cond-time-past');
    await tapKey(tester, 'cond-save');
    await settle(tester);
    expect(
      find.text(
        'Cough · symptom · It is: in the past · what a clinician told me',
      ),
      findsOneWidget,
    );
  });

  test('the Turkish line reads as one account', () {
    const d = ConditionEntryDetails(
      name: 'Öksürük',
      nature: ConditionType.symptom,
      time: ConditionTime.current,
      source: ConditionSource.selfReported,
      since: 'geçen kış',
    );
    expect(
      S(AppLang.tr).condLine(d),
      'Öksürük · belirti · Durumu: sürüyor · kendi anlatımım · '
      'başlangıç: geçen kış',
    );
    expect(S(AppLang.en).condIntro, contains('confirms nothing'));
    expect(S(AppLang.tr).condIntro, contains('doğrulamaz'));
  });

  test('the words diagnose nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.condTitle,
        s.condNone,
        s.condName,
        for (final c in ConditionSource.values) s.condSource(c),
        for (final t in ConditionTime.values) s.condTime(t),
        for (final t in ConditionType.values) s.condNature(t),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
