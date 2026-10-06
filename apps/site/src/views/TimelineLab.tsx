import { useMemo, useState } from 'react';
import { rollingMean } from '@hhos/domain';
import { syntheticTimeline, syntheticWearable } from '@hhos/packs';
import { Chip, MetricValue, fmt } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';
import { Help } from './controls.tsx';

export function TimelineLab({ s }: ViewProps) {
  const L = s.lang;
  const tl = useMemo(() => syntheticTimeline(), []);
  const wear = useMemo(() => syntheticWearable(), []);
  const [showTable, setShowTable] = useState(false);
  const mean7 = useMemo(() => rollingMean({ values: wear.map((w) => w.steps), window: 7, min_count: 4 }), [wear]);
  const max = Math.max(...wear.map((w) => w.steps ?? 0));

  return (
    <section aria-labelledby="tl-title" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <h2 id="tl-title" className="section-title">{L === 'tr' ? 'Zaman çizelgesi ve giyilebilir demo' : 'Timeline & wearable demo'}</h2>
      <div className="hh-card">
        <ol style={{ listStyle: 'none', margin: 0, padding: 0, display: 'grid', gap: 8 }}>
          {tl.map((e) => (
            <li key={e.id} className="hh-row" style={{ borderBottom: '1px solid var(--border)', paddingBottom: 8 }}>
              <span className="hh-mono hh-small" style={{ width: 92 }}>{e.date}</span>
              <Chip tone="muted">{e.kind}</Chip>
              <span style={{ flex: 1, minWidth: 180 }}>{e.title}</span>
              <Chip tone={e.plan_or_actual === 'PLAN' ? 'warn' : 'ok'}>{e.plan_or_actual}</Chip>
              <Chip tone="synthetic">{e.provenance}</Chip>
            </li>
          ))}
        </ol>
        <Help topic="provenance" lang={L}>{L === 'tr' ? 'Köken (provenance) nedir?' : 'What is provenance?'}</Help>
      </div>
      <div className="hh-card">
        <div className="hh-row" style={{ justifyContent: 'space-between' }}>
          <h3>{L === 'tr' ? 'Sentetik giyilebilir: günlük adım (28 gün)' : 'Synthetic wearable: daily steps (28 days)'}</h3>
          <button className="hh-btn" aria-pressed={showTable} onClick={() => setShowTable(!showTable)}>{L === 'tr' ? 'Veri tablosu' : 'Data table'}</button>
        </div>
        <div className="steps-chart" role="img" aria-label={`Daily synthetic steps; ${wear.filter((w) => w.steps === null).length} days without data shown as dashed gaps.`}>
          {wear.map((w) => (
            <div key={w.date} className={`b${w.steps === null ? ' gap' : ''}`} title={`${w.date}: ${w.steps === null ? 'no data' : w.steps}`} style={{ height: w.steps === null ? undefined : `${(w.steps / max) * 100}%` }} />
          ))}
        </div>
        <div className="hh-row hh-small" style={{ marginTop: 8 }}>
          <span>{L === 'tr' ? '7 günlük ortalama (eksik günler hariç)' : '7-day mean (missing days excluded)'}:</span>
          <MetricValue result={mean7} lang={L} digits={0} unit="steps" />
          <Chip tone="muted">{L === 'tr' ? 'kesik çizgi = veri yok (0 değil)' : 'dashed = no data (not 0)'}</Chip>
        </div>
        {showTable ? (
          <div className="hh-scroll-x">
            <table className="hh-table">
              <thead><tr><th>Date</th><th className="num">Steps</th><th className="num">Sleep h</th><th className="num">Resting HR</th><th className="num">Exercise min</th><th>Source</th></tr></thead>
              <tbody>{wear.map((w) => <tr key={w.date}><td>{w.date}</td><td className="num">{w.steps === null ? '—' : fmt(w.steps, 0)}</td><td className="num">{fmt(w.sleep_hours)}</td><td className="num">{fmt(w.resting_hr, 0)}</td><td className="num">{fmt(w.exercise_min, 0)}</td><td>{w.source}</td></tr>)}</tbody>
            </table>
          </div>
        ) : null}
        <p className="hh-small hh-muted">
          {L === 'tr'
            ? 'Bu demo gerçek HealthKit / Health Connect bağlantısı kullanmaz. Gerçek entegrasyon, üretim istemcisinde izinli ve kimlik doğrulamalı ayrı bir adaptördür.'
            : 'This demo uses no real HealthKit / Health Connect connection. Real integration is a separate permissioned, authenticated adapter in the production client.'}
        </p>
      </div>
    </section>
  );
}
