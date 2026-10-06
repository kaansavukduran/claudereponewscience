import { useMemo } from 'react';
import { computeProfileResults } from '@hhos/domain';
import { Chip, ResultCard, fmt, tr } from '@hhos/ui';
import type { AppCtx } from '../App.tsx';

/** Identical result semantics to Site Lab (shared @hhos/domain + @hhos/ui) — FR-200 parity. */
export function ResultsScreen({ ctx }: { ctx: AppCtx }) {
  const L = ctx.prefs.lang;
  const r = useMemo(() => (ctx.self ? computeProfileResults(ctx.self) : null), [ctx.self]);
  if (!r) return null;
  return (
    <section style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <h2 style={{ margin: 0 }}>Longevity ↔ Shortevity</h2>
      <p className="hh-small hh-muted" style={{ margin: 0 }}>{L === 'tr' ? 'Ayrı kanallar; hiçbiri ölüm olasılığı ya da yaşam süresi değildir.' : 'Separate channels; none is a mortality probability or lifespan.'}</p>
      <div className="cards">
        <ResultCard testId="c-protection" title={tr(L, 'protection')} result={r.protection} lang={L} channel="PROTECTION" bar digits={0} unit="/100" />
        <ResultCard testId="c-burden" title={tr(L, 'burden')} result={r.burden} lang={L} channel="BURDEN" bar digits={0} unit="/100" />
        <ResultCard testId="c-function" title={tr(L, 'function')} result={r.function} lang={L} channel="FUNCTION" bar digits={0} unit="/100" />
        <ResultCard testId="c-coverage" title={tr(L, 'coverageConfidence')} result={r.coverage} lang={L} channel="COVERAGE" scale={100} unit="%" digits={0} bar />
        <ResultCard title={tr(L, 'balance')} result={r.balance} lang={L} digits={0} unit="">
          <p className="hh-small hh-muted" style={{ margin: 0 }}>{tr(L, 'protection')} {fmt(r.balance.protection, 0)} · {tr(L, 'burden')} {fmt(r.balance.burden, 0)}</p>
        </ResultCard>
      </div>
      <h3 style={{ margin: 0 }}>{tr(L, 'derived')}</h3>
      <div className="cards">
        <ResultCard testId="c-bmi" title="BMI" result={r.derived.bmi} lang={L} />
        <ResultCard title={L === 'tr' ? 'Bel/boy' : 'Waist/height'} result={r.derived.whtr} lang={L} digits={3} unit="ratio" />
        <ResultCard title={L === 'tr' ? 'Paket-yıl' : 'Pack-years'} result={r.derived.packYears} lang={L} />
      </div>
      <h3 style={{ margin: 0 }}>{tr(L, 'validated')}</h3>
      <div className="cards">
        {r.external.map((e) => (
          <ResultCard key={e.modelId} title={e.title} result={e.result} lang={L}>
            <p className="hh-small hh-muted" style={{ margin: 0 }}>{e.explanation}</p>
          </ResultCard>
        ))}
      </div>
      <Chip tone="muted">{tr(L, 'lifespanState')}: {r.lifespanProjection}</Chip>
    </section>
  );
}
