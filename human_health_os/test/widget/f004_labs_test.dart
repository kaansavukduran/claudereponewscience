// F004@v0.32 Labs screen: a result is entered and shown as printed, a
// missing unit or range is named as missing, the lab's flag is labelled as
// the lab's, no screen text interprets a result (EN and TR), and lab
// results appear on the Timeline.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/app_services.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 't',
  sourceRevision: 't',
);

/// Words that would mean the app judged a result. The lab's own flag and
/// range are verbatim source text and are checked separately.
final RegExp interpretive = RegExp(
  r'\b(normal|abnormal|healthy|unhealthy|deficien\w*|diagnos\w*|disease|'
  r'too high|too low|elevated|risk)\b|'
  r'\b(anormal|sağlıklı|sağlıksız|eksikliği|teşhis|tanı|hastalık|yüksek|düşük|riskli)\b',
  caseSensitive: false,
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
  Size size = const Size(1280, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final s = await tester.runAsync(() async {
    final repo = inMemoryRepository();
    await repo.open();
    return servicesFor(dev, HostPlatform.linux, repo);
  });
  return s!;
}

Future<void> go(WidgetTester tester, AppServices s, String label) async {
  await tester.pumpWidget(HumanOsApp(services: s));
  await settle(tester);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('nav-rail')),
      matching: find.text(label),
    ),
  );
  await settle(tester);
}

/// Scrolls the Labs list until [f] is built and on screen (the list is
/// lazy, so a field far below is not built yet on a small phone).
Future<void> reveal(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    final list = find
        .descendant(
          of: find.byKey(const ValueKey('screen-labs')),
          matching: find.byType(Scrollable),
        )
        .first;
    // Back to the top, then down until the item is built.
    await tester.fling(list, const Offset(0, 4000), 4000);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(f, 150, scrollable: list);
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, String key, String text) async {
  final f = find.byKey(ValueKey(key));
  await reveal(tester, f);
  await tester.enterText(f, text);
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  // A focused text field scrolls itself back into view; release it first.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await reveal(tester, f);
  await tester.tap(f);
  await settle(tester);
}

/// Comparison words: a result row must never compare the value with the
/// range or judge it. (The screen's fixed invariant text, e.g. "Out of range
/// ≠ critical", is outside the rows and is checked with [interpretive].)
final RegExp judged = RegExp(
  r'\b(high|low|above|below|outside|within|in range|out of range|elevated|'
  r'raised|optimal|good|bad|critical|ok)\b|'
  r'(yüksek|düşük|üstünde|altında|aralık dışı|aralıkta|iyi|kötü|kritik|optimal)',
  caseSensitive: false,
);

/// Texts inside every widget whose key starts with [prefix].
List<String> textsIn(WidgetTester tester, String prefix) => [
  for (final row
      in find
          .byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith(prefix),
          )
          .evaluate())
    for (final t in tester.widgetList<Text>(
      find.descendant(
        of: find.byElementPredicate((e) => e == row),
        matching: find.byType(Text),
      ),
    ))
      t.data ?? t.textSpan?.toPlainText() ?? '',
];

List<String> screenTexts(WidgetTester tester) => [
  for (final t in tester.widgetList<Text>(find.byType(Text)))
    t.data ?? t.textSpan?.toPlainText() ?? '',
];

