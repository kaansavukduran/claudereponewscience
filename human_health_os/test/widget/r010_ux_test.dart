// R010: cross-domain review fixes. Every sheet has a visible Cancel; a
// how-you-feel check-in can be corrected; the device capability texts are
// all in Turkish when the app is.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/ports/storage_status.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f007_measurements_test.dart' show settle, tapKey;
import 'u005_settings_test.dart' show launchWith;

void main() {
  testWidgets('each sheet closes with a visible Cancel and saves nothing', (
    tester,
  ) async {
    await launchWith(tester);
    for (final (open, prefix) in [
      ('sleep-add', 'sleep'),
      ('feel-open', 'feel'),
    ]) {
      await tester.ensureVisible(find.byKey(ValueKey(open)));
      await tapKey(tester, open);
      await tapKey(tester, '$prefix-cancel');
      await settle(tester);
      expect(find.byKey(ValueKey('$prefix-save')), findsNothing);
    }
    expect(find.byKey(const ValueKey('sleep-none')), findsOneWidget);
    expect(find.byKey(const ValueKey('feel-none')), findsOneWidget);
    for (final (area, open, prefix) in [
      ('nutrition', 'food-add', 'food'),
      ('activity', 'act-add', 'act'),
    ]) {
      await tester.tap(find.byKey(ValueKey('rail-planned-$area')));
      await settle(tester);
      await tapKey(tester, open);
      await tapKey(tester, '$prefix-cancel');
      await settle(tester);
      expect(find.byKey(ValueKey('$prefix-save')), findsNothing);
      expect(find.byKey(ValueKey('$prefix-none')), findsOneWidget);
    }
    await tester.tap(find.text('Medications').first);
    await settle(tester);
    await tapKey(tester, 'meds-add');
    await tapKey(tester, 'meds-cancel');
    await settle(tester);
    expect(find.byKey(const ValueKey('meds-none')), findsOneWidget);
  });

  testWidgets('a check-in is corrected from the card: the sheet opens with '
      'its levels; a new version shows', (tester) async {
    await launchWith(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('feel-open')));
    await tapKey(tester, 'feel-open');
    await tapKey(tester, 'feel-energy-low');
    await tapKey(tester, 'feel-save');
    await settle(tester);
    expect(find.textContaining('Energy: drained'), findsOneWidget);
    await tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('feel-correct-'),
      ),
    );
    await settle(tester);
    expect(find.text('Correct this check-in'), findsOneWidget);
    final low = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('feel-energy-low')),
    );
    expect(low.selected, isTrue);
    await tapKey(tester, 'feel-energy-high');
    await tapKey(tester, 'feel-save');
    await settle(tester);
    expect(find.textContaining('Energy: lively'), findsOneWidget);
    expect(find.textContaining('Energy: drained'), findsNothing);
  });

  test('a corrected check-in keeps its time and the earlier version', () async {
    final repo = LogRepository(
      sink: MemoryLogSink(),
      durability: StorageDurability.localFile,
      location: 'test',
    );
    await repo.open();
    final svc = HeartbeatService(repo);
    final me = (await svc.ensureSelfProfile()).id;
    final r = await svc.recordFeeling(
      profileId: me,
      mood: SelfLevel.low,
      when: '2026-11-09 08:00',
    );
    final fixed = await svc.recordFeeling(
      profileId: me,
      mood: SelfLevel.medium,
      correcting: r.id,
    );
    expect(fixed.supersedesId, r.id);
    expect(fixed.amendReason, AmendReason.correction);
    expect(fixed.observedAt, r.observedAt);
    expect((await svc.feelings(me)).single.id, fixed.id);
    expect(
      await repo.records(me, kind: RecordKind.feelingCheckIn),
      hasLength(2),
    );
  });

  test('every device capability text has Turkish', () {
    final tr = S(AppLang.tr);
    final texts = <String>{};
    for (final p in HostPlatform.values) {
      for (final reason in [null, ...StorageReason.values]) {
        for (final storage in [
          null,
          for (final d in StorageDurability.values)
            for (final enc in [false, true])
              StorageDescription(
                durability: d,
                encrypted: enc,
                location: 'x',
                vaultId: 'v',
              ),
        ]) {
          final reg = CapabilityRegistry.forPlatform(
            p,
            storage: storage,
            reason: reason,
          );
          for (final c in reg.capabilities) {
            texts
              ..add(c.label)
              ..add(c.detail);
          }
        }
      }
    }
    // Product names stay as they are.
    texts.removeAll({'Health Connect', 'Apple Health (HealthKit)'});
    for (final t in texts) {
      expect(tr.capText(t), isNot(t), reason: 'no Turkish for: $t');
    }
  });
}
