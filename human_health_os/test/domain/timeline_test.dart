// F003@v0.32: timeline ordering and correction lineage (master §39 exit:
// "timeline ordering tests; correction-history tests"). Pure domain.
import 'package:flutter_test/flutter_test.dart';
import 'package:human_health_os/src/domain/records/health_record.dart';

const me = 'p1';

HealthRecord rec(
  String id, {
  required int day,
  int minute = 0,
  int recordedMinute = 0,
  double? kg = 70,
  String? supersedes,
  AmendReason? reason,
  int schema = HealthRecord.currentSchemaVersion,
  DateTime? deletedAt,
  ValueStatus? status,
}) {
  final marker = reason?.isMarker ?? false;
  final vs =
      status ??
      (marker || kg == null ? ValueStatus.notApplicable : ValueStatus.present);
  return HealthRecord(
    id: id,
    profileId: me,
    kind: RecordKind.bodyWeight,
    state: RecordState.observed,
    valueStatus: vs,
    quantity: vs == ValueStatus.present ? Quantity(kg!, 'kg') : null,
    originalText: null,
    provenance: const Provenance.manual(),
    observedAt: DateTime.utc(2026, 10, day, 7, minute),
    recordedAt: DateTime.utc(2026, 10, day, 8, recordedMinute),
    supersedesId: supersedes,
    amendReason: reason,
    deletedAt: deletedAt,
    schemaVersion: schema,
  );
}

HealthRecord correction(
  String id,
  String of, {
  required int day,
  int at = 1,
  double kg = 71,
}) => rec(
  id,
  day: day,
  recordedMinute: at,
  kg: kg,
  supersedes: of,
  reason: AmendReason.correction,
);

HealthRecord marker(
  String id,
  String of,
  AmendReason r, {
  required int day,
  int at = 30,
}) => rec(
  id,
  day: day,
  recordedMinute: at,
  supersedes: of,
  reason: r,
  deletedAt: r == AmendReason.deleted
      ? DateTime.utc(2026, 10, day, 8, at)
      : null,
);

List<String> ids(Iterable<HealthRecord> rs) => [for (final r in rs) r.id];

