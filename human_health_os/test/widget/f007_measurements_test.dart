// F007@v0.32 Measurements card and Timeline (slice 1): blood pressure,
// resting heart rate and waist circumference entered by hand, shown as
// typed (118/76 mmHg, 84.25 cm), never as 0 when missing, never judged
// (EN and TR), corrected and withdrawn on the Timeline, saved across a
// restart, and laid out at 320 dp with 2x text.
import 'dart:io';

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
import 'package:human_health_os/src/features/measurements/measurement_format.dart';
import 'package:human_health_os/src/features/today/measurements_card.dart';

import 'package:human_health_os/src/l10n/strings.dart';

import 'f004_labs_test.dart' show interpretive, judged;

/// A place where no backup can be written (a full or read-only disk).
class _FilesThatCannotSave extends MemoryDataFiles {
  @override
  Future<String> save(DataFileKind kind, String fileName, String text) async =>
      throw const FileSystemException('disk full');
}

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
  r'kilolu|'
  // Slice 2: temperature, oxygen, breathing, height.
  r'fever|febrile|afebrile|hypotherm\p{L}*|hypertherm\p{L}*|hypoxi\p{L}*|'
  r'hypoxem\p{L}*|tachypn\p{L}*|bradypn\p{L}*|apn\p{L}*|dyspn\p{L}*|'
  r'desaturat\p{L}*|low|high|warning|alert|critical|consult|doctor|'
  r'healthy|good|poor|short|tall|ateş|ateşli|hipoterm\p{L}*|hiperterm\p{L}*|'
  r'hipoksi\p{L}*|hipoksemi|taşipne|bradipne|apne|dispne|düşük|yüksek|'
  r'uyarı|kritik|anormal|sağlıklı|iyi|kötü|kısa|uzun)(?!\p{L})',
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

/// Opens the entry sheet of [kind] from its tile on Today.
Future<void> openSheet(WidgetTester tester, RecordKind kind) =>
    tapKey(tester, 'measure-tile-${kind.code}');

/// Fills a field under "More details", opening the section first.
Future<void> fillMore(WidgetTester tester, String key, String text) async {
  if (find.byKey(ValueKey(key)).evaluate().isEmpty) {
    await tapKey(tester, 'measure-more');
  }
  await fill(tester, key, text);
}

Future<void> saveBp(
  WidgetTester tester,
  String sys,
  String dia, {
  String when = '',
  String context = '',
}) async {
  await openSheet(tester, RecordKind.bloodPressure);
  await fill(tester, 'measure-systolic', sys);
  await fill(tester, 'measure-diastolic', dia);
  if (when.isNotEmpty) await fillMore(tester, 'measure-when', when);
  if (context.isNotEmpty) await fillMore(tester, 'measure-context', context);
  await tapKey(tester, 'measure-save');
}

