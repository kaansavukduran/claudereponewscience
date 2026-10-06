import { useMemo, useState } from 'react';
import { interpretLabResult } from '@hhos/domain';
import { Chip, TrendChart, fmt } from '@hhos/ui';
import type { AppCtx } from '../App.tsx';
import type { LabRecord } from '../data/repository.ts';

/** Same v0.24 engine as Site Lab and API; runs offline on-device. */
export function assessLab(lab: LabRecord, history: LabRecord[]) {
  const prior = history.filter((h) => h.analyte_key === lab.analyte_key && h.observed_at < lab.observed_at && h.result_state === 'PRESENT').at(-1) ?? null;
  const toIn = (r: LabRecord) => ({ analyte_key: r.analyte_key, value: r.numeric_value, unit: r.unit, specimen: r.specimen, method_id: r.method_id, observed_at: r.observed_at, source_flag: r.source_flag });
  return interpretLabResult({
    result: toIn(lab),
    reference: lab.reference_interval ? [lab.reference_interval] : [],
    context: {},
    decision_rules: [],
    critical_rules: [], // no real critical-rule pack installed → never invented
    prior: prior ? toIn(prior) : null,
    comparability_records: [],
    rcv: null, // no source-approved biological-variation pack
    baseline_points: history.filter((h) => h.analyte_key === lab.analyte_key && h.observed_at < lab.observed_at && h.method_id === lab.method_id && h.specimen === lab.specimen).map((h) => h.numeric_value),
  });
}

