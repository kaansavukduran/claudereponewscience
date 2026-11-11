/// MP-CORE-DERIVED-1: transparent deterministic calculations (F011, D-037).
///
/// Dart port of `packages/domain/src/coreDerived.ts` (the reference oracle),
/// checked against `contracts/golden_vectors/core_derived_vectors.json`.
/// Same formulas, same order of arithmetic, same error codes. Missing
/// observations are excluded, never zero-filled; a refused calculation has
/// no value. Each function takes the inputs as a map with the contract's
/// key names, so a result can carry its inputs exactly as given.
///
/// Where the TS reference would throw on a missing list (`sets`, `values`,
/// `points`, `series`), this port refuses with MISSING_INPUT instead.
library;

import 'calc_result.dart';

/// The model pack these models belong to.
const String coreDerivedPackId = 'MP-CORE-DERIVED-1';
const String coreDerivedPackVersion = '1.0.0';

ModelRef _ref(String id, String? unit, [List<String> limitations = const []]) =>
    ModelRef(
      modelId: id,
      version: '1',
      resultClass: ResultClass.derivedMeasurement,
      unit: unit,
      limitations: limitations,
    );

/// The models of MP-CORE-DERIVED-1, all version 1.
abstract final class CoreDerivedModels {
  static final ModelRef bmi = _ref('DERIVED-BMI-1', 'kg/m2', [
    'Number only; no diagnostic category is assigned by this formula.',
  ]);
  static final ModelRef waistHeightRatio = _ref(
    'DERIVED-WAIST_HEIGHT_RATIO-1',
    '1',
    ['No universal good/bad threshold is bundled with this formula.'],
  );
  static final ModelRef packYears = _ref('DERIVED-PACK_YEARS-1', 'pack-years', [
    'Exposure measure, not a mortality probability.',
  ]);
  static final ModelRef percentChange = _ref('DERIVED-PERCENT_CHANGE-1', '%');
  static final ModelRef absoluteDelta = _ref('DERIVED-ABSOLUTE_DELTA-1', null);
  static final ModelRef volumeLoad = _ref(
    'DERIVED-TRAINING_VOLUME_LOAD-1',
    'kg',
    ['Planned sets are excluded until completed.'],
  );
  static final ModelRef rollingMean = _ref('DERIVED-ROLLING_MEAN-1', null);
  static final ModelRef rollingMedian = _ref('DERIVED-ROLLING_MEDIAN-1', null);
  static final ModelRef olsSlope = _ref(
    'DERIVED-TREND-SLOPE-OLS-1',
    'unit/day',
    ['Trend estimator, not a clinical prediction.'],
  );
  static final ModelRef robustZ = _ref('DERIVED-ROBUST_DEVIATION-MAD-1', '1', [
    'Personal-baseline deviation; not a population reference comparison.',
  ]);
}

/// Minimum sample size for the MAD-based personal baseline (versioned with
/// DERIVED-ROBUST_DEVIATION-MAD-1).
const int robustZMinSample = 5;

/// Scale that makes the MAD consistent with a normal standard deviation.
const double madScale = 1.4826;

double _num(Map<String, Object?> inputs, String key) =>
    (inputs[key]! as num).toDouble();

/// Median of an already sorted, non-empty list.
double median(List<double> sorted) {
  final n = sorted.length;
  final mid = n ~/ 2;
  return n.isOdd ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
}

/// The present values of [values] (null and non-finite left out), in order.
List<double> presentValues(Iterable<Object?> values) => [
  for (final v in values)
    if (isPresent(v)) (v! as num).toDouble(),
];

/// Body mass index: weight_kg / height_m².
CalcResult bmi(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.bmi;
  final miss = missingKeys(inputs, ['weight_kg', 'height_m']);
  if (miss.isNotEmpty) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'MISSING_REQUIRED_INPUT',
      inputs,
      miss,
    );
  }
  final w = _num(inputs, 'weight_kg');
  final h = _num(inputs, 'height_m');
  if (w <= 0 || h <= 0) {
    return CalcResult.fail(
      m,
      CalcStatus.invalidInput,
      'NON_POSITIVE_INPUT',
      inputs,
    );
  }
  return CalcResult.ok(m, w / (h * h), inputs);
}

