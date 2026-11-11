/// LAB-INTERPRETATION-ENGINE-1 v0.24.0 (F011, D-037).
///
/// Dart port of `packages/domain/src/labInterpretation.ts` (the reference
/// oracle), checked against
/// `contracts/golden_vectors/lab_interpretation_vectors.json`. Reference
/// interval, decision limit, critical rule, method comparability, delta/RCV
/// and personal baseline are SEPARATE channels: reference interval is not an
/// optimal target nor a clinical decision limit, outside reference is not
/// critical. No real clinical threshold is bundled; every rule comes in with
/// the input and keeps its source and version.
///
/// Not wired to the Labs screen (F004 keeps printed details verbatim and
/// interprets nothing). The assessment adds `inputs` and `missingInputs` to
/// the TS shape; states and numbers are the same.
library;

import 'dart:math' as math;

import 'calc_result.dart';
import 'core_derived.dart' show madScale, median, robustZMinSample;

const String labEngineId = 'LAB-INTERPRETATION-ENGINE-1';
const String labEngineVersion = '0.24.0';

/// Rule ID of the synthetic personal-baseline threshold (default 3.5).
const String labBaselineRuleId = 'RULE-LAB-BASELINE-SYNTH-1';
const double labBaselineDefaultThreshold = 3.5;

const List<String> labLimitations = [
  'Reference interval ≠ optimal target ≠ clinical decision limit.',
  'Outside reference ≠ critical; within reference ≠ unchanged for this person.',
  'Software semantics only; fixtures do not validate medical thresholds.',
];

String? _str(Object? v) => v as String?;

/// JavaScript truthiness for an optional string: non-null and non-empty.
bool _truthy(String? s) => s != null && s.isNotEmpty;

/// One lab result (or the prior one) with its method context.
class LabResultInput {
  const LabResultInput({
    required this.analyteKey,
    required this.value,
    required this.unit,
    required this.observedAt,
    required this.methodId,
    required this.specimen,
    this.laboratory,
    this.sourceFlag,
  });

  factory LabResultInput.fromJson(Map<String, Object?> j) => LabResultInput(
    analyteKey: j['analyte_key']! as String,
    value: presentOrNull(j['value']),
    unit: j['unit']! as String,
    observedAt: j['observed_at']! as String,
    methodId: _str(j['method_id']),
    specimen: _str(j['specimen']),
    laboratory: _str(j['laboratory']),
    sourceFlag: _str(j['source_flag']),
  );

  final String analyteKey;

  /// null = not reported (never 0).
  final double? value;
  final String unit;
  final String observedAt;
  final String? methodId;
  final String? specimen;
  final String? laboratory;

  /// Laboratory-printed flag, preserved verbatim.
  final String? sourceFlag;
}

class ReferenceIntervalSnapshot {
  const ReferenceIntervalSnapshot({
    required this.intervalId,
    required this.low,
    required this.high,
    required this.unit,
    required this.specimen,
    required this.methodId,
    required this.source,
    required this.version,
    required this.requiredContext,
  });

  factory ReferenceIntervalSnapshot.fromJson(Map<String, Object?> j) =>
      ReferenceIntervalSnapshot(
        intervalId: j['interval_id']! as String,
        low: presentOrNull(j['low']),
        high: presentOrNull(j['high']),
        unit: j['unit']! as String,
        specimen: _str(j['specimen']),
        methodId: _str(j['method_id']),
        source: j['source']! as String,
        version: j['version']! as String,
        requiredContext: [
          for (final k in j['required_context']! as List<Object?>) k! as String,
        ],
      );

  final String intervalId;
  final double? low;
  final double? high;
  final String unit;
  final String? specimen;
  final String? methodId;
  final String source;
  final String version;

  /// Partition variables the source requires, e.g. age_years.
  final List<String> requiredContext;
}

class DecisionLimitRule {
  const DecisionLimitRule({
    required this.ruleId,
    required this.label,
    required this.threshold,
    required this.direction,
    required this.unit,
    required this.source,
    required this.version,
  });

  factory DecisionLimitRule.fromJson(Map<String, Object?> j) =>
      DecisionLimitRule(
        ruleId: j['rule_id']! as String,
        label: j['label']! as String,
        threshold: (j['threshold']! as num).toDouble(),
        direction: j['direction']! as String,
        unit: j['unit']! as String,
        source: j['source']! as String,
        version: j['version']! as String,
      );

