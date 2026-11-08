// U019@v0.32: measurement tiles size their columns by the space measured in
// text of the chosen size: large text on a narrow phone gets one tile per
// row, normal text two, wide windows three or four (G-49).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/features/today/measurements_card.dart';

import 'f007_measurements_test.dart' show settle;
import 'u005_settings_test.dart' show launchWith;

Future<List<double>> tileLefts(WidgetTester tester) async {
  final tiles = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('measure-tile-'),
  );
  return [
    for (final e in tiles.evaluate())
      tester.getTopLeft(find.byWidget(e.widget)).dx,
  ];
}

void main() {
  test('columns by width in text of the chosen size', () {
    expect(tileColumns(1200, 1), 4);
    expect(tileColumns(600, 1), 3);
    expect(tileColumns(288, 1), 2);
    expect(tileColumns(288, 2), 1);
    expect(tileColumns(1200, 2), 3);
    expect(tileColumns(200, 1), 1);
    expect(tileColumns(500, 0), 3, reason: 'a zero scale counts as 1');
  });

  testWidgets('320 dp phone: two tiles a row at normal text, one at the '
      'largest size with large system text', (tester) async {
    await launchWith(tester);
    tester.view.physicalSize = const Size(320, 2400);
    await settle(tester);
    expect((await tileLefts(tester)).toSet().length, 2);

    await launchWith(
      tester,
      initial: const AppearanceSettings(textSize: TextSizeChoice.largest),
    );
    tester.view.physicalSize = const Size(320, 4000);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await settle(tester);
    expect((await tileLefts(tester)).toSet().length, 1);
    expect(tester.takeException(), isNull);
  });
}
