// G-75 (D-038): the TS reference refuses the same inputs as the Dart engines, beyond the golden vectors.
// Rolling windows refuse an empty or all-missing list and a bad min_count; no engine reports NaN or an
// infinity; a result keeps a frozen copy of its inputs; a missing list is refused instead of throwing.
// Mirrors human_health_os/test/domain/f011_engine_hardening_test.dart.

import { describe, expect, it } from 'vitest';
import {
  NON_FINITE_RESULT,
  bmi,
  combineAmounts,
  computeRecipe,
  interpretLabResult,
  median,
  ok,
  olsSlope,
  robustZ,
  rollingMean,
  rollingMedian,
  scaleFood,
  trainingVolumeLoad,
  type FoodSnapshot,
  type LabInterpretationInput,
  type ModelRef,
} from '../src/index.ts';

const fns = { mean: rollingMean, median: rollingMedian } as const;

describe('rolling windows (min_count, empty lists)', () => {
  for (const [name, fn] of Object.entries(fns)) {
    for (const bad of [0, -1, 1.5, Number.NaN, Number.POSITIVE_INFINITY, '3']) {
      it(`${name} refuses min_count ${String(bad)}`, () => {
        const r = fn({ values: [1, 2, 3], window: 3, min_count: bad as never });
        expect(r.status).toBe('INVALID_INPUT');
        expect(r.errorCode).toBe('INVALID_MIN_COUNT');
        expect(r.value).toBeNull();
      });
    }
    it(`${name} refuses an empty list (no NaN)`, () => {
      const r = fn({ values: [], window: 3 });
      expect(r.status).toBe('MISSING_INPUT');
      expect(r.errorCode).toBe('INSUFFICIENT_OBSERVATIONS');
      expect(r.value).toBeNull();
    });
    it(`${name} refuses an empty list even with min_count 1`, () => {
      expect(fn({ values: [], window: 3, min_count: 1 }).errorCode).toBe('INSUFFICIENT_OBSERVATIONS');
    });
    it(`${name} refuses an all-missing list`, () => {
      const r = fn({ values: [null, Number.NaN, null], window: 3 });
      expect(r.errorCode).toBe('INSUFFICIENT_OBSERVATIONS');
      expect(r.value).toBeNull();
    });
    it(`${name} refuses a missing values list instead of throwing`, () => {
      const r = fn({ window: 3 } as never);
      expect(r.status).toBe('MISSING_INPUT');
      expect(r.errorCode).toBe('MISSING_REQUIRED_INPUT');
      expect(r.missingInputs).toEqual(['values']);
    });
    it(`${name} checks the window before min_count`, () => {
      expect(fn({ values: [1], window: 0, min_count: 0 }).errorCode).toBe('INVALID_WINDOW');
    });
    it(`${name} accepts min_count 2 and 2.0 and a null min_count`, () => {
      for (const mc of [2, 2.0, null, undefined]) {
        const r = fn({ values: [1, null, 3], window: 3, min_count: mc as never });
        expect(r.status, String(mc)).toBe('OK');
        expect(r.value).toBe(2);
      }
    });
  }

  it('median of nothing throws, never a value', () => {
    expect(() => median([])).toThrow(RangeError);
  });
});

describe('missing lists are refused, never thrown', () => {
  it('training volume load without sets', () => {
    const r = trainingVolumeLoad({} as never);
    expect(r.status).toBe('MISSING_INPUT');
    expect(r.errorCode).toBe('MISSING_REQUIRED_INPUT');
    expect(r.missingInputs).toEqual(['sets']);
  });
  it('OLS slope without points', () => {
    const r = olsSlope({} as never);
    expect(r.errorCode).toBe('INSUFFICIENT_OBSERVATIONS');
    expect(r.missingInputs).toEqual(['points']);
  });
  it('robust z without series', () => {
    const r = robustZ({ x: 1 } as never);
    expect(r.errorCode).toBe('INSUFFICIENT_OBSERVATIONS');
    expect(r.missingInputs).toEqual(['series']);
  });
});

