// F009 slice 2: the Preventive screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

/// Words that would recommend, schedule or remind.
final RegExp advising = RegExp(
  r'(?<!\p{L})(due|overdue|recommended|should|you need|'
  r'gerekli|önerilir|gecikmiş|vakti geldi)(?!\p{L})',
  caseSensitive: false,
  unicode: true,
);

void main() {
  testWidgets('add a planned item; the sheet starts at not sure; correct it '
      'to done', (tester) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-preventive')));
    await settle(tester);
    expect(find.byKey(const ValueKey('screen-preventive')), findsOneWidget);
    expect(find.byKey(const ValueKey('prev-none')), findsOneWidget);
    await tapKey(tester, 'prev-add');
    // Nothing is pre-selected as done.
    ChoiceChip chip(String key) =>
        tester.widget<ChoiceChip>(find.byKey(ValueKey(key)));
    expect(chip('prev-status-unsure').selected, isTrue);
    expect(chip('prev-status-done').selected, isFalse);
    expect(chip('prev-status-planned').selected, isFalse);
    await tapKey(tester, 'prev-save');
    expect(find.text(S(AppLang.en).inputError('EMPTY')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('prev-name')),
      'Tetanus vaccine',
    );
    await tapKey(tester, 'prev-status-planned');
    await tapKey(tester, 'prev-source-toldByClinician');
    await tester.enterText(find.byKey(const ValueKey('prev-when')), '2027-03');
    await tapKey(tester, 'prev-save');
    await settle(tester);
    const planned =
        'Tetanus vaccine · vaccination · Status: planned · '
        'what a clinician told me · when: 2027-03';
    expect(find.text(planned), findsOneWidget);
    expect(planned, isNot(contains('done')));
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('prev-correct-'),
      ),
    );
    await settle(tester);
    // The correction starts from the shown version.
    expect(chip('prev-status-planned').selected, isTrue);
    await tapKey(tester, 'prev-status-done');
    await tapKey(tester, 'prev-save');
    await settle(tester);
    expect(
      find.text(
        'Tetanus vaccine · vaccination · Status: done · '
        'what a clinician told me · when: 2027-03',
      ),
      findsOneWidget,
    );
    expect(find.text(planned), findsNothing);
  });

  testWidgets('cancel writes nothing; a screening saved untouched reads as '
      'not sure', (tester) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-preventive')));
    await settle(tester);
    await tapKey(tester, 'prev-add');
    await tester.enterText(find.byKey(const ValueKey('prev-name')), 'x');
    await tapKey(tester, 'prev-cancel');
    await settle(tester);
    expect(find.byKey(const ValueKey('prev-none')), findsOneWidget);
    await tapKey(tester, 'prev-add');
    await tester.enterText(
      find.byKey(const ValueKey('prev-name')),
      'Colon screening',
    );
    await tapKey(tester, 'prev-nature-screening');
    await tapKey(tester, 'prev-save');
    await settle(tester);
    expect(
      find.text(
        'Colon screening · screening · Status: not sure · my own account',
      ),
      findsOneWidget,
    );
  });

  test('a planned line never reads as done, in either language', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      const d = PreventiveEntryDetails(
        name: 'Flu',
        nature: PreventiveType.vaccination,
        status: PreventiveStatus.planned,
        source: ConditionSource.selfReported,
      );
      final line = s.prevLine(d);
      expect(line, contains(s.prevStatus(PreventiveStatus.planned)));
      expect(line, isNot(contains(s.prevStatus(PreventiveStatus.done))));
    }
  });

  test('the Turkish line reads as one account', () {
    const d = PreventiveEntryDetails(
      name: 'Diş kontrolü',
      nature: PreventiveType.checkup,
      status: PreventiveStatus.done,
      source: ConditionSource.selfReported,
      when: 'geçen bahar',
    );
    expect(
      S(AppLang.tr).prevLine(d),
      'Diş kontrolü · kontrol · Durumu: yapıldı · kendi anlatımım · '
      'zaman: geçen bahar',
    );
    expect(S(AppLang.tr).prevNature(PreventiveType.vaccination), 'aşı');
    expect(S(AppLang.tr).prevNature(PreventiveType.screening), 'tarama');
    expect(S(AppLang.tr).prevStatus(PreventiveStatus.planned), 'planlandı');
    expect(S(AppLang.tr).prevStatus(PreventiveStatus.unsure), 'emin değilim');
    expect(S(AppLang.en).prevIntro, contains('recommends nothing'));
    expect(S(AppLang.tr).prevIntro, contains('önermez'));
  });

  test('the words judge, diagnose and recommend nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.prevTitle,
        s.prevIntro,
        s.prevNone,
        s.prevName,
        s.prevWhen,
        s.prevAdd,
        s.prevStatusLabel,
        s.recordKind(RecordKind.preventiveEntry),
        for (final c in ConditionSource.values) s.condSource(c),
        for (final t in PreventiveStatus.values) s.prevStatus(t),
        for (final t in PreventiveType.values) s.prevNature(t),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(advising.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
