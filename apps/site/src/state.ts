// Site Lab state: synthetic-only, client-side, deterministic. Persisted in localStorage as a
// per-viewer convenience (try/catch, renders correctly without it). Reset ≠ delete real data.

import {
  applyPatch,
  cloneAsScenario,
  defaultModules,
  emptyInputs,
  resetScenarioToSource,
  type BodyProfile,
  type ExposureEntry,
  type MissionEvent,
  type ModuleId,
  type ProfileInputs,
} from '@hhos/domain';
import { syntheticProfiles } from '@hhos/packs';
import type { Lang } from '@hhos/ui';

export type TabId = 'lab' | 'compare' | 'labs' | 'prevent' | 'safety' | 'nutrition' | 'missions' | 'timeline' | 'learn' | 'sources';
export type Theme = 'auto' | 'light' | 'dark' | 'clarity';

export interface LabLabState {
  value: number | null;
  refLow: number | null;
  refHigh: number | null;
  critActive: 'ACTIVE' | 'STALE' | 'NONE';
  critLow: number | null;
  critHigh: number | null;
  priorValue: number | null;
  method: 'M1' | 'M2';
  priorMethod: 'M1' | 'M2';
  specimen: 'serum' | 'plasma';
  priorSpecimen: 'serum' | 'plasma';
  cva: number | null;
  cvi: number | null;
  z: number | null;
  baseline: string;
  requireContext: boolean;
  unitMismatch: boolean;
}

export interface PreventLabState {
  jurisdiction: 'SYN-LAND' | 'OTHER-LAND' | '';
  asOf: string;
  age: number | null;
  risk: boolean;
  anatomy: boolean;
  history: 'KNOWN' | 'UNKNOWN';
  lastCompletion: string;
  doses: string;
  contraindicated: boolean;
  packVariant: 'NORMAL' | 'STALE' | 'CONFLICT';
}

export interface NutritionLabState {
  oats_g: number | null;
  drink_amount: number | null;
  drink_unit: 'g' | 'mL';
  density: boolean;
  servings: number | null;
  cookedMass: number | null;
}

export interface MissionLabState {
  date: string;
  safetyFlag: boolean;
  benchAllReps: boolean;
  benchPain: boolean;
  events: Record<string, MissionEvent[]>;
  moodToday: boolean;
}

export interface SiteState {
  schema: 1;
  lang: Lang;
  theme: Theme;
  tab: TabId;
  tourDone: boolean;
  profiles: BodyProfile[];
  activeId: string;
  baselineId: string;
  compareMetrics: string[];
  labLab: LabLabState;
  preventLab: PreventLabState;
  safetyLab: { entries: ExposureEntry[]; conditions: string[] };
  nutritionLab: NutritionLabState;
  missionLab: MissionLabState;
  learn: { lessonIdx: number; answers: Record<string, number>; revealed: Record<string, boolean> };
  seq: number;
}

export const DEFAULT_COMPARE_METRICS = ['weight_kg', 'resting_hr', 'systolic_bp', 'bmi', 'pack_years', 'protection', 'burden', 'function', 'coverage', 'cvd_prevent'];

export const DEFAULT_LAB_LAB: LabLabState = {
  value: 7, refLow: 4, refHigh: 10, critActive: 'ACTIVE', critLow: 2, critHigh: 20, priorValue: 9,
  method: 'M1', priorMethod: 'M1', specimen: 'serum', priorSpecimen: 'serum', cva: 2, cvi: 5, z: 1.96,
  baseline: '9, 9.2, 8.8, 9.1, 8.9', requireContext: false, unitMismatch: false,
};

export const DEFAULT_PREVENT_LAB: PreventLabState = {
  jurisdiction: 'SYN-LAND', asOf: '2026-10-06', age: 50, risk: false, anatomy: true, history: 'KNOWN',
  lastCompletion: '2024-10-20', doses: '2026-09-20', contraindicated: false, packVariant: 'NORMAL',
};

export function defaultState(lang: Lang = 'en', theme: Theme = 'auto'): SiteState {
  const profiles = syntheticProfiles();
  return {
    schema: 1,
    lang,
    theme,
    tab: 'lab',
    tourDone: false,
    profiles,
    activeId: profiles[0]!.id,
    baselineId: profiles[0]!.id,
    compareMetrics: DEFAULT_COMPARE_METRICS,
    labLab: DEFAULT_LAB_LAB,
    preventLab: DEFAULT_PREVENT_LAB,
    safetyLab: {
      entries: [
        { entry_id: 'E-1', product_id: 'PRD-SYN-A', kind: 'PLAN', servings_per_day: 1, time: '08:00' },
        { entry_id: 'E-2', product_id: 'PRD-SYN-B', kind: 'TAKEN', servings_per_day: 1, time: '08:30' },
      ],
      conditions: [],
    },
    nutritionLab: { oats_g: 80, drink_amount: 300, drink_unit: 'g', density: false, servings: 2, cookedMass: 400 },
    missionLab: { date: '2026-10-06', safetyFlag: false, benchAllReps: true, benchPain: false, events: {}, moodToday: false },
    learn: { lessonIdx: 0, answers: {}, revealed: {} },
    seq: 1,
  };
}

