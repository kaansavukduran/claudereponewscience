import { describe, expect, it } from 'vitest';
import { defaultState, reducer } from '../src/state.ts';

describe('Site Lab state', () => {
  it('reset restores declared synthetic defaults and keeps display prefs (AT-763/764)', () => {
    let s = defaultState('tr', 'dark');
    s = reducer(s, { type: 'patchInputs', id: 'SYNTH-BASIC-A', patch: { weight_kg: 120 } });
    s = reducer(s, { type: 'cloneScenario', id: 'SYNTH-BASIC-A' });
    const r = reducer(s, { type: 'resetDemo' });
    const d = defaultState('tr', 'dark');
    expect(r.profiles).toEqual(d.profiles);
    expect(r.lang).toBe('tr');
    expect(r.theme).toBe('dark');
  });
  it('clone + patch leaves the source untouched; scenario reset copies source inputs back', () => {
    let s = reducer(defaultState(), { type: 'cloneScenario', id: 'SYNTH-BASIC-A' });
    const scnId = s.activeId;
    s = reducer(s, { type: 'patchInputs', id: scnId, patch: { weight_kg: 60 } });
    expect(s.profiles.find((p) => p.id === 'SYNTH-BASIC-A')!.inputs.weight_kg).toBe(78);
    s = reducer(s, { type: 'resetScenario', id: scnId });
    expect(s.profiles.find((p) => p.id === scnId)!.inputs.weight_kg).toBe(78);
  });
  it('profiles are not hard-capped; the last profile cannot be removed', () => {
    let s = defaultState();
    for (let i = 0; i < 20; i++) s = reducer(s, { type: 'addBlank' });
    expect(s.profiles).toHaveLength(24);
    let one = { ...s, profiles: s.profiles.slice(0, 1) };
    one = reducer(one, { type: 'deleteProfile', id: one.profiles[0]!.id });
    expect(one.profiles).toHaveLength(1);
  });
  it('blank profile starts with missing values, never zeros', () => {
    const s = reducer(defaultState(), { type: 'addBlank' });
    const p = s.profiles.at(-1)!;
    expect(Object.entries(p.inputs).filter(([k, v]) => k !== 'conditions' && k !== 'smoking_status' && v !== null)).toEqual([]);
  });
});
