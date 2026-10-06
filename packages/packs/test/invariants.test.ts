// RP-CORE-INVARIANTS-1 semantic tests over the synthetic pack (shared by Site + Client + API).

import { describe, expect, it } from 'vitest';
import {
  applyMissionEvent,
  applyPatch,
  cloneAsScenario,
  compareProfiles,
  computeProfileResults,
  editRecipe,
  generateMissions,
  resetScenarioToSource,
  xpEarned,
  type MissionInput,
} from '@hhos/domain';
import { DEMO_PROGRAM, LESSONS, gradeMcq, syntheticProfiles, syntheticWearable } from '../src/index.ts';

const [A, B, C, BASE] = syntheticProfiles() as [ReturnType<typeof syntheticProfiles>[number], ReturnType<typeof syntheticProfiles>[number], ReturnType<typeof syntheticProfiles>[number], ReturnType<typeof syntheticProfiles>[number]];

describe('synthetic pack', () => {
  it('AT-756: default profiles are explicitly synthetic and include the four required IDs', () => {
    const ps = syntheticProfiles();
    expect(ps.map((p) => p.id)).toEqual(['SYNTH-BASIC-A', 'SYNTH-HIGH-BURDEN-B', 'SYNTH-ACTIVE-C', 'SYNTH-SCENARIO-BASE']);
    expect(ps.every((p) => p.synthetic && p.profile_type === 'SYNTHETIC')).toBe(true);
  });
  it('wearable generator is seeded/deterministic and keeps gaps as null', () => {
    const a = syntheticWearable();
    expect(a).toEqual(syntheticWearable());
    expect(a.some((d) => d.steps === null)).toBe(true);
    expect(a.some((d) => d.steps === 0)).toBe(false);
  });
  it('AT-793/796: 15 lessons, missing≠zero answer key rejects zero', () => {
    expect(LESSONS.map((l) => l.id)).toEqual(Array.from({ length: 15 }, (_, i) => `EDU-${String(i + 1).padStart(3, '0')}`));
    expect(gradeMcq('EDU-002', 0, 0)).toBe(false);
    expect(gradeMcq('EDU-002', 0, 1)).toBe(true);
  });
});

describe('results & compare', () => {
  it('AT-806/10: deterministic repeatability', () => {
    expect(computeProfileResults(A)).toEqual(computeProfileResults(structuredClone(A)));
  });
  it('AT-766/780: app scores are APP_COMPOSITE and external models never fabricate numbers', () => {
    const r = computeProfileResults(B);
    expect(r.protection.resultClass).toBe('APP_COMPOSITE');
    expect(r.burden.value).toBeGreaterThan(computeProfileResults(C).burden.value as number);
    for (const e of r.external) {
      expect(e.result.status).toBe('UNAVAILABLE');
      expect(e.result.value).toBeNull();
    }
    expect(r.lifespanProjection).not.toBe('VALIDATED_PERSONAL_MODEL_AVAILABLE');
  });
  it('missing inputs do not become zero; sparse profile reports coverage instead of a fake score', () => {
    const r = computeProfileResults(BASE);
    expect(r.derived.whtr.status).toBe('MISSING_INPUT');
    expect(r.derived.whtr.value).toBeNull();
    expect(r.function.status).toBe('MISSING_INPUT');
    expect(r.function.value).toBeNull();
    expect(r.protection.missingInputs).toContain('P-STEPS');
  });
  it('AT-201/762/641: scenario clone changes never mutate the source', () => {
    const before = structuredClone(A);
    const s = cloneAsScenario(A, 'SCN-1', 'A −10 kg');
    const s2 = applyPatch(s, { weight_kg: 68 });
    expect(A).toEqual(before);
    expect(s2.source_profile_id).toBe('SYNTH-BASIC-A');
    expect(computeProfileResults(s2).hypothetical).toBe(true);
    expect(computeProfileResults(s2).derived.bmi.value).toBeLessThan(computeProfileResults(A).derived.bmi.value as number);
    expect(resetScenarioToSource(s2, A).inputs).toEqual(A.inputs);
  });
  it('AT-202/761/563/634: compare 4 profiles with mixed states, %Δ only where meaningful', () => {
    const rows = compareProfiles([A, B, C, BASE], A.id);
    const weight = rows.find((r) => r.metric.id === 'weight_kg')!;
    const bCell = weight.cells.find((c) => c.profileId === B.id)!;
    expect(bCell.delta).toBe(34);
    expect(bCell.percentDelta).toBeCloseTo((34 / 78) * 100, 9);
    const prot = rows.find((r) => r.metric.id === 'protection')!;
    expect(prot.cells.find((c) => c.profileId === B.id)!.deltaState).toBe('PERCENT_NOT_MEANINGFUL');
    const fn = rows.find((r) => r.metric.id === 'function')!;
    expect(fn.cells.find((c) => c.profileId === BASE.id)!.deltaState).toBe('NOT_COMPARABLE');
    const cvd = rows.find((r) => r.metric.id === 'cvd_prevent')!;
    expect(cvd.cells.every((c) => c.state === 'UNAVAILABLE' && c.value === null)).toBe(true);
  });
  it('module toggle hides components without deleting profile data (FR-46)', () => {
    const off = { ...A, modules: { ...A.modules, cardiovascular: false } };
    const r = computeProfileResults(off);
    expect(r.burden.components.find((c) => c.id === 'B-SYSTOLIC')!.eligible).toBe(false);
    expect(off.inputs.systolic_bp).toBe(124);
  });
});