export type Action =
  | { type: 'set'; patch: Partial<SiteState> }
  | { type: 'selectProfile'; id: string }
  | { type: 'patchInputs'; id: string; patch: Partial<ProfileInputs> }
  | { type: 'toggleModule'; id: string; module: ModuleId }
  | { type: 'rename'; id: string; name: string }
  | { type: 'addBlank' }
  | { type: 'cloneScenario'; id: string }
  | { type: 'resetScenario'; id: string }
  | { type: 'deleteProfile'; id: string }
  | { type: 'pinBaseline'; id: string }
  | { type: 'labLab'; patch: Partial<LabLabState> }
  | { type: 'preventLab'; patch: Partial<PreventLabState> }
  | { type: 'safetyLab'; patch: Partial<SiteState['safetyLab']> }
  | { type: 'nutritionLab'; patch: Partial<NutritionLabState> }
  | { type: 'missionLab'; patch: Partial<MissionLabState> }
  | { type: 'missionEvent'; missionId: string; event: MissionEvent }
  | { type: 'learn'; patch: Partial<SiteState['learn']> }
  | { type: 'resetDemo' }
  | { type: 'clearLocal' };

const mapProfile = (s: SiteState, id: string, f: (p: BodyProfile) => BodyProfile): SiteState => ({ ...s, profiles: s.profiles.map((p) => (p.id === id ? f(p) : p)) });

export function reducer(s: SiteState, a: Action): SiteState {
  switch (a.type) {
    case 'set':
      return { ...s, ...a.patch };
    case 'selectProfile':
      return { ...s, activeId: a.id };
    case 'patchInputs':
      return mapProfile(s, a.id, (p) => applyPatch(p, a.patch));
    case 'toggleModule':
      return mapProfile(s, a.id, (p) => ({ ...p, modules: { ...p.modules, [a.module]: !p.modules[a.module] } }));
    case 'rename':
      return mapProfile(s, a.id, (p) => ({ ...p, name: a.name }));
    case 'addBlank': {
      const id = `SYNTH-USER-${s.seq}`;
      const p: BodyProfile = { id, name: `Synthetic body ${s.seq}`, profile_type: 'SYNTHETIC', synthetic: true, source_profile_id: null, pinned_baseline: false, modules: defaultModules(), inputs: emptyInputs() };
      return { ...s, seq: s.seq + 1, profiles: [...s.profiles, p], activeId: id };
    }
    case 'cloneScenario': {
      const src = s.profiles.find((p) => p.id === a.id);
      if (!src) return s;
      const id = `SCENARIO-${s.seq}`;
      const clone = cloneAsScenario(src, id, `${src.name} · scenario ${s.seq}`);
      return { ...s, seq: s.seq + 1, profiles: [...s.profiles, clone], activeId: id };
    }
    case 'resetScenario': {
      const scn = s.profiles.find((p) => p.id === a.id);
      const src = scn?.source_profile_id ? s.profiles.find((p) => p.id === scn.source_profile_id) : undefined;
      if (!scn || !src) return s;
      return mapProfile(s, a.id, () => resetScenarioToSource(scn, src));
    }
    case 'deleteProfile': {
      if (s.profiles.length <= 1) return s;
      const profiles = s.profiles.filter((p) => p.id !== a.id).map((p) => (p.source_profile_id === a.id ? { ...p, source_profile_id: null } : p));
      const first = profiles[0]!.id;
      return { ...s, profiles, activeId: s.activeId === a.id ? first : s.activeId, baselineId: s.baselineId === a.id ? first : s.baselineId };
    }
    case 'pinBaseline':
      return { ...s, baselineId: a.id };
    case 'labLab':
      return { ...s, labLab: { ...s.labLab, ...a.patch } };
    case 'preventLab':
      return { ...s, preventLab: { ...s.preventLab, ...a.patch } };
    case 'safetyLab':
      return { ...s, safetyLab: { ...s.safetyLab, ...a.patch } };
    case 'nutritionLab':
      return { ...s, nutritionLab: { ...s.nutritionLab, ...a.patch } };
    case 'missionLab':
      return { ...s, missionLab: { ...s.missionLab, ...a.patch } };
    case 'missionEvent': {
      const prev = s.missionLab.events[a.missionId] ?? [];
      return { ...s, missionLab: { ...s.missionLab, events: { ...s.missionLab.events, [a.missionId]: [...prev, a.event] } } };
    }
    case 'learn':
      return { ...s, learn: { ...s.learn, ...a.patch } };
    case 'resetDemo':
      // Restores synthetic profiles, demo settings and starter pack selection. Language/theme are viewer display prefs.
      return { ...defaultState(s.lang, s.theme), tourDone: true };
    case 'clearLocal':
      return defaultState();
  }
}

export const STORAGE_KEY = 'hhos-site-lab-v1';

export function loadState(): SiteState {
  try {
    const raw = globalThis.localStorage?.getItem(STORAGE_KEY);
    if (raw) {
      const s = JSON.parse(raw) as SiteState;
      if (s && s.schema === 1 && Array.isArray(s.profiles) && s.profiles.length) return { ...defaultState(), ...s };
    }
  } catch {
    /* storage unavailable or corrupt → defaults */
  }
  return defaultState();
}

export function saveState(s: SiteState): void {
  try {
    globalThis.localStorage?.setItem(STORAGE_KEY, JSON.stringify(s));
  } catch {
    /* ignore */
  }
}

export function clearStorage(): void {
  try {
    globalThis.localStorage?.removeItem(STORAGE_KEY);
  } catch {
    /* ignore */
  }
}
