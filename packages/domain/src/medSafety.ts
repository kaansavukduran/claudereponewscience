// v0.22 Medication & supplement safety engine (docs 154–163).
// Product ≠ ingredient; plan ≠ taken; duplicate ingredient ≠ toxicity; no rule found ≠ guaranteed safe.

export const SAFETY_ENGINE = { engineId: 'MED-SAFETY-ENGINE-1', version: '0.22.0' } as const;

export type MappingState = 'REVIEWED' | 'AMBIGUOUS' | 'UNKNOWN_COMPOSITION';

export interface IngredientAmount {
  ingredient_id: string;
  label: string;
  amount: number | null;
  unit: 'mcg' | 'mg' | 'g' | 'IU' | string | null;
  /** Amount basis, e.g. ELEMENTAL vs COMPOUND. Different bases are never summed. */
  basis: string;
  mapping: MappingState;
}

export interface ProductConcept {
  product_id: string;
  name: string;
  route: 'ORAL' | 'TOPICAL' | string;
  label_version: string;
  ingredients: IngredientAmount[];
  composition_known: boolean;
}

export interface ExposureEntry {
  entry_id: string;
  product_id: string;
  kind: 'PLAN' | 'TAKEN';
  servings_per_day: number;
  /** HH:MM local time of intake (TAKEN) or scheduled time (PLAN). */
  time: string | null;
}

export interface InteractionRule {
  rule_id: string;
  version: string;
  source: string;
  kind: 'PAIR' | 'TIMING_SEPARATION' | 'CONDITION';
  participants: string[];
  route: string | null;
  min_separation_minutes?: number;
  condition?: string;
  action: 'REVIEW_WITH_CLINICIAN' | 'SEPARATE_TIMING' | 'INFORM';
  test_only: boolean;
}

export type FindingType =
  | 'EXACT_DUPLICATE_ACTIVE_INGREDIENT'
  | 'SAME_ACTIVE_DIFFERENT_PRODUCT'
  | 'POSSIBLE_NAME_DUPLICATE'
  | 'UNKNOWN_INGREDIENT'
  | 'INSUFFICIENT_CONTEXT'
  | 'SYNTHETIC_PAIR_INTERACTION'
  | 'TIMING_SEPARATION'
  | 'CONDITION_CONTEXT'
  | 'CLEAR_NO_MATCH_FOUND';

export interface SafetyFinding {
  type: FindingType;
  ingredient_id: string | null;
  products: string[];
  rule_id: string | null;
  rule_version: string | null;
  action: string | null;
  /** Combined daily amount when bases/units are compatible, otherwise null with reason. */
  combined_amount: { value: number; unit: string } | null;
  combined_reason: string | null;
  exposure_basis: 'PLANNED' | 'TAKEN' | 'MIXED';
  guaranteed_safe: false;
  note: string;
}

export interface InteractionAssessment {
  engine: typeof SAFETY_ENGINE;
  pack: { pack_id: string; version: string; status: string };
  findings: SafetyFinding[];
  limitations: string[];
}

const MASS_TO_MCG: Record<string, number> = { mcg: 1, mg: 1000, g: 1_000_000 };

/** Sum only identical basis + convertible mass units (AT-986/987). IU never converts without a rule. */
export function combineAmounts(parts: Array<{ amount: number | null; unit: string | null; basis: string }>): {
  value: number | null;
  unit: string | null;
  reason: string | null;
} {
  if (parts.some((p) => p.amount === null || p.unit === null)) return { value: null, unit: null, reason: 'UNDISCLOSED_AMOUNT' };
  if (new Set(parts.map((p) => p.basis)).size > 1) return { value: null, unit: null, reason: 'BASIS_MISMATCH' };
  const units = new Set(parts.map((p) => p.unit as string));
  if (units.size === 1) return { value: parts.reduce((a, p) => a + (p.amount as number), 0), unit: [...units][0] as string, reason: null };
  if ([...units].every((u) => u in MASS_TO_MCG)) {
    const mcg = parts.reduce((a, p) => a + (p.amount as number) * (MASS_TO_MCG[p.unit as string] as number), 0);
    const largest = [...units].sort((a, b) => (MASS_TO_MCG[b] as number) - (MASS_TO_MCG[a] as number))[0] as string;
    return { value: mcg / (MASS_TO_MCG[largest] as number), unit: largest, reason: null };
  }
  return { value: null, unit: null, reason: 'UNIT_CONVERSION_RULE_NOT_INSTALLED' };
}

