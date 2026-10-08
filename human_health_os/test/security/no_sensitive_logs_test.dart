// F006@v0.32 AC-7, master §37 (exit "sensitive-data logging tests"):
// redaction lives in one place, and synthetic sensitive strings (a
// passphrase, a recovery key, values, an analyte, a laboratory, a path)
// never reach console output, log lines or error screens, whatever the
// flow or failure.
import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/app/bootstrap.dart';
import 'package:human_health_os/src/app/human_os_app.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/config/app_config.dart';
import 'package:human_health_os/src/core/capabilities.dart';
import 'package:human_health_os/src/core/redact.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/crypto/recovery_key.dart';
import 'package:human_health_os/src/data/crypto/vault_crypto.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/vault_envelope.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const passphrase = 'Synthetic Pass-Phrase 7 Ağaç!';
const analyte = 'Açlık kan şekeri (synthetic)';
const laboratory = 'Örnek Lab Synthetic';
const value = '92,4';
const path = '/home/synthetic-user/.local/share/human-health-os';
const note = 'Synthetic posture note';
final recovery = newRecoveryKey();

List<String> get sensitive => [
  passphrase,
  analyte,
  'Açlık',
  laboratory,
  value,
  '92.4',
  '73,6',
  '73.6',
  path,
  'synthetic-user',
  recovery,
  recovery.replaceAll('-', ''),
  // F007 measurements: kind codes, a note and typed values. Only strings
  // that cannot occur by chance in base64 ciphertext ("." "_" ",").
  note,
  '84,75',
  'vital.blood_pressure',
  'vital.resting_heart_rate',
  'body.waist_circumference',
  'systolic_text',
];

KdfParams cheap() =>
    KdfParams(salt: randomBytes(16), memoryKib: 64, iterations: 1);

/// Runs [body] while capturing every `print` and `debugPrint`.
Future<String> captured(Future<void> Function() body) async {
  final out = StringBuffer();
  final previous = debugPrint;
  debugPrint = (String? m, {int? wrapWidth}) => out.writeln(m);
  try {
    await runZoned(
      body,
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => out.writeln(line),
      ),
    );
  } finally {
    debugPrint = previous;
  }
  return out.toString();
}

void expectClean(String text, {String where = 'output'}) {
  for (final s in sensitive) {
    expect(text, isNot(contains(s)), reason: '$where leaks "$s"');
  }
}

