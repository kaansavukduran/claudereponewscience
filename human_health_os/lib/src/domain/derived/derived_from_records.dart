/// Values worked out from the person's own records (U029, D-039).
///
/// Pure Dart. Feeds the latest live, measured body weight, height and waist
/// circumference into the MP-CORE-DERIVED-1 engines (`core_derived.dart`)
/// and keeps, for each model, the engine's result together with the records
/// it used. Nothing here judges: no category, band or advice is attached.
/// A derived value is a model output, never an observed fact.
///
/// Rules:
/// - only the newest live entry of a kind that has a measured value is used
///   (a newer "not measured" entry is history, never a 0);
/// - an input with no such entry is missing: the engine is still called, so
///   the result is its MISSING_INPUT refusal, with no value;
/// - when the newest entry has two live versions (a conflict the person has
///   not resolved), neither is chosen: the input is passed as missing and
///   named in [DerivedRow.unresolved];
/// - no staleness rule exists in the engines, so none is added here: every
///   record used keeps its own date and [DerivedRow.daysApart] says how far
///   apart they are, as a plain fact.
library;

import '../engines/calc_result.dart';
import '../engines/core_derived.dart' as core;
import '../records/health_record.dart';

/// One record that went into a calculation.
class DerivedInput {
  const DerivedInput({
    required this.key,
    required this.kind,
    required this.record,
  });

  /// The engine's input name (e.g. `height_m`).
  final String key;
  final RecordKind kind;

  /// The record as stored: its value and date are shown as recorded.
  final HealthRecord record;
}

/// One model applied to the person's records.
class DerivedRow {
  const DerivedRow({
    required this.result,
    required this.used,
    required this.needs,
    required this.unresolved,
  });

  /// The engine's result: a value only when [CalcResult.status] is OK.
  final CalcResult result;

  /// Records that were used, in the model's input order.
  final List<DerivedInput> used;

  /// Kinds with no measured record (shown as "needs: …", never a number).
  final List<RecordKind> needs;

  /// Kinds whose newest entry has competing versions; not used until the
  /// person chooses one on the Timeline.
  final List<RecordKind> unresolved;

  ModelRef get model => result.model;
  bool get computed => result.status == CalcStatus.ok && result.value != null;

  /// Whole days between the oldest and newest record used (0 when one
  /// record or the same day); null when fewer than two records were used.
  int? get daysApart {
    if (used.length < 2) return null;
    final times = [for (final u in used) u.record.observedAt]..sort();
    return times.last.difference(times.first).inDays;
  }
}

/// The record's measured quantity in [unit], or null when it has none.
double? _valueIn(HealthRecord r, String unit) {
  if (r.valueStatus != ValueStatus.present) return null;
  final q = r.quantity;
  if (q == null || q.unit != unit || !isPresent(q.value)) return null;
  return q.value;
}

/// The newest live entry with a measured value in [unit] (newest first, as
/// [buildTimeline] orders them).
({HealthRecord? record, bool conflict}) _latest(
  List<TimelineEntry> entries,
  String unit,
) {
  for (final e in entries) {
    if (!e.isLive) continue;
    // Two live versions of one fact are never settled here, not even by
    // dropping a "not measured" one: the person chooses on the Timeline.
    if (e.status == EntryStatus.conflict &&
        e.heads.any((h) => _valueIn(h, unit) != null)) {
      return (record: null, conflict: true);
    }
    final measured = [
      for (final h in e.heads)
        if (_valueIn(h, unit) != null) h,
    ];
    if (measured.isEmpty) continue;
    if (measured.length > 1) return (record: null, conflict: true);
    return (record: measured.single, conflict: false);
  }
  return (record: null, conflict: false);
}

/// The derived values that can be worked out from body weight, height and
/// waist records (each list a timeline, newest first, e.g. from
/// `HeartbeatService.weightTimeline` and `measurementTimeline`).
List<DerivedRow> derivedFromRecords({
  required List<TimelineEntry> weights,
  required List<TimelineEntry> heights,
  required List<TimelineEntry> waists,
}) {
  final w = _latest(weights, 'kg');
  final h = _latest(heights, 'cm');
  final waist = _latest(waists, 'cm');

  DerivedRow row(
    CalcResult Function(Map<String, Object?>) engine,
    List<(String, RecordKind, ({HealthRecord? record, bool conflict}))> ins,
    Map<String, Object?> inputs,
  ) {
    return DerivedRow(
      result: engine(inputs),
      used: [
        for (final (key, kind, x) in ins)
          if (x.record != null)
            DerivedInput(key: key, kind: kind, record: x.record!),
      ],
      needs: [
        for (final (_, kind, x) in ins)
          if (x.record == null && !x.conflict) kind,
      ],
      unresolved: [
        for (final (_, kind, x) in ins)
          if (x.conflict) kind,
      ],
    );
  }

  final weightKg = w.record == null ? null : _valueIn(w.record!, 'kg');
  final heightCm = h.record == null ? null : _valueIn(h.record!, 'cm');
  final waistCm = waist.record == null ? null : _valueIn(waist.record!, 'cm');

  return [
    // Height is stored in cm; the formula takes metres (cm / 100, a unit
    // definition, not an assumption).
    row(
      core.bmi,
      [
        ('weight_kg', RecordKind.bodyWeight, w),
        ('height_m', RecordKind.height, h),
      ],
      {
        'weight_kg': weightKg,
        'height_m': heightCm == null ? null : heightCm / 100,
      },
    ),
    row(
      core.waistHeightRatio,
      [
        ('waist', RecordKind.waistCircumference, waist),
        ('height', RecordKind.height, h),
      ],
      {
        'waist': waistCm,
        'height': heightCm,
        'waist_unit': 'cm',
        'height_unit': 'cm',
      },
    ),
  ];
}