/// Waist-to-height ratio; both lengths must share a unit (default cm).
CalcResult waistHeightRatio(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.waistHeightRatio;
  final miss = missingKeys(inputs, ['waist', 'height']);
  if (miss.isNotEmpty) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'MISSING_REQUIRED_INPUT',
      inputs,
      miss,
    );
  }
  if ((inputs['waist_unit'] ?? 'cm') != (inputs['height_unit'] ?? 'cm')) {
    return CalcResult.fail(m, CalcStatus.invalidInput, 'UNIT_MISMATCH', inputs);
  }
  final waist = _num(inputs, 'waist');
  final height = _num(inputs, 'height');
  if (waist <= 0 || height <= 0) {
    return CalcResult.fail(
      m,
      CalcStatus.invalidInput,
      'NON_POSITIVE_INPUT',
      inputs,
    );
  }
  return CalcResult.ok(m, waist / height, inputs);
}

/// Pack-years: packs_per_day × years_smoked.
CalcResult packYears(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.packYears;
  final miss = missingKeys(inputs, ['packs_per_day', 'years_smoked']);
  if (miss.isNotEmpty) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'MISSING_REQUIRED_INPUT',
      inputs,
      miss,
    );
  }
  final p = _num(inputs, 'packs_per_day');
  final y = _num(inputs, 'years_smoked');
  if (p < 0 || y < 0) {
    return CalcResult.fail(
      m,
      CalcStatus.invalidInput,
      'NEGATIVE_INPUT',
      inputs,
    );
  }
  return CalcResult.ok(m, p * y, inputs);
}

/// comparison − baseline, in the inputs' unit.
CalcResult absoluteDelta(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.absoluteDelta;
  final miss = missingKeys(inputs, ['baseline', 'comparison']);
  if (miss.isNotEmpty) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'MISSING_REQUIRED_INPUT',
      inputs,
      miss,
    );
  }
  return CalcResult.ok(
    m,
    _num(inputs, 'comparison') - _num(inputs, 'baseline'),
    inputs,
  );
}

/// (new − baseline) / baseline × 100; a zero baseline is refused.
CalcResult percentChange(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.percentChange;
  final miss = missingKeys(inputs, ['baseline', 'new']);
  if (miss.isNotEmpty) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'MISSING_REQUIRED_INPUT',
      inputs,
      miss,
    );
  }
  final b = _num(inputs, 'baseline');
  if (b == 0) {
    return CalcResult.fail(m, CalcStatus.invalidInput, 'ZERO_BASELINE', inputs);
  }
  return CalcResult.ok(m, ((_num(inputs, 'new') - b) / b) * 100, inputs);
}

/// Σ load_kg × reps over COMPLETED sets only (plan is not completion).
CalcResult trainingVolumeLoad(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.volumeLoad;
  final sets = inputs['sets'];
  if (sets is! List) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'MISSING_REQUIRED_INPUT',
      inputs,
      ['sets'],
    );
  }
  final completed = [
    for (final s in sets)
      if (s is Map && s['state'] == 'COMPLETED') s,
  ];
  if (completed.isEmpty) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'NO_COMPLETED_SETS',
      inputs,
      ['sets'],
    );
  }
  if (completed.any((s) => !isPresent(s['load_kg']) || !isPresent(s['reps']))) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'MISSING_REQUIRED_INPUT',
      inputs,
      ['load_kg|reps'],
    );
  }
  double load(Map<Object?, Object?> s) => (s['load_kg']! as num).toDouble();
  double reps(Map<Object?, Object?> s) => (s['reps']! as num).toDouble();
  if (completed.any((s) => load(s) < 0 || reps(s) < 0)) {
    return CalcResult.fail(
      m,
      CalcStatus.invalidInput,
      'NEGATIVE_INPUT',
      inputs,
    );
  }
  var v = 0.0;
  for (final s in completed) {
    v += load(s) * reps(s);
  }
  return CalcResult.ok(m, v, inputs);
}

/// The present values among the last `window` entries, or a refusal.
({List<double>? values, CalcResult? refusal}) _window(
  ModelRef m,
  Map<String, Object?> inputs,
) {
  final w = presentOrNull(inputs['window']);
  if (w == null || w != w.truncateToDouble() || w <= 0) {
    return (
      values: null,
      refusal: CalcResult.fail(
        m,
        CalcStatus.invalidInput,
        'INVALID_WINDOW',
        inputs,
      ),
    );
  }
  final all = inputs['values'];
  if (all is! List) {
    return (
      values: null,
      refusal: CalcResult.fail(
        m,
        CalcStatus.missingInput,
        'MISSING_REQUIRED_INPUT',
        inputs,
        ['values'],
      ),
    );
  }
  final n = w.toInt();
  final start = all.length > n ? all.length - n : 0;
  final vals = presentValues(all.sublist(start));
  final minCount = inputs['min_count'] as num? ?? 1;
  if (vals.length < minCount) {
    return (
      values: null,
      refusal: CalcResult.fail(
        m,
        CalcStatus.missingInput,
        'INSUFFICIENT_OBSERVATIONS',
        inputs,
        ['values'],
      ),
    );
  }
  return (values: vals, refusal: null);
}

