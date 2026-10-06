// Compare Lab (FR-41..44, AT-202/204/563/634): N profiles, pinned baseline, Δ and %Δ only when meaningful.

import { absoluteDelta, percentChange } from './coreDerived.ts';
import type { BodyProfile } from './profile.ts';
import type { CalcResult, ResultClass } from './result.ts';
import { computeProfileResults, type ProfileResults } from './results.ts';

export interface CompareMetric {
  id: string;
  label: string;
  unit: string;
  resultClass: ResultClass | 'OBSERVED_INPUT';
  /** %Δ is meaningful only for ratio-scale metrics; never for app scores with arbitrary zero. */
  percentMeaningful: boolean;
  pick: (p: BodyProfile, r: ProfileResults) => CalcResult | number | null;
}

export const COMPARE_METRICS: CompareMetric[] = [
  { id: 'weight_kg', label: 'Weight', unit: 'kg', resultClass: 'OBSERVED_INPUT', percentMeaningful: true, pick: (p) => p.inputs.weight_kg },
  { id: 'resting_hr', label: 'Resting HR', unit: 'bpm', resultClass: 'OBSERVED_INPUT', percentMeaningful: true, pick: (p) => p.inputs.resting_hr },
  { id: 'systolic_bp', label: 'Systolic BP', unit: 'mmHg', resultClass: 'OBSERVED_INPUT', percentMeaningful: true, pick: (p) => p.inputs.systolic_bp },
  { id: 'sleep_hours', label: 'Sleep', unit: 'h', resultClass: 'OBSERVED_INPUT', percentMeaningful: true, pick: (p) => p.inputs.sleep_hours },
  { id: 'steps_per_day', label: 'Steps', unit: 'steps/day', resultClass: 'OBSERVED_INPUT', percentMeaningful: true, pick: (p) => p.inputs.steps_per_day },
  { id: 'bmi', label: 'BMI', unit: 'kg/m²', resultClass: 'DERIVED_MEASUREMENT', percentMeaningful: true, pick: (_p, r) => r.derived.bmi },
  { id: 'whtr', label: 'Waist/height', unit: 'ratio', resultClass: 'DERIVED_MEASUREMENT', percentMeaningful: true, pick: (_p, r) => r.derived.whtr },
  { id: 'pack_years', label: 'Pack-years', unit: 'pack-years', resultClass: 'DERIVED_MEASUREMENT', percentMeaningful: false, pick: (_p, r) => r.derived.packYears },
  { id: 'protection', label: 'Protection (app)', unit: '0–100', resultClass: 'APP_COMPOSITE', percentMeaningful: false, pick: (_p, r) => r.protection },
  { id: 'burden', label: 'Burden (app)', unit: '0–100', resultClass: 'APP_COMPOSITE', percentMeaningful: false, pick: (_p, r) => r.burden },
  { id: 'function', label: 'Function (app)', unit: '0–100', resultClass: 'APP_COMPOSITE', percentMeaningful: false, pick: (_p, r) => r.function },
  { id: 'coverage', label: 'Coverage', unit: '%', resultClass: 'COVERAGE', percentMeaningful: false, pick: (_p, r) => r.coverage },
  { id: 'cvd_prevent', label: 'CVD risk (PREVENT)', unit: '%', resultClass: 'VALIDATED_RISK', percentMeaningful: false, pick: (_p, r) => r.external.find((e) => e.modelId === 'EXT-AHA-PREVENT')?.result ?? null },
];

export type CellState = 'VALUE' | 'MISSING' | 'NOT_ELIGIBLE' | 'UNAVAILABLE' | 'INVALID';

export interface CompareCell {
  profileId: string;
  state: CellState;
  value: number | null;
  errorCode: string | null;
  delta: number | null;
  percentDelta: number | null;
  deltaState: 'BASELINE' | 'OK' | 'NOT_COMPARABLE' | 'PERCENT_NOT_MEANINGFUL' | 'ZERO_BASELINE';
}

export interface CompareRow {
  metric: CompareMetric;
  cells: CompareCell[];
}

function cellFrom(profileId: string, x: CalcResult | number | null): Omit<CompareCell, 'delta' | 'percentDelta' | 'deltaState'> {
  if (x === null || x === undefined) return { profileId, state: 'MISSING', value: null, errorCode: 'MISSING' };
  if (typeof x === 'number')
    return Number.isFinite(x)
      ? { profileId, state: 'VALUE', value: x, errorCode: null }
      : { profileId, state: 'MISSING', value: null, errorCode: 'MISSING' };
  switch (x.status) {
    case 'OK':
      return { profileId, state: 'VALUE', value: x.value, errorCode: null };
    case 'NOT_ELIGIBLE':
      return { profileId, state: 'NOT_ELIGIBLE', value: null, errorCode: x.errorCode };
    case 'UNAVAILABLE':
      return { profileId, state: 'UNAVAILABLE', value: null, errorCode: x.errorCode };
    case 'INVALID_INPUT':
      return { profileId, state: 'INVALID', value: null, errorCode: x.errorCode };
    default:
      return { profileId, state: 'MISSING', value: null, errorCode: x.errorCode };
  }
}

export function compareProfiles(profiles: BodyProfile[], baselineId: string | null, metricIds?: string[]): CompareRow[] {
  const results = new Map(profiles.map((p) => [p.id, computeProfileResults(p)]));
  const metrics = metricIds ? COMPARE_METRICS.filter((m) => metricIds.includes(m.id)) : COMPARE_METRICS;
  return metrics.map((metric) => {
    const raw = profiles.map((p) => cellFrom(p.id, metric.pick(p, results.get(p.id) as ProfileResults)));
    const base = raw.find((c) => c.profileId === baselineId) ?? null;
    const cells: CompareCell[] = raw.map((c) => {
      if (!base || c.profileId === baselineId)
        return { ...c, delta: null, percentDelta: null, deltaState: 'BASELINE' };
      if (c.state !== 'VALUE' || base.state !== 'VALUE')
        return { ...c, delta: null, percentDelta: null, deltaState: 'NOT_COMPARABLE' };
      const d = absoluteDelta({ baseline: base.value, comparison: c.value });
      if (!metric.percentMeaningful)
        return { ...c, delta: d.value, percentDelta: null, deltaState: 'PERCENT_NOT_MEANINGFUL' };
      const pc = percentChange({ baseline: base.value, new: c.value });
      if (pc.status !== 'OK') return { ...c, delta: d.value, percentDelta: null, deltaState: 'ZERO_BASELINE' };
      return { ...c, delta: d.value, percentDelta: pc.value, deltaState: 'OK' };
    });
    return { metric, cells };
  });
}
