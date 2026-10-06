import { useMemo } from 'react';
import { assessService, type PreventiveRule } from '@hhos/domain';
import { SYNTHETIC_PREVENTIVE_RULES } from '@hhos/packs';
import { Chip } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';
import type { PreventLabState } from '../state.ts';

const tone = (s: string): 'ok' | 'warn' | 'info' | 'muted' =>
  /UP_TO_DATE|SERIES_COMPLETE/.test(s) ? 'ok' : /DUE_NOW|OVERDUE|DUE_SOON|TOO_EARLY/.test(s) ? 'info' : /UNKNOWN|REVIEW|CONFLICT|STALE|BLOCKED/.test(s) ? 'warn' : 'muted';

export function PreventiveLab({ s, d }: ViewProps) {
  const L = s.lang;
  const c = s.preventLab;
  const set = (patch: Partial<PreventLabState>) => d({ type: 'preventLab', patch });
  const rules: PreventiveRule[] = useMemo(() => {
    if (c.packVariant === 'STALE') return SYNTHETIC_PREVENTIVE_RULES.map((r) => ({ ...r, pack_status: 'STALE' as const }));
    if (c.packVariant === 'CONFLICT') return [...SYNTHETIC_PREVENTIVE_RULES, ...SYNTHETIC_PREVENTIVE_RULES.map((r) => ({ ...r, rule_id: `${r.rule_id}-ALT`, pack_id: 'RP-PREVENTIVE-SYNTHETIC-ALT', interval_days: r.interval_days === null ? null : Math.round(r.interval_days / 2), mode: r.mode }))];
    return SYNTHETIC_PREVENTIVE_RULES;
  }, [c.packVariant]);
  const rows = useMemo(() => {
    const services = [...new Set(SYNTHETIC_PREVENTIVE_RULES.map((r) => r.service_id))];
    return services.map((svc) =>
      assessService(svc, rules, {
        as_of: c.asOf,
        jurisdiction: c.jurisdiction || null,
        age_years: c.age,
        risks: c.risk ? ['RISK-SYN-1'] : [],
        anatomy: c.anatomy ? ['ANATOMY-SYN-1'] : [],
        history: c.history,
        completions: svc === 'SVC-SYN-VACCINE-ALPHA' ? c.doses.split(',').map((x) => x.trim()).filter(Boolean) : c.lastCompletion ? [c.lastCompletion] : [],
        contraindicated: c.contraindicated,
        due_soon_window_days: 30,
      }),
    );
  }, [rules, c]);

  return (
    <section aria-labelledby="pv-title" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <h2 id="pv-title" className="section-title">{L === 'tr' ? 'Koruyucu bakım laboratuvarı' : 'Preventive Care Lab'} <Chip tone="synthetic">RP-PREVENTIVE-SYNTHETIC-1 · SYNTHETIC_ONLY</Chip></h2>
      <div className="hh-card controls">
        <label>{L === 'tr' ? 'Kılavuz yetki alanı' : 'Guideline jurisdiction'}<select data-testid="pv-jur" className="hh-input" value={c.jurisdiction} onChange={(e) => set({ jurisdiction: e.target.value as PreventLabState['jurisdiction'] })}><option value="SYN-LAND">SYN-LAND</option><option value="OTHER-LAND">OTHER-LAND</option><option value="">{L === 'tr' ? '(seçilmedi)' : '(none selected)'}</option></select></label>
        <label>{L === 'tr' ? 'Değerlendirme tarihi' : 'As of'}<input className="hh-input" type="date" value={c.asOf} onChange={(e) => set({ asOf: e.target.value || '2026-10-06' })} /></label>
        <label>{L === 'tr' ? 'Yaş' : 'Age'}<input data-testid="pv-age" className="hh-input" type="number" value={c.age ?? ''} onChange={(e) => set({ age: e.target.value === '' ? null : Number(e.target.value) })} /></label>
        <label>{L === 'tr' ? 'Geçmiş' : 'History'}<select data-testid="pv-history" className="hh-input" value={c.history} onChange={(e) => set({ history: e.target.value as 'KNOWN' | 'UNKNOWN' })}><option value="KNOWN">KNOWN</option><option value="UNKNOWN">UNKNOWN</option></select></label>
        <label>{L === 'tr' ? 'Son tamamlanma (Beta/Zeta)' : 'Last completion (Beta/Zeta)'}<input className="hh-input" type="date" value={c.lastCompletion} onChange={(e) => set({ lastCompletion: e.target.value })} /></label>
        <label>{L === 'tr' ? 'Alpha doz tarihleri' : 'Alpha dose dates'}<input className="hh-input" value={c.doses} onChange={(e) => set({ doses: e.target.value })} placeholder="2026-01-01, 2026-02-01" /></label>
        <label>{L === 'tr' ? 'Paket' : 'Pack state'}<select className="hh-input" value={c.packVariant} onChange={(e) => set({ packVariant: e.target.value as PreventLabState['packVariant'] })}><option value="NORMAL">ACTIVE</option><option value="STALE">STALE</option><option value="CONFLICT">{L === 'tr' ? 'Eşit öncelikli çatışma' : 'Equal-precedence conflict'}</option></select></label>
        <label className="check"><input type="checkbox" checked={c.risk} onChange={(e) => set({ risk: e.target.checked })} />{L === 'tr' ? 'Sentetik risk faktörü' : 'Synthetic risk factor'}</label>
        <label className="check"><input type="checkbox" checked={c.anatomy} onChange={(e) => set({ anatomy: e.target.checked })} />{L === 'tr' ? 'İlgili anatomi mevcut' : 'Relevant anatomy present'}</label>
        <label className="check"><input type="checkbox" checked={c.contraindicated} onChange={(e) => set({ contraindicated: e.target.checked })} />{L === 'tr' ? 'Kontrendikasyon' : 'Contraindication'}</label>
      </div>
      <div className="hh-card hh-scroll-x">
        <table className="hh-table" data-testid="pv-table">
          <thead><tr><th>{L === 'tr' ? 'Hizmet' : 'Service'}</th><th>{L === 'tr' ? 'Uygunluk' : 'Eligibility'}</th><th>{L === 'tr' ? 'Öneri modu' : 'Recommendation mode'}</th><th>{L === 'tr' ? 'Zamanlama' : 'Due state'}</th><th>{L === 'tr' ? 'Değerlendirme' : 'Assessment'}</th><th>{L === 'tr' ? 'Sonraki tarih' : 'Next date'}</th><th>{L === 'tr' ? 'Açıklama' : 'Explanation'}</th></tr></thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.service_id} data-testid={`pv-${r.service_id}`}>
                <td>{r.service_label}</td>
                <td><Chip tone={r.eligibility_state === 'ELIGIBLE' ? 'ok' : 'muted'}>{r.eligibility_state}</Chip></td>
                <td>{r.recommendation_mode ?? '—'}</td>
                <td><Chip tone={tone(r.due_state)}>{r.due_state}</Chip></td>
                <td><Chip tone={tone(r.assessment_status)}>{r.assessment_status}</Chip></td>
                <td className="hh-mono">{r.next_due_date ?? '—'}</td>
                <td className="hh-small">{r.explanation.join(' ')}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="callout">
        {L === 'tr'
          ? 'Uygunluk ≠ öneri modu ≠ zamanlama durumu. Tarama ≠ tanı; "daha çok tarama" otomatik olarak daha iyi değildir. Ortak karar asla "gecikmiş" gösterilmez. Bilinmeyen geçmiş "hiç yapılmadı" sayılmaz. Gerçek bir ulusal paket (CDC/USPSTF/WHO/T.C. Sağlık Bakanlığı) burada AKTİF değildir.'
          : 'Eligibility ≠ recommendation mode ≠ due state. Screening ≠ diagnosis; "more screening" is not automatically better. Shared decisions are never shown as overdue. Unknown history is not "never done". No real national pack (CDC/USPSTF/WHO/Türkiye MoH) is ACTIVE here.'}
      </div>
    </section>
  );
}
