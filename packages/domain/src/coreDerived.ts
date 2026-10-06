// MP-CORE-DERIVED-1 — transparent deterministic calculations owned by the app.
// Executable specification shared by Site Lab, production client and API.
// Same golden vectors are checked by tools/verify_contracts.py (independent Python port).

import { type CalcResult, type ModelRef, fail, isPresent, missingKeys, ok } from './result.ts';

export const CORE_DERIVED_PACK = { packId: 'MP-CORE-DERIVED-1', version: '1.0.0' } as const;

const ref = (modelId: string, unit: string | null, limitations: string[] = []): ModelRef => ({
  modelId,
  version: '1',
  resultClass: 'DERIVED_MEASUREMENT',
  unit,
  limitations,
});

export const MODELS = {
  BMI: ref('DERIVED-BMI-1', 'kg/m2', [
    'Number only; no diagnostic category is assigned by this formula.',
  ]),
  WHTR: ref('DERIVED-WAIST_HEIGHT_RATIO-1', '1', [
    'No universal good/bad threshold is bundled with this formula.',
  ]),
  PACK_YEARS: ref('DERIVED-PACK_YEARS-1', 'pack-years', [
    'Exposure measure, not a mortality probability.',
  ]),
  PERCENT_CHANGE: ref('DERIVED-PERCENT_CHANGE-1', '%'),
  ABSOLUTE_DELTA: ref('DERIVED-ABSOLUTE_DELTA-1', null),
  VOLUME_LOAD: ref('DERIVED-TRAINING_VOLUME_LOAD-1', 'kg', [
    'Planned sets are excluded until completed.',
  ]),
  ROLLING_MEAN: ref('DERIVED-ROLLING_MEAN-1', null),
  ROLLING_MEDIAN: ref('DERIVED-ROLLING_MEDIAN-1', null),
  OLS_SLOPE: ref('DERIVED-TREND-SLOPE-OLS-1', 'unit/day', [
    'Trend estimator, not a clinical prediction.',
  ]),
  ROBUST_Z: ref('DERIVED-ROBUST_DEVIATION-MAD-1', '1', [
    'Personal-baseline deviation; not a population reference comparison.',
  ]),
} as const;

/** Minimum sample size for MAD-based personal baseline (versioned with DERIVED-ROBUST_DEVIATION-MAD-1). */
export const ROBUST_Z_MIN_SAMPLE = 5;
export const MAD_SCALE = 1.4826;

function nonPositive(inputs: Record<string, unknown>, keys: string[]): string[] {
  return keys.filter((k) => (inputs[k] as number) <= 0);
}

export function bmi(inputs: { weight_kg?: number | null; height_m?: number | null }): CalcResult {
  const m = MODELS.BMI;
  const miss = missingKeys(inputs, ['weight_kg', 'height_m']);
  if (miss.length) return fail(m, 'MISSING_INPUT', 'MISSING_REQUIRED_INPUT', inputs, miss);
  if (nonPositive(inputs, ['weight_kg', 'height_m']).length)
    return fail(m, 'INVALID_INPUT', 'NON_POSITIVE_INPUT', inputs);
  const h = inputs.height_m as number;
  return ok(m, (inputs.weight_kg as number) / (h * h), inputs);
}

export function waistHeightRatio(inputs: {
  waist?: number | null;
  height?: number | null;
  waist_unit?: string;
  height_unit?: string;
}): CalcResult {
  const m = MODELS.WHTR;
  const miss = missingKeys(inputs, ['waist', 'height']);
  if (miss.length) return fail(m, 'MISSING_INPUT', 'MISSING_REQUIRED_INPUT', inputs, miss);
  if ((inputs.waist_unit ?? 'cm') !== (inputs.height_unit ?? 'cm'))
    return fail(m, 'INVALID_INPUT', 'UNIT_MISMATCH', inputs);
  if (nonPositive(inputs, ['waist', 'height']).length)
    return fail(m, 'INVALID_INPUT', 'NON_POSITIVE_INPUT', inputs);
  return ok(m, (inputs.waist as number) / (inputs.height as number), inputs);
}

export function packYears(inputs: {
  packs_per_day?: number | null;
  years_smoked?: number | null;
}): CalcResult {
  const m = MODELS.PACK_YEARS;
  const miss = missingKeys(inputs, ['packs_per_day', 'years_smoked']);
  if (miss.length) return fail(m, 'MISSING_INPUT', 'MISSING_REQUIRED_INPUT', inputs, miss);
  if ((inputs.packs_per_day as number) < 0 || (inputs.years_smoked as number) < 0)
    return fail(m, 'INVALID_INPUT', 'NEGATIVE_INPUT', inputs);
  return ok(m, (inputs.packs_per_day as number) * (inputs.years_smoked as number), inputs);
}

export function absoluteDelta(inputs: {
  baseline?: number | null;
  comparison?: number | null;
}): CalcResult {
  const m = MODELS.ABSOLUTE_DELTA;
  const miss = missingKeys(inputs, ['baseline', 'comparison']);
  if (miss.length) return fail(m, 'MISSING_INPUT', 'MISSING_REQUIRED_INPUT', inputs, miss);
  return ok(m, (inputs.comparison as number) - (inputs.baseline as number), inputs);
}

export function percentChange(inputs: {
  baseline?: number | null;
  new?: number | null;
}): CalcResult {
  const m = MODELS.PERCENT_CHANGE;
  const miss = missingKeys(inputs, ['baseline', 'new']);
  if (miss.length) return fail(m, 'MISSING_INPUT', 'MISSING_REQUIRED_INPUT', inputs, miss);
  if (inputs.baseline === 0) return fail(m, 'INVALID_INPUT', 'ZERO_BASELINE', inputs);
  const b = inputs.baseline as number;
  return ok(m, (((inputs.new as number) - b) / b) * 100, inputs);
}