function minutes(t: string | null): number | null {
  if (!t) return null;
  const [h, m] = t.split(':').map(Number);
  return Number.isFinite(h) && Number.isFinite(m) ? (h as number) * 60 + (m as number) : null;
}

export function assessSafety(
  products: ProductConcept[],
  entries: ExposureEntry[],
  rules: InteractionRule[],
  conditions: string[],
  pack: InteractionAssessment['pack'],
): InteractionAssessment {
  const byId = new Map(products.map((p) => [p.product_id, p]));
  const active = entries.filter((e) => byId.has(e.product_id));
  const findings: SafetyFinding[] = [];
  const basisOf = (es: ExposureEntry[]): SafetyFinding['exposure_basis'] => {
    const k = new Set(es.map((e) => e.kind));
    return k.size > 1 ? 'MIXED' : k.has('TAKEN') ? 'TAKEN' : 'PLANNED';
  };
  const mk = (f: Omit<SafetyFinding, 'guaranteed_safe'>): SafetyFinding => ({ ...f, guaranteed_safe: false });

  for (const e of active) {
    const p = byId.get(e.product_id) as ProductConcept;
    if (!p.composition_known)
      findings.push(mk({ type: 'INSUFFICIENT_CONTEXT', ingredient_id: null, products: [p.product_id], rule_id: null, rule_version: null, action: null, combined_amount: null, combined_reason: 'UNKNOWN_COMPOSITION', exposure_basis: basisOf([e]), note: 'Composition unknown; ingredient-level checks cannot run.' }));
    for (const ing of p.ingredients.filter((i) => i.mapping === 'AMBIGUOUS'))
      findings.push(mk({ type: 'UNKNOWN_INGREDIENT', ingredient_id: ing.ingredient_id, products: [p.product_id], rule_id: null, rule_version: null, action: null, combined_amount: null, combined_reason: null, exposure_basis: basisOf([e]), note: `"${ing.label}" mapping is ambiguous; it cannot trigger exact hard rules.` }));
  }

  // Duplicate ingredient detection over reviewed identities only.
  const reviewed = new Map<string, Array<{ entry: ExposureEntry; ing: IngredientAmount }>>();
  for (const e of active) {
    const p = byId.get(e.product_id) as ProductConcept;
    for (const ing of p.ingredients.filter((i) => i.mapping === 'REVIEWED')) {
      const list = reviewed.get(ing.ingredient_id) ?? [];
      list.push({ entry: e, ing });
      reviewed.set(ing.ingredient_id, list);
    }
  }
  for (const [ingId, list] of [...reviewed.entries()].sort(([a], [b]) => a.localeCompare(b))) {
    if (list.length < 2) continue;
    const prods = [...new Set(list.map((l) => l.entry.product_id))];
    const combined = combineAmounts(list.map((l) => ({ amount: l.ing.amount === null ? null : l.ing.amount * l.entry.servings_per_day, unit: l.ing.unit, basis: l.ing.basis })));
    findings.push(
      mk({
        type: prods.length > 1 ? 'SAME_ACTIVE_DIFFERENT_PRODUCT' : 'EXACT_DUPLICATE_ACTIVE_INGREDIENT',
        ingredient_id: ingId,
        products: prods,
        rule_id: 'RULE-DUPLICATE-INGREDIENT-1',
        rule_version: '1',
        action: 'INFORM',
        combined_amount: combined.value === null ? null : { value: combined.value, unit: combined.unit as string },
        combined_reason: combined.reason,
        exposure_basis: basisOf(list.map((l) => l.entry)),
        note: 'Same normalized ingredient in more than one entry. This is not a toxicity or overdose finding.',
      }),
    );
  }

  const ingredientEntries = (id: string) => [...(reviewed.get(id) ?? [])];
  for (const rule of rules) {
    if (rule.kind === 'PAIR') {
      const parts = rule.participants.map(ingredientEntries);
      if (parts.some((p) => !p.length)) continue;
      const routeOk = rule.route === null || parts.every((p) => p.some((x) => (byId.get(x.entry.product_id) as ProductConcept).route === rule.route));
      if (!routeOk) continue;
      findings.push(mk({ type: 'SYNTHETIC_PAIR_INTERACTION', ingredient_id: rule.participants.join('+'), products: [...new Set(parts.flat().map((x) => x.entry.product_id))], rule_id: rule.rule_id, rule_version: rule.version, action: rule.action, combined_amount: null, combined_reason: null, exposure_basis: basisOf(parts.flat().map((x) => x.entry)), note: `Synthetic pair rule from ${rule.source}. Evidence ≠ diagnosis.` }));
    } else if (rule.kind === 'TIMING_SEPARATION') {
      const a = ingredientEntries(rule.participants[0] ?? '');
      const b = ingredientEntries(rule.participants[1] ?? '');
      if (!a.length || !b.length) continue;
      for (const x of a)
        for (const y of b) {
          const tx = minutes(x.entry.time);
          const ty = minutes(y.entry.time);
          if (tx === null || ty === null) {
            findings.push(mk({ type: 'INSUFFICIENT_CONTEXT', ingredient_id: rule.participants.join('+'), products: [x.entry.product_id, y.entry.product_id], rule_id: rule.rule_id, rule_version: rule.version, action: null, combined_amount: null, combined_reason: 'MISSING_TIME', exposure_basis: basisOf([x.entry, y.entry]), note: 'Timing rule needs intake times.' }));
          } else if (Math.abs(tx - ty) < (rule.min_separation_minutes ?? 0)) {
            findings.push(mk({ type: 'TIMING_SEPARATION', ingredient_id: rule.participants.join('+'), products: [x.entry.product_id, y.entry.product_id], rule_id: rule.rule_id, rule_version: rule.version, action: rule.action, combined_amount: null, combined_reason: null, exposure_basis: basisOf([x.entry, y.entry]), note: `Synthetic rule asks for ≥${rule.min_separation_minutes} min separation; observed ${Math.abs(tx - ty)} min.` }));
          }
        }
    } else if (rule.kind === 'CONDITION') {
      const p = ingredientEntries(rule.participants[0] as string);
      if (p.length && rule.condition && conditions.includes(rule.condition))
        findings.push(mk({ type: 'CONDITION_CONTEXT', ingredient_id: rule.participants[0] as string, products: [...new Set(p.map((x) => x.entry.product_id))], rule_id: rule.rule_id, rule_version: rule.version, action: rule.action, combined_amount: null, combined_reason: null, exposure_basis: basisOf(p.map((x) => x.entry)), note: `Synthetic condition-context rule (${rule.condition}).` }));
    }
  }

  if (!findings.length)
    findings.push(mk({ type: 'CLEAR_NO_MATCH_FOUND', ingredient_id: null, products: active.map((e) => e.product_id), rule_id: null, rule_version: null, action: null, combined_amount: null, combined_reason: null, exposure_basis: basisOf(active), note: 'No applicable rule found in the installed pack. This is NOT a guarantee of safety.' }));

  return {
    engine: SAFETY_ENGINE,
    pack,
    findings,
    limitations: [
      'Synthetic knowledge pack: test-only IDs, not production clinical knowledge.',
      'No rule found ≠ guaranteed safe. This engine never prescribes, stops or changes a dose.',
    ],
  };
}
