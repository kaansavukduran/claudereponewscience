// Executes every shared golden-vector catalog in /contracts against @hhos/domain.
// The same files are executed by tools/verify_contracts.py (independent Python port) → parity.

import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import {
  CORE_DERIVED_FUNCTIONS,
  assessSafety,
  assessService,
  computeRecipe,
  interpretLabResult,
  scaleFood,
  type LabInterpretationInput,
} from '../src/index.ts';

const load = (name: string) =>
  JSON.parse(readFileSync(fileURLToPath(new URL(`../../../contracts/golden_vectors/${name}`, import.meta.url)), 'utf8'));

const close = (a: number | null | undefined, b: number, tol: number) => {
  expect(a).not.toBeNull();
  expect(Math.abs((a as number) - b)).toBeLessThanOrEqual(tol);
};

describe('core_derived_vectors (AT-805, AT-806)', () => {
  const cat = load('core_derived_vectors.json');
  for (const v of cat.vectors) {
    it(`${v.vector_id} ${v.model_id}`, () => {
      const fn = CORE_DERIVED_FUNCTIONS[v.model_id];
      expect(fn, `no implementation for ${v.model_id}`).toBeDefined();
      const r1 = fn!(structuredClone(v.inputs) as never);
      const r2 = fn!(structuredClone(v.inputs) as never);
      expect(r1).toEqual(r2); // deterministic repeatability
      expect(r1.status).toBe(v.expected.status);
      if ('value' in v.expected) close(r1.value, v.expected.value, v.tolerance);
      else expect(r1.value).toBeNull(); // invalid/missing never becomes a number
      if (v.expected.error_code) expect(r1.errorCode).toBe(v.expected.error_code);
    });
  }
});

describe('lab_interpretation_vectors (AT-1064..1097)', () => {
  const cat = load('lab_interpretation_vectors.json');
  for (const v of cat.vectors) {
    it(`${v.vector_id} ${v.note}`, () => {
      const a = interpretLabResult(v.input as LabInterpretationInput);
      const e = v.expected;
      if (e.status) expect(a.status).toBe(e.status);
      if (e.reference) expect(a.reference.state).toBe(e.reference);
      if (e.critical) expect(a.critical.state).toBe(e.critical);
      if ('external_receipt_confirmed' in e) expect(a.critical.external_receipt_confirmed).toBe(false);
      if (e.decision_matched) expect(a.decision.filter((d) => d.matched).map((d) => d.rule_id)).toEqual(e.decision_matched);
      if (e.comparability) expect(a.comparability.state).toBe(e.comparability);
      if ('trend_discontinuity' in e) expect(a.comparability.trend_discontinuity).toBe(e.trend_discontinuity);
      if (e.rcv) expect(a.rcv.state).toBe(e.rcv);
      if (e.rcv_percent) close(a.rcv.rcv_percent, e.rcv_percent, e.tolerance);
      if (e.observed_percent_change) close(a.rcv.observed_percent_change, e.observed_percent_change, e.tolerance);
      if (e.baseline) expect(a.baseline.state).toBe(e.baseline);
      if (e.robust_z) close(a.baseline.robust_z, e.robust_z, e.tolerance);
      if (e.flag_origins) expect(a.flags.map((f) => f.origin)).toEqual(e.flag_origins);
      if ('value' in e) expect(a.value).toBe(e.value);
    });
  }
});

describe('nutrition_vectors (AT-042/043/047/412/655)', () => {
  const cat = load('nutrition_vectors.json');
  for (const v of cat.vectors) {
    it(`${v.vector_id} ${v.note}`, () => {
      if (v.kind === 'scale') {
        const r = scaleFood(v.food, v.quantity);
        expect(r.ok).toBe(v.expected.ok);
        if (v.expected.error) expect(r.error).toBe(v.expected.error);
        for (const [k, val] of Object.entries(v.expected.nutrients ?? {})) {
          if (val === null) expect(r.nutrients[k]).toBeNull();
          else close(r.nutrients[k], val as number, 1e-9);
        }
      } else {
        const r = computeRecipe(v.recipe);
        expect(r.ok).toBe(v.expected.ok);
        for (const [k, val] of Object.entries(v.expected.totals_known ?? {})) close(r.totals[k]?.known, val as number, 1e-9);
        for (const [k, val] of Object.entries(v.expected.missing_sources ?? {})) expect(r.totals[k]?.missing_sources).toBe(val);
        if (v.expected.per_serving === null) expect(r.per_serving).toBeNull();
        else for (const [k, val] of Object.entries(v.expected.per_serving ?? {})) close(r.per_serving?.[k], val as number, 1e-9);
        if (v.expected.per_100g_cooked === null) expect(r.per_100g_cooked).toBeNull();
        else for (const [k, val] of Object.entries(v.expected.per_100g_cooked ?? {})) close(r.per_100g_cooked?.[k], val as number, 1e-9);
      }
    });
  }
});

describe('preventive_vectors (AT-1019..1049)', () => {
  const cat = load('preventive_vectors.json');
  for (const v of cat.vectors) {
    it(`${v.vector_id} ${v.service_id}`, () => {
      const a = assessService(v.service_id, v.rules ?? cat.rules, v.input);
      for (const [k, val] of Object.entries(v.expected)) expect((a as unknown as Record<string, unknown>)[k], k).toEqual(val);
    });
  }
});

describe('medication_safety_vectors (AT-980..1008)', () => {
  const cat = load('medication_safety_vectors.json');
  for (const v of cat.vectors) {
    it(`${v.vector_id} ${v.note}`, () => {
      const a = assessSafety(cat.products, v.entries, cat.rules, v.conditions, cat.pack);
      expect(a.findings.map((f) => f.type)).toEqual(v.expected.types);
      for (const f of a.findings) expect(f.guaranteed_safe).toBe(false);
      for (const [ing, val] of Object.entries(v.expected.combined ?? {})) {
        const f = a.findings.find((x) => x.ingredient_id === ing);
        if (val === null) expect(f?.combined_amount).toBeNull();
        else {
          close(f?.combined_amount?.value, (val as { value: number }).value, 1e-12);
          expect(f?.combined_amount?.unit).toBe((val as { unit: string }).unit);
        }
      }
      for (const [ing, reason] of Object.entries(v.expected.combined_reason ?? {}))
        expect(a.findings.find((x) => x.ingredient_id === ing)?.combined_reason).toBe(reason);
      if (v.expected.exposure_basis) expect(a.findings[0]?.exposure_basis).toBe(v.expected.exposure_basis);
    });
  }
});