Iterable<File> dartFiles(String dir) =>
    Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('only core/redact.dart writes to the console', () {
    final writers = RegExp(
      r'(^|[^A-Za-z_.])(print|debugPrint\w*)\s*\(|'
      r'\bstd(out|err)\.(write|add)|\bdeveloper\.log\s*\(|'
      r'''import\s+['"]dart:developer['"]|'''
      r'\b(presentError|dumpErrorToConsole)\s*\(|'
      r'\bZone\.current\.print\s*\(',
      multiLine: true,
    );
    final offenders = [
      for (final f in dartFiles('lib'))
        if (!f.path.endsWith('core/redact.dart') &&
            writers.hasMatch(
              f
                  .readAsStringSync()
                  .split('\n')
                  .where((l) => !l.trimLeft().startsWith('//'))
                  .join('\n'),
            ))
          f.path,
    ];
    expect(offenders, isEmpty);
    // The guard itself catches the forms it claims to.
    for (final sample in [
      "print('x');",
      'debugPrint(x);',
      'debugPrintThrottled(x);',
      'debugPrintSynchronously(x);',
      'debugPrintStack(stackTrace: s);',
      'stderr.write(x);',
      "  developer.log('x');",
      "import 'dart:developer';",
      'import "dart:developer" as dev;',
      'FlutterError.presentError(details);',
      'FlutterError.dumpErrorToConsole(details);',
      "Zone.current.print('x');",
    ]) {
      expect(writers.hasMatch(sample), isTrue, reason: sample);
    }
  });

  test('an error is shown as its type and code, never its message', () {
    final cases = <Object, String>{
      VaultFormatError('RECORD_SCHEMA_NEWER', 'record $analyte at $path'):
          'VaultFormatError(RECORD_SCHEMA_NEWER)',
      BackupError('RESTORE_TARGET_HAS_RECORDS', 'holds $value records'):
          'BackupError(RESTORE_TARGET_HAS_RECORDS)',
      const CryptoFailure('NOT_AUTHENTIC'): 'CryptoFailure(NOT_AUTHENTIC)',
      const VaultEnvelopeError('ENVELOPE_NEWER'):
          'VaultEnvelopeError(ENVELOPE_NEWER)',
      const RecoveryKeyFormatError():
          'RecoveryKeyFormatError(RECOVERY_KEY_FORMAT)',
      const InputError('AMBIGUOUS_SEPARATOR'):
          'InputError(AMBIGUOUS_SEPARATOR)',
      const StorageWriteRefused('RESTART_REQUIRED'):
          'StorageWriteRefused(RESTART_REQUIRED)',
      RecordValidationError('UNIT_REQUIRED', '$analyte $value'):
          'RecordValidationError(UNIT_REQUIRED)',
      FormatException('{"analyte":"$analyte","value":$value}'):
          'FormatException',
      StateError('passphrase was $passphrase'): 'StateError',
      FileSystemException('cannot open', path): 'FileSystemException',
      'a bare string with $passphrase': 'String',
    };
    for (final e in cases.entries) {
      expect(describeError(e.key), e.value);
    }
    // A "code" that is not code-like is not trusted either.
    expect(describeError(const InputError('Açlık 92,4')), 'InputError');
  });

  test('log events keep safe fields only', () {
    final line = formatEvent(
      'restore_failed',
      error: BackupError('DIGEST_MISMATCH', 'payload $value'),
      fields: {
        'records': 3,
        'ok': false,
        'kind': LoadWarningKind.entryMissing,
        'step': 'switch_vault',
        'analyte': analyte,
        'secret': passphrase,
        'where': path,
        'value': value,
        'dotted': '92.4',
        'key': recovery,
        'key_compact': recovery.replaceAll('-', ''),
        'record': '00000000-0000-4000-8000-0000000000a1',
        'code': 'VAULT_NEWER',
      },
    );
    expect(
      line,
      '[hhos] restore_failed error=BackupError(DIGEST_MISMATCH) records=3 '
      'ok=false kind=entryMissing step=switch_vault analyte=<redacted> '
      'secret=<redacted> where=<redacted> value=<redacted> '
      'dotted=<redacted> key=<redacted> key_compact=<redacted> '
      'record=<redacted> code=<redacted>',
    );
  });

  test('framework and uncaught errors are reported redacted', () async {
    final previousFlutter = FlutterError.onError;
    final out = await captured(() async {
      final dispatcher = PlatformDispatcher.instance;
      final previousPlatform = dispatcher.onError;
      installRedactedErrorReporting();
      try {
        expect(FlutterError.onError, same(reportFlutterError));
        // Uncaught asynchronous errors go through the same redaction.
        expect(dispatcher.onError, same(reportUncaughtError));
        expect(
          dispatcher.onError!(
            FileSystemException('cannot write $analyte', path),
            StackTrace.current,
          ),
          isTrue,
        );
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FormatException('$analyte: $value mg/dL'),
            library: 'widgets library',
            context: ErrorDescription('while showing $laboratory'),
          ),
        );
        // The default library name is a constant, kept readable.
        FlutterError.reportError(
          FlutterErrorDetails(exception: StateError('$analyte $value')),
        );
      } finally {
        FlutterError.onError = previousFlutter;
        dispatcher.onError = previousPlatform;
      }
      expect(
        reportUncaughtError(
          StateError('unlock with $passphrase / $recovery'),
          StackTrace.current,
        ),
        isTrue,
      );
    });
    expect(out, contains('[hhos] ui_error error=FormatException'));
    expect(out, contains('library=widgets_library'));
    expect(
      out,
      contains('[hhos] ui_error error=StateError library=flutter_framework'),
    );
    expect(out, contains('[hhos] uncaught_error error=StateError'));
    expect(out, contains('[hhos] uncaught_error error=FileSystemException'));
    expectClean(out);
  });

  test('vault, records, wrong keys, tampering, backups and refused '
      'restores print nothing sensitive', () async {
    final raw = MemoryLogSink();
    EncryptedVault vault() =>
        EncryptedVault(raw: raw, location: path, newKdf: cheap);
    final out = await captured(() async {
      final o = await vault().create(
        passphrase: passphrase,
        recoveryKey: recovery,
      );
      final svc = HeartbeatService(o.repository);
      final me = (await svc.ensureSelfProfile()).id;
      await svc.recordWeightKg(profileId: me, input: '73,6');
      await svc.recordLab(
        profileId: me,
        input: const LabInput(
          analyte: analyte,
          value: value,
          notReported: false,
          unit: 'mg/dL',
          sampleDate: '2026-10-03',
          laboratory: laboratory,
        ),
      );
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.bloodPressure,
        input: const MeasurementInput(
          systolic: '131',
          diastolic: '87',
          context: note,
        ),
      );
      await svc.recordMeasurement(
        profileId: me,
        kind: RecordKind.waistCircumference,
        input: const MeasurementInput(value: '84,75'),
      );
      final errors = <Object>[];
      Future<void> fails(Future<Object?> Function() f) async {
        try {
          await f();
        } catch (e) {
          errors.add(e);
          logEvent('step_failed', error: e);
        }
      }

      await fails(() => vault().unlock('$passphrase?'));
      await fails(
        () => vault().recover(recoveryKey: 'nope', newPassphrase: passphrase),
      );
      await fails(
        () => svc.recordLab(
          profileId: me,
          input: const LabInput(
            analyte: analyte,
            value: '1.000',
            notReported: false,
            unit: 'mg/dL',
            sampleDate: '2026-10-03',
          ),
        ),
      );
      await fails(
        () => svc.recordMeasurement(
          profileId: me,
          kind: RecordKind.bloodPressure,
          input: const MeasurementInput(
            systolic: '87',
            diastolic: '131',
            context: note,
          ),
        ),
      );
      final both = await o.sink.readBoth();
      final bundle = createEncryptedBackupBundle(
        envelopeText: both.raw,
        innerLogText: both.opened.inner,
        appVersion: 't',
        sourceRevision: 't',
        createdAt: DateTime.utc(2026, 10, 7),
      );
      expectClean(bundle, where: 'the backup');
      expectClean(raw.text!, where: 'the vault file');
      await fails(
        () => unlockStagedRestore(
          stageRestore(bundle),
          'not it at all',
          kind: KeyKind.passphrase,
        ),
      );
      // Tamper with a record entry (line 4), reopen, look at the report.
      final ls = raw.text!.split('\n');
      ls[3] = ls[3].replaceFirst('"c":"', '"c":"AAAA');
      raw.text = ls.join('\n');
      final again = await vault().unlock(passphrase);
      for (final w in again.report.warnings) {
        logEvent('load_warning', fields: {'kind': w.kind, 'line': w.line});
      }
      expect(errors.length, 5);
      for (final e in errors) {
        expectClean(describeError(e), where: '$e');
      }
    });
    expect(
      out,
      contains('[hhos] step_failed error=CryptoFailure(NOT_AUTHENTIC)'),
    );
    expect(out, contains('[hhos] load_warning kind=entryUnreadable'));
    expect(out, contains('[hhos] step_failed error=InputError(BP_ORDER)'));
    expectClean(out);
  });

  testWidgets('a failing vault store: the gate and the log show only the '
      'error type', (tester) async {
    final gate = VaultGate(
      vault: EncryptedVault(
        raw: _ThrowingSink(),
        location: path,
        newKdf: cheap,
      ),
      inspection: const VaultInspection(VaultAccess.create),
      open: (o) => servicesFor(
        const AppConfig(
          profile: BuildProfile.production,
          version: 't',
          sourceRevision: 't',
        ),
        HostPlatform.linux,
        o.repository,
      ),
      memoryOnly: (reason, {detail}) => throw UnimplementedError(),
    );
    final lines = <String>[];
    final previous = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => lines.add('$m');
    try {
      await _failCreate(tester, gate);
    } finally {
      debugPrint = previous;
    }
    final error = tester
        .widget<Text>(find.byKey(const ValueKey('gate-error')))
        .data!;
    expect(
      error,
      'Something went wrong (FileSystemException). Nothing was changed.',
    );
    expectClean(error, where: 'the gate');
    expectClean(lines.join('\n'), where: 'the log');
    expect(
      lines.join('\n'),
      contains('vault_create_failed error=FileSystemException'),
    );
  });
}

Future<void> _failCreate(WidgetTester tester, VaultGate gate) async {
  await tester.pumpWidget(HumanOsApp(gate: gate));
  await tester.enterText(
    find.byKey(const ValueKey('gate-passphrase')),
    passphrase,
  );
  await tester.enterText(
    find.byKey(const ValueKey('gate-passphrase-confirm')),
    passphrase,
  );
  await tester.tap(find.byKey(const ValueKey('gate-continue')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('gate-key-written')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('gate-create-vault')));
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

/// A store whose writes fail with a message full of data.
class _ThrowingSink implements LogSink {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> create(String text) async =>
      throw FileSystemException('cannot write $passphrase $analyte', path);

  @override
  Future<void> appendLine(String line) async =>
      throw FileSystemException('cannot write $line', path);
}
