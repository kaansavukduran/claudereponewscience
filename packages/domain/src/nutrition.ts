// Nutrition, recipe and portion math engine (doc 140). Missing nutrients stay MISSING, never 0.
// Volume → mass only with an explicit density/measure mapping. Logged snapshots are immutable.

import { isPresent } from './result.ts';

export const NUTRITION_ENGINE = { engineId: 'NUTRITION-MATH-1', version: '0.20.0' } as const;

export type Basis = { amount: number; unit: 'g' | 'mL' | 'serving' | 'piece' };

/** Nutrient map: value null = MISSING (provider did not report it). */
export type NutrientMap = Record<string, number | null>;

export interface FoodSnapshot {
  snapshot_id: string;
  name: string;
  basis: Basis;
  nutrients: NutrientMap;
  /** Optional explicit density for mL ↔ g conversion (g per mL). */
  density_g_per_ml?: number | null;
  /** Optional household measures in grams, e.g. { slice: 30 }. */
  measures_g?: Record<string, number>;
  source: string;
}

export interface Quantity {
  amount: number;
  unit: 'g' | 'mL' | 'serving' | 'piece' | string;
}

export type ScaleError = 'VOLUME_TO_MASS_BLOCKED' | 'UNKNOWN_MEASURE' | 'INVALID_QUANTITY' | 'BASIS_INCOMPATIBLE';

export interface ScaledNutrients {
  ok: boolean;
  error: ScaleError | null;
  nutrients: NutrientMap;
  factor: number | null;
  conversion: string | null;
}

/** Converts the consumed quantity into the food's basis unit; returns factor = consumed/basis. */
export function scaleFactor(food: FoodSnapshot, q: Quantity): { factor: number | null; error: ScaleError | null; conversion: string | null } {
  if (!isPresent(q.amount) || q.amount < 0) return { factor: null, error: 'INVALID_QUANTITY', conversion: null };
  const b = food.basis;
  if (q.unit === b.unit) return { factor: q.amount / b.amount, error: null, conversion: null };
  if (b.unit === 'g' && q.unit === 'mL') {
    if (!isPresent(food.density_g_per_ml)) return { factor: null, error: 'VOLUME_TO_MASS_BLOCKED', conversion: null };
    return { factor: (q.amount * food.density_g_per_ml) / b.amount, error: null, conversion: `density ${food.density_g_per_ml} g/mL` };
  }
  if (b.unit === 'mL' && q.unit === 'g') {
    if (!isPresent(food.density_g_per_ml)) return { factor: null, error: 'VOLUME_TO_MASS_BLOCKED', conversion: null };
    return { factor: q.amount / food.density_g_per_ml / b.amount, error: null, conversion: `density ${food.density_g_per_ml} g/mL` };
  }
  if (b.unit === 'g' && food.measures_g && q.unit in food.measures_g) {
    const g = food.measures_g[q.unit] as number;
    return { factor: (q.amount * g) / b.amount, error: null, conversion: `measure ${q.unit} = ${g} g` };
  }
  if (b.unit === 'g') return { factor: null, error: 'UNKNOWN_MEASURE', conversion: null };
  return { factor: null, error: 'BASIS_INCOMPATIBLE', conversion: null };
}

export function scaleFood(food: FoodSnapshot, q: Quantity): ScaledNutrients {
  const { factor, error, conversion } = scaleFactor(food, q);
  if (factor === null) return { ok: false, error, nutrients: {}, factor: null, conversion: null };
  const nutrients: NutrientMap = {};
  for (const [k, v] of Object.entries(food.nutrients)) nutrients[k] = isPresent(v) ? v * factor : null;
  return { ok: true, error: null, nutrients, factor, conversion };
}

export interface NutrientTotal {
  /** Sum of known contributions only. null if no contribution is known. */
  known: number | null;
  known_sources: number;
  missing_sources: number;
  /** Fraction of contributing items that reported this nutrient. */
  coverage: number;
  complete: boolean;
}

/** Daily or recipe totals: known total + missing-source count (AT-047, AT-655, nutrition vector 10). */
export function sumNutrients(items: NutrientMap[], keys?: string[]): Record<string, NutrientTotal> {
  const all = keys ?? [...new Set(items.flatMap((i) => Object.keys(i)))].sort();
  const out: Record<string, NutrientTotal> = {};
  for (const k of all) {
    let known = 0;
    let ks = 0;
    let ms = 0;
    for (const it of items) {
      const v = it[k];
      if (isPresent(v)) {
        known += v;
        ks++;
      } else ms++;
    }
    out[k] = {
      known: ks ? known : null,
      known_sources: ks,
      missing_sources: ms,
      coverage: items.length ? ks / items.length : 0,
      complete: ms === 0 && ks > 0,
    };
  }
  return out;
}

export interface RecipeIngredient {
  food: FoodSnapshot;
  quantity: Quantity;
}

export interface RecipeVersion {
  recipe_id: string;
  version: number;
  name: string;
  ingredients: RecipeIngredient[];
  serving_count: number | null;
  final_cooked_mass_g: number | null;
}

export interface RecipeResult {
  ok: boolean;
  errors: Array<{ ingredient: string; error: ScaleError }>;
  totals: Record<string, NutrientTotal>;
  per_serving: Record<string, number | null> | null;
  per_100g_cooked: Record<string, number | null> | null;
}

export function computeRecipe(recipe: RecipeVersion): RecipeResult {
  const scaled = recipe.ingredients.map((ing) => ({ ing, s: scaleFood(ing.food, ing.quantity) }));
  const errors = scaled.filter((x) => !x.s.ok).map((x) => ({ ingredient: x.ing.food.name, error: x.s.error as ScaleError }));
  const totals = sumNutrients(scaled.filter((x) => x.s.ok).map((x) => x.s.nutrients));
  const div = (d: number | null) =>
    d === null || d <= 0 ? null : Object.fromEntries(Object.entries(totals).map(([k, t]) => [k, t.known === null ? null : t.known / d]));
  return {
    ok: errors.length === 0,
    errors,
    totals,
    per_serving: div(recipe.serving_count),
    // Cooking yield is never assumed: per-100g cooked density requires a measured final mass.
    per_100g_cooked: recipe.final_cooked_mass_g ? div(recipe.final_cooked_mass_g / 100) : null,
  };
}

/** Editing a recipe yields a new version; history keeps the old one untouched. */
export function editRecipe(r: RecipeVersion, change: Partial<Omit<RecipeVersion, 'recipe_id' | 'version'>>): RecipeVersion {
  return { ...structuredClone(r), ...structuredClone(change), version: r.version + 1 };
}

/** Display rounding is separate from stored precision. */
export function roundForDisplay(x: number | null, digits = 1): string {
  if (x === null) return '—';
  return x.toFixed(digits);
}
