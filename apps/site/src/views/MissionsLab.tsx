import { useMemo } from 'react';
import { applyMissionEvent, generateMissions, sessionVolume, xpEarned, type CompletedSession } from '@hhos/domain';
import { DEMO_PROGRAM } from '@hhos/packs';
import { Chip, MetricValue } from '@hhos/ui';
import type { ViewProps } from '../App.tsx';
import type { MissionLabState } from '../state.ts';

export function MissionsLab({ s, d }: ViewProps) {
  const L = s.lang;
  const c = s.missionLab;
  const set = (patch: Partial<MissionLabState>) => d({ type: 'missionLab', patch });
  const lastBench: CompletedSession = useMemo(() => ({
    session_id: 'WK-SYN-0930',
    date: '2026-09-30',
    exercise_id: 'EX-BENCH',
    prescribed_load_kg: 30,
    prescribed_reps: 10,
    pain_stop: c.benchPain,
    sets: [
      { load_kg: 30, reps: 10, state: 'COMPLETED' },
      { load_kg: 30, reps: 10, state: 'COMPLETED' },
      c.benchAllReps ? { load_kg: 30, reps: 10, state: 'COMPLETED' } : { load_kg: 30, reps: 7, state: 'COMPLETED' },
      { load_kg: 30, reps: 10, state: 'PLANNED' },
    ],
  }), [c.benchAllReps, c.benchPain]);
  const missions = useMemo(() => {
    const base = generateMissions({
      profile_id: s.activeId,
      date: c.date,
      program: DEMO_PROGRAM,
      sessions: [lastBench],
      safety_flags: c.safetyFlag ? ['ACUTE_INJURY'] : [],
      last_mood_checkin_date: c.moodToday ? c.date : null,
      next_lesson_id: 'EDU-010',
      preventive_review_needed: true,
    });
    return base.map((m) => (c.events[m.id] ?? []).reduce(applyMissionEvent, m));
  }, [s.activeId, c, lastBench]);
  const vol = useMemo(() => sessionVolume(lastBench), [lastBench]);

  return (
    <section aria-labelledby="ms-title" style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
      <h2 id="ms-title" className="section-title">{L === 'tr' ? 'Günlük görevler' : 'Daily missions'} <Chip tone="synthetic">RP-MISSIONS-DEMO-1 · v0.25.0</Chip></h2>
      <div className="hh-card controls">
        <label>{L === 'tr' ? 'Tarih' : 'Date'}<input className="hh-input" type="date" value={c.date} onChange={(e) => set({ date: e.target.value || '2026-10-06', events: {} })} /></label>
        <label className="check"><input type="checkbox" data-testid="ms-allreps" checked={c.benchAllReps} onChange={(e) => set({ benchAllReps: e.target.checked, events: {} })} />{L === 'tr' ? 'Son bench seansında tüm tekrarlar tamamlandı' : 'Last bench session: all prescribed reps completed'}</label>
        <label className="check"><input type="checkbox" checked={c.benchPain} onChange={(e) => set({ benchPain: e.target.checked, events: {} })} />{L === 'tr' ? 'Ağrı nedeniyle durdu' : 'Pain stop recorded'}</label>
        <label className="check"><input type="checkbox" data-testid="ms-safety" checked={c.safetyFlag} onChange={(e) => set({ safetyFlag: e.target.checked, events: {} })} />{L === 'tr' ? 'Güvenlik bayrağı: akut sakatlık' : 'Safety flag: acute injury'}</label>
        <label className="check"><input type="checkbox" checked={c.moodToday} onChange={(e) => set({ moodToday: e.target.checked, events: {} })} />{L === 'tr' ? 'Bugünkü ruh hâli kaydı var' : 'Mood check-in already recorded today'}</label>
      </div>
      <div className="hh-card">
        <div className="hh-label">{L === 'tr' ? 'Son bench seansı (gerçekleşen)' : 'Last bench session (actual)'}</div>
        <p className="hh-small" style={{ margin: '4px 0' }}>2026-09-30 · {lastBench.sets.map((x) => `${x.load_kg}×${x.reps} ${x.state === 'PLANNED' ? '(PLANNED)' : ''}`).join(' · ')}</p>
        <div className="hh-row"><span className="hh-small">{L === 'tr' ? 'Hacim yükü (yalnız tamamlanan setler)' : 'Volume load (completed sets only)'}:</span> <MetricValue result={vol} lang={L} digits={0} /></div>
      </div>
      <div className="state-grid" data-testid="ms-list" aria-live="polite">
        {missions.map((m) => (
          <div key={m.id} className="state-card" data-testid={`mission-${m.mission_type}`}>
            <div className="hh-row" style={{ justifyContent: 'space-between' }}>
              <span className="hh-label">{m.category}</span>
              <Chip tone={m.status === 'COMPLETED' ? 'ok' : m.status === 'BLOCKED' ? 'risk' : m.status === 'SKIPPED' ? 'muted' : 'info'}>{m.status}</Chip>
            </div>
            <strong style={{ display: 'block', margin: '4px 0' }}>{m.title}</strong>
            <p className="hh-small hh-muted" style={{ margin: 0 }}>{m.rationale}</p>
            <p className="hh-small hh-mono hh-muted" style={{ margin: '4px 0' }}>{m.source_rule_id}@{m.source_rule_version}{m.completion_record_ids.length ? ` · ✓ ${m.completion_record_ids.join(',')}` : ''}</p>
            {m.status !== 'BLOCKED' ? (
              <div className="hh-row">
                <button className="hh-btn" data-testid="ms-notify" onClick={() => d({ type: 'missionEvent', missionId: m.id, event: { kind: 'NOTIFICATION_OPENED' } })}>{L === 'tr' ? 'Bildirim açıldı' : 'Notification opened'}</button>
                <button className="hh-btn primary" data-testid="ms-complete" disabled={m.status === 'COMPLETED'} onClick={() => d({ type: 'missionEvent', missionId: m.id, event: { kind: 'COMPLETED', completion_record_id: `REC-${m.id.slice(-2)}` } })}>{L === 'tr' ? 'Tamamlandı kaydı' : 'Log completion'}</button>
                <button className="hh-btn" disabled={m.status === 'COMPLETED'} onClick={() => d({ type: 'missionEvent', missionId: m.id, event: { kind: 'SKIPPED' } })}>{L === 'tr' ? 'Atla' : 'Skip'}</button>
              </div>
            ) : null}
          </div>
        ))}
      </div>
      <div className="hh-row">
        <Chip tone="info">XP {xpEarned(missions)}</Chip>
        <span className="hh-small hh-muted">{L === 'tr' ? 'XP oyunlaştırmadır; sağlık skorunu değiştirmez. Bildirim açılması görevi tamamlamaz. Kaçırılan gün ertesi güne yığılmaz.' : 'XP is gamification and never changes health scores. Opening a notification never completes a mission. Missed days are not stacked.'}</span>
      </div>
    </section>
  );
}
