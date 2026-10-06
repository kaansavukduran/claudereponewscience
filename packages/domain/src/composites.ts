// MP-APP-COMPOSITES-1 (demo activation: APP-COMPOSITES-DEMO-1).
// App-defined Protection / Burden / Function / Coverage channels.
// NOT mortality probability, NOT diagnosis, NOT life expectancy, NOT validated clinical risk.
// Normalisation anchors below are synthetic demo anchors, visibly versioned, not clinical targets.

import { bmi, packYears } from './coreDerived.ts';
import type { BodyProfile, ModuleId, ProfileInputs } from './profile.ts';
import { type CalcResult, isPresent } from './result.ts';

export const COMPOSITE_PACK = {
  packId: 'APP-COMPOSITES-DEMO-1',
  version: '0.25.0',
  label: 'APP_DEFINED_DEMO',
} as const;

export type Channel = 'PROTECTION' | 'BURDEN' | 'FUNCTION';

export type Normalization =
  | { kind: 'HIGHER_IS_BETTER'; lo: number; hi: number }
  | { kind: 'LOWER_IS_BETTER'; lo: number; hi: number }
  | { kind: 'TARGET_BAND'; lo: number; hi: number; falloff: number }
  | { kind: 'HIGHER_IS_MORE_BURDEN'; lo: number; hi: number };

export interface CompositeComponent {
  id: string;
  channel: Channel;
  label: string;
  /** Module that must be enabled for the component to be eligible; null = always on. */
  module: ModuleId | null;
  weight: number;
  /** Data-quality factor q_i in [0,1] for this input source in the demo (self-report < measured). */
  quality: number;
  unit: string;
  read: (i: ProfileInputs) => number | null;
  norm: Normalization;
}

const clamp01 = (x: number) => Math.min(1, Math.max(0, x));

export function normalize(value: number, n: Normalization): number {
  switch (n.kind) {
    case 'HIGHER_IS_BETTER':
    case 'HIGHER_IS_MORE_BURDEN':
      return 100 * clamp01((value - n.lo) / (n.hi - n.lo));
    case 'LOWER_IS_BETTER':
      return 100 * clamp01((n.hi - value) / (n.hi - n.lo));
    case 'TARGET_BAND': {
      if (value >= n.lo && value <= n.hi) return 100;
      const dist = value < n.lo ? n.lo - value : value - n.hi;
      return 100 * clamp01(1 - dist / n.falloff);
    }
  }
}

const v = (x: number | null | undefined) => (isPresent(x) ? x : null);