describe('missions', () => {
  const input: MissionInput = {
    profile_id: 'SYNTH-ACTIVE-C',
    date: '2026-10-06',
    program: DEMO_PROGRAM,
    sessions: [
      { session_id: 'S1', date: '2026-09-30', exercise_id: 'EX-BENCH', prescribed_load_kg: 30, prescribed_reps: 10, pain_stop: false, sets: [1, 2, 3].map(() => ({ load_kg: 30, reps: 10, state: 'COMPLETED' as const })) },
      { session_id: 'S2', date: '2026-09-30', exercise_id: 'EX-SQUAT', prescribed_load_kg: 16, prescribed_reps: 12, pain_stop: false, sets: [{ load_kg: 16, reps: 12, state: 'COMPLETED' }, { load_kg: 16, reps: 9, state: 'COMPLETED' }] },
    ],
    safety_flags: [],
    last_mood_checkin_date: null,
    next_lesson_id: 'EDU-010',
    preventive_review_needed: true,
  };
  it('AT-220/221: deterministic mission set; progression from real completions only', () => {
    const m = generateMissions(input);
    expect(m).toEqual(generateMissions(structuredClone(input)));
    expect(m.find((x) => x.title.startsWith('Bench'))!.title).toBe('Bench Press — 3 × 10 @ 32.5 kg');
    expect(m.find((x) => x.title.startsWith('Goblet'))!.title).toBe('Goblet Squat — 2 × 12 @ 16 kg');
    expect(m.every((x) => x.status === 'PLANNED')).toBe(true);
  });
  it('AT-224/289: safety flag BLOCKS physical missions', () => {
    const m = generateMissions({ ...input, safety_flags: ['ACUTE_INJURY'] });
    expect(m.filter((x) => x.category === 'Train').every((x) => x.status === 'BLOCKED')).toBe(true);
  });
  it('AT-510/783/633: notification delivered/opened never completes; XP ≠ health score', () => {
    const m = generateMissions(input)[1]!;
    const after = applyMissionEvent(applyMissionEvent(m, { kind: 'NOTIFICATION_DELIVERED' }), { kind: 'NOTIFICATION_OPENED' });
    expect(after.status).toBe('PLANNED');
    const done = applyMissionEvent(after, { kind: 'COMPLETED', completion_record_id: 'WK-1' });
    expect(done.status).toBe('COMPLETED');
    expect(xpEarned([done])).toBe(20);
    expect(computeProfileResults(C)).toEqual(computeProfileResults(C));
  });
  it('AT-288: a missed day is not stacked', () => {
    const later = generateMissions({ ...input, date: '2026-10-08' });
    expect(later.filter((x) => x.category === 'Train')).toHaveLength(2);
  });
});

describe('recipe versioning', () => {
  it('editing a recipe creates a new version and keeps the old one intact', () => {
    const r1 = { recipe_id: 'R', version: 1, name: 'x', ingredients: [], serving_count: 2, final_cooked_mass_g: null };
    const r2 = editRecipe(r1, { serving_count: 4 });
    expect(r1.serving_count).toBe(2);
    expect(r2.version).toBe(2);
  });
});
