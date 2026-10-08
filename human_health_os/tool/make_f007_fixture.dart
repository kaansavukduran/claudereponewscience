// Writes the record schema 4 fixture (F007) with the app's own writer:
// every line is `encodeOp(...)` of a record built the way the F007 build
// builds it. Run from human_health_os/:
//   dart run tool/make_f007_fixture.dart test/fixtures/vault/v1_f007_schema4.hhoslog.jsonl
// Synthetic data only. A committed fixture is never regenerated or edited.
import 'dart:io';

import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/profile/profile.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const profileId = '00000000-0000-4000-8000-0000000000a1';
String id(int n) => '00000000-0000-4000-8000-0000000000e${n.toRadixString(16)}';
DateTime at(int minute, [int second = 0]) =>
    DateTime.utc(2026, 10, 7, 6, minute, second);

HealthRecord measurement(
  int n,
  RecordKind kind, {
  Quantity? q,
  String? text,
  BloodPressureDetails? bp,
  String? context,
  ValueStatus status = ValueStatus.present,
  required DateTime observed,
  DateTime? recorded,
  String? supersedes,
}) => HealthRecord(
  id: id(n),
  profileId: profileId,
  kind: kind,
  state: RecordState.observed,
  valueStatus: status,
  quantity: q,
  originalText: text,
  provenance: const Provenance.manual(),
  observedAt: observed,
  recordedAt: recorded ?? observed,
  supersedesId: supersedes,
  amendReason: supersedes == null ? null : AmendReason.correction,
  context: context,
  details: bp,
  schemaVersion: HealthRecord.writeSchemaFor(kind),
);

HealthRecord marker(
  int n,
  HealthRecord target,
  AmendReason reason,
  DateTime t,
) => HealthRecord(
  id: id(n),
  profileId: profileId,
  kind: target.kind,
  state: RecordState.reported,
  valueStatus: ValueStatus.notApplicable,
  quantity: null,
  originalText: null,
  provenance: const Provenance.manual(),
  observedAt: target.observedAt,
  recordedAt: t,
  supersedesId: target.id,
  amendReason: reason,
  deletedAt: reason == AmendReason.deleted ? t : null,
  schemaVersion: HealthRecord.writeSchemaFor(target.kind),
);

BloodPressureDetails bp(String sys, String dia) => BloodPressureDetails(
  systolic: double.parse(sys),
  diastolic: double.parse(dia),
  systolicText: sys,
  diastolicText: dia,
);

void main(List<String> args) {
  final header = VaultHeader(
    vaultId: '00000000-0000-4000-8000-0000000000f7',
    createdAt: at(0),
  );
  final profile = Profile(
    id: profileId,
    type: ProfileType.self,
    createdAt: at(0),
  );
  final records = <HealthRecord>[
    // Written by an F003 build (schema 2) and an F004 build (schema 3).
    HealthRecord(
      id: id(0),
      profileId: profileId,
      kind: RecordKind.bodyWeight,
      state: RecordState.observed,
      valueStatus: ValueStatus.present,
      quantity: const Quantity(78, 'kg'),
      originalText: '78',
      provenance: const Provenance.manual(),
      observedAt: at(1),
      recordedAt: at(1),
      schemaVersion: 2,
    ),
    HealthRecord(
      id: id(1),
      profileId: profileId,
      kind: RecordKind.labResult,
      state: RecordState.reported,
      valueStatus: ValueStatus.present,
      quantity: const Quantity(142, 'mg/dL'),
      originalText: '142',
      provenance: const Provenance.manual(),
      observedAt: DateTime.utc(2026, 10, 3),
      recordedAt: at(2),
      lab: const LabDetails(analyteLabel: 'LDL Kolesterol', sourceFlag: 'H'),
    ),
    // Written by the F007 build: weight stays at schema 3.
    HealthRecord(
      id: id(2),
      profileId: profileId,
      kind: RecordKind.bodyWeight,
      state: RecordState.observed,
      valueStatus: ValueStatus.present,
      quantity: const Quantity(77.5, 'kg'),
      originalText: '77,5',
      provenance: const Provenance.manual(),
      observedAt: at(3),
      recordedAt: at(3),
    ),
    // Two identical readings 30 s apart: both kept.
    measurement(
      3,
      RecordKind.bloodPressure,
      bp: bp('118', '76'),
      context: 'sitting, left arm',
      observed: at(4),
    ),
    measurement(
      4,
      RecordKind.bloodPressure,
      bp: bp('118', '76'),
      observed: at(4, 30),
    ),
    // A reading and its correction.
    measurement(
      5,
      RecordKind.bloodPressure,
      bp: bp('128', '84'),
      observed: at(5),
    ),
    measurement(
      6,
      RecordKind.bloodPressure,
      bp: bp('124', '82'),
      observed: at(5),
      recorded: at(6),
      supersedes: id(5),
    ),
    measurement(
      7,
      RecordKind.waistCircumference,
      q: const Quantity(84.25, 'cm'),
      text: '84,25',
      context: 'standing',
      observed: at(7),
    ),
    measurement(
      8,
      RecordKind.restingHeartRate,
      q: const Quantity(57, 'bpm'),
      text: '57',
      observed: at(8),
    ),
    measurement(
      9,
      RecordKind.restingHeartRate,
      q: const Quantity(61, 'bpm'),
      text: '61',
      observed: at(9),
    ),
    measurement(
      11,
      RecordKind.waistCircumference,
      q: const Quantity(85, 'cm'),
      text: '85',
      observed: at(11),
    ),
    measurement(
      13,
      RecordKind.restingHeartRate,
      status: ValueStatus.notMeasured,
      context: 'watch not worn',
      observed: at(13),
    ),
  ];
  final byId = {for (final r in records) r.id: r};
  records
    ..insert(10, marker(10, byId[id(9)]!, AmendReason.enteredInError, at(10)))
    ..insert(12, marker(12, byId[id(11)]!, AmendReason.deleted, at(12)));
  final out = StringBuffer()
    ..writeln(header.encode())
    ..writeln(encodeOp('profile.put', profile.toJson()));
  for (final r in records) {
    r.validate();
    out.writeln(encodeOp('record.append', r.toJson()));
  }
  final state = parseVaultLog(out.toString());
  if (state.warnings.isNotEmpty) {
    throw StateError('fixture does not replay cleanly: ${state.warnings}');
  }
  File(args.single).writeAsStringSync(out.toString());
  stdout.writeln('wrote ${args.single} (${records.length} records)');
}
