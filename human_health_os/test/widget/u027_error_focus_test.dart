// U027 (G-73): after a refused save, keyboard focus moves to the field the
// error is about, so a keyboard or screen-reader user lands on it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

/// Whether the text field keyed [key] holds primary focus.
bool focused(WidgetTester tester, String key) {
  final editable = tester.widget<EditableText>(
    find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(EditableText),
    ),
  );
  return editable.focusNode.hasPrimaryFocus &&
      FocusManager.instance.primaryFocus == editable.focusNode;
}

Future<void> openRail(WidgetTester tester, String rail) async {
  await tester.tap(find.byKey(ValueKey(rail)));
  await settle(tester);
}

void main() {
  testWidgets('activity: an empty save focuses what was done', (tester) async {
    await launchWith(tester);
    await openRail(tester, 'rail-planned-activity');
    await tapKey(tester, 'act-add');
    expect(focused(tester, 'act-what'), isFalse);
    await tapKey(tester, 'act-save');
    expect(focused(tester, 'act-what'), isTrue);
  });

  testWidgets('nutrition: an empty save focuses what was eaten; a value '
      'the service refuses focuses that nutrient', (tester) async {
    await launchWith(tester);
    await openRail(tester, 'rail-planned-nutrition');
    await tapKey(tester, 'food-add');
    await tapKey(tester, 'food-save');
    expect(focused(tester, 'food-what'), isTrue);
    await tester.enterText(
      find.byKey(const ValueKey('food-n-protein')),
      '1,2,3',
    );
    await tapKey(tester, 'food-save');
    expect(focused(tester, 'food-n-protein'), isTrue);
    expect(focused(tester, 'food-what'), isFalse);
    // The focused field is in view.
    expect(
      find.byKey(const ValueKey('food-n-protein')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('sleep: an empty save focuses the time in bed', (tester) async {
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
    await tapKey(tester, 'sleep-add');
    await tapKey(tester, 'sleep-save');
    expect(focused(tester, 'sleep-bed'), isTrue);
  });

  testWidgets('conditions: an empty save focuses the name', (tester) async {
    await launchWith(tester);
    await openRail(tester, 'rail-planned-conditions');
    await tapKey(tester, 'cond-add');
    await tapKey(tester, 'cond-save');
    expect(focused(tester, 'cond-name'), isTrue);
  });
}
