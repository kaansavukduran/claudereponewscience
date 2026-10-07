// F003@v0.32: record schema 2 rules, referential integrity in the store and
// the correction / entered-in-error / delete use cases (append-only).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/application/heartbeat_service.dart';
import 'package:human_health_os/src/core/ids.dart';
import 'package:human_health_os/src/data/local/log_repository.dart';
import 'package:human_health_os/src/data/local/vault_log.dart';
import 'package:human_health_os/src/domain/ports/health_repository.dart';
import 'package:human_health_os/src/domain/profile/profile.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

class StepClock implements Clock {
  DateTime t = DateTime.utc(2026, 10, 7, 9);
  @override
  DateTime nowUtc() => t = t.add(const Duration(minutes: 1));
}

HealthRecord base({
  String id = 'r',
  String? supersedes,
  AmendReason? reason,
  ValueStatus status = ValueStatus.present,
  Quantity? q = const Quantity(70, 'kg'),
  DateTime? deletedAt,
  int schema = HealthRecord.currentSchemaVersion,
}) => HealthRecord(
  id: id,
  profileId: 'p',
  kind: RecordKind.bodyWeight,
  state: RecordState.observed,
  valueStatus: status,
  quantity: q,
  originalText: null,
  provenance: const Provenance.manual(),
  observedAt: DateTime.utc(2026, 10, 1),
  recordedAt: DateTime.utc(2026, 10, 1),
  supersedesId: supersedes,
  amendReason: reason,
  deletedAt: deletedAt,
  schemaVersion: schema,
);

Matcher rule(String code) =>
    throwsA(isA<RecordValidationError>().having((e) => e.code, 'code', code));

