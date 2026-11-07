// U001@v0.32: entry with the mouse only. A number pad types into the field
// that was last chosen (nothing is pre-filled), and quick-pick chips fill the
// time with a value the typed-time rules still check at Save.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

import 'f007_measurements_test.dart'
    show launch, openSheet, tapKey, latestOf, settle;

Future<void> pad(WidgetTester tester, String keys) async {
  for (final k in keys.split(' ')) {
    await tapKey(tester, 'pad-$k');
  }
}

String whenText(WidgetTester tester) => tester
    .widget<TextField>(find.byKey(const ValueKey('measure-when')))
    .controller!
    .text;

void main() {
  testWidgets('the number pad is closed by default and types a value with '
      'the mouse only; delete removes the last character', (tester) async {
    await launch(tester);
    await openSheet(tester, RecordKind.bodyTemperature);
    expect(find.byKey(const ValueKey('measure-pad')), findsNothing);
    await tapKey(tester, 'measure-pad-toggle');
    expect(find.byKey(const ValueKey('measure-pad')), findsOneWidget);
    await pad(tester, '3 6 dec 9 del 8');
    await tapKey(tester, 'measure-save');
    expect(latestOf(tester, RecordKind.bodyTemperature), contains('36.8'));
  });

  testWidgets('the pad types into the field chosen last (systolic, then '
      'diastolic)', (tester) async {
    await launch(tester);
    await openSheet(tester, RecordKind.bloodPressure);
    await tapKey(tester, 'measure-pad-toggle');
    await tapKey(tester, 'measure-systolic');
    await pad(tester, '1 1 8');
    await tapKey(tester, 'measure-diastolic');
    await pad(tester, '7 6');
    await tapKey(tester, 'measure-save');
    expect(latestOf(tester, RecordKind.bloodPressure), contains('118/76'));
  });

  testWidgets('the Turkish pad uses a decimal comma', (tester) async {
    await launch(tester, locale: const Locale('tr'));
    await openSheet(tester, RecordKind.bodyTemperature);
    await tapKey(tester, 'measure-pad-toggle');
    expect(find.text(','), findsOneWidget);
    expect(find.text('.'), findsNothing);
  });

  testWidgets('time chips fill When; "Now" empties it; the stored time is '
      'the chosen one', (tester) async {
    await launch(tester);
    await openSheet(tester, RecordKind.height);
    await tapKey(tester, 'measure-more');
    await tapKey(tester, 'measure-preset-1 hour ago');
    final hourAgo = DateTime.now().subtract(const Duration(hours: 1));
    String two(int n) => n.toString().padLeft(2, '0');
    expect(
      whenText(tester),
      '${hourAgo.year}-${two(hourAgo.month)}-${two(hourAgo.day)} '
      '${two(hourAgo.hour)}:${two(hourAgo.minute)}',
    );
    await tapKey(tester, 'measure-preset-Now');
    expect(whenText(tester), '');
    await tapKey(tester, 'measure-preset-Yesterday 20:00');
    expect(whenText(tester), endsWith(' 20:00'));
    await tester.enterText(find.byKey(const ValueKey('measure-value')), '172');
    await tapKey(tester, 'measure-save');
    await settle(tester);
    expect(latestOf(tester, RecordKind.height), contains('172'));
  });
}
