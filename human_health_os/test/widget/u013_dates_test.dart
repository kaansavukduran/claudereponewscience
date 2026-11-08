// U013@v0.32: date order and clock style for displayed times; typed-time
// rules unchanged.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/settings/appearance.dart';
import 'package:human_health_os/src/domain/settings/date_style.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;
import 'f007_measurements_test.dart' show saveScalar, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  tearDown(() {
    displayDateOrder = DateOrder.iso;
    displayClock = ClockStyle.h24;
  });

  test('every order and clock', () {
    final t = DateTime(2026, 11, 8, 20, 5);
    expect(formatWhen(t, DateOrder.iso, ClockStyle.h24), '2026-11-08 20:05');
    expect(
      formatWhen(t, DateOrder.dayMonth, ClockStyle.h24),
      '08.11.2026 20:05',
    );
    expect(
      formatWhen(t, DateOrder.monthDay, ClockStyle.h12),
      '11/08/2026 8:05 PM',
    );
    expect(
      formatWhen(DateTime(2026, 1, 2, 0, 7), DateOrder.iso, ClockStyle.h12),
      '2026-01-02 12:07 AM',
    );
    expect(
      formatWhen(DateTime(2026, 1, 2, 12, 0), DateOrder.iso, ClockStyle.h12),
      '2026-01-02 12:00 PM',
    );
  });

  testWidgets('choosing day.month and 12-hour changes shown times at once', (
    tester,
  ) async {
    await launchWith(tester);
    await saveScalar(
      tester,
      RecordKind.height,
      '172',
      when: '2026-11-01 20:05',
    );
    await tapKey(tester, 'open-settings');
    await tapKey(tester, 'set-date-dayMonth');
    await tapKey(tester, 'set-clock-h12');
    await tester.tap(find.byTooltip('Back').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('01.11.2026 8:05 PM'), findsWidgets);
  });

  test('round trip and words', () {
    const s = AppearanceSettings(
      dateOrder: DateOrder.monthDay,
      clock: ClockStyle.h12,
    );
    expect(AppearanceSettings.fromJson(s.toJson()), s);
    for (final lang in AppLang.values) {
      for (final w in [S(lang).settingsDates, S(lang).datesNote]) {
        expect(interpretive.hasMatch(w), isFalse, reason: w);
        expect(judged.hasMatch(w), isFalse, reason: w);
      }
    }
  });
}
