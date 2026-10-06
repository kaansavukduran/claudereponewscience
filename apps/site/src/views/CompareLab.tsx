import { useMemo } from 'react';
import { COMPARE_METRICS, compareProfiles, type CompareCell } from '@hhos/domain';
import { Chip, RESULT_CLASS_LABEL, fmt, tr } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';
import { Help } from './controls.tsx';

function Cell({ c, unit, lang }: { c: CompareCell; unit: string; lang: 'en' | 'tr' }) {
  const scale = unit === '%' && c.value !== null && c.value <= 1 ? 100 : 1;
  if (c.state !== 'VALUE')
    return (
      <span className="hh-missing" data-testid="cell-state">
        {c.state === 'MISSING' ? tr(lang, 'missingValue') : c.state === 'NOT_ELIGIBLE' ? tr(lang, 'notEligible') : c.state === 'UNAVAILABLE' ? tr(lang, 'unavailable') : tr(lang, 'invalid')}
      </span>
    );
  return (
    <>
      <span className="hh-mono">{fmt((c.value as number) * scale, 2)}</span>
      {c.deltaState === 'OK' ? (
        <span className="delta">Δ {c.delta! >= 0 ? '+' : ''}{fmt(c.delta, 2)} · {c.percentDelta! >= 0 ? '+' : ''}{fmt(c.percentDelta, 1)}%</span>
      ) : c.deltaState === 'PERCENT_NOT_MEANINGFUL' ? (
        <span className="delta">Δ {c.delta! >= 0 ? '+' : ''}{fmt((c.delta as number) * scale, 2)} · %Δ n/a</span>
      ) : c.deltaState === 'NOT_COMPARABLE' ? (
        <span className="delta">{lang === 'tr' ? 'karşılaştırılamaz' : 'not comparable'}</span>
      ) : c.deltaState === 'ZERO_BASELINE' ? (
        <span className="delta">Δ {fmt(c.delta, 2)} · %Δ: ZERO_BASELINE</span>
      ) : (
        <span className="delta">{lang === 'tr' ? 'bazal' : 'baseline'}</span>
      )}
    </>
  );
}

export function CompareLab({ s, d }: ViewProps) {
  const L = s.lang;
  const rows = useMemo(() => compareProfiles(s.profiles, s.baselineId, s.compareMetrics), [s.profiles, s.baselineId, s.compareMetrics]);
  return (
    <section aria-labelledby="cmp-title" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <div className="hh-row" style={{ justifyContent: 'space-between' }}>
        <h2 id="cmp-title" className="section-title">{L === 'tr' ? 'Karşılaştırma laboratuvarı' : 'Compare Lab'} <span className="hh-small hh-muted">{s.profiles.length} {L === 'tr' ? 'profil' : 'profiles'}</span></h2>
        <div className="hh-row">
          <button className="hh-btn" data-testid="cmp-add" onClick={() => d({ type: 'addBlank' })}>＋ {L === 'tr' ? 'Profil ekle' : 'Add profile'}</button>
          <button className="hh-btn" data-testid="cmp-clone" onClick={() => d({ type: 'cloneScenario', id: s.activeId })}>⑂ {L === 'tr' ? 'Aktif profili klonla' : 'Clone active profile'}</button>
        </div>
      </div>
      <Help topic="scenario" lang={L}>{L === 'tr' ? 'Senaryo nedir?' : 'What is a scenario?'}</Help>

      <div className="hh-card hh-scroll-x">
        <table className="hh-table compare-table" data-testid="compare-table">
          <thead>
            <tr>
              <th scope="col">{L === 'tr' ? 'Metrik' : 'Metric'}</th>
              {s.profiles.map((p) => (
                <th key={p.id} scope="col">
                  <input className="hh-input" aria-label={`Rename ${p.name}`} value={p.name} onChange={(e) => d({ type: 'rename', id: p.id, name: e.target.value })} />
                  <div className="hh-row" style={{ marginTop: 6 }}>
                    {p.id === s.baselineId ? <Chip tone="info">{L === 'tr' ? 'bazal' : 'baseline'}</Chip> : <button className="hh-btn" onClick={() => d({ type: 'pinBaseline', id: p.id })}>📌 {L === 'tr' ? 'Bazal yap' : 'Pin baseline'}</button>}
                    {p.profile_type === 'SCENARIO' ? <Chip tone="warn">{L === 'tr' ? 'senaryo' : 'scenario'}</Chip> : <Chip tone="synthetic">{p.profile_type.toLowerCase()}</Chip>}
                  </div>
                  <div className="hh-row" style={{ marginTop: 6 }}>
                    <button className="hh-btn" onClick={() => d({ type: 'selectProfile', id: p.id })}>{L === 'tr' ? 'Düzenle' : 'Edit'}</button>
                    {p.profile_type === 'SCENARIO' ? <button className="hh-btn" disabled={!p.source_profile_id || !s.profiles.some((x) => x.id === p.source_profile_id)} title={L === 'tr' ? 'Kaynağa döndür' : 'Reset to source'} onClick={() => d({ type: 'resetScenario', id: p.id })}>↺</button> : null}
                    <button className="hh-btn danger" aria-label={`Remove ${p.name}`} disabled={s.profiles.length <= 1} onClick={() => d({ type: 'deleteProfile', id: p.id })}>✕</button>
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.metric.id}>
                <th scope="row">
                  {r.metric.label} <span className="hh-small hh-muted">{r.metric.unit}</span>
                  <div className="hh-small hh-muted">{RESULT_CLASS_LABEL[r.metric.resultClass]?.[L]}</div>
                </th>
                {r.cells.map((c) => (
                  <td key={c.profileId}>
                    <Cell c={c} unit={r.metric.unit} lang={L} />
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <fieldset className="group hh-card">
        <legend>{L === 'tr' ? 'Metrik filtresi' : 'Metric filter'}</legend>
        <div className="controls">
          {COMPARE_METRICS.map((m) => (
            <label key={m.id} className="check">
              <input
                type="checkbox"
                checked={s.compareMetrics.includes(m.id)}
                onChange={(e) => d({ type: 'set', patch: { compareMetrics: e.target.checked ? COMPARE_METRICS.map((x) => x.id).filter((id) => id === m.id || s.compareMetrics.includes(id)) : s.compareMetrics.filter((x) => x !== m.id) } })}
              />
              {m.label}
            </label>
          ))}
        </div>
        <p className="hh-small hh-muted">
          {L === 'tr'
            ? '%Δ yalnız oran ölçekli metriklerde ve bazal ≠ 0 iken hesaplanır. Uygulama skorlarında yalnız mutlak Δ gösterilir. Uygun olmayan/eksik hücreler sayı üretmez.'
            : '%Δ is computed only for ratio-scale metrics with a non-zero baseline. App scores show absolute Δ only. Ineligible/missing cells never produce numbers.'}
        </p>
      </fieldset>
    </section>
  );
}
