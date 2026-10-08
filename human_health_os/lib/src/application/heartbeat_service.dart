/// Record use cases: a local SELF profile, canonical body-weight observations
/// (F002) and their timeline with corrections, withdrawals and deletions
/// (F003), lab results as printed (F004) and measurements typed by hand
/// (F007), all through the [HealthRepository] port.
library;

import '../core/ids.dart';
import '../domain/errors.dart';
import '../domain/ports/health_repository.dart';
import '../domain/profile/profile.dart';
import '../domain/records/health_record.dart';

class InputError implements Exception, CodedError {
  const InputError(this.code, [this.field]);

  /// Stable code; the UI maps it to localized text.
  /// `EMPTY` · `NOT_A_NUMBER` · `OUT_OF_RANGE` · `FUTURE_TIME` ·
  /// `TARGET_NOT_FOUND` · `TARGET_NOT_CURRENT` · `TARGET_WRONG_KIND` ·
  /// `LAB_ANALYTE_EMPTY` · `DATE_INVALID` · `AMBIGUOUS_SEPARATOR` ·
  /// `NOT_POSITIVE` · `BP_ORDER` · `CONTEXT_TOO_LONG`
  @override
  final String code;

  /// Which input the error belongs to, when a form has several
  /// (`value`, `systolic`, `diastolic`, `context`); null otherwise.
  final String? field;

  @override
  String toString() => 'InputError($code)';
}

/// Parses user text such as `78.4`, `78,4` or ` 78 `. Blank input is an error,
/// never zero (missing ≠ zero).
double parseDecimal(String raw) {
  final t = raw.trim().replaceAll(' ', '');
  if (t.isEmpty) throw const InputError('EMPTY');
  if (!RegExp(r'^\d+([.,]\d+)?$').hasMatch(t)) {
    throw const InputError('NOT_A_NUMBER');
  }
  return double.parse(t.replaceAll(',', '.'));
}

/// A lab result as typed from a report. Every field is the printed text.
class LabInput {
  const LabInput({
    required this.analyte,
    required this.value,
    required this.notReported,
    required this.unit,
    required this.sampleDate,
    this.specimen = '',
    this.laboratory = '',
    this.sourceFlag = '',
    this.referenceText = '',
  });

  final String analyte;
  final String value;

  /// The report lists the test but gives no value (missing ≠ zero).
  final bool notReported;
  final String unit;

  /// `YYYY-MM-DD`, the day the sample was collected.
  final String sampleDate;
  final String specimen;
  final String laboratory;
  final String sourceFlag;
  final String referenceText;
}

/// Parses `YYYY-MM-DD` into that calendar day (UTC midnight, a date without
/// a time of day). Anything else is `DATE_INVALID`.
DateTime parseSampleDate(String raw) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw.trim());
  if (m == null) throw const InputError('DATE_INVALID');
  final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
  final date = DateTime.utc(y, mo, d);
  if (date.year != y || date.month != mo || date.day != d) {
    throw const InputError('DATE_INVALID');
  }
  return date;
}

/// What a person typed for one measurement (F007). A blood pressure reading
/// uses [systolic] and [diastolic]; the other kinds use [value]. [context]
/// is optional free text ("sitting, left arm"), kept exactly as typed.
class MeasurementInput {
  const MeasurementInput({
    this.value = '',
    this.systolic = '',
    this.diastolic = '',
    this.context = '',
  });

  final String value;
  final String systolic;
  final String diastolic;
  final String context;
}

/// Like [parseDecimal], but refuses a value whose separator could be a
/// thousands separator ("150,000", "7.500", "250.000"): guessing would store
/// a number 1000 times off while the screen shows the printed text.
double parseLabDecimal(String raw) {
  final t = raw.trim().replaceAll(' ', '');
  if (RegExp(r'^[1-9]\d{0,2}[.,]\d{3}$').hasMatch(t)) {
    throw const InputError('AMBIGUOUS_SEPARATOR');
  }
  return parseDecimal(raw);
}

class HeartbeatService {
  HeartbeatService(
    this.repository, {
    this.clock = const SystemClock(),
    IdGenerator? ids,
  }) : _ids = ids ?? UuidV4Generator();

  final HealthRepository repository;
  final Clock clock;
  final IdGenerator _ids;

  /// Returns the existing SELF profile, or creates one the first time.
  /// The id lives inside the vault, so the same profile survives restarts
  /// and moving a portable folder.
  Future<Profile> ensureSelfProfile() async {
    final existing = (await repository.profiles()).where(
      (p) => p.type == ProfileType.self,
    );
    if (existing.isNotEmpty) return existing.first;
    final p = Profile(
      id: _ids.newId(),
      type: ProfileType.self,
      createdAt: clock.nowUtc(),
    );
    await repository.putProfile(p);
    return p;
  }

  double _weightKg(String input) {
    final value = parseDecimal(input);
    if (value <= 0 || value > 700) throw const InputError('OUT_OF_RANGE');
    return value;
  }

