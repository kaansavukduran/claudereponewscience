import { useMemo, useState } from 'react';
import { compareProfiles } from '@hhos/domain';
import { Chip, fmt } from '@hhos/ui';
import type { AppCtx } from '../App.tsx';

const METRICS = ['weight_kg', 'resting_hr', 'systolic_bp', 'bmi', 'protection', 'burden', 'function', 'coverage', 'cvd_prevent'];

export function CompareScreen({ ctx }: { ctx: AppCtx }) {
  const L = ctx.prefs.lang;
  const [busy, setBusy] = useState(false);
  const baseline = ctx.self?.id ?? ctx.profiles[0]?.id ?? null;
  const rows = useMemo(() => compareProfiles(ctx.profiles, baseline, METRICS), [ctx.profiles, baseline]);

  const act = async (fn: () => Promise<unknown>) => {
    setBusy(true);
    try {
      await fn();
      await ctx.refresh();
    } catch (e) {
      ctx.setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  };

  return (
    <section style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <h2 style={{ margin: 0 }}>{L === 'tr' ? 'Karşılaştır' : 'Compare'}</h2>
      <div className="hh-row">
        <button className="hh-btn" data-testid="seed-synthetic" disabled={busy} onClick={() => act(() => ctx.repo.seedSyntheticDemo())}>◆ {L === 'tr' ? 'Sentetik karşılaştırma profilleri ekle' : 'Add synthetic comparison profiles'}</button>
        {ctx.self ? (
          <button className="hh-btn" data-testid="clone-self" disabled={busy} onClick={() => act(() => ctx.repo.cloneScenario(ctx.self!, `${ctx.self!.name} · −5 kg`, { weight_kg: ctx.self!.inputs.weight_kg === null ? null : ctx.self!.inputs.weight_kg - 5 }))}>
            ⑂ {L === 'tr' ? 'Senaryo: −5 kg' : 'Scenario: −5 kg'}
          </button>
        ) : null}
      </div>
      <p className="hh-small hh-muted" style={{ margin: 0 }}>{L === 'tr' ? 'Senaryolar varsayımsaldır; kaynak profilini ve geçmişini değiştirmez.' : 'Scenarios are hypothetical; they never change your source profile or history.'}</p>
      <div className="hh-card hh-scroll-x">
        <table className="hh-table" data-testid="client-compare">
          <thead>
            <tr>
              <th>{L === 'tr' ? 'Metrik' : 'Metric'}</th>
              {ctx.profiles.map((p) => (
                <th key={p.id}>
                  {p.name}
                  <div><Chip tone={p.profile_type === 'SCENARIO' ? 'warn' : p.synthetic ? 'synthetic' : 'info'}>{p.profile_type}</Chip></div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((r) => (
              <tr key={r.metric.id}>
                <th scope="row">{r.metric.label} <span className="hh-small hh-muted">{r.metric.unit}</span></th>
                {r.cells.map((c) => (
                  <td key={c.profileId}>
                    {c.state === 'VALUE' ? (
                      <>
                        <span className="hh-mono">{fmt(r.metric.id === 'coverage' ? (c.value as number) * 100 : c.value, 1)}</span>
                        {c.deltaState === 'OK' ? <span className="delta"> Δ {fmt(c.delta, 1)} ({fmt(c.percentDelta, 1)}%)</span> : c.deltaState === 'PERCENT_NOT_MEANINGFUL' ? <span className="delta"> Δ {fmt(r.metric.id === 'coverage' ? (c.delta as number) * 100 : c.delta, 1)}</span> : null}
                      </>
                    ) : (
                      <span className="hh-missing">{c.state}</span>
                    )}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </section>
  );
}
