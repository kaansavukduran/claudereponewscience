import { useEffect, useMemo, useState } from 'react';
import { applyMissionEvent, generateMissions, xpEarned, type MissionEvent } from '@hhos/domain';
import { LESSONS } from '@hhos/packs';
import { Chip } from '@hhos/ui';
import type { AppCtx } from '../App.tsx';

const today = () => new Date().toISOString().slice(0, 10);
const EVENTS_KEY = 'hhos-client-mission-events-v1';

/** Missions are plans generated offline from deterministic rules; only a logged completion completes one. */
export function TodayScreen({ ctx }: { ctx: AppCtx }) {
  const L = ctx.prefs.lang;
  const date = today();
  const [events, setEvents] = useState<Record<string, MissionEvent[]>>(() => {
    try {
      return JSON.parse(localStorage.getItem(EVENTS_KEY) ?? '{}');
    } catch {
      return {};
    }
  });
  useEffect(() => {
    try {
      localStorage.setItem(EVENTS_KEY, JSON.stringify(events));
    } catch {
      /* ignore */
    }
  }, [events]);

  const missions = useMemo(() => {
    if (!ctx.self) return [];
    // No training program is configured for a new user → no training prescription is invented.
    return generateMissions({ profile_id: ctx.self.id, date, program: [], sessions: [], safety_flags: [], last_mood_checkin_date: null, next_lesson_id: LESSONS[0]!.id, preventive_review_needed: false }).map((m) => (events[m.id] ?? []).reduce(applyMissionEvent, m));
  }, [ctx.self, date, events]);

  const push = (id: string, e: MissionEvent) => setEvents((cur) => ({ ...cur, [id]: [...(cur[id] ?? []), e] }));

  return (
    <section style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
      <h2 style={{ margin: 0 }}>{L === 'tr' ? 'Bugün' : 'Today'} <span className="hh-small hh-muted">{date}</span></h2>
      {missions.map((m) => (
        <article key={m.id} className="hh-card" data-testid={`today-${m.mission_type}`}>
          <div className="hh-row" style={{ justifyContent: 'space-between' }}>
            <span className="hh-label">{m.category}</span>
            <Chip tone={m.status === 'COMPLETED' ? 'ok' : m.status === 'SKIPPED' ? 'muted' : 'info'}>{m.status}</Chip>
          </div>
          <strong>{m.title}</strong>
          <p className="hh-small hh-muted" style={{ margin: '4px 0' }}>{m.rationale}</p>
          <div className="hh-row">
            <button className="hh-btn primary" disabled={m.status === 'COMPLETED'} data-testid="today-complete" onClick={() => push(m.id, { kind: 'COMPLETED', completion_record_id: `REC-${m.id}` })}>{L === 'tr' ? 'Yaptım (kaydet)' : 'Done (log it)'}</button>
            <button className="hh-btn" disabled={m.status === 'COMPLETED'} onClick={() => push(m.id, { kind: 'SKIPPED' })}>{L === 'tr' ? 'Atla' : 'Skip'}</button>
          </div>
        </article>
      ))}
      <p className="hh-small hh-muted">XP {xpEarned(missions)} · {L === 'tr' ? 'XP sağlık skoru değildir.' : 'XP is not a health score.'}</p>
    </section>
  );
}
