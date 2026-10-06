// REF-SYNTHETIC-DEMO-1 — synthetic people, labs, wearable series, timeline and scenarios.
// No record is a real person's health data. Seeded generation → identical output on every run.

import { defaultModules, emptyInputs, type BodyProfile, type ProfileInputs } from '@hhos/domain';

export const SYNTHETIC_PACK = {
  packId: 'REF-SYNTHETIC-DEMO-1',
  version: '0.25.0',
  status: 'BUNDLE_DEFAULT',
  label: 'SYNTHETIC DEMO DATA — not a real person',
} as const;

function profile(id: string, name: string, patch: Partial<ProfileInputs>): BodyProfile {
  return {
    id,
    name,
    profile_type: 'SYNTHETIC',
    synthetic: true,
    source_profile_id: null,
    pinned_baseline: false,
    modules: defaultModules(),
    inputs: { ...emptyInputs(), ...patch },
  };
}

export function syntheticProfiles(): BodyProfile[] {
  return [
    profile('SYNTH-BASIC-A', 'Synthetic A · basic', {
      age_years: 42, height_cm: 172, weight_kg: 78, waist_cm: 88, systolic_bp: 124, diastolic_bp: 80, resting_hr: 66,
      sleep_hours: 6.8, sleep_quality_1_10: 6, steps_per_day: 7200, exercise_min_week: 90, smoking_status: 'NEVER',
      alcohol_units_week: 4, mood_1_10: 7, pain_0_10: 2, mobility_1_10: 8, cognition_self_1_10: 8, skin_symptom_0_10: 1,
      breathlessness_0_10: 1, synth_lipid_marker: 128, synth_glycemic_marker: 5.4, synth_kidney_marker: 0.9,
      preventive_items_up_to_date: 3, preventive_items_total: 5, poor_air_days_month: 4,
    }),
    profile('SYNTH-HIGH-BURDEN-B', 'Synthetic B · high burden', {
      age_years: 58, height_cm: 168, weight_kg: 112, waist_cm: 118, systolic_bp: 156, diastolic_bp: 94, resting_hr: 84,
      sleep_hours: 5.4, sleep_quality_1_10: 4, steps_per_day: 2600, exercise_min_week: 0, smoking_status: 'CURRENT',
      packs_per_day: 1, years_smoked: 30, alcohol_units_week: 18, mood_1_10: 4, pain_0_10: 6, mobility_1_10: 4,
      cognition_self_1_10: 6, skin_symptom_0_10: 3, breathlessness_0_10: 5, synth_lipid_marker: 196,
      synth_glycemic_marker: 7.6, synth_kidney_marker: 1.3, preventive_items_up_to_date: 1, preventive_items_total: 5,
      poor_air_days_month: 12,
      conditions: [
        { id: 'COND-SYN-1', label: 'Synthetic condition (cardiometabolic)', status: 'CONFIRMED', module: 'cardiovascular' },
        { id: 'COND-SYN-2', label: 'Synthetic condition (self-reported)', status: 'SELF_REPORTED', module: 'musculoskeletal' },
      ],
    }),
    profile('SYNTH-ACTIVE-C', 'Synthetic C · active', {
      age_years: 35, height_cm: 180, weight_kg: 74, waist_cm: 80, systolic_bp: 116, diastolic_bp: 74, resting_hr: 54,
      sleep_hours: 7.8, sleep_quality_1_10: 8, steps_per_day: 12500, exercise_min_week: 240, smoking_status: 'NEVER',
      alcohol_units_week: 1, mood_1_10: 8, pain_0_10: 1, mobility_1_10: 9, cognition_self_1_10: 9, skin_symptom_0_10: 0,
      breathlessness_0_10: 0, synth_lipid_marker: 104, synth_glycemic_marker: 5.0, synth_kidney_marker: 0.95,
      preventive_items_up_to_date: 4, preventive_items_total: 5, poor_air_days_month: 2,
    }),
    profile('SYNTH-SCENARIO-BASE', 'Synthetic base · sparse data', {
      age_years: 47, height_cm: 165, weight_kg: 90, smoking_status: 'FORMER', packs_per_day: 0.5, years_smoked: 12,
      sleep_hours: 6.5, steps_per_day: null, systolic_bp: 132,
    }),
  ].map((p, i) => ({ ...p, pinned_baseline: i === 0 }));
}

