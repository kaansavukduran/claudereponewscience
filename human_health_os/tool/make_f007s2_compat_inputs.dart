// Writes the inputs of the F007 slice 2 old-code check (AC-10) with this
// build's own code: schema-5 backups, vaults where slice 2 saved only what
// slice 1 could read, and the checkpoint backup slice 2 keeps before its
// first schema-5 record. The check itself runs on an older revision
// (tools/compat/old_code_check.sh <revision> f007s2).
// Run from human_health_os/:
//   dart run tool/make_f007s2_compat_inputs.dart <out-dir>
// Synthetic data only; the passphrases are the published fixture secrets.
import 'dart:convert';
import 'dart:io';

import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/data/backup/backup_bundle.dart';
import 'package:human_health_os/src/data/local/encrypted_vault.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/vault_envelope.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const fixturePassphrase = 'fixture passphrase F006 (synthetic)';
const fixtureRecoveryKey = 'K7QM-2XRA-PLMN-B3DE-ZZ4H-QW5T-RT6Y-HJ7U';
final createdAt = DateTime.utc(2026, 11, 7, 12);

const bp = MeasurementInput(systolic: '118', diastolic: '76');
const height = MeasurementInput(value: '172', when: '2026-11-01 08:00Z');

String bundleOf(String log) => createBackupBundle(
  vaultLogText: log,
  appVersion: 'f007s2-compat',
  sourceRevision: 'f007s2-compat',
  createdAt: createdAt,
);

Future<void> main(List<String> args) async {
  final out = Directory(args.single)..createSync(recursive: true);
  File file(String name) => File('${out.path}/$name');
  const fixtures = 'test/fixtures/vault';

  // 1. The committed schema-5 fixtures, and backups of them made here.
  final plain = File('$fixtures/v1_f007s2_schema5.hhoslog.jsonl')
      .readAsStringSync();
  final envelope = File('$fixtures/enc_v1_f007s2.hhosvault').readAsStringSync();
  file('v1_f007s2_schema5.hhoslog.jsonl').writeAsStringSync(plain);
  file('enc_v1_f007s2.hhosvault').writeAsStringSync(envelope);
  file('f007s2_plain_backup.hhosbackup.json')
      .writeAsStringSync(bundleOf(plain));
  final sealed = await EncryptedLogSink.unlock(
    MemoryLogSink()..text = envelope,
    fixturePassphrase,
    kind: KeyKind.passphrase,
    derive: deriveInline,
  );
  file('f007s2_enc_backup.hhosbackup.json').writeAsStringSync(
    createEncryptedBackupBundle(
      envelopeText: envelope,
      innerLogText: (await sealed.read())!,
      appVersion: 'f007s2-compat',
      sourceRevision: 'f007s2-compat',
      createdAt: createdAt,
    ),
  );

  // 2. A development vault with a weight and a blood pressure (what slice 1
  // reads), then the same vault after a height, with the checkpoint.
  // Memory sinks: the file adapter imports Flutter, which `dart run` cannot
  // load; the stored text is written out as files.
  final dev = MemoryLogSink();
  final repo = LogRepository(
    sink: dev,
    durability: StorageDurability.localFile,
    location: 'f007s2-compat',
  );
  await repo.open();
  final svc = HeartbeatService(repo);
  final me = (await svc.ensureSelfProfile()).id;
  final weight = await svc.recordWeightKg(profileId: me, input: '79,4');
  final pressure = await svc.recordMeasurement(
    profileId: me,
    kind: RecordKind.bloodPressure,
    input: bp,
  );
  file('f007s2_before_height.hhoslog.jsonl').writeAsStringSync(dev.text!);
  file('f007s2_before_height.records.json')
      .writeAsStringSync(jsonEncode([weight.toJson(), pressure.toJson()]));
  var checkpoints = 0;
  repo.beforeSchemaUpgrade = () async {
    checkpoints++;
    file('f007s2_checkpoint.hhosbackup.json')
        .writeAsStringSync(bundleOf((await repo.sink.read())!));
  };
  await svc.recordMeasurement(
    profileId: me,
    kind: RecordKind.height,
    input: height,
  );
  if (checkpoints != 1) throw StateError('checkpoint not kept ($checkpoints)');
  file('f007s2_after_height.hhoslog.jsonl').writeAsStringSync(dev.text!);

  // 3. The same in an encrypted vault (production key cost).
  final enc = MemoryLogSink();
  final opened = await EncryptedVault(
    raw: enc,
    location: 'f007s2-compat',
  ).create(passphrase: fixturePassphrase, recoveryKey: fixtureRecoveryKey);
  final esvc = HeartbeatService(opened.repository);
  final eme = (await esvc.ensureSelfProfile()).id;
  final eweight = await esvc.recordWeightKg(profileId: eme, input: '74,2');
  final epressure = await esvc.recordMeasurement(
    profileId: eme,
    kind: RecordKind.bloodPressure,
    input: bp,
  );
  file('enc_f007s2_before_height.hhosvault').writeAsStringSync(enc.text!);
  file('enc_f007s2_before_height.records.json')
      .writeAsStringSync(jsonEncode([eweight.toJson(), epressure.toJson()]));
  opened.repository.beforeSchemaUpgrade = () async {
    checkpoints++;
    final both = await opened.sink.readBoth();
    file('enc_f007s2_checkpoint.hhosbackup.json').writeAsStringSync(
      createEncryptedBackupBundle(
        envelopeText: both.raw,
        innerLogText: both.opened.inner,
        appVersion: 'f007s2-compat',
        sourceRevision: 'f007s2-compat',
        createdAt: createdAt,
      ),
    );
  };
  await esvc.recordMeasurement(
    profileId: eme,
    kind: RecordKind.height,
    input: height,
  );
  if (checkpoints != 2) throw StateError('checkpoint not kept ($checkpoints)');
  file('enc_f007s2_after_height.hhosvault').writeAsStringSync(enc.text!);
  stdout.writeln('wrote the F007 slice 2 compatibility inputs to ${out.path}');
}
