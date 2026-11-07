// U001@v0.32: a first-time user finds a plain "how to use" page from Today
// with the mouse; it names the real buttons and judges nothing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show launch, tapKey;

void main() {
  testWidgets('How to use opens from Today and lists six steps', (
    tester,
  ) async {
    await launch(tester);
    await tapKey(tester, 'tool-howto');
    expect(find.byKey(const ValueKey('screen-howto')), findsOneWidget);
    for (var i = 1; i <= 6; i++) {
      expect(find.byKey(ValueKey('howto-step-$i')), findsOneWidget);
    }
    expect(find.textContaining('Show number pad'), findsOneWidget);
  });

  testWidgets('the steps name buttons that exist, in both languages', (
    tester,
  ) async {
    for (final lang in AppLang.values) {
      final s = S(lang);
      final all = s.howToSteps.map((e) => e.$2).join(' ');
      for (final label in [
        s.numberPadShow,
        s.saveMeasurement,
        s.moreDetails,
        s.createBackup,
      ]) {
        expect(all, contains(label), reason: '$lang $label');
      }
      for (final t in [
        s.howToTitle,
        s.howToTileHint,
        s.howToNote,
        for (final e in s.howToSteps) ...[e.$1, e.$2],
      ]) {
        expect(interpretive.hasMatch(t), isFalse, reason: t);
        expect(judged.hasMatch(t), isFalse, reason: t);
      }
    }
  });
}