export const COMPONENTS: CompositeComponent[] = [
  // PROTECTION / RESILIENCE
  { id: 'P-SLEEP-DURATION', channel: 'PROTECTION', label: 'Sleep duration', module: null, weight: 2, quality: 0.7, unit: 'h', read: (i) => v(i.sleep_hours), norm: { kind: 'TARGET_BAND', lo: 7, hi: 9, falloff: 3 } },
  { id: 'P-STEPS', channel: 'PROTECTION', label: 'Daily steps', module: null, weight: 2, quality: 0.8, unit: 'steps/day', read: (i) => v(i.steps_per_day), norm: { kind: 'HIGHER_IS_BETTER', lo: 2000, hi: 10000 } },
  { id: 'P-EXERCISE', channel: 'PROTECTION', label: 'Exercise minutes', module: null, weight: 2, quality: 0.7, unit: 'min/week', read: (i) => v(i.exercise_min_week), norm: { kind: 'HIGHER_IS_BETTER', lo: 0, hi: 150 } },
  { id: 'P-RESTING-HR', channel: 'PROTECTION', label: 'Resting heart rate', module: 'cardiovascular', weight: 1, quality: 0.8, unit: 'bpm', read: (i) => v(i.resting_hr), norm: { kind: 'LOWER_IS_BETTER', lo: 50, hi: 95 } },
  { id: 'P-MOOD', channel: 'PROTECTION', label: 'Mood self-rating', module: 'neurology', weight: 1, quality: 0.5, unit: '1-10', read: (i) => v(i.mood_1_10), norm: { kind: 'HIGHER_IS_BETTER', lo: 1, hi: 10 } },
  { id: 'P-PREVENTION', channel: 'PROTECTION', label: 'Preventive items up to date', module: 'prevention', weight: 1, quality: 0.6, unit: 'fraction', read: (i) => (isPresent(i.preventive_items_up_to_date) && isPresent(i.preventive_items_total) && i.preventive_items_total > 0 ? i.preventive_items_up_to_date / i.preventive_items_total : null), norm: { kind: 'HIGHER_IS_BETTER', lo: 0, hi: 1 } },
  // RISK / BURDEN
  { id: 'B-PACK-YEARS', channel: 'BURDEN', label: 'Smoking exposure (pack-years)', module: null, weight: 3, quality: 0.6, unit: 'pack-years', read: (i) => smokingPackYears(i), norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 0, hi: 40 } },
  { id: 'B-ALCOHOL', channel: 'BURDEN', label: 'Alcohol units', module: null, weight: 2, quality: 0.5, unit: 'units/week', read: (i) => v(i.alcohol_units_week), norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 0, hi: 28 } },
  { id: 'B-SYSTOLIC', channel: 'BURDEN', label: 'Systolic blood pressure', module: 'cardiovascular', weight: 2, quality: 0.8, unit: 'mmHg', read: (i) => v(i.systolic_bp), norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 115, hi: 170 } },
  { id: 'B-BMI', channel: 'BURDEN', label: 'BMI above demo anchor', module: 'metabolic', weight: 1, quality: 0.9, unit: 'kg/m2', read: (i) => bmiValue(i), norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 25, hi: 40 } },
  { id: 'B-SYNTH-GLYC', channel: 'BURDEN', label: 'Synthetic glycemic marker', module: 'metabolic', weight: 1, quality: 0.9, unit: 'synthetic units', read: (i) => v(i.synth_glycemic_marker), norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 5, hi: 9 } },
  { id: 'B-SYNTH-LIPID', channel: 'BURDEN', label: 'Synthetic lipid marker', module: 'cardiovascular', weight: 1, quality: 0.9, unit: 'synthetic units', read: (i) => v(i.synth_lipid_marker), norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 100, hi: 220 } },
  { id: 'B-AIR', channel: 'BURDEN', label: 'Poor-air exposure days', module: 'environment', weight: 1, quality: 0.5, unit: 'days/month', read: (i) => v(i.poor_air_days_month), norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 0, hi: 20 } },
  { id: 'B-SKIN', channel: 'BURDEN', label: 'Skin symptom burden', module: 'dermatology', weight: 1, quality: 0.5, unit: '0-10', read: (i) => v(i.skin_symptom_0_10), norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 0, hi: 10 } },
  { id: 'B-CONDITIONS', channel: 'BURDEN', label: 'Confirmed condition count', module: null, weight: 1, quality: 0.9, unit: 'count', read: (i) => i.conditions.filter((c) => c.status === 'CONFIRMED').length, norm: { kind: 'HIGHER_IS_MORE_BURDEN', lo: 0, hi: 4 } },
  // FUNCTION / CAPACITY
  { id: 'F-MOBILITY', channel: 'FUNCTION', label: 'Mobility self-rating', module: 'musculoskeletal', weight: 2, quality: 0.5, unit: '1-10', read: (i) => v(i.mobility_1_10), norm: { kind: 'HIGHER_IS_BETTER', lo: 1, hi: 10 } },
  { id: 'F-PAIN', channel: 'FUNCTION', label: 'Pain (inverted)', module: 'musculoskeletal', weight: 1, quality: 0.5, unit: '0-10', read: (i) => v(i.pain_0_10), norm: { kind: 'LOWER_IS_BETTER', lo: 0, hi: 10 } },
  { id: 'F-COGNITION', channel: 'FUNCTION', label: 'Cognition self-rating', module: 'neurology', weight: 1, quality: 0.5, unit: '1-10', read: (i) => v(i.cognition_self_1_10), norm: { kind: 'HIGHER_IS_BETTER', lo: 1, hi: 10 } },
  { id: 'F-BREATH', channel: 'FUNCTION', label: 'Breathlessness (inverted)', module: 'respiratory', weight: 1, quality: 0.5, unit: '0-10', read: (i) => v(i.breathlessness_0_10), norm: { kind: 'LOWER_IS_BETTER', lo: 0, hi: 10 } },
  { id: 'F-SLEEP-QUALITY', channel: 'FUNCTION', label: 'Sleep quality self-rating', module: null, weight: 1, quality: 0.5, unit: '1-10', read: (i) => v(i.sleep_quality_1_10), norm: { kind: 'HIGHER_IS_BETTER', lo: 1, hi: 10 } },
];

export function bmiValue(i: ProfileInputs): number | null {
  const r = bmi({ weight_kg: i.weight_kg, height_m: isPresent(i.height_cm) ? i.height_cm / 100 : null });
  return r.status === 'OK' ? r.value : null;
}

/** Never-smokers have 0 pack-years by definition (explicit status), unknown status stays missing. */
export function smokingPackYears(i: ProfileInputs): number | null {
  if (i.smoking_status === 'NEVER') return 0;
  if (i.smoking_status === 'UNKNOWN') return null;
  const r = packYears({ packs_per_day: i.packs_per_day, years_smoked: i.years_smoked });
  return r.status === 'OK' ? r.value : null;
}

