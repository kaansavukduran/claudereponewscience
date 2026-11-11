// F007 slice 5: the Nutrition screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/features/timeline/timeline_screen.dart'
    show fmtValue;
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('add food: an error on its field, then the entry as typed, '
      'without the nutrient left empty', (tester) async {
    await launchWith(tester);
    await tester.tap(find.byKey(const ValueKey('rail-planned-nutrition')));
    await settle(tester);
    expect(find.byKey(const ValueKey('food-none')), findsOneWidget);
    await tapKey(tester, 'food-add');
    await tapKey(tester, 'food-save');
    expect(find.byKey(const ValueKey('food-error')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('food-what')), 'Hummus');
    await tester.enterText(find.byKey(const ValueKey('food-amount')), '100 g');
    await tester.enterText(find.byKey(const ValueKey('food-n-protein')), '7,9');
    // A label value without its basis is refused, in words.
    await tapKey(tester, 'food-save');
    expect(
      find.text(S(AppLang.en).inputError('FOOD_LABEL_BASIS_REQUIRED')),
      findsOneWidget,
    );
    await tapKey(tester, 'food-per-per100g');
    await tapKey(tester, 'food-save');
    await settle(tester);
    expect(
      find.text('Hummus · 100 g · label (per 100 g) Protein 7,9 g'),
      findsOneWidget,
    );
    expect(find.textContaining('Fat'), findsNothing);

    // Correct it: the sheet opens with what was typed; a new version shows.
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('food-correct-'),
      ),
    );
    await settle(tester);
    expect(find.text('Correct this entry'), findsOneWidget);
    expect(find.text('Hummus'), findsWidgets);
    await tester.enterText(find.byKey(const ValueKey('food-amount')), '150 g');
    await tapKey(tester, 'food-save');
    await settle(tester);
    expect(
      find.text('Hummus · 150 g · label (per 100 g) Protein 7,9 g'),
      findsOneWidget,
    );
    expect(find.textContaining('Hummus · 100 g'), findsNothing);
  });

  test('the Timeline line keeps the label apart from the amount eaten', () {
    final r = HealthRecord(
      id: 'x',
      profileId: 'p',
      kind: RecordKind.foodEntry,
      state: RecordState.reported,
      valueStatus: ValueStatus.present,
      quantity: null,
      originalText: null,
      provenance: const Provenance.manual(),
      observedAt: DateTime.utc(2026, 11, 10, 12),
      recordedAt: DateTime.utc(2026, 11, 10, 12),
      details: const FoodEntryDetails(
        what: 'Yogurt',
        amount: '250 g',
        nutrients: {
          PrintedNutrient.energyKj: '250',
          PrintedNutrient.salt: '0,1',
        },
        per: LabelBasis.per100g,
      ),
      schemaVersion: 9,
    );
    expect(
      fmtValue(S(AppLang.en), r),
      'Yogurt · 250 g · label (per 100 g) Energy 250 kJ, Salt 0,1 g',
    );
    expect(
      fmtValue(S(AppLang.tr), r),
      'Yogurt · 250 g · etiket (100 g için) Enerji 250 kJ, Tuz 0,1 g',
    );
  });

  test('the words judge nothing', () {
    for (final lang in AppLang.values) {
      final s = S(lang);
      for (final w in [
        s.foodTitle,
        s.foodIntro,
        s.foodNone,
        s.foodLabelTitle,
        s.foodLabelHelp,
        s.foodPer,
        for (final b in LabelBasis.values) s.foodBasis(b),
        s.inputError('FOOD_LABEL_BASIS_REQUIRED'),
        for (final n in PrintedNutrient.values) s.foodNutrient(n),
        s.inputError('FOOD_NUTRIENT_NOT_A_NUMBER'),
      ]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