void main() {
  group('ordering', () {
    test('newest observation first; same time -> newest entry first -> id', () {
      final records = [
        rec('a', day: 1),
        rec('b', day: 3),
        rec('c', day: 2, minute: 5),
        rec('d', day: 2, minute: 5, recordedMinute: 9),
        rec('e', day: 2, minute: 5, recordedMinute: 9),
      ];
      expect(buildTimeline(records).map((e) => e.rootId), [
        'b',
        'd',
        'e',
        'c',
        'a',
      ]);
    });

    test('the order does not depend on the order records were read', () {
      final records = [
        rec('a', day: 1),
        correction('a2', 'a', day: 1),
        rec('b', day: 4),
        rec('c', day: 4),
        marker('cx', 'c', AmendReason.enteredInError, day: 4),
        rec('d', day: 2),
        correction('d2', 'd', day: 2),
        correction('d3', 'd', day: 2, at: 2),
      ];
      final expected = buildTimeline(records, includeHidden: true)
          .map((e) => '${e.rootId}|${e.status.name}|${ids(e.heads).join(',')}')
          .toList();
      for (var shift = 1; shift < records.length; shift++) {
        final rotated = [...records.skip(shift), ...records.take(shift)];
        expect(
          buildTimeline(rotated, includeHidden: true).map(
            (e) => '${e.rootId}|${e.status.name}|${ids(e.heads).join(',')}',
          ),
          expected,
          reason: 'rotation $shift',
        );
      }
      expect(
        buildTimeline(
          records.reversed,
          includeHidden: true,
        ).map((e) => e.rootId),
        expected.map((k) => k.split('|').first),
      );
    });
  });

  group('correction lineage', () {
    test('a chain of corrections is one entry; the newest version counts; '
        'every version stays in history', () {
      final t = buildTimeline([
        rec('x', day: 1, kg: 80),
        correction('y', 'x', day: 1, kg: 78),
        correction('z', 'y', day: 1, at: 2, kg: 77.5),
      ]);
      final e = t.single;
      expect(e.status, EntryStatus.current);
      expect(e.rootId, 'x');
      expect(ids(e.heads), ['z']);
      expect(ids(e.versions), ['x', 'y', 'z']);
      expect(e.corrected, isTrue);
      expect(e.shown.quantity, const Quantity(77.5, 'kg'));
      expect(ids(currentRecords([...e.versions])), ['z']);
    });

    test('versions keep lineage order even with the same entry time and '
        'ids that sort the other way', () {
      final e = buildTimeline([
        rec('zz-original', day: 1),
        rec(
          'aa-fix',
          day: 1,
          supersedes: 'zz-original',
          reason: AmendReason.correction,
          kg: 71,
        ),
      ]).single;
      expect(ids(e.versions), ['zz-original', 'aa-fix']);
      expect(ids(e.heads), ['aa-fix']);
    });

    test('a correction to "not measured" stays missing, never zero', () {
      final e = buildTimeline([
        rec('x', day: 1),
        rec(
          'y',
          day: 1,
          recordedMinute: 1,
          supersedes: 'x',
          reason: AmendReason.correction,
          kg: null,
          status: ValueStatus.notMeasured,
        ),
      ]).single;
      expect(e.shown.valueStatus, ValueStatus.notMeasured);
      expect(e.shown.quantity, isNull);
    });

    test(
      'a schema 1 record that supersedes without a reason is a correction',
      () {
        final e = buildTimeline([
          rec('x', day: 1, schema: 1),
          rec('y', day: 1, recordedMinute: 1, supersedes: 'x', schema: 1),
        ]).single;
        expect(ids(e.heads), ['y']);
        expect(e.status, EntryStatus.current);
      },
    );
  });

  group('entered in error vs deleted', () {
    test(
      'entered in error on a correction: the previous version counts again',
      () {
        final records = [
          rec('x', day: 1, kg: 80),
          correction('y', 'x', day: 1, kg: 8),
          marker('m', 'y', AmendReason.enteredInError, day: 1),
        ];
        final e = buildTimeline(records).single;
        expect(e.status, EntryStatus.current);
        expect(ids(e.heads), ['x']);
        expect(e.withdrawn, {'y'});
        expect(ids(e.versions), [
          'x',
          'y',
        ], reason: 'the withdrawn version stays in history');
      },
    );

    test('entered in error on an original: the entry leaves every current '
        'view but stays in the history view', () {
      final records = [
        rec('x', day: 1),
        marker('m', 'x', AmendReason.enteredInError, day: 1),
      ];
      expect(buildTimeline(records), isEmpty);
      expect(currentRecords(records), isEmpty);
      final e = buildTimeline(records, includeHidden: true).single;
      expect(e.status, EntryStatus.enteredInError);
      expect(e.heads, isEmpty);
      expect(e.shown.id, 'x');
    });

    test('delete removes the whole fact (all versions), keeps history, and '
        'is not a correction: nothing returns', () {
      final records = [
        rec('x', day: 1, kg: 80),
        correction('y', 'x', day: 1, kg: 79),
        marker('d', 'y', AmendReason.deleted, day: 1),
      ];
      expect(buildTimeline(records), isEmpty);
      expect(currentRecords(records), isEmpty, reason: 'x does not come back');
      final e = buildTimeline(records, includeHidden: true).single;
      expect(e.status, EntryStatus.deleted);
      expect(e.deletion!.id, 'd');
      expect(ids(e.versions), ['x', 'y']);
    });

    test(
      'no resurrection: a stale correction after a deletion stays deleted',
      () {
        final records = [
          rec('x', day: 1),
          marker('d', 'x', AmendReason.deleted, day: 1),
          correction('late', 'x', day: 1, at: 59),
        ];
        expect(buildTimeline(records), isEmpty);
        expect(
          buildTimeline(records, includeHidden: true).single.status,
          EntryStatus.deleted,
        );
      },
    );

    test('a schema 1 record carrying its own deletion time is deleted', () {
      final records = [
        rec('x', day: 1, schema: 1, deletedAt: DateTime.utc(2026, 10, 2)),
      ];
      expect(buildTimeline(records), isEmpty);
      expect(
        buildTimeline(records, includeHidden: true).single.status,
        EntryStatus.deleted,
      );
    });

    test('markers are never entries, heads or versions', () {
      final records = [
        rec('x', day: 1),
        correction('y', 'x', day: 1),
        marker('m', 'y', AmendReason.enteredInError, day: 1),
        rec('z', day: 2),
        marker('d', 'z', AmendReason.deleted, day: 2),
      ];
      final all = buildTimeline(records, includeHidden: true);
      for (final e in all) {
        expect([
          ...ids(e.versions),
          ...ids(e.heads),
        ], isNot(contains(anyOf('m', 'd'))));
      }
      expect(all.map((e) => e.rootId).toSet(), {'x', 'z'});
    });
  });

  group('conflicts (v0.24 FR-166)', () {
    test('two live corrections of one version are a conflict: both shown, '
        'neither chosen by timestamp', () {
      final records = [
        rec('x', day: 1, kg: 80),
        correction('y1', 'x', day: 1, at: 1, kg: 79),
        correction('y2', 'x', day: 1, at: 2, kg: 81),
      ];
      final e = buildTimeline(records).single;
      expect(e.status, EntryStatus.conflict);
      expect(ids(e.heads), ['y2', 'y1']);
      expect(ids(currentRecords(records)), ['y2', 'y1']);
    });

    test('marking one side entered in error resolves the conflict', () {
      final e = buildTimeline([
        rec('x', day: 1, kg: 80),
        correction('y1', 'x', day: 1, at: 1, kg: 79),
        correction('y2', 'x', day: 1, at: 2, kg: 81),
        marker('m', 'y2', AmendReason.enteredInError, day: 1),
      ]).single;
      expect(e.status, EntryStatus.current);
      expect(ids(e.heads), ['y1']);
    });
  });

  group('calendar days vs instants (review finding)', () {
    HealthRecord labOn(String id, int y, int m, int d) => HealthRecord(
      id: id,
      profileId: me,
      kind: RecordKind.labResult,
      state: RecordState.reported,
      valueStatus: ValueStatus.present,
      quantity: const Quantity(1, 'u'),
      originalText: '1',
      provenance: const Provenance.manual(),
      observedAt: DateTime.utc(y, m, d),
      recordedAt: DateTime.utc(y, m, d, 12),
      lab: const LabDetails(analyteLabel: 'X'),
    );

    // Host-independent: the local day start is injected for a zone five
    // hours west of UTC and one three hours east (review finding: the test
    // passed without the fix on a UTC host).
    DateTime Function(int, int, int) zone(int hours) =>
        (y, m, d) => DateTime.utc(y, m, d).subtract(Duration(hours: hours));

    for (final hours in [-5, 3]) {
      test('a lab dated D sorts above an entry made at 21:00 local the day '
          'before (UTC${hours >= 0 ? '+' : ''}$hours)', () {
        // 21:00 local on Oct 6 in that zone, as a UTC instant.
        final evening = rec('w', day: 1).copyObservedAt(
          DateTime.utc(2026, 10, 6, 21).subtract(Duration(hours: hours)),
        );
        final lab = labOn('l', 2026, 10, 7);
        expect(
          buildTimeline([
            evening,
            lab,
          ], localMidnight: zone(hours)).map((e) => e.rootId),
          ['l', 'w'],
        );
        expect(
          orderingInstant(lab, localMidnight: zone(hours)),
          DateTime.utc(2026, 10, 7).subtract(Duration(hours: hours)),
        );
      });
    }
  });
}

extension on HealthRecord {
  HealthRecord copyObservedAt(DateTime t) => HealthRecord(
    id: id,
    profileId: profileId,
    kind: kind,
    state: state,
    valueStatus: valueStatus,
    quantity: quantity,
    originalText: originalText,
    provenance: provenance,
    observedAt: t,
    recordedAt: t,
  );
}