/** Mulberry32 — tiny deterministic PRNG for synthetic fixture generation (never for health scores). */
export function seeded(seed: number): () => number {
  let a = seed >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

export interface WearableDay {
  date: string;
  steps: number | null;
  sleep_hours: number | null;
  resting_hr: number | null;
  exercise_min: number | null;
  source: 'SYNTHETIC_WATCH' | 'SYNTHETIC_PHONE';
}

/** 28 days of synthetic wearable data with deliberate gaps (missing ≠ zero). */
export function syntheticWearable(seed = 2401, endDate = '2026-10-05', days = 28): WearableDay[] {
  const rnd = seeded(seed);
  const end = Date.UTC(Number(endDate.slice(0, 4)), Number(endDate.slice(5, 7)) - 1, Number(endDate.slice(8, 10)));
  const out: WearableDay[] = [];
  for (let i = days - 1; i >= 0; i--) {
    const date = new Date(end - i * 86_400_000).toISOString().slice(0, 10);
    // Fixed, documented gap days so the demo always shows "no data" (never 0).
    const gap = i === 5 || i === 17;
    out.push({
      date,
      steps: gap ? null : Math.round(5500 + rnd() * 6000),
      sleep_hours: i === 11 ? null : Math.round((6 + rnd() * 2.2) * 10) / 10,
      resting_hr: gap ? null : Math.round(58 + rnd() * 10),
      exercise_min: Math.round(rnd() < 0.4 ? 20 + rnd() * 50 : 0),
      source: i % 7 === 3 ? 'SYNTHETIC_PHONE' : 'SYNTHETIC_WATCH',
    });
  }
  return out;
}

export interface TimelineEvent {
  id: string;
  date: string;
  kind: 'LAB' | 'VACCINE' | 'MEDICATION_INTAKE' | 'WORKOUT' | 'SYMPTOM' | 'TREATMENT' | 'WEARABLE' | 'CONDITION';
  title: string;
  provenance: 'MANUAL' | 'SYNTHETIC_IMPORT' | 'SYNTHETIC_DOCUMENT' | 'SYNTHETIC_WEARABLE';
  plan_or_actual: 'ACTUAL' | 'PLAN';
}

export function syntheticTimeline(): TimelineEvent[] {
  return [
    { id: 'TL-01', date: '2026-03-14', kind: 'LAB', title: 'Synthetic panel: SYN-ANALYTE-X 6.4 syn-u (method M1)', provenance: 'SYNTHETIC_DOCUMENT', plan_or_actual: 'ACTUAL' },
    { id: 'TL-02', date: '2026-04-02', kind: 'VACCINE', title: 'Synthetic Vaccine Alpha — dose 1', provenance: 'MANUAL', plan_or_actual: 'ACTUAL' },
    { id: 'TL-03', date: '2026-05-10', kind: 'SYMPTOM', title: 'Synthetic symptom: knee pain 4/10 (self-report ≠ diagnosis)', provenance: 'MANUAL', plan_or_actual: 'ACTUAL' },
    { id: 'TL-04', date: '2026-06-01', kind: 'LAB', title: 'Synthetic panel: SYN-ANALYTE-X 9.0 syn-u (method M1)', provenance: 'SYNTHETIC_DOCUMENT', plan_or_actual: 'ACTUAL' },
    { id: 'TL-05', date: '2026-07-18', kind: 'TREATMENT', title: 'Synthetic physiotherapy course started', provenance: 'MANUAL', plan_or_actual: 'ACTUAL' },
    { id: 'TL-06', date: '2026-08-22', kind: 'LAB', title: 'Synthetic panel: SYN-ANALYTE-X 7.0 syn-u (method M2 — discontinuity)', provenance: 'SYNTHETIC_DOCUMENT', plan_or_actual: 'ACTUAL' },
    { id: 'TL-07', date: '2026-09-30', kind: 'WORKOUT', title: 'Bench Press 3 × 10 @ 30 kg — completed', provenance: 'MANUAL', plan_or_actual: 'ACTUAL' },
    { id: 'TL-08', date: '2026-10-03', kind: 'MEDICATION_INTAKE', title: 'Synthetic Sunvita A — taken 08:10', provenance: 'MANUAL', plan_or_actual: 'ACTUAL' },
    { id: 'TL-09', date: '2026-10-05', kind: 'WEARABLE', title: 'Synthetic watch import: 8,214 steps', provenance: 'SYNTHETIC_WEARABLE', plan_or_actual: 'ACTUAL' },
    { id: 'TL-10', date: '2026-10-07', kind: 'WORKOUT', title: 'Bench Press 3 × 10 @ 32.5 kg — planned (not completed)', provenance: 'MANUAL', plan_or_actual: 'PLAN' },
  ];
}

export interface SyntheticLabPoint {
  date: string;
  value: number | null;
  unit: string;
  method_id: string;
  specimen: string;
  state: 'PRESENT' | 'NOT_REPORTED';
  reference_low: number | null;
  reference_high: number | null;
  provenance: string;
}

export function syntheticLabSeries(): SyntheticLabPoint[] {
  return [
    { date: '2025-09-10', value: 8.8, unit: 'syn-u', method_id: 'M1', specimen: 'serum', state: 'PRESENT', reference_low: 4, reference_high: 10, provenance: 'SYNTHETIC-LAB-A' },
    { date: '2025-12-02', value: 9.2, unit: 'syn-u', method_id: 'M1', specimen: 'serum', state: 'PRESENT', reference_low: 4, reference_high: 10, provenance: 'SYNTHETIC-LAB-A' },
    { date: '2026-03-14', value: null, unit: 'syn-u', method_id: 'M1', specimen: 'serum', state: 'NOT_REPORTED', reference_low: 4, reference_high: 10, provenance: 'SYNTHETIC-LAB-A' },
    { date: '2026-04-20', value: 9.1, unit: 'syn-u', method_id: 'M1', specimen: 'serum', state: 'PRESENT', reference_low: 4, reference_high: 10, provenance: 'SYNTHETIC-LAB-A' },
    { date: '2026-06-01', value: 9.0, unit: 'syn-u', method_id: 'M1', specimen: 'serum', state: 'PRESENT', reference_low: 4, reference_high: 10, provenance: 'SYNTHETIC-LAB-A' },
    { date: '2026-08-22', value: 7.0, unit: 'syn-u', method_id: 'M2', specimen: 'serum', state: 'PRESENT', reference_low: 3.5, reference_high: 9.5, provenance: 'SYNTHETIC-LAB-B' },
  ];
}