export type Confidence = 'INSUFFICIENT_DATA' | 'LOW' | 'MODERATE' | 'HIGH';

export function confidenceFromCoverage(coverage: number): Confidence {
  if (coverage < 0.34) return 'INSUFFICIENT_DATA';
  if (coverage < 0.6) return 'LOW';
  if (coverage < 0.85) return 'MODERATE';
  return 'HIGH';
}

export interface ComponentEvaluation {
  id: string;
  label: string;
  unit: string;
  raw: number | null;
  normalized: number | null;
  weight: number;
  quality: number;
  eligible: boolean;
}

export interface ChannelResult extends CalcResult {
  channel: Channel;
  coverage: number | null;
  confidence: Confidence;
  components: ComponentEvaluation[];
}

const MIN_CHANNEL_COVERAGE = 0.34;

/** Score = Σ(w·q·s)/Σ(w·q) over available eligible components; Coverage = Σw(avail)/Σw(eligible). */
export function channelScore(profile: BodyProfile, channel: Channel): ChannelResult {
  const comps = COMPONENTS.filter((c) => c.channel === channel);
  const evals: ComponentEvaluation[] = comps.map((c) => {
    const eligible = c.module === null || profile.modules[c.module];
    const raw = eligible ? c.read(profile.inputs) : null;
    return {
      id: c.id,
      label: c.label,
      unit: c.unit,
      raw,
      normalized: raw === null ? null : normalize(raw, c.norm),
      weight: c.weight,
      quality: c.quality,
      eligible,
    };
  });
  const eligible = evals.filter((e) => e.eligible);
  const available = eligible.filter((e) => e.normalized !== null);
  const wEligible = eligible.reduce((a, e) => a + e.weight, 0);
  const wAvail = available.reduce((a, e) => a + e.weight, 0);
  const coverage = wEligible > 0 ? wAvail / wEligible : null;
  const confidence = coverage === null ? 'INSUFFICIENT_DATA' : confidenceFromCoverage(coverage);
  const missingInputs = eligible.filter((e) => e.normalized === null).map((e) => e.id);
  const modelId = `APP-${channel}-SCORE-DEMO-1`;
  const base = {
    channel,
    coverage,
    confidence,
    components: evals,
    unit: '0-100 app-defined',
    modelId,
    version: COMPOSITE_PACK.version,
    resultClass: 'APP_COMPOSITE' as const,
    inputs: Object.fromEntries(available.map((e) => [e.id, e.raw])),
    missingInputs,
    limitations: [
      'APP_DEFINED_DEMO score: not a mortality probability, diagnosis or life expectancy.',
      'Normalisation anchors are synthetic demo anchors, not clinical targets.',
      'Cannot be converted into years gained or lost.',
    ],
  };
  if (!available.length || coverage === null || coverage < MIN_CHANNEL_COVERAGE) {
    return { ...base, status: 'MISSING_INPUT', value: null, errorCode: 'INSUFFICIENT_COVERAGE' };
  }
  const num = available.reduce((a, e) => a + e.weight * e.quality * (e.normalized as number), 0);
  const den = available.reduce((a, e) => a + e.weight * e.quality, 0);
  return { ...base, status: 'OK', value: num / den, errorCode: null };
}

export interface BalanceResult extends CalcResult {
  protection: number | null;
  burden: number | null;
}

/** BalanceIndex = Protection − Burden (−100..+100). Always shown next to both source channels. */
export function balanceIndex(protection: ChannelResult, burden: ChannelResult): BalanceResult {
  const ref = {
    unit: '-100..+100 app-defined',
    modelId: 'APP-BALANCE-INDEX-DEMO-1',
    version: COMPOSITE_PACK.version,
    resultClass: 'APP_COMPOSITE' as const,
    inputs: { protection: protection.value, burden: burden.value },
    limitations: ['Visualisation only; a net value can hide simultaneous high protection and high burden.'],
    protection: protection.value,
    burden: burden.value,
  };
  if (protection.status !== 'OK' || burden.status !== 'OK') {
    return {
      ...ref,
      status: 'MISSING_INPUT',
      value: null,
      missingInputs: [protection.status !== 'OK' ? 'PROTECTION' : '', burden.status !== 'OK' ? 'BURDEN' : ''].filter(Boolean),
      errorCode: 'CHANNEL_UNAVAILABLE',
    };
  }
  return { ...ref, status: 'OK', value: (protection.value as number) - (burden.value as number), missingInputs: [], errorCode: null };
}
