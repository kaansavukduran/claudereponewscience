// F007@v0.32 Measurements card and Timeline (slice 1): blood pressure,
// resting heart rate and waist circumference entered by hand, shown as
// typed (118/76 mmHg, 84.25 cm), never as 0 when missing, never judged
// (EN and TR), corrected and withdrawn on the Timeline, saved across a
// restart, and laid out at 320 dp with 2x text.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/app_services.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/data/backup/data_files.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';
import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;

const dev = AppConfig(
  profile: BuildProfile.development,
  version: 't',
  sourceRevision: 't',
);

/// Words that would classify a reading (F004's lists do not hold them).
final RegExp measurementJudged = RegExp(
  r'(?<!\p{L})(hypertensi\p{L}*|hypotensi\p{L}*|prehypertensi\p{L}*|'
  r'normotensi\p{L}*|stage|tachycardi\p{L}*|bradycardi\p{L}*|obes\p{L}*|'
  r'overweight|category|hipertansiyon\p{L}*|hipotansiyon\p{L}*|evre|'
  r'taşikardi\p{L}*|bradikardi\p{L}*|obez\p{L}*|kategori\p{L}*|'
  r'kilolu)(?!\p{L})',
  caseSensitive: false,
  unicode: true,
);

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

/// The app on [sink] (a "file" kept across restarts) with [files].
Future<AppServices> launch(
  WidgetTester tester, {
  MemoryLogSink? sink,
  DataFiles? files,
  Locale? locale,
  Size size = const Size(1280, 3200),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  if (locale != null) {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }
  final s = await tester.runAsync(() async {
    final repo = LogRepository(
      sink: sink ?? MemoryLogSink(),
      durability: StorageDurability.localFile,
      location: 'test',
    );
    final report = await repo.open();
    return servicesFor(
      dev,
      HostPlatform.linux,
      repo,
      report: report,
      files: files,
    );
  });
  await tester.pumpWidget(HumanOsApp(services: s!));
  await settle(tester);
  return s;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await settle(tester);
}

Future<void> fill(WidgetTester tester, String key, String text) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.enterText(f, text);
}

Future<void> saveBp(WidgetTester tester, String sys, String dia) async {
  await tapKey(tester, 'measure-kind-vital.blood_pressure');
  await fill(tester, 'measure-systolic', sys);
  await fill(tester, 'measure-diastolic', dia);
  await tapKey(tester, 'measure-save');
}

Future<void> saveScalar(
  WidgetTester tester,
  RecordKind kind,
  String value, {
  String context = '',
}) async {
  await tapKey(tester, 'measure-kind-${kind.code}');
  await fill(tester, 'measure-value', value);
  if (context.isNotEmpty) await fill(tester, 'measure-context', context);
  await tapKey(tester, 'measure-save');
}

String latestOf(WidgetTester tester, RecordKind kind) => tester
    .widget<Text>(find.byKey(ValueKey('measure-latest-value-${kind.code}')))
    .data!;

/// Every text inside the widget with [key], and inside widgets whose key
/// starts with [prefix].
List<String> textsUnder(WidgetTester tester, Finder f) => [
  for (final e in f.evaluate())
    for (final t in tester.widgetList<Text>(
      find.descendant(of: find.byWidget(e.widget), matching: find.byType(Text)),
    ))
      t.data ?? t.textSpan?.toPlainText() ?? '',
];

Future<void> openTimeline(WidgetTester tester) async {
  final lang = S.of(tester.element(find.byType(Scaffold).first)).lang;
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('nav-rail')),
      matching: find.text(lang == AppLang.tr ? 'Zaman çizelgesi' : 'Timeline'),
    ),
  );
  await settle(tester);
}

