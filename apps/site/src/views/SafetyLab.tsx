import { useMemo } from 'react';
import { assessSafety, type ExposureEntry } from '@hhos/domain';
import { SYNTHETIC_INTERACTION_RULES, SYNTHETIC_PRODUCTS, SYNTHETIC_SAFETY_PACK } from '@hhos/packs';
import { Chip, fmt } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';

export function SafetyLab({ s, d }: ViewProps) {
  const L = s.lang;
  const { entries, conditions } = s.safetyLab;
  const setEntries = (e: ExposureEntry[]) => d({ type: 'safetyLab', patch: { entries: e } });
  const a = useMemo(() => assessSafety(SYNTHETIC_PRODUCTS, entries, SYNTHETIC_INTERACTION_RULES, conditions, SYNTHETIC_SAFETY_PACK), [entries, conditions]);
  const has = (id: string) => entries.find((e) => e.product_id === id);

  return (
    <section aria-labelledby="sf-title" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <h2 id="sf-title" className="section-title">{L === 'tr' ? 'İlaç ve takviye güvenlik laboratuvarı' : 'Medication & supplement Safety Lab'} <Chip tone="synthetic">SYNTHETIC-SAFETY-PACK-1 · test-only</Chip></h2>
      <div className="hh-card hh-scroll-x">
        <table className="hh-table">
          <thead><tr><th>{L === 'tr' ? 'Ürün (sahte)' : 'Product (fake)'}</th><th>{L === 'tr' ? 'Bileşenler' : 'Ingredients'}</th><th>Route</th><th>{L === 'tr' ? 'Kullan' : 'Use'}</th><th>{L === 'tr' ? 'Plan / alındı' : 'Plan / taken'}</th><th>{L === 'tr' ? 'Porsiyon/gün' : 'Servings/day'}</th><th>{L === 'tr' ? 'Saat' : 'Time'}</th></tr></thead>
          <tbody>
            {SYNTHETIC_PRODUCTS.map((p) => {
              const e = has(p.product_id);
              const upd = (patch: Partial<ExposureEntry>) => setEntries(entries.map((x) => (x.product_id === p.product_id ? { ...x, ...patch } : x)));
              return (
                <tr key={p.product_id}>
                  <td>{p.name}<div className="hh-small hh-muted hh-mono">{p.product_id}</div></td>
                  <td className="hh-small">{p.composition_known ? p.ingredients.map((i) => `${i.label} ${i.amount === null ? '(amount undisclosed)' : `${fmt(i.amount)} ${i.unit}`} · ${i.basis}${i.mapping !== 'REVIEWED' ? ` · ${i.mapping}` : ''}`).join('; ') : (L === 'tr' ? 'bileşim bilinmiyor' : 'composition unknown')}</td>
                  <td>{p.route}</td>
                  <td><input type="checkbox" aria-label={`Use ${p.name}`} data-testid={`sf-use-${p.product_id}`} checked={!!e} onChange={(ev) => setEntries(ev.target.checked ? [...entries, { entry_id: `E-${p.product_id}`, product_id: p.product_id, kind: 'PLAN', servings_per_day: 1, time: '08:00' }] : entries.filter((x) => x.product_id !== p.product_id))} /></td>
                  <td>{e ? <select className="hh-input compact" aria-label={`${p.name} plan or taken`} value={e.kind} onChange={(ev) => upd({ kind: ev.target.value as 'PLAN' | 'TAKEN' })}><option value="PLAN">PLAN</option><option value="TAKEN">TAKEN</option></select> : '—'}</td>
                  <td>{e ? <input className="hh-input compact" style={{ width: 64 }} type="number" min={1} max={6} aria-label={`${p.name} servings`} value={e.servings_per_day} onChange={(ev) => upd({ servings_per_day: Math.max(1, Number(ev.target.value) || 1) })} /> : '—'}</td>
                  <td>{e ? <input className="hh-input compact" type="time" aria-label={`${p.name} time`} value={e.time ?? ''} onChange={(ev) => upd({ time: ev.target.value || null })} /> : '—'}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
        <label className="hh-row hh-small" style={{ marginTop: 8 }}>
          <input type="checkbox" checked={conditions.includes('COND-SYN-KIDNEY')} onChange={(e) => d({ type: 'safetyLab', patch: { conditions: e.target.checked ? ['COND-SYN-KIDNEY'] : [] } })} />
          {L === 'tr' ? 'Sentetik durum bağlamı: COND-SYN-KIDNEY' : 'Synthetic condition context: COND-SYN-KIDNEY'}
        </label>
      </div>

      <div className="state-grid" aria-live="polite" data-testid="sf-findings">
        {a.findings.map((f, i) => (
          <div key={i} className="state-card">
            <div className="hh-label">{f.rule_id ?? 'NO RULE'} {f.rule_version ? `v${f.rule_version}` : ''}</div>
            <div className="state" style={{ color: f.type === 'CLEAR_NO_MATCH_FOUND' ? 'var(--text-2)' : 'var(--warning)' }}>{f.type === 'CLEAR_NO_MATCH_FOUND' ? '○' : '⚠'} {f.type}</div>
            <p className="hh-small" style={{ margin: '4px 0' }}>{f.note}</p>
            <div className="hh-row">
              {f.ingredient_id ? <Chip tone="info">{f.ingredient_id}</Chip> : null}
              <Chip tone="muted">{f.exposure_basis}</Chip>
              {f.action ? <Chip tone="warn">{f.action}</Chip> : null}
              {f.combined_amount ? <Chip tone="info">Σ {fmt(f.combined_amount.value, 3)} {f.combined_amount.unit}/day</Chip> : f.combined_reason ? <Chip tone="muted">Σ n/a: {f.combined_reason}</Chip> : null}
              <Chip tone="muted">guaranteed_safe = false</Chip>
            </div>
          </div>
        ))}
      </div>
      <div className="callout">
        {L === 'tr'
          ? 'Marka ≠ etken bileşen. Plan ≠ alınan doz. Aynı bileşen ≠ zehirlilik. Etkileşim kanıtı ≠ tanı. "Uygulanabilir kural bulunamadı" ≠ "güvenli olduğu garanti". Bu motor doz yazmaz, kesmez ya da değiştirmez.'
          : 'Brand ≠ active ingredient. Plan ≠ actual intake. Duplicate ingredient ≠ toxicity. Interaction evidence ≠ diagnosis. "No applicable rule found" ≠ "guaranteed safe". This engine never prescribes, stops or changes a dose.'}
      </div>
    </section>
  );
}
