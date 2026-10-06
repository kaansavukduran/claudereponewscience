// Body/comparison profile model shared by Site Lab, client and API.
// Missing values are null/undefined — never 0. Scenario clones never mutate their source.

export type ProfileType = 'SELF' | 'REAL_OTHER' | 'SYNTHETIC' | 'SCENARIO';

export const MODULE_IDS = [
  'cardiovascular',
  'oncology',
  'metabolic',
  'renal',
  'respiratory',
  'neurology',
  'dermatology',
  'musculoskeletal',
  'prevention',
  'environment',
] as const;
export type ModuleId = (typeof MODULE_IDS)[number];

export type ConditionStatus = 'CONFIRMED' | 'SUSPECTED' | 'HISTORY' | 'SELF_REPORTED';
export type SmokingStatus = 'NEVER' | 'FORMER' | 'CURRENT' | 'UNKNOWN';

export interface ConditionEntry {
  id: string;
  label: string;
  status: ConditionStatus;
  module: ModuleId | null;
}

export interface ProfileInputs {
  age_years: number | null;
  height_cm: number | null;
  weight_kg: number | null;
  waist_cm: number | null;
  body_fat_pct: number | null;
  systolic_bp: number | null;
  diastolic_bp: number | null;
  resting_hr: number | null;
  sleep_hours: number | null;
  sleep_quality_1_10: number | null;
  steps_per_day: number | null;
  exercise_min_week: number | null;
  smoking_status: SmokingStatus;
  packs_per_day: number | null;
  years_smoked: number | null;
  alcohol_units_week: number | null;
  mood_1_10: number | null;
  pain_0_10: number | null;
  mobility_1_10: number | null;
  cognition_self_1_10: number | null;
  skin_symptom_0_10: number | null;
  breathlessness_0_10: number | null;
  /** Synthetic demo lab values (synthetic units). */
  synth_lipid_marker: number | null;
  synth_glycemic_marker: number | null;
  synth_kidney_marker: number | null;
  preventive_items_up_to_date: number | null;
  preventive_items_total: number | null;
  poor_air_days_month: number | null;
  conditions: ConditionEntry[];
}

export interface BodyProfile {
  id: string;
  name: string;
  profile_type: ProfileType;
  synthetic: boolean;
  source_profile_id: string | null;
  pinned_baseline: boolean;
  modules: Record<ModuleId, boolean>;
  inputs: ProfileInputs;
}

export function emptyInputs(): ProfileInputs {
  return {
    age_years: null,
    height_cm: null,
    weight_kg: null,
    waist_cm: null,
    body_fat_pct: null,
    systolic_bp: null,
    diastolic_bp: null,
    resting_hr: null,
    sleep_hours: null,
    sleep_quality_1_10: null,
    steps_per_day: null,
    exercise_min_week: null,
    smoking_status: 'UNKNOWN',
    packs_per_day: null,
    years_smoked: null,
    alcohol_units_week: null,
    mood_1_10: null,
    pain_0_10: null,
    mobility_1_10: null,
    cognition_self_1_10: null,
    skin_symptom_0_10: null,
    breathlessness_0_10: null,
    synth_lipid_marker: null,
    synth_glycemic_marker: null,
    synth_kidney_marker: null,
    preventive_items_up_to_date: null,
    preventive_items_total: null,
    poor_air_days_month: null,
    conditions: [],
  };
}

export function defaultModules(): Record<ModuleId, boolean> {
  return Object.fromEntries(MODULE_IDS.map((m) => [m, true])) as Record<ModuleId, boolean>;
}

/** Non-destructive clone (FR-42 / AT-201). The returned profile shares no references with the source. */
export function cloneAsScenario(source: BodyProfile, newId: string, name: string): BodyProfile {
  const copy = structuredClone(source);
  return {
    ...copy,
    id: newId,
    name,
    profile_type: 'SCENARIO',
    synthetic: source.synthetic,
    source_profile_id: source.id,
    pinned_baseline: false,
  };
}

/** ScenarioPatch application: returns a new profile, never mutates `profile`. */
export function applyPatch(
  profile: BodyProfile,
  patch: Partial<ProfileInputs>,
): BodyProfile {
  const next = structuredClone(profile);
  next.inputs = { ...next.inputs, ...structuredClone(patch) };
  return next;
}

/** Reset a scenario to its source baseline (AT-212); identity and name are kept. */
export function resetScenarioToSource(scenario: BodyProfile, source: BodyProfile): BodyProfile {
  return {
    ...scenario,
    inputs: structuredClone(source.inputs),
    modules: structuredClone(source.modules),
  };
}