/// Mean of the last `window` observations; missing points are excluded,
/// never zero-filled. Optional `min_count` (default 1).
CalcResult rollingMean(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.rollingMean;
  final w = _window(m, inputs);
  if (w.refusal != null) return w.refusal!;
  final vals = w.values!;
  var sum = 0.0;
  for (final v in vals) {
    sum += v;
  }
  return CalcResult.ok(m, sum / vals.length, inputs);
}

/// Median of the last `window` observations; missing points are excluded.
CalcResult rollingMedian(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.rollingMedian;
  final w = _window(m, inputs);
  if (w.refusal != null) return w.refusal!;
  return CalcResult.ok(m, median(w.values!..sort()), inputs);
}

/// Ordinary least-squares slope of `points` ({t: days, v: value}); points
/// with a missing t or v are left out. Optional `min_n` (at least 2).
CalcResult olsSlope(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.olsSlope;
  final points = inputs['points'];
  final pts = <(double, double)>[
    if (points is List)
      for (final p in points)
        if (p is Map && isPresent(p['t']) && isPresent(p['v']))
          ((p['t']! as num).toDouble(), (p['v']! as num).toDouble()),
  ];
  final minN = inputs['min_n'] as num? ?? 2;
  if (pts.length < (minN > 2 ? minN : 2)) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'INSUFFICIENT_OBSERVATIONS',
      inputs,
      ['points'],
    );
  }
  final n = pts.length;
  var st = 0.0;
  var sv = 0.0;
  for (final (t, v) in pts) {
    st += t;
    sv += v;
  }
  final mt = st / n;
  final mv = sv / n;
  var sxx = 0.0;
  var sxy = 0.0;
  for (final (t, v) in pts) {
    sxx += (t - mt) * (t - mt);
    sxy += (t - mt) * (v - mv);
  }
  if (sxx == 0) {
    return CalcResult.fail(
      m,
      CalcStatus.invalidInput,
      'ZERO_TIME_VARIANCE',
      inputs,
    );
  }
  return CalcResult.ok(m, sxy / sxx, inputs);
}

/// Robust deviation of `x` from the person's own `series`:
/// (x − median) / (1.4826 × MAD). Needs at least [robustZMinSample] values.
CalcResult robustZ(Map<String, Object?> inputs) {
  final m = CoreDerivedModels.robustZ;
  if (!isPresent(inputs['x'])) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'MISSING_REQUIRED_INPUT',
      inputs,
      ['x'],
    );
  }
  final series = inputs['series'];
  final vals = presentValues(series is List ? series : const <Object?>[])
    ..sort();
  if (vals.length < robustZMinSample) {
    return CalcResult.fail(
      m,
      CalcStatus.missingInput,
      'INSUFFICIENT_OBSERVATIONS',
      inputs,
      ['series'],
    );
  }
  final med = median(vals);
  final mad = median([for (final v in vals) (v - med).abs()]..sort());
  if (mad == 0) {
    return CalcResult.fail(m, CalcStatus.invalidInput, 'ZERO_MAD', inputs);
  }
  return CalcResult.ok(m, (_num(inputs, 'x') - med) / (madScale * mad), inputs);
}

/// Model ID → function, so golden vectors run generically (as in TS).
final Map<String, CalcResult Function(Map<String, Object?>)>
coreDerivedFunctions = Map.unmodifiable({
  'DERIVED-BMI-1': bmi,
  'DERIVED-WAIST_HEIGHT_RATIO-1': waistHeightRatio,
  'DERIVED-PACK_YEARS-1': packYears,
  'DERIVED-ABSOLUTE_DELTA-1': absoluteDelta,
  'DERIVED-PERCENT_CHANGE-1': percentChange,
  'DERIVED-TRAINING_VOLUME_LOAD-1': trainingVolumeLoad,
  'DERIVED-ROLLING_MEAN-1': rollingMean,
  'DERIVED-ROLLING_MEDIAN-1': rollingMedian,
  'DERIVED-TREND-SLOPE-OLS-1': olsSlope,
  'DERIVED-ROBUST_DEVIATION-MAD-1': robustZ,
});
