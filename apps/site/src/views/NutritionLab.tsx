import { useMemo } from 'react';
import { computeRecipe, type FoodSnapshot, type RecipeVersion } from '@hhos/domain';
import { Chip, fmt } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';
import type { NutritionLabState } from '../state.ts';
import { NumField } from './controls.tsx';

const OATS: FoodSnapshot = { snapshot_id: 'FS-SYN-OATS-v1', name: 'Synthetic oats', basis: { amount: 100, unit: 'g' }, nutrients: { energy_kcal: 380, protein_g: 12, fiber_g: 10, vitamin_b12_ug: null, iron_mg: 4.2 }, source: 'SYNTHETIC' };
const DRINK: FoodSnapshot = { snapshot_id: 'FS-SYN-SOYDRINK-v1', name: 'Synthetic fortified soy drink', basis: { amount: 100, unit: 'g' }, nutrients: { energy_kcal: 39, protein_g: 3.3, fiber_g: 0.5, vitamin_b12_ug: 0.38, iron_mg: null }, source: 'SYNTHETIC' };

export function NutritionLab({ s, d }: ViewProps) {
  const L = s.lang;
  const c = s.nutritionLab;
  const set = (patch: Partial<NutritionLabState>) => d({ type: 'nutritionLab', patch });
  const recipe: RecipeVersion = useMemo(() => ({
    recipe_id: 'RC-SYN-PORRIDGE',
    version: 1,
    name: 'Synthetic porridge',
    ingredients: [
      ...(c.oats_g === null ? [] : [{ food: OATS, quantity: { amount: c.oats_g, unit: 'g' } }]),
      ...(c.drink_amount === null ? [] : [{ food: { ...DRINK, density_g_per_ml: c.density ? 1.03 : null }, quantity: { amount: c.drink_amount, unit: c.drink_unit } }]),
    ],
    serving_count: c.servings,
    final_cooked_mass_g: c.cookedMass,
  }), [c]);
  const r = useMemo(() => computeRecipe(recipe), [recipe]);

  return (
    <section aria-labelledby="nu-title" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <h2 id="nu-title" className="section-title">{L === 'tr' ? 'Tarif ve porsiyon hesabı' : 'Recipe & portion math'} <Chip tone="synthetic">NUTRITION-MATH-1 · synthetic foods</Chip></h2>
      <div className="split">
        <div className="hh-card">
          <NumField label={L === 'tr' ? 'Sentetik yulaf' : 'Synthetic oats'} unit="g" min={0} max={200} value={c.oats_g} lang={L} onChange={(v) => set({ oats_g: v })} />
          <NumField label={L === 'tr' ? 'Sentetik soya içeceği' : 'Synthetic soy drink'} unit={c.drink_unit} min={0} max={600} step={10} value={c.drink_amount} lang={L} onChange={(v) => set({ drink_amount: v })} />
          <div className="controls" style={{ marginTop: 8 }}>
            <label>{L === 'tr' ? 'İçecek birimi' : 'Drink unit'}<select data-testid="nu-unit" className="hh-input" value={c.drink_unit} onChange={(e) => set({ drink_unit: e.target.value as 'g' | 'mL' })}><option value="g">g</option><option value="mL">mL</option></select></label>
            <label className="check"><input type="checkbox" checked={c.density} onChange={(e) => set({ density: e.target.checked })} />{L === 'tr' ? 'Yoğunluk biliniyor (1,03 g/mL)' : 'Density known (1.03 g/mL)'}</label>
          </div>
          <NumField label={L === 'tr' ? 'Porsiyon sayısı' : 'Servings'} unit="n" min={1} max={8} value={c.servings} lang={L} onChange={(v) => set({ servings: v })} />
          <NumField label={L === 'tr' ? 'Pişmiş son kütle' : 'Final cooked mass'} unit="g" min={50} max={1200} step={10} value={c.cookedMass} lang={L} onChange={(v) => set({ cookedMass: v })} />
        </div>
        <div className="hh-card" aria-live="polite">
          {r.errors.length ? (
            <p className="hh-missing" data-testid="nu-error">{r.errors.map((e) => `${e.ingredient}: ${e.error}`).join(' · ')}</p>
          ) : null}
          <div className="hh-scroll-x">
          <table className="hh-table" data-testid="nu-table">
            <thead><tr><th>{L === 'tr' ? 'Besin öğesi' : 'Nutrient'}</th><th className="num">{L === 'tr' ? 'Bilinen toplam' : 'Known total'}</th><th>{L === 'tr' ? 'Kapsam' : 'Coverage'}</th><th className="num">/ {L === 'tr' ? 'porsiyon' : 'serving'}</th><th className="num">/ 100 g {L === 'tr' ? 'pişmiş' : 'cooked'}</th></tr></thead>
            <tbody>
              {Object.entries(r.totals).map(([k, t]) => (
                <tr key={k}>
                  <td className="hh-mono">{k}</td>
                  <td className="num">{t.known === null ? <span className="hh-missing">MISSING</span> : fmt(t.known, 2)}</td>
                  <td>{t.complete ? <Chip tone="ok">{t.known_sources}/{t.known_sources + t.missing_sources}</Chip> : <Chip tone="warn">{t.known_sources}/{t.known_sources + t.missing_sources} · {L === 'tr' ? 'eksik kaynak' : 'incomplete'}</Chip>}</td>
                  <td className="num">{r.per_serving ? fmt(r.per_serving[k], 2) : '—'}</td>
                  <td className="num">{r.per_100g_cooked ? fmt(r.per_100g_cooked[k], 2) : '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
          </div>
          <p className="hh-small hh-muted">
            {L === 'tr'
              ? 'Eksik besin öğesi 0 sayılmaz; bilinen toplam + eksik kaynak sayısı ayrı gösterilir. mL → g yalnız açık yoğunlukla. Pişme verimi varsayılmaz: son kütle bilinmiyorsa 100 g başına değer hesaplanmaz. Kaydedilen öğün geçmişi değişmez anlık görüntü (snapshot) tutar.'
              : 'Missing nutrients never count as 0; known total + missing-source count are shown separately. mL → g only with explicit density. Cooking yield is never assumed: no per-100 g value without a measured final mass. Logged meals keep immutable snapshots.'}
          </p>
        </div>
      </div>
    </section>
  );
}
