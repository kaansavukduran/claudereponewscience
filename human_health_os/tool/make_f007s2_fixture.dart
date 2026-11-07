// Writes the record schema 5 fixture (F007 slice 2) with the app's own
// writer: the committed schema 1-4 fixture of slice 1, unchanged, followed by
// records written the way the slice 2 build writes them. Run from
// human_health_os/:
//   dart run tool/make_f007s2_fixture.dart \
//     test/fixtures/vault/v1_f007_schema4.hhoslog.jsonl \
//     test/fixtures/vault/v1_f007s2_schema5.hhoslog.jsonl
// Synthetic data only. A committed fixture is never regenerated or edited.
import 'dart:io';

import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const profileId = '00000000-0000-4000-8000-0000000000a1';
String id(int n) =>
    '00000000-0000-4000-8000-0000000001${n.toRadixString(16).padLeft(2, '0')}';
DateTime at(int minute, [int second = 0]) =>
    DateTime.utc(2026, 10, 9, 6, minute, second);

HealthRecord measurement(
  int n,
  RecordKind kind, {
  Quantity? q,
  String? text,
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
  schemaVersion: HealthRecord.writeSchemaFor(kind),
);

HealthRecord marker(int n, HealthRecord target, AmendReason r, DateTime t) =>
    HealthRecord(
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
      amendReason: r,
      deletedAt: r == AmendReason.deleted ? t : null,
      schemaVersion: HealthRecord.writeSchemaFor(target.kind),
    );

void main(List<String> args) {
  final base = File(args[0]).readAsStringSync();
  final records = <HealthRecord>[
    // Two heights: a new height is a new record, not a correction.
    measurement(
      0,
      RecordKind.height,
      q: const Quantity(171, 'cm'),
      text: '171',
      observed: DateTime.utc(2026, 9, 1, 8),
      recorded: at(14),
    ),
    measurement(
      1,
      RecordKind.height,
      q: const Quantity(172.5, 'cm'),
      text: '172,5',
      context: 'barefoot',
      observed: at(15),
    ),
    measurement(
      2,
      RecordKind.bodyTemperature,
      q: const Quantity(36.8, '°C'),
      text: '36,8',
      context: 'ear',
      observed: at(16),
    ),
    // A reading and its correction (same observation).
    measurement(
      3,
      RecordKind.oxygenSaturation,
      q: const Quantity(96, '%'),
      text: '96',
      observed: at(17),
    ),
    measurement(
      4,
      RecordKind.oxygenSaturation,
      q: const Quantity(97, '%'),
      text: '97',
      observed: at(17),
      recorded: at(18),
      supersedes: id(3),
    ),
    // Back-dated: measured the day before, saved now.
    measurement(
      5,
      RecordKind.respiratoryRate,
      q: const Quantity(14, 'breaths/min'),
      text: '14',
      observed: DateTime.utc(2026, 10, 8, 21, 30),
      recorded: at(19),
    ),
    measurement(
      6,
      RecordKind.respiratoryRate,
      q: const Quantity(16, 'breaths/min'),
      text: '16',
      observed: at(20),
    ),
    // Newest temperature: not measured (thermometer not at hand).
    measurement(
      8,
      RecordKind.bodyTemperature,
      status: ValueStatus.notMeasured,
      context: 'thermometer not at hand',
      observed: at(22),
    ),
  ];
  final byId = {for (final r in records) r.id: r};
  final all = [
    ...records,
    marker(7, byId[id(6)]!, AmendReason.enteredInError, at(21)),
  ];
  final out = StringBuffer(base);
  for (final r in all) {
    r.validate();
    out.writeln(encodeOp('record.append', r.toJson()));
  }
  final state = parseVaultLog(out.toString());
  if (state.warnings.isNotEmpty) {
    throw StateError('fixture does not replay cleanly: ${state.warnings}');
  }
  File(args[1]).writeAsStringSync(out.toString());
  stdout.writeln('wrote ${args[1]} (${all.length} records added)');
}