export function LabsScreen({ ctx }: { ctx: AppCtx }) {
  const L = ctx.prefs.lang;
  const [f, setF] = useState({ analyte: '', value: '', notReported: false, unit: '', date: new Date().toISOString().slice(0, 10), specimen: 'serum', method: '', refLow: '', refHigh: '', refSource: '', flag: '' });
  const [err, setErr] = useState<string | null>(null);
  const analytes = useMemo(() => [...new Set(ctx.labs.map((l) => l.analyte_key))], [ctx.labs]);

  const save = async () => {
    if (!ctx.self) return;
    setErr(null);
    try {
      const num = (s: string) => (s.trim() === '' ? null : Number(s));
      await ctx.repo.addLab(ctx.self.id, {
        analyte_key: f.analyte.trim(),
        numeric_value: f.notReported ? null : num(f.value),
        result_state: f.notReported ? 'NOT_REPORTED' : 'PRESENT',
        unit: f.unit.trim(),
        specimen: f.specimen || null,
        method_id: f.method.trim() || null,
        observed_at: f.date,
        source_flag: f.flag.trim() || null,
        reference_interval:
          f.refLow.trim() || f.refHigh.trim()
            ? { interval_id: `RI-${f.date}-${f.analyte}`, low: num(f.refLow), high: num(f.refHigh), unit: f.unit.trim(), specimen: f.specimen || null, method_id: f.method.trim() || null, source: f.refSource.trim() || 'REPORT', version: f.date, required_context: [] }
            : null,
        provenance: 'MANUAL',
      });
      setF({ ...f, value: '', flag: '', notReported: false });
      await ctx.refresh();
    } catch (e) {
      setErr(`${(e as Error).message} — ${L === 'tr' ? 'kaydedilmedi' : 'not saved'}`);
    }
  };

  return (
    <section style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <form className="hh-card" onSubmit={(e) => { e.preventDefault(); void save(); }} aria-labelledby="lab-add">
        <h2 id="lab-add" style={{ marginTop: 0 }}>{L === 'tr' ? 'Lab sonucu ekle' : 'Add a lab result'}</h2>
        <div className="form-grid">
          <label>{L === 'tr' ? 'Analit' : 'Analyte'}<input required className="hh-input" data-testid="lab-analyte" list="analytes" value={f.analyte} onChange={(e) => setF({ ...f, analyte: e.target.value })} /></label>
          <datalist id="analytes">{analytes.map((a) => <option key={a} value={a} />)}</datalist>
          <label>{L === 'tr' ? 'Değer' : 'Value'}<input className="hh-input" data-testid="lab-value" type="number" step="any" disabled={f.notReported} value={f.value} onChange={(e) => setF({ ...f, value: e.target.value })} /></label>
          <label>{L === 'tr' ? 'Birim (rapordaki gibi)' : 'Unit (as reported)'}<input required className="hh-input" data-testid="lab-unit" value={f.unit} onChange={(e) => setF({ ...f, unit: e.target.value })} /></label>
          <label>{L === 'tr' ? 'Tarih' : 'Date'}<input required className="hh-input" type="date" data-testid="lab-date" value={f.date} onChange={(e) => setF({ ...f, date: e.target.value })} /></label>
          <label>{L === 'tr' ? 'Numune' : 'Specimen'}<select className="hh-input" value={f.specimen} onChange={(e) => setF({ ...f, specimen: e.target.value })}><option>serum</option><option>plasma</option><option>whole blood</option><option>urine</option></select></label>
          <label>{L === 'tr' ? 'Yöntem/cihaz (biliniyorsa)' : 'Method (if known)'}<input className="hh-input" data-testid="lab-method" value={f.method} onChange={(e) => setF({ ...f, method: e.target.value })} /></label>
          <label>{L === 'tr' ? 'Rapor referans alt' : 'Report reference low'}<input className="hh-input" data-testid="lab-reflow" type="number" step="any" value={f.refLow} onChange={(e) => setF({ ...f, refLow: e.target.value })} /></label>
          <label>{L === 'tr' ? 'Rapor referans üst' : 'Report reference high'}<input className="hh-input" data-testid="lab-refhigh" type="number" step="any" value={f.refHigh} onChange={(e) => setF({ ...f, refHigh: e.target.value })} /></label>
          <label>{L === 'tr' ? 'Rapordaki işaret (H/L…)' : 'Report flag (H/L…)'}<input className="hh-input" value={f.flag} onChange={(e) => setF({ ...f, flag: e.target.value })} /></label>
          <label className="check"><input type="checkbox" data-testid="lab-nr" checked={f.notReported} onChange={(e) => setF({ ...f, notReported: e.target.checked, value: '' })} />{L === 'tr' ? 'Raporda yok (NOT_REPORTED, 0 değil)' : 'Not reported (NOT_REPORTED, not 0)'}</label>
        </div>
        {err ? <p className="hh-banner" role="alert">⚠ {err}</p> : null}
        <button className="hh-btn primary" data-testid="lab-save" type="submit">{L === 'tr' ? 'Kaydet' : 'Save'}</button>
        <p className="hh-small hh-muted">{L === 'tr' ? 'Birimler dönüştürülmez; referans aralığı rapordaki haliyle saklanır ve optimal hedef değildir.' : 'Units are never silently converted; the reference interval is stored exactly as reported and is not an optimal target.'}</p>
      </form>

      {analytes.map((a) => {
        const rows = ctx.labs.filter((l) => l.analyte_key === a);
        return (
          <article key={a} className="hh-card" data-testid={`lab-group-${a}`}>
            <h3>{a}</h3>
            <TrendChart title={a} unit={rows[0]?.unit ?? ''} points={rows.map((r, i) => ({ x: r.observed_at, y: r.numeric_value, discontinuity: i > 0 && (r.method_id !== rows[i - 1]!.method_id || r.specimen !== rows[i - 1]!.specimen) }))} />
            <div className="hh-scroll-x">
              <table className="hh-table">
                <thead><tr><th>{L === 'tr' ? 'Tarih' : 'Date'}</th><th className="num">{L === 'tr' ? 'Değer' : 'Value'}</th><th>{L === 'tr' ? 'Referans' : 'Reference'}</th><th>{L === 'tr' ? 'Kritik' : 'Critical'}</th><th>{L === 'tr' ? 'Önceki ile' : 'vs prior'}</th><th>{L === 'tr' ? 'Kişisel bazal' : 'Personal baseline'}</th><th>{L === 'tr' ? 'Rapor işareti' : 'Source flag'}</th></tr></thead>
                <tbody>
                  {rows.map((r) => {
                    const x = assessLab(r, rows);
                    return (
                      <tr key={r.id}>
                        <td className="hh-mono">{r.observed_at}</td>
                        <td className="num">{r.result_state === 'PRESENT' ? `${fmt(r.numeric_value, 3)} ${r.unit}` : <span className="hh-missing">{r.result_state}</span>}</td>
                        <td data-testid="lab-ref-state"><Chip tone={x.reference.state === 'WITHIN_REFERENCE' ? 'ok' : /ABOVE|BELOW/.test(x.reference.state) ? 'warn' : 'muted'}>{x.reference.state}</Chip></td>
                        <td><Chip tone="muted">{x.critical.state}</Chip></td>
                        <td><Chip tone={x.comparability.trend_discontinuity ? 'warn' : 'muted'}>{x.comparability.state}</Chip></td>
                        <td>{x.baseline.state}</td>
                        <td>{r.source_flag ?? '—'}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </article>
        );
      })}
    </section>
  );
}