void main() {
  testWidgets('nothing yet: each kind says so, never 0; the note says values '
      'are kept as typed with the time Save is pressed', (tester) async {
    await launch(tester);
    for (final k in [
      RecordKind.bloodPressure,
      RecordKind.restingHeartRate,
      RecordKind.waistCircumference,
    ]) {
      expect(
        latestOf(tester, k),
        'Not recorded yet. An empty field is never stored as 0.',
      );
    }
    expect(find.textContaining('with the time you press Save'), findsOneWidget);
    expect(find.text('Save measurement'), findsOneWidget);
  });

  testWidgets('blood pressure, heart rate and waist are saved as typed, '
      'shown with their units and typed decimals, and back after a restart', (
    tester,
  ) async {
    final sink = MemoryLogSink();
    await launch(tester, sink: sink);
    await saveBp(tester, '118', '76');
    expect(find.byKey(const ValueKey('measure-saved')), findsOneWidget);
    expect(latestOf(tester, RecordKind.bloodPressure), '118/76 mmHg');
    await saveScalar(tester, RecordKind.restingHeartRate, '57');
    expect(latestOf(tester, RecordKind.restingHeartRate), '57 bpm');
    await saveScalar(
      tester,
      RecordKind.waistCircumference,
      '84,25',
      context: 'standing, after breakfast',
    );
    expect(latestOf(tester, RecordKind.waistCircumference), '84.25 cm');
    final row = textsUnder(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('measure-row-'),
      ),
    ).join(' | ');
    expect(row, contains('entered as "84,25"'));
    expect(row, contains('note: "standing, after breakfast"'));

    await launch(tester, sink: sink); // restart on the same "file"
    expect(latestOf(tester, RecordKind.bloodPressure), '118/76 mmHg');
    expect(latestOf(tester, RecordKind.restingHeartRate), '57 bpm');
    expect(latestOf(tester, RecordKind.waistCircumference), '84.25 cm');
  });

  testWidgets('errors are shown on their own field and nothing is saved; '
      'a typed 0 and swapped numbers are refused', (tester) async {
    final s = await launch(tester);
    await saveBp(tester, '76', '118');
    expect(
      find.textContaining('must be larger than the lower number'),
      findsOneWidget,
    );
    await saveBp(tester, '118', '');
    expect(find.textContaining('Empty is not saved as 0'), findsOneWidget);
    await saveScalar(tester, RecordKind.restingHeartRate, '0');
    expect(find.textContaining('greater than 0'), findsOneWidget);
    expect(
      await s.heartbeat.repository.records(s.self.id),
      isEmpty,
      reason: 'nothing was written',
    );
  });

  testWidgets('a reading is never judged: no category, stage or range on the '
      'card, the Timeline rows or the detail sheet (EN and TR)', (
    tester,
  ) async {
    for (final locale in [const Locale('en'), const Locale('tr')]) {
      await launch(tester, locale: locale);
      await saveBp(tester, '182', '121');
      await saveScalar(tester, RecordKind.restingHeartRate, '44');
      await saveScalar(tester, RecordKind.waistCircumference, '130');
      final card = textsUnder(
        tester,
        find.byKey(const ValueKey('measurements-card')),
      ).join('\n');
      expect(card, contains('182/121 mmHg'));
      for (final re in [interpretive, judged, measurementJudged]) {
        expect(re.firstMatch(card)?.group(0), isNull, reason: '$locale card');
      }
      await openTimeline(tester);
      final rows = textsUnder(
        tester,
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('timeline-entry-'),
        ),
      ).join('\n');
      expect(rows, contains('182/121 mmHg'));
      for (final re in [interpretive, judged, measurementJudged]) {
        expect(re.firstMatch(rows)?.group(0), isNull, reason: '$locale rows');
      }
      await tester.tap(find.text('182/121 mmHg').first);
      await settle(tester);
      final sheet = textsUnder(
        tester,
        find.byKey(const ValueKey('timeline-detail')),
      ).join('\n');
      // The sheet's fixed explanation ("listed below") is not a value: the
      // comparison words are checked on the version rows only (as in F004).
      for (final re in [interpretive, measurementJudged]) {
        expect(re.firstMatch(sheet)?.group(0), isNull, reason: '$locale sheet');
      }
      final versionRows = textsUnder(
        tester,
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith('version-'),
        ),
      ).join('\n');
      expect(versionRows, contains('182/121 mmHg'));
      expect(
        judged.firstMatch(versionRows)?.group(0),
        isNull,
        reason: '$locale version rows',
      );
    }
  });

  testWidgets('Timeline: correct a blood pressure (two fields, the note kept), '
      'withdraw a heart rate; both versions stay in history', (tester) async {
    final s = await launch(tester);
    await saveBp(tester, '128', '76');
    await saveScalar(tester, RecordKind.restingHeartRate, '57');
    await openTimeline(tester);
    expect(find.text('128/76 mmHg'), findsOneWidget);
    await tester.tap(find.text('128/76 mmHg'));
    await settle(tester);
    final head = (await tester.runAsync(
      () =>
          s.heartbeat.measurementTimeline(s.self.id, RecordKind.bloodPressure),
    ))!.single.heads.single;
    await tapKey(tester, 'action-correct-${head.id}');
    expect(
      find.byKey(const ValueKey('correct-input-systolic')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('correct-input-diastolic')),
      findsOneWidget,
    );
    await fill(tester, 'correct-input-systolic', '118');
    await fill(tester, 'correct-input-diastolic', '76');
    await tapKey(tester, 'correct-save');
    expect(find.text('118/76 mmHg'), findsOneWidget);
    expect(find.text('128/76 mmHg'), findsNothing);
    await tester.tap(find.text('118/76 mmHg'));
    await settle(tester);
    final versions = textsUnder(
      tester,
      find.byKey(const ValueKey('timeline-detail')),
    ).join('\n');
    expect(versions, contains('128/76 mmHg'));
    expect(versions, contains('118/76 mmHg'));
    Navigator.of(tester.element(find.byKey(const ValueKey('timeline-detail'))))
        .pop();
    await settle(tester);

    final hr = (await tester.runAsync(
      () => s.heartbeat.measurementTimeline(
        s.self.id,
        RecordKind.restingHeartRate,
      ),
    ))!.single.heads.single;
    await tester.tap(find.text('57 bpm'));
    await settle(tester);
    await tapKey(tester, 'action-error-${hr.id}');
    await tapKey(tester, 'confirm-entered_in_error');
    expect(find.text('57 bpm'), findsNothing, reason: 'withdrawn');
    final all = await tester.runAsync(
      () => s.heartbeat.repository.records(s.self.id),
    );
    expect(all, hasLength(4), reason: '2 readings, a correction, a marker');
  });

  testWidgets('a heart-rate correction refuses a 0 on its field and keeps '
      'the version unchanged', (tester) async {
    final s = await launch(tester);
    await saveScalar(tester, RecordKind.restingHeartRate, '57');
    await openTimeline(tester);
    await tester.tap(find.text('57 bpm'));
    await settle(tester);
    final head = (await tester.runAsync(
      () => s.heartbeat.measurementTimeline(
        s.self.id,
        RecordKind.restingHeartRate,
      ),
    ))!.single.heads.single;
    await tapKey(tester, 'action-correct-${head.id}');
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('correct-input')))
          .decoration!
          .labelText,
      'Resting heart rate (bpm)',
    );
    await fill(tester, 'correct-input', '0');
    await tapKey(tester, 'correct-save');
    expect(find.textContaining('greater than 0'), findsOneWidget);
    final all = await tester.runAsync(
      () => s.heartbeat.repository.records(s.self.id),
    );
    expect(all, hasLength(1));
  });

  testWidgets('the first measurement in a vault of older records keeps a '
      'backup first and says where', (tester) async {
    final files = MemoryDataFiles();
    final s = await launch(tester, files: files);
    await tester.runAsync(
      () => s.heartbeat.recordWeightKg(profileId: s.self.id, input: '70'),
    );
    await saveScalar(tester, RecordKind.restingHeartRate, '57');
    final saved = tester
        .widget<Text>(find.byKey(const ValueKey('measure-saved')))
        .data!;
    expect(saved, startsWith('Saved. Before this first measurement'));
    expect(saved, contains('memory:backup/'));
    expect(files.files.keys.single, startsWith('backup/'));
    await saveScalar(tester, RecordKind.restingHeartRate, '58');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('measure-saved'))).data,
      'Saved',
      reason: 'only once',
    );
    expect(files.files, hasLength(1));
  });

  testWidgets('accessibility: the card has a header, each latest value is '
      'one spoken summary, the save message is a live region', (tester) async {
    final handle = tester.ensureSemantics();
    await launch(tester);
    await saveBp(tester, '118', '76');
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'^Blood pressure: systolic 118, diastolic 76 millimetres of '
          r'mercury, measured \d{4}-\d{2}-\d{2} \d{2}:\d{2}, Manual entry$',
        ),
      ),
      findsOneWidget,
    );
    final header = tester.getSemantics(find.text('Measurements'));
    expect(header.flagsCollection.isHeader, isTrue);
    final saved = tester.getSemantics(
      find.byKey(const ValueKey('measure-saved')),
    );
    expect(saved.flagsCollection.isLiveRegion, isTrue);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('320 dp wide at 2x text: no overflow (EN and TR)', (
    tester,
  ) async {
    for (final locale in [const Locale('en'), const Locale('tr')]) {
      await launch(
        tester,
        locale: locale,
        size: const Size(320, 4000),
        textScale: 2.0,
      );
      await saveBp(tester, '118', '76');
      expect(tester.takeException(), isNull, reason: '$locale');
    }
  });

  testWidgets('Turkish: labels, unit and errors are Turkish', (tester) async {
    await launch(tester, locale: const Locale('tr'));
    expect(find.text('Ölçümler'), findsOneWidget);
    await saveScalar(tester, RecordKind.restingHeartRate, '57');
    expect(latestOf(tester, RecordKind.restingHeartRate), '57 atım/dk');
    await saveBp(tester, '76', '118');
    expect(find.textContaining('İkisi yer mi değiştirdi?'), findsOneWidget);
  });

  test('every F007 error code has its own text in both languages, never the '
      'generic one', () {
    const codes = [
      'NOT_POSITIVE',
      'VALUE_NOT_POSITIVE',
      'BP_ORDER',
      'TARGET_WRONG_KIND',
      'CONTEXT_TOO_LONG',
      'CHECKPOINT_FAILED',
      'VALUE_NOT_FINITE',
      'UNIT_NOT_SUPPORTED',
      'KIND_NEEDS_NEWER_SCHEMA',
      'FIELD_NEEDS_NEWER_SCHEMA',
      'BP_HAS_NO_QUANTITY',
      'DETAILS_MISMATCH',
      'CONTEXT_NOT_SUPPORTED',
      'CONTEXT_EMPTY',
    ];
    for (final lang in AppLang.values) {
      final s = S(lang);
      final generic = s.inputError('NO_SUCH_CODE_EVER');
      for (final c in codes) {
        expect(s.inputError(c), isNot(generic), reason: '$lang $c');
      }
    }
  });
}
