import { useMemo } from 'react';
import { interpretLabResult, type LabInterpretationInput } from '@hhos/domain';
import { syntheticLabSeries } from '@hhos/packs';
import { Chip, TrendChart, fmt } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';
import { DEFAULT_LAB_LAB, type LabLabState } from '../state.ts';
import { StateCard } from './controls.tsx';

const PRESETS: Array<{ id: string; en: string; tr: string; patch: Partial<LabLabState> }> = [
  { id: 'outside-not-critical', en: '1 · Outside range, not critical', tr: '1 · Aralık dışı, kritik değil', patch: { ...DEFAULT_LAB_LAB, value: 12, priorValue: 11.5, baseline: '11, 11.4, 11.8, 11.2, 11.6' } },
  { id: 'critical-independent', en: '2 · Critical independent of range', tr: '2 · Aralıktan bağımsız kritik', patch: { ...DEFAULT_LAB_LAB, value: 25, refHigh: 30, critHigh: 20, priorValue: 24 } },
  { id: 'method-change', en: '3 · Method change breaks trend', tr: '3 · Yöntem değişimi trendi böler', patch: { ...DEFAULT_LAB_LAB, method: 'M2', priorMethod: 'M1' } },
  { id: 'within-unusual', en: '4 · Within range, unusual for person', tr: '4 · Aralık içi, kişiye göre olağandışı', patch: { ...DEFAULT_LAB_LAB } },
  { id: 'unknown-context', en: '5 · Unknown context → no interpretation', tr: '5 · Bilinmeyen bağlam → yorum yok', patch: { ...DEFAULT_LAB_LAB, requireContext: true } },
];

function tone(state: string): 'ok' | 'warn' | 'risk' | 'info' | 'muted' {
  if (/CRITICAL.*MATCHED/.test(state)) return 'risk';
  if (/ABOVE|BELOW|EXCEEDS|UNUSUAL|UNKNOWN_COMPARABILITY|NOT_COMPARABLE|STALE|CONFLICT|INSUFFICIENT|INVALID|BLOCKED/.test(state)) return 'warn';
  if (/WITHIN|DIRECTLY|NO_MATCH/.test(state)) return 'ok';
  return 'muted';
}