void main() {
  testWidgets('a result typed from a report is listed exactly as printed', (
    tester,
  ) async {
    final s = await start(tester);
    await go(tester, s, 'Labs');
    await fill(tester, 'lab-analyte', 'HbA1c');
    await fill(tester, 'lab-value', '5,4');
    await fill(tester, 'lab-unit', '%');
    await fill(tester, 'lab-date', '2026-10-03');
    await fill(tester, 'lab-flag', 'H');
    await fill(tester, 'lab-range', '4.0 - 6.0');
    await tapKey(tester, 'lab-save');

    expect(find.byKey(const ValueKey('lab-saved')), findsOneWidget);
    final row = find.byKey(
      ValueKey(
        'lab-row-${(await tester.runAsync(() => s.heartbeat.labTimeline(s.self.id)))!.single.shown.id}',
      ),
    );
    Finder inRow(String t) => find.descendant(of: row, matching: find.text(t));
    expect(inRow('HbA1c'), findsOneWidget);
    expect(inRow('5,4 %'), findsOneWidget, reason: 'printed text, not 5.4');
    expect(inRow('Lab flag: H'), findsOneWidget);
    expect(inRow("Lab's printed range: 4.0 - 6.0"), findsOneWidget);
  });

  testWidgets('a missing unit and a missing range are named, a missing '
      'value is "Not reported"', (tester) async {
    final s = await start(tester);
    await tester.runAsync(() async {
      await s.heartbeat.recordLab(
        profileId: s.self.id,
        input: const LabInput(
          analyte: 'Ferritin',
          value: '38',
          notReported: false,
          unit: '',
          sampleDate: '2026-10-02',
        ),
      );
      await s.heartbeat.recordLab(
        profileId: s.self.id,
        input: const LabInput(
          analyte: 'TSH',
          value: '',
          notReported: true,
          unit: 'mIU/L',
          sampleDate: '2026-10-01',
        ),
      );
    });
    await go(tester, s, 'Labs');
    expect(find.text('38 (unit not given)'), findsOneWidget);
    expect(find.text('No range printed'), findsNWidgets(2));
    expect(find.text('Not reported'), findsOneWidget);
    expect(find.textContaining('0 mIU/L'), findsNothing, reason: 'never zero');
  });

  for (final (locale, labs) in [
    (const Locale('en'), 'Labs'),
    (const Locale('tr'), 'Lab'),
  ]) {
    testWidgets('no screen text interprets a result ($locale)', (tester) async {
      final s = await start(tester, locale: locale);
      await tester.runAsync(
        () => s.heartbeat.recordLab(
          profileId: s.self.id,
          input: const LabInput(
            analyte: 'LDL',
            value: '190',
            notReported: false,
            unit: 'mg/dL',
            sampleDate: '2026-10-03',
            sourceFlag: 'H',
            referenceText: '< 130',
          ),
        ),
      );
      await go(tester, s, labs);
      final texts = screenTexts(tester);
      expect(texts.where(interpretive.hasMatch), isEmpty);
      final row = textsIn(tester, 'lab-row-');
      expect(row, isNotEmpty, reason: 'the row is scanned');
      expect(row.where(judged.hasMatch), isEmpty, reason: row.join(' | '));
      await go(
        tester,
        s,
        locale.languageCode == 'tr' ? 'Zaman çizelgesi' : 'Timeline',
      );
      expect(screenTexts(tester).where(interpretive.hasMatch), isEmpty);
      final entry = textsIn(tester, 'timeline-entry-');
      expect(entry, isNotEmpty);
      expect(entry.where(judged.hasMatch), isEmpty, reason: entry.join(' | '));
      expect(
        find.text('LDL'),
        findsOneWidget,
        reason: 'listed on the Timeline',
      );
    });
  }

  testWidgets('correct a mistyped result: the new version replaces it on '
      'Labs and the old one stays in the Timeline history', (tester) async {
    final s = await start(tester);
    late HealthRecord first;
    await tester.runAsync(() async {
      first = await s.heartbeat.recordLab(
        profileId: s.self.id,
        input: const LabInput(
          analyte: 'Glukoz',
          value: '901',
          notReported: false,
          unit: 'mg/dL',
          sampleDate: '2026-10-03',
        ),
      );
    });
    await go(tester, s, 'Labs');
    await tapKey(tester, 'lab-correct-${first.id}');
    await fill(tester, 'lab-value', '91');
    await tapKey(tester, 'lab-save');
    expect(find.text('91 mg/dL'), findsOneWidget);
    expect(find.text('901 mg/dL'), findsNothing);

    await go(tester, s, 'Timeline');
    await tester.tap(find.byKey(ValueKey('timeline-entry-${first.id}')));
    await settle(tester);
    final detail = find.byKey(const ValueKey('timeline-detail'));
    expect(
      find.descendant(of: detail, matching: find.text('901 mg/dL')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('action-correct-${first.id}')),
      findsNothing,
      reason: 'labs are corrected on Labs',
    );
  });

  testWidgets('entered in error from the Timeline removes it from Labs', (
    tester,
  ) async {
    final s = await start(tester);
    late HealthRecord r;
    await tester.runAsync(() async {
      r = await s.heartbeat.recordLab(
        profileId: s.self.id,
        input: const LabInput(
          analyte: 'CRP',
          value: '3',
          notReported: false,
          unit: 'mg/L',
          sampleDate: '2026-10-03',
        ),
      );
    });
    await go(tester, s, 'Timeline');
    await tester.tap(find.byKey(ValueKey('timeline-entry-${r.id}')));
    await settle(tester);
    await tester.tap(find.byKey(ValueKey('action-error-${r.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-entered_in_error')));
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('nav-rail')),
        matching: find.text('Labs'),
      ),
    );
    await settle(tester);
    expect(find.byKey(const ValueKey('labs-empty')), findsOneWidget);
  });

  testWidgets('the Labs form fits a 320 dp phone at 2x text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final s = await start(tester, size: const Size(320, 640));
    await tester.pumpWidget(HumanOsApp(services: s));
    await settle(tester);
    await tester.tap(find.text('Labs').last);
    await settle(tester);
    await fill(tester, 'lab-analyte', 'Hemoglobin A1c (IFCC)');
    await fill(tester, 'lab-value', '37');
    await fill(tester, 'lab-unit', 'mmol/mol');
    await fill(tester, 'lab-date', '2026-10-03');
    await tapKey(tester, 'lab-save');
    await reveal(tester, find.byKey(const ValueKey('lab-saved')));
    expect(find.byKey(const ValueKey('lab-saved')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a cancelled correction gives the add form its own sample date '
      'and laboratory back (review finding)', (tester) async {
    final s = await start(tester);
    late HealthRecord old;
    await tester.runAsync(() async {
      old = await s.heartbeat.recordLab(
        profileId: s.self.id,
        input: const LabInput(
          analyte: 'TSH',
          value: '2',
          notReported: false,
          unit: 'mIU/L',
          sampleDate: '2025-03-01',
          laboratory: 'Old Lab',
        ),
      );
    });
    await go(tester, s, 'Labs');
    await fill(tester, 'lab-date', '2026-10-05');
    await fill(tester, 'lab-laboratory', 'New Lab');
    await tapKey(tester, 'lab-correct-${old.id}');
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('lab-date')))
          .controller!
          .text,
      '2025-03-01',
    );
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('lab-date')))
          .controller!
          .text,
      '2026-10-05',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('lab-laboratory')))
          .controller!
          .text,
      'New Lab',
    );
  });
}
