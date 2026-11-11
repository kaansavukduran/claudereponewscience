// U028@v0.32: complete Turkish: profile names, banner, 12-hour clock
// markers, no Forge ids and no raw type names in user text.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/domain/settings/date_style.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f007_measurements_test.dart' show saveScalar, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  const en = S(AppLang.en);
  const tr = S(AppLang.tr);

  tearDown(() {
    displayDateOrder = DateOrder.iso;
    displayClock = ClockStyle.h24;
    displayDayPeriods = ('AM', 'PM');
  });

  test('profile names in both languages', () {
    expect(en.profileName(BuildProfile.development), 'DEVELOPMENT');
    expect(en.profileName(BuildProfile.staging), 'STAGING');
    expect(en.profileName(BuildProfile.production), 'PRODUCTION');
    expect(tr.profileName(BuildProfile.development), 'GELİŞTİRME');
    expect(tr.profileName(BuildProfile.staging), 'TEST');
    expect(tr.profileName(BuildProfile.production), 'YAYIN');
  });

  test('banners: Turkish staging banner has no STAGING', () {
    expect(
      tr.stagingBanner,
      'Klinik karar için değildir · TEST SÜRÜMÜ · yalnızca deneme amaçlı',
    );
    expect(tr.stagingBanner, isNot(contains('STAGING')));
    expect(tr.devBanner, contains('GELİŞTİRME SÜRÜMÜ'));
    expect(
      en.stagingBanner,
      'Not for clinical decisions · STAGING BUILD · test use only',
    );
  });

  test('12-hour markers: the domain stays AM/PM, Turkish shows ÖÖ/ÖS', () {
    final t = DateTime(2026, 11, 8, 20, 5);
    expect(formatWhen(t, DateOrder.iso, ClockStyle.h12), '2026-11-08 8:05 PM');
    expect(
      formatWhen(
        DateTime(2026, 11, 8, 9, 5),
        DateOrder.iso,
        ClockStyle.h12,
        am: tr.dayPeriods.$1,
        pm: tr.dayPeriods.$2,
      ),
      '2026-11-08 9:05 ÖÖ',
    );
    expect(tr.clock12Sample, '8:05 ÖS');
    expect(tr.clock12Sample, isNot(contains('PM')));
    expect(en.clock12Sample, '8:05 PM');
    displayDayPeriods = tr.dayPeriods;
    expect(
      formatWhenShown(t, DateOrder.dayMonth, ClockStyle.h12),
      '08.11.2026 8:05 ÖS',
    );
    // Typed input is unchanged: the 24-hour form still shows as before.
    expect(
      formatWhenShown(t, DateOrder.iso, ClockStyle.h24),
      '2026-11-08 20:05',
    );
  });

  test('planned text carries no Forge id', () {
    expect(en.plannedLater, 'Planned for a later version');
    expect(tr.plannedLater, 'İleriki bir sürümde gelecek');
    expect(en.plannedLater, isNot(contains('Forge')));
    expect(tr.plannedLater, isNot(contains('Forge')));
  });

  test('BACKUP_KEY_NEEDED has its own sentence', () {
    expect(
      en.backupError('BACKUP_KEY_NEEDED'),
      'This encrypted backup needs its passphrase or recovery key.',
    );
    expect(
      tr.backupError('BACKUP_KEY_NEEDED'),
      'Bu şifreli yedeği açmak için parolası ya da kurtarma anahtarı gerekiyor.',
    );
  });

  test('a type name goes on its own technical-detail line', () {
    expect(
      tr.gateFailed('PathAccessException'),
      'Bir şey ters gitti. Hiçbir şey değiştirilmedi.\n'
      'Teknik ayrıntı: PathAccessException',
    );
    expect(
      en.dataFileFailed('PathAccessException'),
      'That did not work. Nothing was changed.\n'
      'Technical detail: PathAccessException',
    );
  });

  testWidgets('Turkish 12-hour times and the settings sample show ÖS', (
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
    await tapKey(tester, 'set-language-tr');
    await tapKey(tester, 'set-clock-h12');
    expect(find.text('8:05 ÖS'), findsWidgets);
    expect(find.text('8:05 PM'), findsNothing);
    await tester.tap(find.byTooltip('Geri').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('8:05 ÖS'), findsWidgets);
    expect(find.textContaining(RegExp(r'\d PM\b')), findsNothing);
    // The build facts show the Turkish profile name, not the enum.
    expect(find.text('GELİŞTİRME'), findsWidgets);
    expect(find.text('DEVELOPMENT'), findsNothing);
    expect(find.byType(Text), findsWidgets);
  });
}
