/// Record use cases: a local SELF profile, canonical body-weight observations
/// (F002) and their timeline with corrections, withdrawals and deletions
/// (F003), lab results as printed (F004) and measurements typed by hand
/// (F007), all through the [HealthRepository] port.
library;

import '../core/ids.dart';
import 'input_error.dart';
import 'measured_at.dart';
import '../domain/ports/health_repository.dart';
import '../domain/profile/profile.dart';
import '../domain/records/health_record.dart';

export 'input_error.dart';

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
    this.when = '',
  });

  final String value;
  final String systolic;
  final String diastolic;
  final String context;

  /// The time typed in the "When" field; blank means the save time.
  final String when;
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
    final value = parseLabDecimal(input);
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
    if (isFutureTime(when, now)) throw const InputError('FUTURE_TIME');
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
    // Hundreds of digits overflow to infinity: not a number a person measured.
    if (!v.isFinite) throw InputError('NOT_A_NUMBER', field);
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
    if (context.runes.length > HealthRecord.maxContextLength) {
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
      final number = _measurementNumber(input.value, 'value');
      // Definitional, not clinical: a percentage cannot be above 100. An
      // entry rule only; stored records are not re-judged (D-018).
      if (kind == RecordKind.oxygenSaturation && number > 100) {
        throw const InputError('OUT_OF_DEFINITION', 'value');
      }
      quantity = Quantity(number, kind.unit);
      originalText = input.value.trim();
    }
    final now = clock.nowUtc();
    // A correction is the same observation and keeps its time (a time typed
    // for it is not read); a new entry takes the typed time, or the save
    // time. Resolved once, before the record is built.
    final observedAt = target != null
        ? target.observedAt
        : parseMeasuredAt(input.when, nowUtc: now) ?? now;
    return HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: kind,
      state: RecordState.observed,
      valueStatus: ValueStatus.present,
      quantity: quantity,
      originalText: originalText,
      provenance: const Provenance.manual(),
      observedAt: observedAt,
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

  // Medicines and supplements (F008). The person's own words, kept as
  // typed. A plan is never turned into doses; only a recorded dose says
  // what was taken.

  static String? _medsText(String raw, String field, {bool required = false}) {
    final t = raw.trim();
    if (t.isEmpty) {
      if (required) throw InputError('EMPTY', field);
      return null;
    }
    if (t.runes.length > maxMedicationText) {
      throw InputError('TEXT_TOO_LONG', field);
    }
    return t;
  }

  /// The live medicine or supplement whose first version is [itemRootId].
  Future<TimelineEntry> _liveItem(String profileId, String itemRootId) async {
    final entries = buildTimeline(
      await repository.records(profileId, kind: RecordKind.medicationItem),
    );
    for (final e in entries) {
      if (e.rootId == itemRootId) return e;
    }
    throw const InputError('TARGET_NOT_FOUND');
  }

  HealthRecord _medsRecord(
    String profileId,
    RecordKind kind,
    RecordDetails details, {
    DateTime? observedAt,
  }) {
    final now = clock.nowUtc();
    return HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: kind,
      state: RecordState.reported,
      valueStatus: ValueStatus.present,
      quantity: null,
      originalText: null,
      provenance: const Provenance.manual(),
      observedAt: observedAt ?? now,
      recordedAt: now,
      details: details,
      schemaVersion: HealthRecord.writeSchemaFor(kind),
    );
  }

  /// Adds a medicine or supplement the person uses (the product, as named).
  Future<HealthRecord> addMedication({
    required String profileId,
    required String name,
    required MedicationCategory category,
    String ingredients = '',
    String strength = '',
    String form = '',
  }) async {
    final record = _medsRecord(
      profileId,
      RecordKind.medicationItem,
      MedicationItemDetails(
        name: _medsText(name, 'name', required: true)!,
        category: category,
        ingredients: _medsText(ingredients, 'ingredients'),
        strength: _medsText(strength, 'strength'),
        form: _medsText(form, 'form'),
      ),
    );
    await repository.appendRecord(record);
    return record;
  }

  /// Writes how a medicine or supplement is meant to be taken. A newer plan
  /// for the same item replaces the shown one; older plans stay in history.
  Future<HealthRecord> planMedication({
    required String profileId,
    required String itemRootId,
    required String schedule,
    PlanSource source = PlanSource.unknown,
  }) async {
    await _liveItem(profileId, itemRootId);
    // A new wording keeps a paused or stopped plan paused or stopped: only
    // setPlanState changes the state.
    final earlier = _latest(
      await repository.records(profileId, kind: RecordKind.medicationPlan),
      itemRootId,
    );
    final record = _medsRecord(
      profileId,
      RecordKind.medicationPlan,
      MedicationPlanDetails(
        itemRootId: itemRootId,
        schedule: _medsText(schedule, 'schedule', required: true)!,
        source: source,
        state: earlier?.state ?? PlanState.active,
      ),
    );
    await repository.appendRecord(record);
    return record;
  }

  /// Pauses, stops or resumes the shown plan of an item: a new plan record
  /// with the same words and source and the new [state]; the earlier plan
  /// stays in history. Refused when there is no plan to change.
  Future<HealthRecord> setPlanState({
    required String profileId,
    required String itemRootId,
    required PlanState state,
  }) async {
    await _liveItem(profileId, itemRootId);
    final all = await repository.records(
      profileId,
      kind: RecordKind.medicationPlan,
    );
    final current = _latest(all, itemRootId);
    if (current == null) throw const InputError('TARGET_NOT_FOUND');
    if (current.state == state) throw const InputError('NO_CHANGE');
    final record = _medsRecord(
      profileId,
      RecordKind.medicationPlan,
      MedicationPlanDetails(
        itemRootId: itemRootId,
        schedule: current.schedule,
        source: current.source,
        state: state,
      ),
    );
    await repository.appendRecord(record);
    return record;
  }

  /// Records one dose the person took or skipped, at the typed time or now.
  Future<HealthRecord> recordDose({
    required String profileId,
    required String itemRootId,
    required IntakeStatus status,
    String amount = '',
    String when = '',
  }) async {
    await _liveItem(profileId, itemRootId);
    final now = clock.nowUtc();
    final record = _medsRecord(
      profileId,
      RecordKind.medicationIntake,
      MedicationIntakeDetails(
        itemRootId: itemRootId,
        status: status,
        amount: _medsText(amount, 'amount'),
      ),
      observedAt: parseMeasuredAt(when, nowUtc: now) ?? now,
    );
    await repository.appendRecord(record);
    return record;
  }

  /// Records one night: going to bed and waking up as typed. A blank
  /// waking time is now. A going-to-bed time without a date (`HH:MM`) is the
  /// last such time before waking, so "23:10" then "07:00" is one night.
  Future<HealthRecord> recordSleep({
    required String profileId,
    required String wentToBed,
    String wokeUp = '',
    WakeFeeling? feeling,
    LocalZone zone = const SystemLocalZone(),
  }) async {
    final now = clock.nowUtc();
    final bedText = wentToBed.trim();
    if (bedText.isEmpty) throw const InputError('EMPTY', 'bed');
    // Each error names the field it is about.
    T inField<T>(String field, T Function() read) {
      try {
        return read();
      } on InputError catch (e) {
        throw InputError(e.code, field);
      }
    }

    final up = inField(
      'woke',
      () => parseMeasuredAt(wokeUp, nowUtc: now, zone: zone) ?? now,
    );
    final bed = inField('bed', () {
      if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(bedText)) {
        return parseMeasuredAt(bedText, nowUtc: now, zone: zone)!;
      }
      String on(DateTime wall) =>
          '${wall.year.toString().padLeft(4, '0')}-'
          '${wall.month.toString().padLeft(2, '0')}-'
          '${wall.day.toString().padLeft(2, '0')} $bedText';
      final upWall = zone.toLocal(up);
      DateTime? sameDay;
      try {
        sameDay = parseMeasuredAt(on(upWall), nowUtc: now, zone: zone);
      } on InputError catch (e) {
        if (e.code != 'FUTURE_TIME') rethrow;
      }
      if (sameDay != null && sameDay.isBefore(up)) return sameDay;
      final dayBefore = DateTime.utc(upWall.year, upWall.month, upWall.day - 1);
      return parseMeasuredAt(on(dayBefore), nowUtc: now, zone: zone)!;
    });
    final details = SleepNightDetails(
      wentToBed: bed,
      wokeUp: up,
      feeling: feeling,
    );
    final problem = details.problem();
    if (problem != null) throw InputError(problem, 'bed');
    final record = HealthRecord(
      id: _ids.newId(),
      profileId: profileId,
      kind: RecordKind.sleepNight,
      state: RecordState.reported,
      valueStatus: ValueStatus.present,
      quantity: null,
      originalText: null,
      provenance: const Provenance.manual(),
      observedAt: up,
      recordedAt: now,
      details: details,
      schemaVersion: HealthRecord.writeSchemaFor(RecordKind.sleepNight),
    );
    await repository.appendRecord(record);
    return record;
  }

  /// The live nights, the latest waking first.
  Future<List<HealthRecord>> sleepNights(String profileId) async {
    final all = await repository.records(
      profileId,
      kind: RecordKind.sleepNight,
    );
    final heads = [
      for (final e in buildTimeline(all))
        for (final h in e.heads)
          if (h.details is SleepNightDetails) h,
    ]..sort((a, b) => b.observedAt.compareTo(a.observedAt));
    return heads;
  }

  /// Each live medicine or supplement with its newest live plan and its
  /// recorded doses (newest first). Doses come only from dose records.
  Future<List<MedicationView>> medications(String profileId) async {
    final all = await repository.records(profileId);
    List<TimelineEntry> of(RecordKind k) =>
        buildTimeline(all.where((r) => r.kind == k));
    final planRecords = [
      for (final r in all)
        if (r.kind == RecordKind.medicationPlan) r,
    ];
    final doses = of(RecordKind.medicationIntake);
    return [
      for (final e in of(RecordKind.medicationItem))
        if (e.heads.isNotEmpty && e.shown.details is MedicationItemDetails)
          MedicationView(
            rootId: e.rootId,
            item: e.shown.details! as MedicationItemDetails,
            itemRecord: e.shown,
            plan: _latest(planRecords, e.rootId),
            doses: [
              for (final d in doses)
                for (final h in d.heads)
                  if (h.details is MedicationIntakeDetails &&
                      (h.details! as MedicationIntakeDetails).itemRootId ==
                          e.rootId)
                    h,
            ]..sort((a, b) => b.observedAt.compareTo(a.observedAt)),
          ),
    ];
  }

  /// The shown plan of an item among [stored] plan records (in the order
  /// they were written): the live one saved last; on equal save times (a
  /// coarse clock) the one written later.
  static MedicationPlanDetails? _latest(
    List<HealthRecord> stored,
    String itemRootId,
  ) {
    final written = {for (var i = 0; i < stored.length; i++) stored[i].id: i};
    HealthRecord? best;
    for (final p in buildTimeline(stored)) {
      for (final h in p.heads) {
        final d = h.details;
        if (d is! MedicationPlanDetails || d.itemRootId != itemRootId) continue;
        if (best == null ||
            h.recordedAt.isAfter(best.recordedAt) ||
            (h.recordedAt == best.recordedAt &&
                written[h.id]! > written[best.id]!)) {
          best = h;
        }
      }
    }
    return best?.details as MedicationPlanDetails?;
  }
}

/// One medicine or supplement as Human OS shows it (F008).
class MedicationView {
  const MedicationView({
    required this.rootId,
    required this.item,
    required this.itemRecord,
    required this.plan,
    required this.doses,
  });

  final String rootId;
  final MedicationItemDetails item;
  final HealthRecord itemRecord;
  final MedicationPlanDetails? plan;

  /// Dose records only, newest first.
  final List<HealthRecord> doses;

  int count(IntakeStatus s) => doses
      .where((d) => (d.details! as MedicationIntakeDetails).status == s)
      .length;
}
