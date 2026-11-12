/// PREVENTIVE-ENGINE-1 v0.23.0 (F011, D-038).
///
/// Dart port of `packages/domain/src/preventive.ts` (the reference oracle,
/// with `dates.ts`), checked against
/// `contracts/golden_vectors/preventive_vectors.json`. Evaluation order:
/// jurisdiction → pack status → applicability → eligibility →
/// contraindication → recommendation mode → history quality →
/// series/interval timing → due state → explanation. Ships with the
/// synthetic pack RP-PREVENTIVE-SYNTHETIC-1 only; no real national pack is
/// ACTIVE. Unknown history is not "never done"; a due state is a timing
/// state from an installed source rule, never a diagnosis and never a
/// recommendation by this engine; screening ≠ diagnosis.
///
/// Not wired to any screen. The assessment adds `engineId`, `inputs`,
/// `missingInputs` and `limitations` to the TS shape (TS carries no
/// limitations array; the Dart text restates the TS module's own header).
library;

const String preventiveEngineId = 'PREVENTIVE-ENGINE-1';
const String preventiveEngineVersion = '0.23.0';

const List<String> preventiveLimitations = [
  'Ships with the synthetic pack RP-PREVENTIVE-SYNTHETIC-1 only; no real national pack is ACTIVE.',
  'A due state is a timing state from an installed source rule; it is not a diagnosis and this engine recommends nothing.',
  'Unknown history ≠ never done; jurisdiction is never inferred and never falls back to another country.',
];

String? _str(Object? v) => v as String?;
List<String> _strings(Object? v) => [
  for (final s in (v as List<Object?>?) ?? const []) s! as String,
];

/// JavaScript `String(x)` for the numbers and nulls the texts print.
String _js(num? n) {
  if (n == null) return 'null';
  return n.isFinite && n == n.truncateToDouble() ? n.toInt().toString() : '$n';
}

// --- Calendar-date arithmetic on ISO dates (YYYY-MM-DD), timezone-free. ---

const int _dayMs = 86400000;