export function LabInterpretationLab({ s, d }: ViewProps) {
  const L = s.lang;
  const c = s.labLab;
  const set = (patch: Partial<LabLabState>) => d({ type: 'labLab', patch });
  const num = (v: string) => (v === '' ? null : Number(v));
  const input: LabInterpretationInput = useMemo(() => ({
    result: { analyte_key: 'SYN-ANALYTE-X', value: c.value, unit: c.unitMismatch ? 'other-u' : 'syn-u', specimen: c.specimen, method_id: c.method, observed_at: '2026-10-01' },
    reference: c.refLow === null && c.refHigh === null ? [] : [{ interval_id: 'RI-SYN-LAB', low: c.refLow, high: c.refHigh, unit: 'syn-u', specimen: 'serum', method_id: null, source: 'SYNTHETIC-LAB-A', version: '1', required_context: c.requireContext ? ['age_years', 'source_sex_variable'] : [] }],
    context: { age_years: 40, profile_gender_label: 'synthetic' },
    decision_rules: [{ rule_id: 'DL-SYN-1', label: 'Synthetic decision limit ≥ 8', threshold: 8, direction: 'AT_OR_ABOVE', unit: 'syn-u', source: 'SYNTHETIC-DECISION-PACK', version: '1' }],
    critical_rules: c.critActive === 'NONE' ? [] : [{ rule_id: 'CR-SYN-1', low: c.critLow, high: c.critHigh, unit: 'syn-u', specimen: null, source: 'SYNTHETIC-CRITICAL-PACK', version: '1', status: c.critActive }],
    prior: c.priorValue === null ? null : { analyte_key: 'SYN-ANALYTE-X', value: c.priorValue, unit: 'syn-u', specimen: c.priorSpecimen, method_id: c.priorMethod, observed_at: '2026-06-01' },
    comparability_records: [],
    rcv: { cva: c.cva, cvi: c.cvi, z: c.z, source: 'SYNTHETIC-BIOLOGICAL-VARIATION' },
    baseline_points: c.baseline.split(',').map((x) => x.trim()).filter(Boolean).map(Number).filter(Number.isFinite),
  }), [c]);
  const a = useMemo(() => interpretLabResult(input), [input]);
  const series = useMemo(() => syntheticLabSeries(), []);

  return (
    <section aria-labelledby="li-title" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <h2 id="li-title" className="section-title">{L === 'tr' ? 'Lab yorumlama ve yöntem karşılaştırma' : 'Lab interpretation & method comparison'} <Chip tone="synthetic">LAB-INTERPRETATION-ENGINE-1 · v0.24</Chip></h2>
      <div className="hh-row" role="group" aria-label="Teaching presets">
        {PRESETS.map((p) => (
          <button key={p.id} className="hh-btn" data-testid={`preset-${p.id}`} onClick={() => set(p.patch)}>{p[L]}</button>
        ))}
      </div>
      <div className="hh-card">
        <div className="controls">
          <label>{L === 'tr' ? 'Sonuç değeri' : 'Result value'} (syn-u)<input data-testid="li-value" className="hh-input" type="number" step="0.1" value={c.value ?? ''} onChange={(e) => set({ value: num(e.target.value) })} /></label>
          <label>{L === 'tr' ? 'Referans alt' : 'Reference low'}<input className="hh-input" type="number" step="0.1" value={c.refLow ?? ''} onChange={(e) => set({ refLow: num(e.target.value) })} /></label>
          <label>{L === 'tr' ? 'Referans üst' : 'Reference high'}<input className="hh-input" type="number" step="0.1" value={c.refHigh ?? ''} onChange={(e) => set({ refHigh: num(e.target.value) })} /></label>
          <label>{L === 'tr' ? 'Kritik kural' : 'Critical rule'}<select className="hh-input" value={c.critActive} onChange={(e) => set({ critActive: e.target.value as LabLabState['critActive'] })}><option value="ACTIVE">ACTIVE</option><option value="STALE">STALE</option><option value="NONE">{L === 'tr' ? 'yok' : 'none'}</option></select></label>
          <label>{L === 'tr' ? 'Sentetik kritik alt' : 'Synthetic critical low'}<input className="hh-input" type="number" step="0.1" value={c.critLow ?? ''} onChange={(e) => set({ critLow: num(e.target.value) })} /></label>
          <label>{L === 'tr' ? 'Sentetik kritik üst' : 'Synthetic critical high'}<input className="hh-input" type="number" step="0.1" value={c.critHigh ?? ''} onChange={(e) => set({ critHigh: num(e.target.value) })} /></label>
          <label>{L === 'tr' ? 'Önceki sonuç' : 'Prior result'}<input className="hh-input" type="number" step="0.1" value={c.priorValue ?? ''} onChange={(e) => set({ priorValue: num(e.target.value) })} /></label>
          <label>{L === 'tr' ? 'Güncel yöntem' : 'Current method'}<select data-testid="li-method" className="hh-input" value={c.method} onChange={(e) => set({ method: e.target.value as 'M1' | 'M2' })}><option>M1</option><option>M2</option></select></label>
          <label>{L === 'tr' ? 'Önceki yöntem' : 'Prior method'}<select className="hh-input" value={c.priorMethod} onChange={(e) => set({ priorMethod: e.target.value as 'M1' | 'M2' })}><option>M1</option><option>M2</option></select></label>
          <label>{L === 'tr' ? 'Güncel numune' : 'Current specimen'}<select className="hh-input" value={c.specimen} onChange={(e) => set({ specimen: e.target.value as 'serum' | 'plasma' })}><option>serum</option><option>plasma</option></select></label>
          <label>{L === 'tr' ? 'Önceki numune' : 'Prior specimen'}<select className="hh-input" value={c.priorSpecimen} onChange={(e) => set({ priorSpecimen: e.target.value as 'serum' | 'plasma' })}><option>serum</option><option>plasma</option></select></label>
          <label>CVa % <input className="hh-input" type="number" step="0.1" value={c.cva ?? ''} onChange={(e) => set({ cva: num(e.target.value) })} /></label>
          <label>CVi % <input className="hh-input" type="number" step="0.1" value={c.cvi ?? ''} onChange={(e) => set({ cvi: num(e.target.value) })} /></label>
          <label>Z <input className="hh-input" type="number" step="0.01" value={c.z ?? ''} onChange={(e) => set({ z: num(e.target.value) })} /></label>
          <label style={{ gridColumn: '1 / -1' }}>{L === 'tr' ? 'Kişisel geçmiş (virgülle)' : 'Personal history points (comma-separated)'}<input className="hh-input" value={c.baseline} onChange={(e) => set({ baseline: e.target.value })} /></label>
          <label className="check"><input type="checkbox" checked={c.requireContext} onChange={(e) => set({ requireContext: e.target.checked })} />{L === 'tr' ? 'Kaynak yaş+cinsiyet değişkeni ister' : 'Source requires age + source sex variable'}</label>
          <label className="check"><input type="checkbox" checked={c.unitMismatch} onChange={(e) => set({ unitMismatch: e.target.checked })} />{L === 'tr' ? 'Sonuç farklı birimde' : 'Result reported in another unit'}</label>
        </div>
      </div>

      <div className="state-grid" aria-live="polite">
        <StateCard testId="li-reference" title={L === 'tr' ? 'Referans aralığı' : 'Reference interval'} state={a.reference.state} tone={tone(a.reference.state)}>{a.reference.interval ? `${fmt(a.reference.interval.low)}–${fmt(a.reference.interval.high)} ${a.reference.interval.unit} · ${a.reference.interval.source}` : '—'}</StateCard>
        <StateCard testId="li-critical" title={L === 'tr' ? 'Kritik kural' : 'Critical rule'} state={a.critical.state} tone={tone(a.critical.state)}>{L === 'tr' ? 'Klinisyen bildirimi: kanıt yok → iddia yok' : 'Clinician notification: no receipt → not claimed'}</StateCard>
        <StateCard title={L === 'tr' ? 'Karar sınırı' : 'Decision limit'} state={a.decision.length ? (a.decision[0]!.matched ? 'MATCHED' : 'NOT_MATCHED') : 'NO_ACTIVE_RULE'} tone="info">{a.decision[0]?.label}</StateCard>
        <StateCard testId="li-method-state" title={L === 'tr' ? 'Yöntem karşılaştırılabilirliği' : 'Method comparability'} state={a.comparability.state} tone={tone(a.comparability.state)}>{a.comparability.trend_discontinuity ? (L === 'tr' ? 'Trend kopukluğu işaretlendi' : 'Trend discontinuity marked') : ''}</StateCard>
        <StateCard testId="li-rcv" title="Delta / RCV" state={a.rcv.state} tone={tone(a.rcv.state)}>{a.rcv.rcv_percent !== null ? `RCV ${fmt(a.rcv.rcv_percent, 1)}% · Δ ${fmt(a.rcv.observed_percent_change, 1)}%` : ''}</StateCard>
        <StateCard testId="li-baseline" title={L === 'tr' ? 'Kişisel bazal' : 'Personal baseline'} state={a.baseline.state} tone={tone(a.baseline.state)}>{a.baseline.robust_z !== null ? `robust z ${fmt(a.baseline.robust_z, 2)} · n=${a.baseline.n}` : `n=${a.baseline.n}`}</StateCard>
      </div>
      <div className="hh-row">
        <Chip tone={a.status === 'SUCCESS' ? 'ok' : 'warn'}>assessment: {a.status}</Chip>
        {a.flags.map((f) => <Chip key={f.origin + f.label} tone="info">{f.origin}: {f.label}</Chip>)}
      </div>
      <div className="callout">
        {L === 'tr'
          ? 'Referans aralığı ≠ optimal hedef ≠ karar sınırı. Aralık dışı ≠ kritik. Aralık içi ≠ kişi için değişmemiş. RCV = Z × √2 × √(CVa² + CVi²); CV değerleri burada sentetiktir, gerçek biyolojik varyasyon değeri uydurulmaz.'
          : 'Reference interval ≠ optimal target ≠ decision limit. Outside range ≠ critical. Within range ≠ unchanged for this person. RCV = Z × √2 × √(CVa² + CVi²); CV values here are synthetic — real biological-variation values are never fabricated.'}
      </div>

      <div className="hh-card">
        <h3>{L === 'tr' ? 'Sentetik zaman serisi (yöntem kopukluğu ile)' : 'Synthetic series with method discontinuity'}</h3>
        <TrendChart title="SYN-ANALYTE-X" unit="syn-u" points={series.map((p, i) => ({ x: p.date, y: p.value, discontinuity: i > 0 && p.method_id !== series[i - 1]!.method_id }))} />
        <div className="hh-scroll-x">
          <table className="hh-table">
            <caption className="sr-only">Data table</caption>
            <thead><tr><th>Date</th><th>Value</th><th>State</th><th>Method</th><th>Reference (source snapshot)</th><th>Provenance</th></tr></thead>
            <tbody>
              {series.map((p) => (
                <tr key={p.date}><td>{p.date}</td><td className="num">{p.value === null ? '—' : fmt(p.value)}</td><td>{p.state}</td><td>{p.method_id}</td><td>{fmt(p.reference_low)}–{fmt(p.reference_high)}</td><td>{p.provenance}</td></tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}
