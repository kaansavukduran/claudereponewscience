// Daily Missions deterministic rule engine (doc 35, FR-47..49, AT-220..225, 281, 288, 289, 510).
// current state + goals + constraints + history + rule version → today's missions.
// A mission is a PLAN. Only a completion event makes it COMPLETED. Notifications never complete it.

import { trainingVolumeLoad, type TrainingSet } from './coreDerived.ts';

export const MISSION_RULE_PACK = { packId: 'RP-MISSIONS-DEMO-1', version: '0.25.0' } as const;

export type MissionStatus = 'PLANNED' | 'STARTED' | 'COMPLETED' | 'SKIPPED' | 'BLOCKED';
export type MissionCategory = 'Observe' | 'Train' | 'Recover' | 'Nutrition' | 'Sleep' | 'Prevention' | 'Medication/Adherence' | 'Learn' | 'Review';

export interface Mission {
  id: string;
  profile_id: string;
  category: MissionCategory;
  mission_type: string;
  title: string;
  rationale: string;
  target: string;
  generated_for_date: string;
  source_rule_id: string;
  source_rule_version: string;
  status: MissionStatus;
  completion_record_ids: string[];
  xp: number;
}

export interface ExerciseProgram {
  exercise_id: string;
  label: string;
  sets: number;
  reps: number;
  start_load_kg: number;
  increment_kg: number;
}

export interface CompletedSession {
  session_id: string;
  date: string;
  exercise_id: string;
  prescribed_load_kg: number;
  prescribed_reps: number;
  sets: TrainingSet[];
  pain_stop: boolean;
}

export interface MissionInput {
  profile_id: string;
  date: string;
  program: ExerciseProgram[];
  /** Real completion events only. */
  sessions: CompletedSession[];
  safety_flags: Array<'ACUTE_INJURY' | 'POST_OPERATIVE' | 'CLINICIAN_EXERCISE_RESTRICTION' | 'SYMPTOMATIC_CARDIO'>;
  last_mood_checkin_date: string | null;
  next_lesson_id: string | null;
  preventive_review_needed: boolean;
}

export interface Prescription {
  exercise_id: string;
  label: string;
  sets: number;
  reps: number;
  load_kg: number;
  decision: 'START' | 'PROGRESS' | 'REPEAT' | 'REPEAT_AFTER_PAIN';
  based_on_session: string | null;
}

/** Progression: all prescribed reps completed and no pain stop → +increment; otherwise repeat. */
export function prescribe(ex: ExerciseProgram, sessions: CompletedSession[]): Prescription {
  const last = sessions
    .filter((s) => s.exercise_id === ex.exercise_id)
    .sort((a, b) => (a.date === b.date ? a.session_id.localeCompare(b.session_id) : a.date.localeCompare(b.date)))
    .at(-1);
  if (!last) return { exercise_id: ex.exercise_id, label: ex.label, sets: ex.sets, reps: ex.reps, load_kg: ex.start_load_kg, decision: 'START', based_on_session: null };
  const done = last.sets.filter((s) => s.state === 'COMPLETED');
  const allReps = done.length >= ex.sets && done.every((s) => (s.reps ?? 0) >= last.prescribed_reps && (s.load_kg ?? 0) >= last.prescribed_load_kg);
  if (last.pain_stop)
    return { exercise_id: ex.exercise_id, label: ex.label, sets: ex.sets, reps: ex.reps, load_kg: last.prescribed_load_kg, decision: 'REPEAT_AFTER_PAIN', based_on_session: last.session_id };
  if (allReps)
    return { exercise_id: ex.exercise_id, label: ex.label, sets: ex.sets, reps: ex.reps, load_kg: last.prescribed_load_kg + ex.increment_kg, decision: 'PROGRESS', based_on_session: last.session_id };
  return { exercise_id: ex.exercise_id, label: ex.label, sets: ex.sets, reps: ex.reps, load_kg: last.prescribed_load_kg, decision: 'REPEAT', based_on_session: last.session_id };
}

function mission(input: MissionInput, n: number, m: Omit<Mission, 'id' | 'profile_id' | 'generated_for_date' | 'source_rule_version' | 'status' | 'completion_record_ids'> & { status?: MissionStatus }): Mission {
  return {
    id: `MIS-${input.profile_id}-${input.date}-${String(n).padStart(2, '0')}`,
    profile_id: input.profile_id,
    generated_for_date: input.date,
    source_rule_version: MISSION_RULE_PACK.version,
    completion_record_ids: [],
    ...m,
    status: m.status ?? 'PLANNED',
  };
}