describe('non-finite results are refused (NON_FINITE_RESULT)', () => {
  it('BMI overflow', () => {
    const r = bmi({ weight_kg: 1e308, height_m: 1e-200 });
    expect(r.status).toBe('INVALID_INPUT');
    expect(r.errorCode).toBe(NON_FINITE_RESULT);
    expect(r.value).toBeNull();
    expect(r.modelId).toBe('DERIVED-BMI-1');
  });

  it('rolling mean overflow', () => {
    const r = rollingMean({ values: [1e308, 1e308], window: 2 });
    expect(r.errorCode).toBe(NON_FINITE_RESULT);
    expect(r.value).toBeNull();
  });

  it('ok never carries NaN', () => {
    const m: ModelRef = { modelId: 'X', version: '1', resultClass: 'EXPERIMENTAL', unit: null };
    const r = ok(m, Number.NaN, {});
    expect(r.status).toBe('INVALID_INPUT');
    expect(r.value).toBeNull();
    expect(r.errorCode).toBe(NON_FINITE_RESULT);
  });

  const food = (nutrients: Record<string, number | null>): FoodSnapshot => ({
    snapshot_id: 'F',
    name: 'synthetic',
    source: 'SYN',
    basis: { amount: 100, unit: 'g' },
    nutrients,
  });

  it('nutrition scaling overflow refuses the whole map', () => {
    const r = scaleFood(food({ protein_g: 1e308, fiber_g: null }), { amount: 1e10, unit: 'g' });
    expect(r.ok).toBe(false);
    expect(r.error).toBe(NON_FINITE_RESULT);
    expect(r.nutrients).toEqual({});
    expect(r.factor).toBeNull();
  });

  it('nutrition scaling with a zero basis is refused, not infinite', () => {
    const f = { ...food({ protein_g: 1 }), basis: { amount: 0, unit: 'g' as const } };
    const r = scaleFood(f, { amount: 10, unit: 'g' });
    expect(r.ok).toBe(false);
    expect(r.error).toBe(NON_FINITE_RESULT);
  });

  it('recipe totals overflow refuses the recipe', () => {
    const ing = { food: food({ protein_g: 1e308 }), quantity: { amount: 100, unit: 'g' } };
    const r = computeRecipe({
      recipe_id: 'R',
      version: 1,
      name: 'overflow',
      ingredients: [ing, ing],
      serving_count: 2,
      final_cooked_mass_g: 100,
    });
    expect(r.ok).toBe(false);
    expect(r.errors.at(-1)).toEqual({ ingredient: 'overflow', error: NON_FINITE_RESULT });
    expect(r.totals).toEqual({});
    expect(r.per_serving).toBeNull();
    expect(r.per_100g_cooked).toBeNull();
  });

  it('lab RCV and baseline overflow', () => {
    const lab = (value: number, observed_at: string) => ({
      analyte_key: 'SYN',
      value,
      unit: 'u',
      observed_at,
      method_id: 'M',
      specimen: 'S',
    });
    const input: LabInterpretationInput = {
      result: lab(1e308, '2026-02-01'),
      reference: [],
      context: {},
      decision_rules: [],
      critical_rules: [],
      prior: lab(1e-308, '2026-01-01'),
      comparability_records: [],
      rcv: { cva: 1, cvi: 1, z: 1.96, source: 'SYN' },
      baseline_points: [-1e-300, 0, 1e-300, 2e-300, 3e-300],
    };
    const a = interpretLabResult(input);
    expect(a.rcv.state).toBe(NON_FINITE_RESULT);
    expect(a.rcv.observed_percent_change).toBeNull();
    expect(a.rcv.rcv_percent).not.toBeNull();
    expect(a.baseline.state).toBe(NON_FINITE_RESULT);
    expect(a.baseline.robust_z).toBeNull();
    expect(a.baseline.n).toBe(5);
  });

  it('lab RCV percent overflow', () => {
    const lab = (value: number) => ({ analyte_key: 'SYN', value, unit: 'u', observed_at: '2026-01-01', method_id: 'M', specimen: 'S' });
    const a = interpretLabResult({
      result: lab(2),
      reference: [],
      context: {},
      decision_rules: [],
      critical_rules: [],
      prior: lab(1),
      comparability_records: [],
      rcv: { cva: 1e200, cvi: 1, z: 1.96, source: 'SYN' },
      baseline_points: [],
    });
    expect(a.rcv).toEqual({ state: NON_FINITE_RESULT, rcv_percent: null, observed_percent_change: null, source: 'SYN' });
  });

  it('medication amounts that overflow are not combined', () => {
    const same = combineAmounts([
      { amount: 1e308, unit: 'g', basis: 'AS_LABELED' },
      { amount: 1e308, unit: 'g', basis: 'AS_LABELED' },
    ]);
    expect(same).toEqual({ value: null, unit: null, reason: NON_FINITE_RESULT });
    const mixed = combineAmounts([
      { amount: 1e308, unit: 'g', basis: 'AS_LABELED' },
      { amount: 1, unit: 'mg', basis: 'AS_LABELED' },
    ]);
    expect(mixed).toEqual({ value: null, unit: null, reason: NON_FINITE_RESULT });
  });
});

describe('inputs are a frozen copy', () => {
  it('mutating the caller object after compute changes nothing', () => {
    const inputs = { values: [1, 2, 3] as Array<number | null>, window: 3 };
    const r = rollingMean(inputs);
    inputs.window = 99;
    inputs.values.push(1000);
    expect(r.inputs.window).toBe(3);
    expect(r.inputs.values).toEqual([1, 2, 3]);
    expect(Object.isFrozen(r.inputs)).toBe(true);
    expect(Object.isFrozen(r.inputs.values)).toBe(true);
    expect(() => {
      (r.inputs as Record<string, unknown>).window = 1;
    }).toThrow(TypeError);
    expect(() => (r.inputs.values as number[]).push(4)).toThrow(TypeError);
  });

  it('a refusal also keeps a copy', () => {
    const inputs: { weight_kg: number | null; height_m: number } = { weight_kg: null, height_m: 1.8 };
    const r = bmi(inputs);
    inputs.weight_kg = 80;
    expect(r.inputs.weight_kg).toBeNull();
    expect(r.missingInputs).toEqual(['weight_kg']);
  });

  it('nested objects are copied too', () => {
    const sets = [{ load_kg: 50, reps: 10, state: 'COMPLETED' as const }];
    const r = trainingVolumeLoad({ sets });
    sets[0]!.reps = 1;
    expect((r.inputs.sets as Array<{ reps: number }>)[0]!.reps).toBe(10);
    expect(r.value).toBe(500);
  });
});
