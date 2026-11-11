// U026 (G-74): Sleep and How you feel can be shown at the top of Today.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';

import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('with the choice on, Sleep and How you feel come before the '
      'weight card; off, after the measurements', (tester) async {
    double top(String key) => tester.getTopLeft(find.byKey(ValueKey(key))).dy;
    await launchWith(tester);
    expect(top('sleep-card'), greaterThan(top('weight-card')));
    await launchWith(
      tester,
      initial: const AppearanceSettings(checkInsFirst: true),
    );
    expect(top('sleep-card'), lessThan(top('weight-card')));
    expect(top('feel-card'), lessThan(top('weight-card')));
    expect(top('sleep-card'), lessThan(top('feel-card')));
  });

  test('saved with the other choices; Reset Today clears it', () {
    const on = AppearanceSettings(checkInsFirst: true);
    expect(AppearanceSettings.fromJson(on.toJson()), on);
    expect(AppearanceSettings.fromJson(on.toJson()).checkInsFirst, isTrue);
    expect(on.resetToday().checkInsFirst, isFalse);
    expect(const AppearanceSettings().checkInsFirst, isFalse);
    expect(AppearanceSettings.fromJson(const {}).checkInsFirst, isFalse);
  });
}