/// Days since 1970-01-01 of the date part of [iso] (as `dates.ts`).
int toDayNumber(String iso) {
  final head = iso.length > 10 ? iso.substring(0, 10) : iso;
  final p = head.split('-');
  if (p.length < 3) throw FormatException('not an ISO date', iso);
  final d = DateTime.utc(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  return (d.millisecondsSinceEpoch / _dayMs).floor();
}

/// The ISO date of day number [n] (a fractional day keeps its date part).
String fromDayNumber(num n) {
  final d = DateTime.fromMillisecondsSinceEpoch(
    (n * _dayMs).truncate(),
    isUtc: true,
  );
  String two(int x) => x.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
}

String addDays(String iso, num days) => fromDayNumber(toDayNumber(iso) + days);

int daysBetween(String a, String b) => toDayNumber(b) - toDayNumber(a);

// --- Rules and input. ---

class SeriesSpec {
  const SeriesSpec(this.doses, this.minIntervalDays);
  final num doses;
  final num minIntervalDays;
}

class PreventiveRule {
  const PreventiveRule({
    required this.ruleId,
    required this.serviceId,
    required this.serviceLabel,
    required this.packId,
    required this.packVersion,
    required this.packStatus,
    required this.precedence,
    required this.jurisdiction,
    required this.sourceSnapshotId,
    required this.sourceGrade,
    required this.mode,
    required this.minAge,
    required this.maxAge,
    required this.requiresRisk,
    required this.requiresAnatomy,
    required this.intervalDays,
    required this.series,
  });

  factory PreventiveRule.fromJson(Map<String, Object?> j) {
    final s = j['series'] as Map<String, Object?>?;
    return PreventiveRule(
      ruleId: j['rule_id']! as String,
      serviceId: j['service_id']! as String,
      serviceLabel: j['service_label']! as String,
      packId: j['pack_id']! as String,
      packVersion: j['pack_version']! as String,
      packStatus: j['pack_status']! as String,
      precedence: j['precedence']! as num,
      jurisdiction: j['jurisdiction']! as String,
      sourceSnapshotId: j['source_snapshot_id']! as String,
      sourceGrade: _str(j['source_grade']),
      mode: j['mode']! as String,
      minAge: j['min_age'] as num?,
      maxAge: j['max_age'] as num?,
      requiresRisk: _str(j['requires_risk']),
      requiresAnatomy: _str(j['requires_anatomy']),
      intervalDays: j['interval_days'] as num?,
      series: s == null
          ? null
          : SeriesSpec(s['doses']! as num, s['min_interval_days']! as num),
    );
  }

  final String ruleId;
  final String serviceId;
  final String serviceLabel;
  final String packId;
  final String packVersion;

  /// `ACTIVE`, `STALE` or `RETIRED`.
  final String packStatus;
  final num precedence;
  final String jurisdiction;
  final String sourceSnapshotId;
  final String? sourceGrade;

  /// `ROUTINE`, `SHARED_DECISION`, `EVIDENCE_INSUFFICIENT` or
  /// `AGAINST_ROUTINE` (the source's mode, kept as given).
  final String mode;
  final num? minAge;
  final num? maxAge;
  final String? requiresRisk;

  /// Anatomy, never gender identity as a proxy.
  final String? requiresAnatomy;
  final num? intervalDays;
  final SeriesSpec? series;
}

class PreventiveInput {
  const PreventiveInput({
    required this.asOf,
    required this.jurisdiction,
    required this.ageYears,
    required this.risks,
    required this.anatomy,
    required this.history,
    required this.completions,
    required this.contraindicated,
    required this.dueSoonWindowDays,
  });

  factory PreventiveInput.fromJson(Map<String, Object?> j) => PreventiveInput(
    asOf: j['as_of']! as String,
    jurisdiction: _str(j['jurisdiction']),
    ageYears: j['age_years'] as num?,
    risks: _strings(j['risks']),
    anatomy: _strings(j['anatomy']),
    history: j['history']! as String,
    completions: _strings(j['completions']),
    contraindicated: j['contraindicated']! as bool,
    dueSoonWindowDays: j['due_soon_window_days']! as num,
  );

  final String asOf;
  final String? jurisdiction;

  /// Null when unknown (never 0).
  final num? ageYears;
  final List<String> risks;
  final List<String> anatomy;

  /// `KNOWN` (completions list is complete) or `UNKNOWN` (≠ never done).
  final String history;
  final List<String> completions;
  final bool contraindicated;
  final num dueSoonWindowDays;
}

class PreventivePackRef {
  const PreventivePackRef(this.packId, this.version);
  final String packId;
  final String version;
}

class PreventiveAssessment {
  PreventiveAssessment._(this.serviceId, this.serviceLabel, this.inputs)
    : jurisdiction = inputs.jurisdiction;

  String get engineId => preventiveEngineId;
  String get engineVersion => preventiveEngineVersion;

  String? ruleId;
  final String serviceId;
  final String serviceLabel;
  PreventivePackRef? pack;
  final String? jurisdiction;

  /// ELIGIBLE, NOT_ELIGIBLE, NOT_APPLICABLE_JURISDICTION or UNKNOWN.
  String eligibilityState = 'UNKNOWN';
  String? recommendationMode;

  /// DUE_NOW, DUE_SOON, UP_TO_DATE, OVERDUE, UNKNOWN_HISTORY, TOO_EARLY,
  /// SERIES_COMPLETE, NOT_APPLICABLE or REVIEW_REQUIRED.
  String dueState = 'NOT_APPLICABLE';

  /// ASSESSED, NOT_APPLICABLE_JURISDICTION, NO_ACTIVE_PACK, PACK_STALE,
  /// PACK_CONFLICT or BLOCKED_CONTRAINDICATION.
  String assessmentStatus = 'ASSESSED';
  String? nextDueDate;
  final List<String> explanation = [];

  /// Input, as given.
  final PreventiveInput inputs;

  /// Unknown inputs: `jurisdiction`, `age_years`, `history` (UNKNOWN).
  final List<String> missingInputs = [];
  List<String> get limitations => preventiveLimitations;
}

/// Assesses one service against the installed rules, in the reference
/// order (see the library comment).
PreventiveAssessment assessService(
  String serviceId,
  List<PreventiveRule> rules,
  PreventiveInput input,
) {
  final forService = rules
      .where((r) => r.serviceId == serviceId && r.packStatus != 'RETIRED')
      .toList();
  final label = forService.isEmpty ? serviceId : forService.first.serviceLabel;
  final out = PreventiveAssessment._(serviceId, label, input);
  final jur = input.jurisdiction;
  if (jur == null || jur.isEmpty) out.missingInputs.add('jurisdiction');
  if (input.ageYears == null) out.missingInputs.add('age_years');
  if (input.history == 'UNKNOWN') out.missingInputs.add('history');

  // 1. Jurisdiction: explicit only; never inferred, never a silent fallback.
  if (jur == null || jur.isEmpty) {
    out.assessmentStatus = 'NO_ACTIVE_PACK';
    out.explanation.add(
      'No guideline jurisdiction selected; nothing is assumed.',
    );
    return out;
  }
  final inJur = forService.where((r) => r.jurisdiction == jur).toList();
  if (inJur.isEmpty) {
    out.eligibilityState = 'NOT_APPLICABLE_JURISDICTION';
    out.assessmentStatus = 'NOT_APPLICABLE_JURISDICTION';
    out.explanation.add(
      'No rule for $serviceId in jurisdiction $jur; not "overdue".',
    );
    return out;
  }
  // 2. Pack status / conflict.
  final active = inJur.where((r) => r.packStatus == 'ACTIVE').toList();
  if (active.isEmpty) {
    final s = inJur.first;
    out.ruleId = s.ruleId;
    out.pack = PreventivePackRef(s.packId, s.packVersion);
    out.assessmentStatus = 'PACK_STALE';
    out.explanation.add(
      'Only a stale pack covers this service; no fresh conclusion is presented.',
    );
    return out;
  }
  final top = active.map((r) => r.precedence).reduce((a, b) => a >= b ? a : b);
  final winners = active.where((r) => r.precedence == top).toList();
  if (winners.length > 1) {
    final signatures = {
      for (final r in winners)
        '${r.mode}|${_js(r.intervalDays)}|${_js(r.minAge)}|${_js(r.maxAge)}',
    };
    if (signatures.length > 1) {
      out.assessmentStatus = 'PACK_CONFLICT';
      out.explanation.add(
        'Equal-precedence packs disagree: ${winners.map((w) => w.packId).join(', ')}.',
      );
      return out;
    }
  }
  final rule = winners.first;
  out.ruleId = rule.ruleId;
  out.pack = PreventivePackRef(rule.packId, rule.packVersion);
  out.recommendationMode = rule.mode;
  final grade = rule.sourceGrade;
  out.explanation.add(
    'Rule ${rule.ruleId} (${rule.packId}@${rule.packVersion}, source ${rule.sourceSnapshotId}${grade != null && grade.isNotEmpty ? ', grade $grade' : ''}).',
  );

  // 3–4. Applicability / eligibility (anatomy, never gender identity).
  final age = input.ageYears;
  if (age == null) {
    out.eligibilityState = 'UNKNOWN';
    out.dueState = 'REVIEW_REQUIRED';
    out.explanation.add('Age unknown; eligibility cannot be determined.');
    return out;
  }
  final ageOk =
      (rule.minAge == null || age >= rule.minAge!) &&
      (rule.maxAge == null || age <= rule.maxAge!);
  final riskOk =
      rule.requiresRisk == null || input.risks.contains(rule.requiresRisk);
  final anatomyOk =
      rule.requiresAnatomy == null ||
      input.anatomy.contains(rule.requiresAnatomy);
  if (!ageOk || !riskOk || !anatomyOk) {
    out.eligibilityState = 'NOT_ELIGIBLE';
    out.explanation.add(
      !ageOk
          ? 'Age outside rule range.'
          : !riskOk
          ? 'Required risk factor absent.'
          : 'Required anatomy absent.',
    );
    return out;
  }
  out.eligibilityState = 'ELIGIBLE';

  // 5. Contraindication blocks routine scheduling (≠ AGAINST_ROUTINE).
  if (input.contraindicated) {
    out.assessmentStatus = 'BLOCKED_CONTRAINDICATION';
    out.dueState = 'REVIEW_REQUIRED';
    out.explanation.add(
      'Contraindication/precaution recorded; clinician review required.',
    );
    return out;
  }
  // 6. Recommendation mode: non-routine modes never manufacture a schedule.
  if (rule.mode == 'SHARED_DECISION') {
    out.dueState = 'REVIEW_REQUIRED';
    out.explanation.add(
      'Shared decision: discuss benefits/harms; never shown as overdue.',
    );
    return out;
  }
  if (rule.mode == 'EVIDENCE_INSUFFICIENT' || rule.mode == 'AGAINST_ROUTINE') {
    out.dueState = 'NOT_APPLICABLE';
    out.explanation.add(
      rule.mode == 'AGAINST_ROUTINE'
          ? 'Source recommends against routine use (not a contraindication).'
          : 'Evidence insufficient; no schedule is invented.',
    );
    return out;
  }
  // 7. History quality: unknown is not "never done".
  if (input.history == 'UNKNOWN') {
    out.dueState = 'UNKNOWN_HISTORY';
    out.explanation.add(
      'History unknown; add or import records. Not treated as never done.',
    );
    return out;
  }
  final done =
      input.completions.where((d) => d.compareTo(input.asOf) <= 0).toList()
        ..sort();
  // 8a. Series logic.
  final series = rule.series;
  if (series != null) {
    if (done.length >= series.doses) {
      out.dueState = 'SERIES_COMPLETE';
      out.explanation.add(
        '${done.length}/${_js(series.doses)} doses recorded; series is not restarted.',
      );
      return out;
    }
    if (done.isEmpty) {
      out.dueState = 'DUE_NOW';
      out.nextDueDate = input.asOf;
      return out;
    }
    final last = done.last;
    final earliest = addDays(last, series.minIntervalDays);
    out.nextDueDate = earliest;
    out.dueState = input.asOf.compareTo(earliest) < 0 ? 'TOO_EARLY' : 'DUE_NOW';
    out.explanation.add(
      'Dose ${done.length + 1}/${_js(series.doses)}: minimum interval ${_js(series.minIntervalDays)} days after $last.',
    );
    return out;
  }
  // 8b. Interval logic.
  if (done.isEmpty) {
    out.dueState = 'DUE_NOW';
    out.nextDueDate = input.asOf;
    out.explanation.add('Eligible, routine, known history with no completion.');
    return out;
  }
  final interval = rule.intervalDays;
  if (interval == null) {
    out.dueState = 'UP_TO_DATE';
    out.explanation.add('One-time service already completed.');
    return out;
  }
  final last = done.last;
  final next = addDays(last, interval);
  out.nextDueDate = next;
  final until = daysBetween(input.asOf, next);
  // 9. Due state. The UI notification window never changes the due date.
  if (until > input.dueSoonWindowDays) {
    out.dueState = 'UP_TO_DATE';
  } else if (until > 0) {
    out.dueState = 'DUE_SOON';
  } else if (until == 0) {
    out.dueState = 'DUE_NOW';
  } else {
    out.dueState = 'OVERDUE';
  }
  if (out.dueState == 'OVERDUE') {
    out.explanation.add(
      'OVERDUE is a timing state, not blame; no backlog is stacked.',
    );
  }
  return out;
}
