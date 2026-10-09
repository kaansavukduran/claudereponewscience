// Writes the inputs of the F007 old-code check (AC-10) with this build's
// own code: F007 backups, vaults where F007 saved only weight, and the
// checkpoint backups F007 keeps before its first measurement. The check
// itself runs on an older revision (tools/compat/old_code_check.sh).
// Run from human_health_os/:
//   dart run tool/make_f007_compat_inputs.dart <out-dir>
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
final createdAt = DateTime.utc(2026, 10, 9, 12);

const bp = MeasurementInput(systolic: '118', diastolic: '76');

Future<void> main(List<String> args) async {
  final out = Directory(args.single)..createSync(recursive: true);
  File file(String name) => File('${out.path}/$name');
  const fixtures = 'test/fixtures/vault';

  // 1. The committed schema-4 fixtures, and backups of them made by F007.
  final plain = File('$fixtures/v1_f007_schema4.hhoslog.jsonl')
      .readAsStringSync();
  final envelope = File('$fixtures/enc_v1_f007.hhosvault').readAsStringSync();
  file('v1_f007_schema4.hhoslog.jsonl').writeAsStringSync(plain);
  file('enc_v1_f007.hhosvault').writeAsStringSync(envelope);
  file('f007_plain_backup.hhosbackup.json').writeAsStringSync(
    createBackupBundle(
      vaultLogText: plain,
      appVersion: 'f007-compat',
      sourceRevision: 'f007-compat',
      createdAt: createdAt,
    ),
  );
  final sealed = await EncryptedLogSink.unlock(
    MemoryLogSink()..text = envelope,
    fixturePassphrase,
    kind: KeyKind.passphrase,
    derive: deriveInline,
  );
  file('f007_enc_backup.hhosbackup.json').writeAsStringSync(
    createEncryptedBackupBundle(
      envelopeText: envelope,
      innerLogText: (await sealed.read())!,
      appVersion: 'f007-compat',
      sourceRevision: 'f007-compat',
      createdAt: createdAt,
    ),
  );

  // 2. A development vault where F007 saved weight and a lab result only,
  // then the same vault after a measurement, with the checkpoint F007 kept.
  // Memory sinks: the stored text is written out as files below (the file
  // adapter imports Flutter, which `dart run` cannot load).
  final dev = MemoryLogSink();
  final repo = LogRepository(
    sink: dev,
    durability: StorageDurability.localFile,
    location: 'f007-compat',
  );
  await repo.open();
  final svc = HeartbeatService(repo);
  final me = (await svc.ensureSelfProfile()).id;
  final weight = await svc.recordWeightKg(profileId: me, input: '79,4');
  final lab = await svc.recordLab(
    profileId: me,
    input: const LabInput(
      analyte: 'LDL Kolesterol',
      value: '142',
      notReported: false,
      unit: 'mg/dL',
      sampleDate: '2026-10-03',
      sourceFlag: 'H',
    ),
  );
  file('f007_weight_only.hhoslog.jsonl').writeAsStringSync(dev.text!);
  file('f007_weight_only.records.json')
      .writeAsStringSync(jsonEncode([weight.toJson(), lab.toJson()]));
  var checkpoints = 0;
  repo.beforeSchemaUpgrade = () async {
    checkpoints++;
    file('f007_checkpoint.hhosbackup.json').writeAsStringSync(
      createBackupBundle(
        vaultLogText: (await repo.sink.read())!,
        appVersion: 'f007-compat',
        sourceRevision: 'f007-compat',
        createdAt: createdAt,
      ),
    );
  };
  await svc.recordMeasurement(
    profileId: me,
    kind: RecordKind.bloodPressure,
    input: bp,
  );
  if (checkpoints != 1) throw StateError('checkpoint not kept ($checkpoints)');
  file('f007_after_measurement.hhoslog.jsonl').writeAsStringSync(dev.text!);

  // 3. The same in an encrypted vault (production key cost).
  final enc = MemoryLogSink();
  final opened = await EncryptedVault(
    raw: enc,
    location: 'f007-compat',
  ).create(passphrase: fixturePassphrase, recoveryKey: fixtureRecoveryKey);
  final esvc = HeartbeatService(opened.repository);
  final eme = (await esvc.ensureSelfProfile()).id;
  final eweight = await esvc.recordWeightKg(profileId: eme, input: '74,2');
  file('enc_f007_weight_only.hhosvault').writeAsStringSync(enc.text!);
  file('enc_f007_weight_only.records.json')
      .writeAsStringSync(jsonEncode([eweight.toJson()]));
  opened.repository.beforeSchemaUpgrade = () async {
    checkpoints++;
    final both = await opened.sink.readBoth();
    file('enc_f007_checkpoint.hhosbackup.json').writeAsStringSync(
      createEncryptedBackupBundle(
        envelopeText: both.raw,
        innerLogText: both.opened.inner,
        appVersion: 'f007-compat',
        sourceRevision: 'f007-compat',
        createdAt: createdAt,
      ),
    );
  };
  await esvc.recordMeasurement(
    profileId: eme,
    kind: RecordKind.bloodPressure,
    input: bp,
  );
  if (checkpoints != 2) throw StateError('checkpoint not kept ($checkpoints)');
  file('enc_f007_after_measurement.hhosvault').writeAsStringSync(enc.text!);
  stdout.writeln('wrote the F007 compatibility inputs to ${out.path}');
}