void main() {
  group('record schema 2 rules', () {
    test('an amendment needs a target, and schema 2 needs a reason', () {
      expect(
        () => base(reason: AmendReason.correction).validate(),
        rule('AMEND_NEEDS_TARGET'),
      );
      expect(
        () => base(supersedes: 'x').validate(),
        rule('AMEND_REASON_REQUIRED'),
      );
      base(supersedes: 'x', schema: 1).validate(); // legacy correction
    });

    test('a withdrawal or deletion carries no value; only a deletion has a '
        'deletion time', () {
      expect(
        () => base(
          supersedes: 'x',
          reason: AmendReason.enteredInError,
        ).validate(),
        rule('MARKER_HAS_NO_VALUE'),
      );
      expect(
        () => base(
          supersedes: 'x',
          reason: AmendReason.deleted,
          status: ValueStatus.notApplicable,
          q: null,
        ).validate(),
        rule('DELETE_TIME_MISMATCH'),
      );
      expect(
        () => base(deletedAt: DateTime.utc(2026, 10, 2)).validate(),
        rule('DELETE_TIME_MISMATCH'),
      );
      base(
        supersedes: 'x',
        reason: AmendReason.deleted,
        status: ValueStatus.notApplicable,
        q: null,
        deletedAt: DateTime.utc(2026, 10, 2),
      ).validate();
    });

    test('schema 1 records keep their exact JSON shape; schema 2 adds '
        'amend_reason', () {
      expect(base(schema: 1).toJson().containsKey('amend_reason'), isFalse);
      final j = base(
        supersedes: 'x',
        reason: AmendReason.enteredInError,
        status: ValueStatus.notApplicable,
        q: null,
      ).toJson();
      expect(j['amend_reason'], 'entered_in_error');
      final back = HealthRecord.fromJson(
        jsonDecode(jsonEncode(j)) as Map<String, Object?>,
      );
      expect(back.amendReason, AmendReason.enteredInError);
      expect(jsonEncode(back.toJson()), jsonEncode(j));
    });
  });

  group('store integrity (checked before writing)', () {
    late MemoryLogSink sink;
    late LogRepository repo;
    late HeartbeatService svc;
    late String me;

    setUp(() async {
      sink = MemoryLogSink();
      repo = LogRepository(
        sink: sink,
        durability: StorageDurability.localFile,
        location: 't',
        clock: StepClock(),
      );
      await repo.open();
      svc = HeartbeatService(repo, clock: StepClock());
      me = (await svc.ensureSelfProfile()).id;
    });

    HealthRecord amendOf(
      String target, {
      String profile = '',
      AmendReason reason = AmendReason.correction,
    }) => HealthRecord(
      id: 'a-$target-${reason.code}',
      profileId: profile.isEmpty ? me : profile,
      kind: RecordKind.bodyWeight,
      state: RecordState.observed,
      valueStatus: reason.isMarker
          ? ValueStatus.notApplicable
          : ValueStatus.present,
      quantity: reason.isMarker ? null : const Quantity(71, 'kg'),
      originalText: null,
      provenance: const Provenance.manual(),
      observedAt: DateTime.utc(2026, 10, 1),
      recordedAt: DateTime.utc(2026, 10, 7, 12),
      supersedesId: target,
      amendReason: reason,
      deletedAt: reason == AmendReason.deleted
          ? DateTime.utc(2026, 10, 7, 12)
          : null,
    );

    test('an amendment of a missing record, of a marker, or across profiles '
        'is refused and nothing is written', () async {
      final w = await svc.recordWeightKg(profileId: me, input: '70');
      final m = await svc.amend(
        profileId: me,
        targetId: w.id,
        reason: AmendReason.enteredInError,
      );
      final before = sink.text;
      await expectLater(
        repo.appendRecord(amendOf('ghost')),
        rule('AMEND_TARGET_MISSING'),
      );
      await expectLater(
        repo.appendRecord(amendOf(m.id)),
        rule('AMEND_TARGET_IS_MARKER'),
      );
      await repo.putProfile(
        Profile(
          id: 'other',
          type: ProfileType.realOther,
          createdAt: DateTime.utc(2026),
        ),
      );
      await expectLater(
        repo.appendRecord(amendOf(w.id, profile: 'other')),
        rule('AMEND_TARGET_MISMATCH'),
      );
      expect(
        sink.text!.split('\n').length,
        before!.split('\n').length + 1,
        reason: 'only the profile line was added',
      );
    });

    test('on replay an orphan amendment is skipped with a warning', () async {
      await svc.recordWeightKg(profileId: me, input: '70');
      await sink.appendLine(
        encodeOp('record.append', amendOf('ghost').toJson()),
      );
      final again = LogRepository(
        sink: sink,
        durability: StorageDurability.localFile,
        location: 't',
      );
      final report = await again.open();
      expect(report.warnings.single.code, 'AMEND_TARGET_MISSING');
    });

    test('correct, withdraw, delete: each appends one line, nothing is '
        'rewritten, and the lineage survives a restart', () async {
      final w = await svc.recordWeightKg(profileId: me, input: '80');
      final c = await svc.correctWeightKg(
        profileId: me,
        targetId: w.id,
        input: '78,6',
      );
      expect(
        (c.supersedesId, c.amendReason, c.observedAt),
        (w.id, AmendReason.correction, w.observedAt),
      );
      expect(c.originalText, '78,6');
      final prefix = sink.text!;
      final e = await svc.amend(
        profileId: me,
        targetId: c.id,
        reason: AmendReason.enteredInError,
      );
      expect(sink.text!.startsWith(prefix), isTrue, reason: 'append-only');
      expect(ids(await svc.currentWeights(me)), [
        w.id,
      ], reason: '80 counts again');
      final d = await svc.amend(
        profileId: me,
        targetId: w.id,
        reason: AmendReason.deleted,
      );
      expect(d.deletedAt, isNotNull);
      expect(await svc.currentWeights(me), isEmpty);

      final restarted = LogRepository(
        sink: sink,
        durability: StorageDurability.localFile,
        location: 't',
      );
      expect((await restarted.open()).warnings, isEmpty);
      final t = await HeartbeatService(restarted)
          .timeline(me, includeHidden: true);
      final entry = t.single;
      expect(entry.status, EntryStatus.deleted);
      expect(ids(entry.versions), [w.id, c.id]);
      expect(entry.withdrawn, {c.id});
      expect(entry.deletion!.id, d.id);
      expect(e.amendReason, AmendReason.enteredInError);
    });

    test('only the current version can be changed', () async {
      final w = await svc.recordWeightKg(profileId: me, input: '80');
      await svc.correctWeightKg(profileId: me, targetId: w.id, input: '79');
      Matcher input(String code) =>
          throwsA(isA<InputError>().having((e) => e.code, 'code', code));
      await expectLater(
        svc.correctWeightKg(profileId: me, targetId: w.id, input: '78'),
        input('TARGET_NOT_CURRENT'),
      );
      await expectLater(
        svc.amend(profileId: me, targetId: w.id, reason: AmendReason.deleted),
        input('TARGET_NOT_CURRENT'),
      );
      await expectLater(
        svc.amend(profileId: me, targetId: 'nope', reason: AmendReason.deleted),
        input('TARGET_NOT_FOUND'),
      );
      await expectLater(
        svc.correctWeightKg(profileId: me, targetId: w.id, input: ''),
        input('EMPTY'),
        reason: 'input is checked first; empty never becomes 0',
      );
    });
  });
}

List<String> ids(Iterable<HealthRecord> rs) => [for (final r in rs) r.id];