  final String ruleId;
  final String label;
  final double threshold;

  /// AT_OR_ABOVE or BELOW.
  final String direction;
  final String unit;
  final String source;
  final String version;
}

class CriticalRule {
  const CriticalRule({
    required this.ruleId,
    required this.low,
    required this.high,
    required this.unit,
    required this.specimen,
    required this.source,
    required this.version,
    required this.status,
  });

  factory CriticalRule.fromJson(Map<String, Object?> j) => CriticalRule(
    ruleId: j['rule_id']! as String,
    low: presentOrNull(j['low']),
    high: presentOrNull(j['high']),
    unit: j['unit']! as String,
    specimen: _str(j['specimen']),
    source: j['source']! as String,
    version: j['version']! as String,
    status: j['status']! as String,
  );

  final String ruleId;
  final double? low;
  final double? high;
  final String unit;
  final String? specimen;
  final String source;
  final String version;

  /// ACTIVE, STALE or RETIRED.
  final String status;
}

class MethodComparabilityRecord {
  const MethodComparabilityRecord({
    required this.fromMethod,
    required this.toMethod,
    required this.source,
    required this.version,
  });

  factory MethodComparabilityRecord.fromJson(Map<String, Object?> j) =>
      MethodComparabilityRecord(
        fromMethod: j['from_method']! as String,
        toMethod: j['to_method']! as String,
        source: (j['source'] as String?) ?? '',
        version: (j['version'] as String?) ?? '',
      );

  final String fromMethod;
  final String toMethod;
  final String source;
  final String version;
}

class RcvParams {
  const RcvParams({
    required this.cva,
    required this.cvi,
    required this.z,
    required this.source,
  });

  factory RcvParams.fromJson(Map<String, Object?> j) => RcvParams(
    cva: presentOrNull(j['cva']),
    cvi: presentOrNull(j['cvi']),
    z: presentOrNull(j['z']),
    source: j['source']! as String,
  );

  final double? cva;
  final double? cvi;
  final double? z;
  final String source;
}

class LabInterpretationInput {
  const LabInterpretationInput({
    required this.result,
    required this.reference,
    required this.context,
    required this.decisionRules,
    required this.criticalRules,
    required this.prior,
    required this.comparabilityRecords,
    required this.rcv,
    required this.baselinePoints,
    this.baselineThreshold,
  });

  factory LabInterpretationInput.fromJson(Map<String, Object?> j) {
    List<T> list<T>(String k, T Function(Map<String, Object?>) f) => [
      for (final e in (j[k] as List<Object?>?) ?? const <Object?>[])
        f(e! as Map<String, Object?>),
    ];
    final prior = j['prior'] as Map<String, Object?>?;
    final rcv = j['rcv'] as Map<String, Object?>?;
    return LabInterpretationInput(
      result: LabResultInput.fromJson(j['result']! as Map<String, Object?>),
      reference: list('reference', ReferenceIntervalSnapshot.fromJson),
      context: Map.unmodifiable(
        (j['context'] as Map<String, Object?>?) ?? const <String, Object?>{},
      ),
      decisionRules: list('decision_rules', DecisionLimitRule.fromJson),
      criticalRules: list('critical_rules', CriticalRule.fromJson),
      prior: prior == null ? null : LabResultInput.fromJson(prior),
      comparabilityRecords: list(
        'comparability_records',
        MethodComparabilityRecord.fromJson,
      ),
      rcv: rcv == null ? null : RcvParams.fromJson(rcv),
      baselinePoints: [
        for (final p in (j['baseline_points'] as List<Object?>?) ?? const [])
          presentOrNull(p),
      ],
      baselineThreshold: presentOrNull(j['baseline_threshold']),
    );
  }

  final LabResultInput result;
  final List<ReferenceIntervalSnapshot> reference;

  /// Explicit partition context supplied by the user or the report. A
  /// gender identity or profile label never fills it.
  final Map<String, Object?> context;
  final List<DecisionLimitRule> decisionRules;
  final List<CriticalRule> criticalRules;
  final LabResultInput? prior;
  final List<MethodComparabilityRecord> comparabilityRecords;
  final RcvParams? rcv;