  /// Records a manually entered body weight in kg as an OBSERVED fact.
  Future<HealthRecord> recordWeightKg({
    required String profileId,
    required String input,
    DateTime? observedAt,
  }) async {
    final value = _weightKg(input);
    final now = clock.nowUtc();
    final when = (observedAt ?? now).toUtc();
    if (when.isAfter(now.add(const Duration(minutes: 5)))) {
      throw const InputError('FUTURE_TIME');
    }
    final record = HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: RecordKind.bodyWeight,
      state: RecordState.observed,
      valueStatus: ValueStatus.present,
      quantity: Quantity(value, 'kg'),
      originalText: input.trim(),
      provenance: const Provenance.manual(),
      observedAt: when,
      recordedAt: now,
    );
    await repository.appendRecord(record);
    return record;
  }

  /// Current weights (heads of live entries), newest first.
  Future<List<HealthRecord>> currentWeights(String profileId) async =>
      currentRecords(
        await repository.records(profileId, kind: RecordKind.bodyWeight),
      );

  /// Body-weight timeline entries, newest first (ladder F003).
  Future<List<TimelineEntry>> weightTimeline(String profileId) async =>
      buildTimeline(
        await repository.records(profileId, kind: RecordKind.bodyWeight),
      );

  /// Every fact of the profile on one timeline. [includeHidden] adds deleted
  /// and withdrawn entries (history view).
  Future<List<TimelineEntry>> timeline(
    String profileId, {
    bool includeHidden = false,
  }) async => buildTimeline(
    await repository.records(profileId),
    includeHidden: includeHidden,
  );

  /// The live version [targetId] of a live entry, or an [InputError]. Only
  /// the current version can be amended: amending an older one would fork
  /// the history (conflicts come from sync or import, never from here).
  Future<HealthRecord> _currentTarget(String profileId, String targetId) async {
    final all = await repository.records(profileId);
    if (!all.any((r) => r.id == targetId)) {
      throw const InputError('TARGET_NOT_FOUND');
    }
    for (final e in buildTimeline(all)) {
      for (final h in e.heads) {
        if (h.id == targetId) return h;
      }
    }
    throw const InputError('TARGET_NOT_CURRENT');
  }

  /// Saves a better value for the same observation. The old version stays
  /// in history; the new one is a manual, OBSERVED entry.
  Future<HealthRecord> correctWeightKg({
    required String profileId,
    required String targetId,
    required String input,
  }) async {
    final value = _weightKg(input);
    final target = await _currentTarget(profileId, targetId);
    if (target.kind != RecordKind.bodyWeight) {
      throw const InputError('TARGET_WRONG_KIND');
    }
    final record = HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: target.kind,
      state: RecordState.observed,
      valueStatus: ValueStatus.present,
      quantity: Quantity(value, 'kg'),
      originalText: input.trim(),
      provenance: const Provenance.manual(),
      observedAt: target.observedAt,
      recordedAt: clock.nowUtc(),
      supersedesId: target.id,
      amendReason: AmendReason.correction,
    );
    await repository.appendRecord(record);
    return record;
  }

  /// Withdraws [targetId] as entered in error, or deletes its whole fact
  /// ([AmendReason.deleted]). Appends a marker; nothing is rewritten.
  Future<HealthRecord> amend({
    required String profileId,
    required String targetId,
    required AmendReason reason,
  }) async {
    if (!reason.isMarker) throw ArgumentError.value(reason, 'reason');
    final target = await _currentTarget(profileId, targetId);
    final now = clock.nowUtc();
    final marker = HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: target.kind,
      state: RecordState.reported,
      valueStatus: ValueStatus.notApplicable,
      quantity: null,
      originalText: null,
      provenance: const Provenance.manual(),
      observedAt: target.observedAt,
      recordedAt: now,
      supersedesId: target.id,
      amendReason: reason,
      deletedAt: reason == AmendReason.deleted ? now : null,
      schemaVersion: HealthRecord.writeSchemaFor(target.kind),
    );
    await repository.appendRecord(marker);
    return marker;
  }

  /// Lab results, newest sample first (ladder F004).
  Future<List<TimelineEntry>> labTimeline(String profileId) async =>
      buildTimeline(
        await repository.records(profileId, kind: RecordKind.labResult),
      );

  HealthRecord _labRecord(
    String profileId,
    LabInput input, {
    String? supersedesId,
  }) {
    final analyte = input.analyte.trim();
    if (analyte.isEmpty) throw const InputError('LAB_ANALYTE_EMPTY');
    final sample = parseSampleDate(input.sampleDate);
    final now = clock.nowUtc();
    // Compare calendar days in the user's time zone: the sample day may be
    // today, never tomorrow (review finding: comparing instants let a
    // mistyped tomorrow through in most zones).
    final local = now.toLocal();
    if (sample.isAfter(DateTime.utc(local.year, local.month, local.day))) {
      throw const InputError('FUTURE_TIME');
    }
    String? opt(String raw) => raw.trim().isEmpty ? null : raw.trim();
    final unit = opt(input.unit);
    final double? value = input.notReported
        ? null
        : parseLabDecimal(input.value);
    return HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: RecordKind.labResult,
      state: RecordState.reported,
      valueStatus: value == null
          ? ValueStatus.notReported
          : ValueStatus.present,
      quantity: value == null ? null : Quantity(value, unit),
      originalText: value == null ? null : input.value.trim(),
      provenance: const Provenance.manual(),
      observedAt: sample,
      recordedAt: now,
      supersedesId: supersedesId,
      amendReason: supersedesId == null ? null : AmendReason.correction,
      lab: LabDetails(
        analyteLabel: analyte,
        specimen: opt(input.specimen),
        laboratory: opt(input.laboratory),
        sourceFlag: opt(input.sourceFlag),
        referenceText: opt(input.referenceText),
      ),
    );
  }

  /// Records a lab result exactly as printed: a REPORTED value with its
  /// printed unit, flag and range. A missing unit or range stays missing.
  Future<HealthRecord> recordLab({
    required String profileId,
    required LabInput input,
  }) async {
    final record = _labRecord(profileId, input);
    await repository.appendRecord(record);
    return record;
  }

  /// A corrected transcription of the same lab result (new version).
  Future<HealthRecord> correctLab({
    required String profileId,
    required String targetId,
    required LabInput input,
  }) async {
    final target = await _currentTarget(profileId, targetId);
    if (target.kind != RecordKind.labResult) {
      throw const InputError('TARGET_WRONG_KIND');
    }
    final record = _labRecord(profileId, input, supersedesId: target.id);
    await repository.appendRecord(record);
    return record;
  }

  /// Measurement entries of [kind], newest first (ladder F007).
  Future<List<TimelineEntry>> measurementTimeline(
    String profileId,
    RecordKind kind,
  ) async => buildTimeline(await repository.records(profileId, kind: kind));

  /// A number typed for a measurement: a decimal comma is fine, a possible
  /// thousands separator is refused, blank is EMPTY (never 0), and 0 or
  /// less is refused (leave a value you do not know empty).
  double _measurementNumber(String raw, String field) {
    final double v;
    try {
      v = parseLabDecimal(raw);
    } on InputError catch (e) {
      throw InputError(e.code, field);
    }
    if (v <= 0) throw InputError('NOT_POSITIVE', field);
    return v;
  }

  HealthRecord _measurementRecord(
    String profileId,
    RecordKind kind,
    MeasurementInput input, {
    HealthRecord? target,
  }) {
    if (!kind.isMeasurement) throw ArgumentError.value(kind, 'kind');
    final context = input.context.trim();
    if (context.length > HealthRecord.maxContextLength) {
      throw const InputError('CONTEXT_TOO_LONG', 'context');
    }
    Quantity? quantity;
    String? originalText;
    BloodPressureDetails? details;
    if (kind.isStructured) {
      final systolic = _measurementNumber(input.systolic, 'systolic');
      final diastolic = _measurementNumber(input.diastolic, 'diastolic');
      // Checked at entry only: the upper number is larger by definition, so
      // an equal or smaller one was mistyped or swapped (D-018).
      if (systolic <= diastolic) throw const InputError('BP_ORDER', 'systolic');
      details = BloodPressureDetails(
        systolic: systolic,
        diastolic: diastolic,
        unit: kind.unit!,
        systolicText: input.systolic.trim(),
        diastolicText: input.diastolic.trim(),
      );
    } else {
      quantity = Quantity(_measurementNumber(input.value, 'value'), kind.unit);
      originalText = input.value.trim();
    }
    final now = clock.nowUtc();
    return HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: kind,
      state: RecordState.observed,
      valueStatus: ValueStatus.present,
      quantity: quantity,
      originalText: originalText,
      provenance: const Provenance.manual(),
      // A correction is the same observation: it keeps its time.
      observedAt: target?.observedAt ?? now,
      recordedAt: now,
      supersedesId: target?.id,
      amendReason: target == null ? null : AmendReason.correction,
      context: context.isEmpty ? null : context,
      details: details,
      schemaVersion: HealthRecord.writeSchemaFor(kind),
    );
  }

  /// Records a measurement typed by hand as an OBSERVED, manual fact at the
  /// moment it is saved. Nothing is derived, averaged or judged.
  Future<HealthRecord> recordMeasurement({
    required String profileId,
    required RecordKind kind,
    required MeasurementInput input,
  }) async {
    final record = _measurementRecord(profileId, kind, input);
    await repository.appendRecord(record);
    return record;
  }

  /// A better value for the same measurement (new version, same kind and
  /// time). Another kind's record is refused.
  Future<HealthRecord> correctMeasurement({
    required String profileId,
    required String targetId,
    required MeasurementInput input,
  }) async {
    final target = await _currentTarget(profileId, targetId);
    if (!target.kind.isMeasurement) {
      throw const InputError('TARGET_WRONG_KIND');
    }
    final record = _measurementRecord(
      profileId,
      target.kind,
      input,
      target: target,
    );
    await repository.appendRecord(record);
    return record;
  }
}