Future<void> saveScalar(
  WidgetTester tester,
  RecordKind kind,
  String value, {
  String context = '',
  String when = '',
}) async {
  await openSheet(tester, kind);
  await fill(tester, 'measure-value', value);
  if (when.isNotEmpty) await fillMore(tester, 'measure-when', when);
  if (context.isNotEmpty) await fillMore(tester, 'measure-context', context);
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
    for (final k in MeasurementsCard.kinds) {
      expect(latestOf(tester, k), 'Not recorded yet', reason: k.code);
      expect(find.byKey(ValueKey('measure-tile-${k.code}')), findsOneWidget);
    }
    expect(find.textContaining('never saved as 0'), findsOneWidget);
    expect(find.byKey(const ValueKey('measure-save')), findsNothing);
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
    await openTimeline(tester);
    await tester.tap(find.text('84.25 cm'));
    await settle(tester);
    final row = textsUnder(
      tester,
      find.byKey(const ValueKey('timeline-detail')),
    ).join(' | ');
    expect(row, contains('entered as "84,25"'));
    expect(row, contains('note: "standing, after breakfast"'));
    Navigator.of(tester.element(find.byKey(const ValueKey('timeline-detail'))))
        .pop();
    await settle(tester);

    await launch(tester, sink: sink); // restart on the same "file"
    expect(latestOf(tester, RecordKind.bloodPressure), '118/76 mmHg');
    expect(latestOf(tester, RecordKind.restingHeartRate), '57 bpm');
    expect(latestOf(tester, RecordKind.waistCircumference), '84.25 cm');
  });

  testWidgets('Latest skips a newer "not measured" entry, a withdrawn reading '
      'and a deleted one: the schema-4 fixture shows the last real values', (
    tester,
  ) async {
    // In the fixture the newest heart-rate entry is "not measured" (watch
    // not worn), the 61 before it was entered in error, and the newest
    // waist reading (85) was deleted: Latest is 57 bpm and 84.25 cm, never
    // 0, never a blank that looks like a value.
    final sink = MemoryLogSink()
      ..text = File('test/fixtures/vault/v1_f007_schema4.hhoslog.jsonl')
          .readAsStringSync();
    await launch(tester, sink: sink);
    expect(latestOf(tester, RecordKind.restingHeartRate), '57 bpm');
    expect(latestOf(tester, RecordKind.waistCircumference), '84.25 cm');
    expect(latestOf(tester, RecordKind.bloodPressure), '124/82 mmHg');
    expect(find.textContaining('0 bpm'), findsNothing);
  });

  test('a number is shown with the decimals it was typed with (84.0 stays '
      '84.0, 57,50 is 57.50), never fewer', () {
    expect(fmtMeasured(84, '84.0'), '84.0');
    expect(fmtMeasured(57.5, '57,50'), '57.50');
    expect(fmtMeasured(120, '120,0'), '120.0');
    expect(fmtMeasured(120, '120'), '120');
    expect(fmtMeasured(0.5, '.5'), '0.5', reason: 'not a typed-decimals form');
    expect(fmtMeasured(84.25, null), '84.25');
    expect(fmtMeasured(84, null), '84');
  });

  testWidgets('typed trailing zeros survive on Today for every kind', (
    tester,
  ) async {
    await launch(tester);
    await saveBp(tester, '120,0', '80.0');
    expect(latestOf(tester, RecordKind.bloodPressure), '120.0/80.0 mmHg');
    await saveScalar(tester, RecordKind.restingHeartRate, '57,50');
    expect(latestOf(tester, RecordKind.restingHeartRate), '57.50 bpm');
    await saveScalar(tester, RecordKind.waistCircumference, '84.0');
    expect(latestOf(tester, RecordKind.waistCircumference), '84.0 cm');
    expect(
      find.byKey(const ValueKey('measure-save')),
      findsNothing,
      reason: 'the sheet closes after Save',
    );
    expect(find.byKey(const ValueKey('measure-saved')), findsOneWidget);
  });

  testWidgets('Timeline: a correction starts from the note, can change it, and '
      'the note shows in the version rows', (tester) async {
    final s = await launch(tester);
    await saveScalar(
      tester,
      RecordKind.restingHeartRate,
      '58',
      context: 'after a walk',
    );
    await openTimeline(tester);
    await tester.tap(find.text('58 bpm'));
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
          .widget<TextField>(
            find.byKey(const ValueKey('correct-input-context')),
          )
          .controller!
          .text,
      'after a walk',
    );
    await fill(tester, 'correct-input', '57');
    await fill(tester, 'correct-input-context', 'at rest');
    await tapKey(tester, 'correct-save');
    final now = (await tester.runAsync(
      () => s.heartbeat.measurementTimeline(
        s.self.id,
        RecordKind.restingHeartRate,
      ),
    ))!.single;
    expect(now.heads.single.context, 'at rest');
    expect(now.heads.single.supersedesId, head.id);
    await tester.tap(find.text('57 bpm'));
    await settle(tester);
    final rows = textsUnder(
      tester,
      find.byKey(const ValueKey('timeline-detail')),
    ).join('\n');
    expect(rows, contains('note: "at rest"'));
    expect(rows, contains('note: "after a walk"'));
  });

  testWidgets('a checkpoint that cannot be saved: the card says nothing was '
      'saved, with the checkpoint text, and the reading is not stored', (
    tester,
  ) async {
    final s = await launch(
      tester,
      sink: MemoryLogSink(),
      files: _FilesThatCannotSave(),
    );
    await tester.runAsync(
      () => s.heartbeat.recordWeightKg(profileId: s.self.id, input: '70'),
    );
    await saveScalar(tester, RecordKind.restingHeartRate, '57');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('measure-error'))).data,
      S(AppLang.en).inputError('CHECKPOINT_FAILED'),
    );
    expect(find.byKey(const ValueKey('measure-saved')), findsNothing);
    expect(latestOf(tester, RecordKind.restingHeartRate), startsWith('Not'));
    expect(
      (await tester.runAsync(
        () => s.heartbeat.measurementTimeline(
          s.self.id,
          RecordKind.restingHeartRate,
        ),
      ))!,
      isEmpty,
    );
  });

  test('error texts, the empty state, the checkpoint text and the notes '
      'judge nothing in either language', () {
    const codes = [
      'EMPTY',
      'NOT_POSITIVE',
      'VALUE_NOT_POSITIVE',
      'NOT_A_NUMBER',
      'AMBIGUOUS_SEPARATOR',
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
      'SAVE_FAILED',
    ];
    for (final lang in AppLang.values) {
      final s = S(lang);
      final texts = [
        for (final c in codes) s.inputError(c),
        s.measurementNotYet,
        s.measurementsNote,
        s.checkpointSaved('/somewhere/backup.json'),
        s.measurementsTitle,
        s.measurementKind,
        s.systolicField,
        s.diastolicField,
        s.contextField,
        s.saveMeasurement,
        for (final k in MeasurementsCard.kinds) s.recordKind(k),
      ];
      for (final t in texts) {
        for (final re in [interpretive, measurementJudged]) {
          expect(re.firstMatch(t)?.group(0), isNull, reason: '$lang "$t"');
        }
      }
    }
  });

  testWidgets('a back-dated height: the tile shows the measured time and says '
      'when it was saved; the spoken label says both; Latest is the newest '
      'observation, not the newest save', (tester) async {
    final handle = tester.ensureSemantics();
    await launch(tester);
    await saveScalar(
      tester,
      RecordKind.height,
      '172',
      when: '2026-10-01 08:00Z',
    );
    expect(latestOf(tester, RecordKind.height), '172 cm');
    final tile = textsUnder(
      tester,
      find.byKey(const ValueKey('measure-tile-body.height')),
    ).join(' | ');
    expect(tile, contains('saved 2'));
    expect(
      find.bySemanticsLabel(
        RegExp(
          r'^Height: 172 centimetres, measured \d{4}-\d{2}-\d{2} \d{2}:\d{2}, '
          r'saved \d{4}-\d{2}-\d{2} \d{2}:\d{2}, Manual entry\. Add a '
          r'measurement$',
        ),
      ),
      findsOneWidget,
    );
    await saveScalar(
      tester,
      RecordKind.height,
      '171',
      when: '2026-09-01 08:00Z',
    );
    expect(
      latestOf(tester, RecordKind.height),
      '172 cm',
      reason: 'the older observation saved later is not Latest',
    );
    await openTimeline(tester);
    expect(find.text('172 cm'), findsOneWidget);
    expect(find.text('171 cm'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a time error opens "More details" and shows on the When '
      'field; the new kinds have their own fields and hints', (tester) async {
    await launch(tester);
    await openSheet(tester, RecordKind.bodyTemperature);
    expect(find.text('Body temperature (°C)'), findsOneWidget);
    expect(find.textContaining('where you measured'), findsOneWidget);
    await fill(tester, 'measure-value', '36,8');
    expect(find.byKey(const ValueKey('measure-when')), findsNothing);
    await tester.enterText(find.byKey(const ValueKey('measure-value')), '');
    await fill(tester, 'measure-value', '36,8');
    await tapKey(tester, 'measure-more');
    await fill(tester, 'measure-when', '31 December');
    await tapKey(tester, 'measure-save');
    expect(find.textContaining('Write the time as'), findsOneWidget);
    await fill(tester, 'measure-when', '2099-01-01 00:00Z');
    await tapKey(tester, 'measure-save');
    expect(find.textContaining('in the future'), findsOneWidget);
    await tapKey(tester, 'measure-cancel');
    expect(latestOf(tester, RecordKind.bodyTemperature), 'Not recorded yet');
    await openSheet(tester, RecordKind.oxygenSaturation);
    expect(find.textContaining('pulse oximeter'), findsOneWidget);
    await tapKey(tester, 'measure-cancel');
    await openSheet(tester, RecordKind.height);
    expect(find.textContaining('new entry'), findsOneWidget);
  });

  test('every string of the new kinds, hints and time errors judges nothing '
      'in either language', () {
    const codes = [
      'OUT_OF_DEFINITION',
      'TIME_FORMAT',
      'TIME_TOO_OLD',
      'TIME_DOES_NOT_EXIST',
      'TIME_AMBIGUOUS',
      'FUTURE_TIME',
    ];
    for (final lang in AppLang.values) {
      final s = S(lang);
      final texts = [
        for (final c in codes) s.inputError(c),
        for (final k in MeasurementsCard.kinds) ...[
          s.recordKind(k),
          s.measurementField(k),
          s.measurementHint(k) ?? '',
        ],
        s.whenField,
        s.whenHint,
        s.addMeasurement,
        s.moreDetails,
        s.savedAtLabel('2026-10-01 08:00'),
        s.measuredAtLabel('2026-10-01 08:00'),
        s.spokenLatest('Height', '172 cm', 'a', 'b', saved: 'c'),
      ];
      for (final t in texts) {
        for (final re in [interpretive, measurementJudged]) {
          expect(re.firstMatch(t)?.group(0), isNull, reason: '$lang "$t"');
        }
      }
    }
    expect(
      S(AppLang.tr).recordKind(RecordKind.bodyTemperature),
      'Vücut sıcaklığı',
    );
    expect(
      S(AppLang.tr).recordKind(RecordKind.bodyTemperature).toLowerCase(),
      isNot(contains('ateş')),
    );
  });

  testWidgets('errors are shown on their own field and nothing is saved; '
      'a typed 0, swapped numbers and a bad time are refused', (tester) async {
    final s = await launch(tester);
    await openSheet(tester, RecordKind.bloodPressure);
    await fill(tester, 'measure-systolic', '76');
    await fill(tester, 'measure-diastolic', '118');
    await tapKey(tester, 'measure-save');
    expect(
      find.textContaining('must be larger than the lower number'),
      findsOneWidget,
    );
    await fill(tester, 'measure-systolic', '118');
    await fill(tester, 'measure-diastolic', '');
    await tapKey(tester, 'measure-save');
    expect(find.textContaining('Empty is not saved as 0'), findsOneWidget);
    await fill(tester, 'measure-diastolic', '76');
    await fillMore(tester, 'measure-when', 'yesterday');
    await tapKey(tester, 'measure-save');
    expect(find.textContaining('Write the time as'), findsOneWidget);
    await tapKey(tester, 'measure-cancel');
    await saveScalar(tester, RecordKind.restingHeartRate, '0');
    expect(find.textContaining('greater than 0'), findsOneWidget);
    await tapKey(tester, 'measure-cancel');
    await saveScalar(tester, RecordKind.oxygenSaturation, '101');
    expect(find.textContaining('cannot be above 100'), findsOneWidget);
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
      await tester.pumpWidget(const SizedBox());
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

  testWidgets('a waist typed with more than 20 decimals is shown as typed and '
      'does not break the card or the Timeline (also after a restart)', (
    tester,
  ) async {
    final sink = MemoryLogSink();
    await launch(tester, sink: sink);
    await saveScalar(
      tester,
      RecordKind.waistCircumference,
      '0.1234567890123456789012',
    );
    expect(find.byKey(const ValueKey('measurements-card')), findsOneWidget);
    expect(
      latestOf(tester, RecordKind.waistCircumference),
      '0.1234567890123456789012 cm',
    );
    await tester.pumpWidget(const SizedBox());
    await launch(tester, sink: sink);
    expect(
      find.byKey(
        ValueKey('measure-tile-${RecordKind.waistCircumference.code}'),
      ),
      findsOneWidget,
    );
    await openTimeline(tester);
    expect(find.text('0.1234567890123456789012 cm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a sheet starts empty for each kind and Cancel keeps nothing; '
      'a save error is announced to a screen reader', (tester) async {
    final s = await launch(
      tester,
      sink: MemoryLogSink(),
      files: _FilesThatCannotSave(),
    );
    await openSheet(tester, RecordKind.restingHeartRate);
    await fill(tester, 'measure-value', '57');
    await fillMore(tester, 'measure-context', 'after a walk');
    await tapKey(tester, 'measure-cancel');
    expect(find.byKey(const ValueKey('measure-save')), findsNothing);
    await openSheet(tester, RecordKind.waistCircumference);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('measure-value')))
          .controller!
          .text,
      isEmpty,
    );
    await tapKey(tester, 'measure-more');
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('measure-context')))
          .controller!
          .text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('measure-when')))
          .controller!
          .text,
      isEmpty,
      reason: 'a time is never pre-filled',
    );
    await tapKey(tester, 'measure-cancel');
    // A refused save (no backup can be made) is a live region.
    await tester.runAsync(
      () => s.heartbeat.recordWeightKg(profileId: s.self.id, input: '70'),
    );
    await saveScalar(tester, RecordKind.restingHeartRate, '57');
    final error = find.byKey(const ValueKey('measure-error'));
    expect(error, findsOneWidget);
    expect(
      find.ancestor(
        of: error,
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.liveRegion == true,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Timeline: a correction can be cancelled and the three buttons '
      'come back', (tester) async {
    final s = await launch(tester);
    await saveBp(tester, '128', '76');
    await openTimeline(tester);
    await tester.tap(find.text('128/76 mmHg'));
    await settle(tester);
    final head = (await tester.runAsync(
      () =>
          s.heartbeat.measurementTimeline(s.self.id, RecordKind.bloodPressure),
    ))!.single.heads.single;
    await tapKey(tester, 'action-correct-${head.id}');
    expect(find.byKey(const ValueKey('correct-cancel')), findsOneWidget);
    expect(find.byKey(ValueKey('action-correct-${head.id}')), findsNothing);
    await tapKey(tester, 'correct-cancel');
    expect(find.byKey(const ValueKey('correct-save')), findsNothing);
    expect(find.byKey(ValueKey('action-correct-${head.id}')), findsOneWidget);
    expect(
      (await tester.runAsync(
        () => s.heartbeat.measurementTimeline(
          s.self.id,
          RecordKind.bloodPressure,
        ),
      ))!.single.versions,
      hasLength(1),
      reason: 'cancel writes nothing',
    );
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
    expect(saved, startsWith('Saved. Before saving this entry'));
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
          r'mercury, measured \d{4}-\d{2}-\d{2} \d{2}:\d{2}, Manual entry\. '
          r'Add a measurement$',
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