  /// Personal history (same analyte, comparable method); null = missing.
  final List<double?> baselinePoints;

  /// Parameter of [labBaselineRuleId]; default 3.5.
  final double? baselineThreshold;
}

// States use the contract spellings (strings), as in the vectors.

class LabFlag {
  const LabFlag(this.origin, this.label);

  /// SOURCE_REPORTED, APP_REFERENCE_COMPARISON or APP_RULE_MATCH.
  final String origin;
  final String label;
}

class LabDecision {
  const LabDecision({
    required this.ruleId,
    required this.label,
    required this.matched,
    required this.source,
    required this.version,
  });

  final String ruleId;
  final String label;
  final bool matched;
  final String source;
  final String version;
}

class LabCritical {
  const LabCritical(this.state, this.ruleId);

  final String state;
  final String? ruleId;

  /// Only an external integration receipt could make this true; this engine
  /// never does.
  bool get externalReceiptConfirmed => false;
}

class LabComparability {
  const LabComparability(this.state, this.trendDiscontinuity, this.record);

  final String state;
  final bool trendDiscontinuity;
  final MethodComparabilityRecord? record;
}

class LabRcv {
  const LabRcv(
    this.state, {
    this.rcvPercent,
    this.observedPercentChange,
    this.source,
  });

  final String state;
  final double? rcvPercent;
  final double? observedPercentChange;
  final String? source;
}

class LabBaseline {
  const LabBaseline(this.state, this.robustZ, this.n);

  final String state;
  final double? robustZ;
  final int n;
}

class LabInterpretationAssessment {
  const LabInterpretationAssessment({
    required this.status,
    required this.value,
    required this.unit,
    required this.flags,
    required this.referenceState,
    required this.interval,
    required this.decision,
    required this.critical,
    required this.comparability,
    required this.rcv,
    required this.baseline,
    required this.inputs,
    required this.missingInputs,
  });

  String get engineId => labEngineId;
  String get engineVersion => labEngineVersion;

  final String status;

  /// The reported value; null when not reported.
  final double? value;
  final String unit;
  final List<LabFlag> flags;
  final String referenceState;
  final ReferenceIntervalSnapshot? interval;
  final List<LabDecision> decision;
  final LabCritical critical;
  final LabComparability comparability;
  final LabRcv rcv;
  final LabBaseline baseline;

  /// Input, as given.
  final LabInterpretationInput inputs;

  /// Inputs whose absence blocked a channel: `result.value`,
  /// `context.<key>`, `prior`, `rcv`, `baseline_points`.
  final List<String> missingInputs;
  List<String> get limitations => labLimitations;
}

/// RCV% = Z × √2 × √(CVa² + CVi²). Refuses missing or negative CVs and a
/// non-positive Z (null).
double? rcvPercent(RcvParams p) {
  final cva = p.cva;
  final cvi = p.cvi;
  final z = p.z;
  if (cva == null || cvi == null || z == null) return null;
  if (cva < 0 || cvi < 0 || z <= 0) return null;
  return z * math.sqrt2 * math.sqrt(cva * cva + cvi * cvi);
}

LabComparability _comparability(
  LabResultInput cur,
  LabResultInput? prior,
  List<MethodComparabilityRecord> records,
) {
  if (prior == null || prior.value == null) {
    return const LabComparability('NO_PRIOR', false, null);
  }
  if (cur.specimen != prior.specimen || cur.unit != prior.unit) {
    return const LabComparability('NOT_COMPARABLE', true, null);
  }
  if (_truthy(cur.methodId) &&
      _truthy(prior.methodId) &&
      cur.methodId == prior.methodId) {
    return const LabComparability('DIRECTLY_COMPARABLE', false, null);
  }
  MethodComparabilityRecord? rec;
  for (final r in records) {
    if ((r.fromMethod == prior.methodId && r.toMethod == cur.methodId) ||
        (r.fromMethod == cur.methodId && r.toMethod == prior.methodId)) {
      rec = r;
      break;
    }
  }
  if (rec != null && _truthy(rec.source) && _truthy(rec.version)) {
    return LabComparability('COMPARABLE_WITH_METHOD_CHANGE_MARKER', true, rec);
  }
  return const LabComparability('UNKNOWN_COMPARABILITY', true, null);
}

