// F003@v0.32 user-visible timeline: entries newest first, a correction adds
// a version, "entered in error" lets the previous version count again,
// delete hides the whole fact (history view keeps it), conflicts are shown
// without picking a number. EN and TR.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/app_services.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 't',
  sourceRevision: 't',
);

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

Future<AppServices> start(
  WidgetTester tester, {
  Locale? locale,
  Size size = const Size(1280, 1800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final services = await tester.runAsync(() async {
    final repo = inMemoryRepository();
    await repo.open();
    return servicesFor(dev, HostPlatform.linux, repo);
  });
  return services!;
}

Future<void> show(WidgetTester tester, AppServices services) async {
  await tester.pumpWidget(HumanOsApp(services: services));
  await settle(tester);
}

Future<void> openTimeline(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('nav-rail')),
      matching: find.text(label),
    ),
  );
  await settle(tester);
}

Finder entry(String rootId) => find.byKey(ValueKey('timeline-entry-$rootId'));

Finder inEntry(String rootId, String text) =>
    find.descendant(of: entry(rootId), matching: find.text(text));

void main() {
  testWidgets('entries are listed newest observation first, with source, '
      'and "No records yet" only when there are none', (tester) async {
    final s = await start(tester);
    late HealthRecord older, newer;
    await tester.runAsync(() async {
      final h = s.heartbeat;
      older = await h.recordWeightKg(
        profileId: s.self.id,
        input: '81',
        observedAt: DateTime.utc(2026, 10, 1, 7),
      );
      newer = await h.recordWeightKg(
        profileId: s.self.id,
        input: '80,5',
        observedAt: DateTime.utc(2026, 10, 3, 7),
      );
    });
    await show(tester, s);
    await openTimeline(tester, 'Timeline');
    expect(find.byKey(const ValueKey('timeline-empty')), findsNothing);
    final yNewer = tester.getTopLeft(entry(newer.id)).dy;
    final yOlder = tester.getTopLeft(entry(older.id)).dy;
    expect(yNewer, lessThan(yOlder));
    expect(inEntry(newer.id, '80.5 kg'), findsOneWidget);
    expect(
      find.descendant(
        of: entry(newer.id),
        matching: find.textContaining('Observed · Manual entry'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('correct a value: the new version counts, the old one stays '
      'in the version history', (tester) async {
    final s = await start(tester);
    late HealthRecord w;
    await tester.runAsync(() async {
      w = await s.heartbeat.recordWeightKg(profileId: s.self.id, input: '87');
    });
    await show(tester, s);
    await openTimeline(tester, 'Timeline');
    await tester.tap(entry(w.id));
    await settle(tester);
    await tester.tap(find.byKey(ValueKey('action-correct-${w.id}')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('correct-input')), '78');
    await tester.tap(find.byKey(const ValueKey('correct-save')));
    await settle(tester);

    expect(inEntry(w.id, '78 kg'), findsOneWidget);
    expect(inEntry(w.id, '2 versions'), findsOneWidget);
    await tester.tap(entry(w.id));
    await settle(tester);
    final detail = find.byKey(const ValueKey('timeline-detail'));
    expect(
      find.descendant(of: detail, matching: find.text('87 kg')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: detail,
        matching: find.textContaining('Correction · current'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('entered in error on a correction: the previous value counts '
      'again (after a confirmation that explains it)', (tester) async {
    final s = await start(tester);
    late HealthRecord w, c;
    await tester.runAsync(() async {
      w = await s.heartbeat.recordWeightKg(profileId: s.self.id, input: '80');
      c = await s.heartbeat.correctWeightKg(
        profileId: s.self.id,
        targetId: w.id,
        input: '8',
      );
    });
    await show(tester, s);
    await openTimeline(tester, 'Timeline');
    expect(inEntry(w.id, '8 kg'), findsOneWidget);
    await tester.tap(entry(w.id));
    await settle(tester);
    await tester.tap(find.byKey(ValueKey('action-error-${c.id}')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('the previous version counts again'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('confirm-entered_in_error')));
    await settle(tester);
    expect(inEntry(w.id, '80 kg'), findsOneWidget);

    // Today agrees with the timeline.
    await openTimeline(tester, 'Today');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('weight-latest'))).data,
      '80 kg',
    );
  });

  testWidgets('delete hides the whole measurement; the history view still '
      'shows it as deleted (TR)', (tester) async {
    final s = await start(tester, locale: const Locale('tr'));
    late HealthRecord w;
    await tester.runAsync(() async {
      w = await s.heartbeat.recordWeightKg(profileId: s.self.id, input: '75');
    });
    await show(tester, s);
    await openTimeline(tester, 'Zaman çizelgesi');
    await tester.tap(entry(w.id));
    await settle(tester);
    await tester.tap(find.byKey(ValueKey('action-delete-${w.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Bu ölçüm silinsin mi?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-deleted')));
    await settle(tester);
    expect(entry(w.id), findsNothing);
    expect(find.byKey(const ValueKey('timeline-empty')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('timeline-show-hidden')));
    await settle(tester);
    expect(inEntry(w.id, 'Silindi'), findsOneWidget);
    await tester.tap(entry(w.id));
    await settle(tester);
    expect(find.byKey(const ValueKey('timeline-deleted-at')), findsOneWidget);
    expect(find.byKey(ValueKey('action-correct-${w.id}')), findsNothing);
  });

  testWidgets('a conflict shows both versions and no single number, on '
      'Timeline and Today', (tester) async {
    final s = await start(tester);
    late HealthRecord w;
    await tester.runAsync(() async {
      final repo = s.heartbeat.repository;
      w = await s.heartbeat.recordWeightKg(profileId: s.self.id, input: '80');
      for (final (id, kg) in [('c1', 79.0), ('c2', 81.0)]) {
        // Two devices corrected the same version independently (sync/import).
        await repo.appendRecord(
          HealthRecord(
            id: id,
            profileId: s.self.id,
            kind: RecordKind.bodyWeight,
            state: RecordState.observed,
            valueStatus: ValueStatus.present,
            quantity: Quantity(kg, 'kg'),
            originalText: null,
            provenance: const Provenance.manual(),
            observedAt: w.observedAt,
            recordedAt: w.recordedAt.add(Duration(minutes: kg.toInt())),
            supersedesId: w.id,
            amendReason: AmendReason.correction,
          ),
        );
      }
    });
    await show(tester, s);
    expect(find.byKey(const ValueKey('weight-conflict')), findsOneWidget);
    expect(find.byKey(const ValueKey('weight-latest')), findsNothing);
    await openTimeline(tester, 'Timeline');
    expect(inEntry(w.id, 'Versions disagree'), findsOneWidget);
    expect(inEntry(w.id, 'Conflict'), findsOneWidget);
    await tester.tap(entry(w.id));
    await settle(tester);
    expect(find.byKey(const ValueKey('action-error-c1')), findsOneWidget);
    expect(find.byKey(const ValueKey('action-error-c2')), findsOneWidget);
  });

  testWidgets('the Timeline fits a 320 dp phone at 2x text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final s = await start(tester, size: const Size(320, 640));
    await tester.runAsync(() async {
      final w = await s.heartbeat.recordWeightKg(
        profileId: s.self.id,
        input: '123,4',
      );
      await s.heartbeat.correctWeightKg(
        profileId: s.self.id,
        targetId: w.id,
        input: '123,5',
      );
    });
    await show(tester, s);
    await tester.tap(find.text('Timeline').last);
    await settle(tester);
    expect(find.byKey(const ValueKey('screen-timeline')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