export interface TrainingSet {
  load_kg: number | null;
  reps: number | null;
  /** PLANNED sets never contribute (plan != completion). */
  state: 'PLANNED' | 'COMPLETED' | 'SKIPPED';
}

export function trainingVolumeLoad(inputs: { sets: TrainingSet[] }): CalcResult {
  const m = MODELS.VOLUME_LOAD;
  const completed = inputs.sets.filter((s) => s.state === 'COMPLETED');
  if (!completed.length) return fail(m, 'MISSING_INPUT', 'NO_COMPLETED_SETS', inputs, ['sets']);
  if (completed.some((s) => !isPresent(s.load_kg) || !isPresent(s.reps)))
    return fail(m, 'MISSING_INPUT', 'MISSING_REQUIRED_INPUT', inputs, ['load_kg|reps']);
  if (completed.some((s) => (s.load_kg as number) < 0 || (s.reps as number) < 0))
    return fail(m, 'INVALID_INPUT', 'NEGATIVE_INPUT', inputs);
  const v = completed.reduce((acc, s) => acc + (s.load_kg as number) * (s.reps as number), 0);
  return ok(m, v, inputs);
}

function presentValues(values: ReadonlyArray<number | null | undefined>): number[] {
  return values.filter(isPresent);
}

export function median(sorted: number[]): number {
  const n = sorted.length;
  const mid = Math.floor(n / 2);
  return n % 2 ? (sorted[mid] as number) : ((sorted[mid - 1] as number) + (sorted[mid] as number)) / 2;
}

/** Rolling mean over the last `window` observations; missing points are excluded, never zero-filled. */
export function rollingMean(inputs: {
  values: Array<number | null>;
  window: number;
  min_count?: number;
}): CalcResult {
  const m = MODELS.ROLLING_MEAN;
  if (!Number.isInteger(inputs.window) || inputs.window <= 0)
    return fail(m, 'INVALID_INPUT', 'INVALID_WINDOW', inputs);
  const vals = presentValues(inputs.values.slice(-inputs.window));
  const minCount = inputs.min_count ?? 1;
  if (vals.length < minCount)
    return fail(m, 'MISSING_INPUT', 'INSUFFICIENT_OBSERVATIONS', inputs, ['values']);
  return ok(m, vals.reduce((a, b) => a + b, 0) / vals.length, inputs);
}

export function rollingMedian(inputs: {
  values: Array<number | null>;
  window: number;
  min_count?: number;
}): CalcResult {
  const m = MODELS.ROLLING_MEDIAN;
  if (!Number.isInteger(inputs.window) || inputs.window <= 0)
    return fail(m, 'INVALID_INPUT', 'INVALID_WINDOW', inputs);
  const vals = presentValues(inputs.values.slice(-inputs.window)).sort((a, b) => a - b);
  const minCount = inputs.min_count ?? 1;
  if (vals.length < minCount)
    return fail(m, 'MISSING_INPUT', 'INSUFFICIENT_OBSERVATIONS', inputs, ['values']);
  return ok(m, median(vals), inputs);
}

export interface SeriesPoint {
  /** Time axis in days (declared unit of the slope is value-unit per day). */
  t: number;
  v: number | null;
}

export function olsSlope(inputs: { points: SeriesPoint[]; min_n?: number }): CalcResult {
  const m = MODELS.OLS_SLOPE;
  const pts = inputs.points.filter((p) => isPresent(p.t) && isPresent(p.v)) as Array<{
    t: number;
    v: number;
  }>;
  const minN = inputs.min_n ?? 2;
  if (pts.length < Math.max(2, minN))
    return fail(m, 'MISSING_INPUT', 'INSUFFICIENT_OBSERVATIONS', inputs, ['points']);
  const n = pts.length;
  const mt = pts.reduce((a, p) => a + p.t, 0) / n;
  const mv = pts.reduce((a, p) => a + p.v, 0) / n;
  let sxx = 0;
  let sxy = 0;
  for (const p of pts) {
    sxx += (p.t - mt) * (p.t - mt);
    sxy += (p.t - mt) * (p.v - mv);
  }
  if (sxx === 0) return fail(m, 'INVALID_INPUT', 'ZERO_TIME_VARIANCE', inputs);
  return ok(m, sxy / sxx, inputs);
}

export function robustZ(inputs: { x?: number | null; series: Array<number | null> }): CalcResult {
  const m = MODELS.ROBUST_Z;
  if (!isPresent(inputs.x)) return fail(m, 'MISSING_INPUT', 'MISSING_REQUIRED_INPUT', inputs, ['x']);
  const vals = presentValues(inputs.series).sort((a, b) => a - b);
  if (vals.length < ROBUST_Z_MIN_SAMPLE)
    return fail(m, 'MISSING_INPUT', 'INSUFFICIENT_OBSERVATIONS', inputs, ['series']);
  const med = median(vals);
  const mad = median(vals.map((v) => Math.abs(v - med)).sort((a, b) => a - b));
  if (mad === 0) return fail(m, 'INVALID_INPUT', 'ZERO_MAD', inputs);
  return ok(m, ((inputs.x as number) - med) / (MAD_SCALE * mad), inputs);
}

/** Dispatch table so golden vectors can be executed generically (Site, client, API and CI share it). */
export const CORE_DERIVED_FUNCTIONS: Record<string, (inputs: never) => CalcResult> = {
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
};