export function generateMissions(input: MissionInput): Mission[] {
  const out: Mission[] = [];
  let n = 1;
  if (input.last_mood_checkin_date !== input.date)
    out.push(mission(input, n++, { category: 'Observe', mission_type: 'MIND_CHECKIN', title: 'Record today’s mind check-in (1–10)', rationale: 'No check-in recorded for today.', target: '1 check-in', source_rule_id: 'MR-OBSERVE-MOOD-1', xp: 5 }));
  const blocked = input.safety_flags.length > 0;
  for (const ex of input.program) {
    const p = prescribe(ex, input.sessions);
    out.push(
      mission(input, n++, {
        category: 'Train',
        mission_type: 'RESISTANCE_PRESCRIPTION',
        title: `${p.label} — ${p.sets} × ${p.reps} @ ${p.load_kg} kg`,
        rationale: blocked
          ? `Blocked by safety flag(s): ${input.safety_flags.join(', ')}. No medical clearance is invented.`
          : p.decision === 'START'
            ? 'No completed session yet: program start load.'
            : p.decision === 'PROGRESS'
              ? `All prescribed reps completed in ${p.based_on_session} without pain stop → +${ex.increment_kg} kg.`
              : p.decision === 'REPEAT_AFTER_PAIN'
                ? `Pain stop recorded in ${p.based_on_session} → repeat load, no progression.`
                : `Prescription not fully completed in ${p.based_on_session} → repeat load.`,
        target: `${p.sets}×${p.reps}@${p.load_kg}kg`,
        source_rule_id: 'MR-TRAIN-PROGRESSION-1',
        xp: 20,
        status: blocked ? 'BLOCKED' : 'PLANNED',
      }),
    );
  }
  out.push(mission(input, n++, { category: blocked ? 'Recover' : 'Recover', mission_type: 'WALK', title: blocked ? 'Gentle recovery: follow your clinician’s activity guidance' : 'Walk 20 minutes', rationale: blocked ? 'Physical targets downscaled while a safety flag is active.' : 'Daily movement baseline mission.', target: blocked ? 'as advised' : '20 min', source_rule_id: 'MR-RECOVER-WALK-1', xp: 10 }));
  if (input.preventive_review_needed)
    out.push(mission(input, n++, { category: 'Prevention', mission_type: 'PREVENTIVE_REVIEW', title: 'Review a preventive item with unknown history', rationale: 'A preventive assessment returned UNKNOWN_HISTORY. Mission completion ≠ service completed.', target: '1 review', source_rule_id: 'MR-PREVENT-REVIEW-1', xp: 5 }));
  if (input.next_lesson_id)
    out.push(mission(input, n++, { category: 'Learn', mission_type: 'LESSON', title: `Read lesson ${input.next_lesson_id}`, rationale: 'Next lesson in EDU-HEALTH-LITERACY-FOUNDATION-1.', target: '1 lesson', source_rule_id: 'MR-LEARN-NEXT-1', xp: 5 }));
  return out;
}

export type MissionEvent =
  | { kind: 'NOTIFICATION_DELIVERED' | 'NOTIFICATION_OPENED' | 'STARTED' }
  | { kind: 'COMPLETED'; completion_record_id: string }
  | { kind: 'SKIPPED' };

/** Notification delivery/open never completes a mission (AT-510, AT-783). */
export function applyMissionEvent(m: Mission, e: MissionEvent): Mission {
  if (m.status === 'BLOCKED') return m;
  switch (e.kind) {
    case 'NOTIFICATION_DELIVERED':
    case 'NOTIFICATION_OPENED':
      return m;
    case 'STARTED':
      return m.status === 'PLANNED' ? { ...m, status: 'STARTED' } : m;
    case 'COMPLETED':
      return { ...m, status: 'COMPLETED', completion_record_ids: [...m.completion_record_ids, e.completion_record_id] };
    case 'SKIPPED':
      return m.status === 'COMPLETED' ? m : { ...m, status: 'SKIPPED' };
  }
}

/** XP is gamification only and never feeds health scores (AT-225). */
export function xpEarned(ms: Mission[]): number {
  return ms.filter((m) => m.status === 'COMPLETED').reduce((a, m) => a + m.xp, 0);
}

export function sessionVolume(s: CompletedSession) {
  return trainingVolumeLoad({ sets: s.sets });
}