/// Key for comparing intervals, with JS-like number text so 4 and 4.0
/// (and 0 and -0) are the same interval.
String _intervalKey(ReferenceIntervalSnapshot c) {
  String n(double? x) => x == null
      ? 'null'
      : x == x.truncateToDouble() && x.abs() < 1e21
      ? x.toInt().toString()
      : '$x';
  return '${n(c.low)}|${n(c.high)}|${c.unit}';
}

bool _contextMissing(Object? v) => v == null || v == '';

LabInterpretationAssessment interpretLabResult(LabInterpretationInput input) {
  final r = input.result;
  final flags = <LabFlag>[];
  if (_truthy(r.sourceFlag)) {
    flags.add(LabFlag('SOURCE_REPORTED', r.sourceFlag!));
  }

  final x = r.value;
  if (x == null) {
    return LabInterpretationAssessment(
      status: 'VALUE_NOT_REPORTED',
      value: null,
      unit: r.unit,
      flags: List.unmodifiable(flags),
      referenceState: 'NO_REFERENCE',
      interval: null,
      decision: const [],
      critical: const LabCritical('NO_ACTIVE_RULE', null),
      comparability: const LabComparability('NO_PRIOR', false, null),
      rcv: const LabRcv('NO_PRIOR'),
      baseline: const LabBaseline('INSUFFICIENT_HISTORY', null, 0),
      inputs: input,
      missingInputs: const ['result.value'],
    );
  }
  final missing = <String>[];

  // Reference interval selection and comparison (after unit compatibility).
  var refState = 'NO_REFERENCE';
  ReferenceIntervalSnapshot? interval;
  final candidates = [
    for (final ri in input.reference)
      if (ri.specimen == null || ri.specimen == r.specimen) ri,
  ];
  if (candidates.length > 1 &&
      {for (final c in candidates) _intervalKey(c)}.length > 1) {
    refState = 'CONFLICTING_REFERENCE_SOURCES';
  }
  if (refState != 'CONFLICTING_REFERENCE_SOURCES' && candidates.isNotEmpty) {
    final iv = interval = candidates.first;
    final missingCtx = [
      for (final k in iv.requiredContext)
        if (_contextMissing(input.context[k])) k,
    ];
    final low = iv.low;
    final high = iv.high;
    if (iv.unit != r.unit) {
      refState = 'UNIT_NOT_COMPARABLE';
    } else if (_truthy(iv.methodId) &&
        _truthy(r.methodId) &&
        iv.methodId != r.methodId) {
      refState = 'METHOD_NOT_COMPARABLE';
    } else if (missingCtx.isNotEmpty) {
      refState = 'INSUFFICIENT_REFERENCE_CONTEXT';
      missing.addAll([for (final k in missingCtx) 'context.$k']);
    } else if (low == null && high == null) {
      refState = 'NO_REFERENCE';
    } else if (low != null && x < low) {
      refState = 'BELOW_REFERENCE';
    } else if (high != null && x > high) {
      refState = 'ABOVE_REFERENCE';
    } else {
      refState = 'WITHIN_REFERENCE';
    }
  }
  if (refState == 'BELOW_REFERENCE' || refState == 'ABOVE_REFERENCE') {
    flags.add(LabFlag('APP_REFERENCE_COMPARISON', refState));
  }

  // Clinical decision limits, evaluated separately from the reference.
  final decision = [
    for (final d in input.decisionRules)
      if (d.unit == r.unit)
        LabDecision(
          ruleId: d.ruleId,
          label: d.label,
          matched: d.direction == 'AT_OR_ABOVE'
              ? x >= d.threshold
              : x < d.threshold,
          source: d.source,
          version: d.version,
        ),
  ];
  for (final d in decision) {
    if (d.matched) flags.add(LabFlag('APP_RULE_MATCH', d.ruleId));
  }

  // Critical rules: independent of the reference interval, never invented.
  var critical = const LabCritical('NO_ACTIVE_RULE', null);
  final crit = [
    for (final c in input.criticalRules)
      if (c.status != 'RETIRED' &&
          (c.specimen == null || c.specimen == r.specimen))
        c,
  ];
  final stale = crit.where((c) => c.status == 'STALE').firstOrNull;
  final active = [
    for (final c in crit)
      if (c.status == 'ACTIVE') c,
  ];
  if (stale != null && active.isEmpty) {
    critical = LabCritical('RULE_PACK_STALE', stale.ruleId);
  }
  for (final c in active) {
    if (c.unit != r.unit) {
      critical = LabCritical('UNIT_NOT_COMPARABLE', c.ruleId);
      continue;
    }
    final low = c.low;
    final high = c.high;
    if (low != null && x < low) {
      critical = LabCritical('SOURCE_DEFINED_CRITICAL_LOW_MATCHED', c.ruleId);
      break;
    }
    if (high != null && x > high) {
      critical = LabCritical('SOURCE_DEFINED_CRITICAL_HIGH_MATCHED', c.ruleId);
      break;
    }
    critical = LabCritical('NO_MATCH', c.ruleId);
  }
  if (critical.state.startsWith('SOURCE_DEFINED')) {
    flags.add(LabFlag('APP_RULE_MATCH', critical.state));
  }

  // Longitudinal method comparability.
  final comparability = _comparability(
    r,
    input.prior,
    input.comparabilityRecords,
  );

  // Delta / RCV: blocked unless directly comparable.
  var rcv = const LabRcv('NO_PRIOR');
  final params = input.rcv;
  if (comparability.state == 'NO_PRIOR') {
    missing.add('prior');
  } else if (comparability.state != 'DIRECTLY_COMPARABLE') {
    rcv = const LabRcv('BLOCKED_BY_COMPARABILITY');
  } else if (params == null) {
    rcv = const LabRcv('NO_RCV_SOURCE');
    missing.add('rcv');
  } else {
    final pct = rcvPercent(params);
    final prior = input.prior!.value!;
    if (pct == null) {
      rcv = LabRcv('INVALID_CV_INPUT', source: params.source);
    } else if (prior == 0) {
      rcv = LabRcv('ZERO_PRIOR', rcvPercent: pct, source: params.source);
    } else {
      final obs = ((x - prior) / prior) * 100;
      rcv = LabRcv(
        obs.abs() > pct ? 'EXCEEDS_RCV' : 'WITHIN_RCV',
        rcvPercent: pct,
        observedPercentChange: obs,
        source: params.source,
      );
    }
  }

  // Personal baseline: separate from the population reference.
  final pts = [
    for (final p in input.baselinePoints)
      if (p != null && p.isFinite) p,
  ]..sort();
  var baseline = LabBaseline('INSUFFICIENT_HISTORY', null, pts.length);
  if (pts.length >= robustZMinSample) {
    final med = median(pts);
    final mad = median([for (final p in pts) (p - med).abs()]..sort());
    if (mad == 0) {
      baseline = LabBaseline('ZERO_MAD', null, pts.length);
    } else {
      final z = (x - med) / (madScale * mad);
      final thr = input.baselineThreshold ?? labBaselineDefaultThreshold;
      baseline = LabBaseline(
        z.abs() >= thr ? 'UNUSUAL_FOR_PERSON' : 'WITHIN_PERSONAL_BASELINE',
        z,
        pts.length,
      );
    }
  } else {
    missing.add('baseline_points');
  }

  var status = 'SUCCESS';
  if (refState == 'UNIT_NOT_COMPARABLE') {
    status = 'UNIT_BLOCKED';
  } else if (refState == 'METHOD_NOT_COMPARABLE') {
    status = 'METHOD_BLOCKED';
  } else if (refState == 'INSUFFICIENT_REFERENCE_CONTEXT') {
    status = 'INSUFFICIENT_CONTEXT';
  } else if (refState == 'CONFLICTING_REFERENCE_SOURCES') {
    status = 'CONFLICTING_REFERENCE_SOURCES';
  } else if (critical.state == 'RULE_PACK_STALE') {
    status = 'RULE_PACK_STALE';
  } else if (refState == 'NO_REFERENCE') {
    status = 'NO_APPLICABLE_REFERENCE';
  }

  return LabInterpretationAssessment(
    status: status,
    value: x,
    unit: r.unit,
    flags: List.unmodifiable(flags),
    referenceState: refState,
    interval: interval,
    decision: List.unmodifiable(decision),
    critical: critical,
    comparability: comparability,
    rcv: rcv,
    baseline: baseline,
    inputs: input,
    missingInputs: List.unmodifiable(missing),
  );
}
