// v0.23 Preventive eligibility / due engine (doc 168). Evaluation order:
// jurisdiction → pack status → applicability → eligibility → contraindication → recommendation mode
// → history quality → series/interval timing → due state → explanation.
// Ships with RP-PREVENTIVE-SYNTHETIC-1 only; no real national pack is ACTIVE.

import { addDays, daysBetween } from './dates.ts';

export const PREVENTIVE_ENGINE = { engineId: 'PREVENTIVE-ENGINE-1', version: '0.23.0' } as const;

export type RecommendationMode = 'ROUTINE' | 'SHARED_DECISION' | 'EVIDENCE_INSUFFICIENT' | 'AGAINST_ROUTINE';

export type DueState =
  | 'DUE_NOW'
  | 'DUE_SOON'
  | 'UP_TO_DATE'
  | 'OVERDUE'
  | 'UNKNOWN_HISTORY'
  | 'TOO_EARLY'
  | 'SERIES_COMPLETE'
  | 'NOT_APPLICABLE'
  | 'REVIEW_REQUIRED';

export type EligibilityState = 'ELIGIBLE' | 'NOT_ELIGIBLE' | 'NOT_APPLICABLE_JURISDICTION' | 'UNKNOWN';

export type PreventiveAssessmentStatus =
  | 'ASSESSED'
  | 'NOT_APPLICABLE_JURISDICTION'
  | 'NO_ACTIVE_PACK'
  | 'PACK_STALE'
  | 'PACK_CONFLICT'
  | 'BLOCKED_CONTRAINDICATION';

export interface PreventiveRule {
  rule_id: string;
  service_id: string;
  service_label: string;
  pack_id: string;
  pack_version: string;
  pack_status: 'ACTIVE' | 'STALE' | 'RETIRED';
  precedence: number;
  jurisdiction: string;
  source_snapshot_id: string;
  source_grade: string | null;
  mode: RecommendationMode;
  min_age: number | null;
  max_age: number | null;
  requires_risk: string | null;
  requires_anatomy: string | null;
  interval_days: number | null;
  series: { doses: number; min_interval_days: number } | null;
}

export interface PreventiveInput {
  as_of: string;
  jurisdiction: string | null;
  age_years: number | null;
  risks: string[];
  anatomy: string[];
  /** KNOWN = completions list is complete; UNKNOWN = we do not know (≠ never done). */
  history: 'KNOWN' | 'UNKNOWN';
  completions: string[];
  contraindicated: boolean;
  due_soon_window_days: number;
}

export interface PreventiveAssessment {
  rule_id: string | null;
  service_id: string;
  service_label: string;
  pack: { pack_id: string; version: string } | null;
  jurisdiction: string | null;
  eligibility_state: EligibilityState;
  recommendation_mode: RecommendationMode | null;
  due_state: DueState;
  assessment_status: PreventiveAssessmentStatus;
  next_due_date: string | null;
  explanation: string[];
}

function base(serviceId: string, label: string, input: PreventiveInput): PreventiveAssessment {
  return {
    rule_id: null,
    service_id: serviceId,
    service_label: label,
    pack: null,
    jurisdiction: input.jurisdiction,
    eligibility_state: 'UNKNOWN',
    recommendation_mode: null,
    due_state: 'NOT_APPLICABLE',
    assessment_status: 'ASSESSED',
    next_due_date: null,
    explanation: [],
  };
}

export function assessService(serviceId: string, rules: PreventiveRule[], input: PreventiveInput): PreventiveAssessment {
  const forService = rules.filter((r) => r.service_id === serviceId && r.pack_status !== 'RETIRED');
  const label = forService[0]?.service_label ?? serviceId;
  const out = base(serviceId, label, input);

  // 1. Jurisdiction — explicit only; never inferred and never silently falls back to another country.
  if (!input.jurisdiction) {
    out.assessment_status = 'NO_ACTIVE_PACK';
    out.explanation.push('No guideline jurisdiction selected; nothing is assumed.');
    return out;
  }
  const inJur = forService.filter((r) => r.jurisdiction === input.jurisdiction);
  if (!inJur.length) {
    out.eligibility_state = 'NOT_APPLICABLE_JURISDICTION';
    out.assessment_status = 'NOT_APPLICABLE_JURISDICTION';
    out.explanation.push(`No rule for ${serviceId} in jurisdiction ${input.jurisdiction}; not "overdue".`);
    return out;
  }
  // 2. Pack status / conflict.
  const active = inJur.filter((r) => r.pack_status === 'ACTIVE');
  if (!active.length) {
    const s = inJur[0] as PreventiveRule;
    out.rule_id = s.rule_id;
    out.pack = { pack_id: s.pack_id, version: s.pack_version };
    out.assessment_status = 'PACK_STALE';
    out.explanation.push('Only a stale pack covers this service; no fresh conclusion is presented.');
    return out;
  }
  const top = Math.max(...active.map((r) => r.precedence));
  const winners = active.filter((r) => r.precedence === top);
  if (winners.length > 1) {
    const signatures = new Set(winners.map((r) => `${r.mode}|${r.interval_days}|${r.min_age}|${r.max_age}`));
    if (signatures.size > 1) {
      out.assessment_status = 'PACK_CONFLICT';
      out.explanation.push(`Equal-precedence packs disagree: ${winners.map((w) => w.pack_id).join(', ')}.`);
      return out;
    }
  }
  const rule = winners[0] as PreventiveRule;
  out.rule_id = rule.rule_id;
  out.pack = { pack_id: rule.pack_id, version: rule.pack_version };
  out.recommendation_mode = rule.mode;
  out.explanation.push(`Rule ${rule.rule_id} (${rule.pack_id}@${rule.pack_version}, source ${rule.source_snapshot_id}${rule.source_grade ? `, grade ${rule.source_grade}` : ''}).`);

  // 3–4. Applicability / eligibility (anatomy, never gender identity as proxy).
  if (input.age_years === null) {
    out.eligibility_state = 'UNKNOWN';
    out.due_state = 'REVIEW_REQUIRED';
    out.explanation.push('Age unknown; eligibility cannot be determined.');
    return out;
  }
  const ageOk = (rule.min_age === null || input.age_years >= rule.min_age) && (rule.max_age === null || input.age_years <= rule.max_age);
  const riskOk = rule.requires_risk === null || input.risks.includes(rule.requires_risk);
  const anatomyOk = rule.requires_anatomy === null || input.anatomy.includes(rule.requires_anatomy);
  if (!ageOk || !riskOk || !anatomyOk) {
    out.eligibility_state = 'NOT_ELIGIBLE';
    out.explanation.push(!ageOk ? 'Age outside rule range.' : !riskOk ? 'Required risk factor absent.' : 'Required anatomy absent.');
    return out;
  }
  out.eligibility_state = 'ELIGIBLE';

  // 5. Contraindication blocks routine scheduling (distinct from AGAINST_ROUTINE).
  if (input.contraindicated) {
    out.assessment_status = 'BLOCKED_CONTRAINDICATION';
    out.due_state = 'REVIEW_REQUIRED';
    out.explanation.push('Contraindication/precaution recorded; clinician review required.');
    return out;
  }
  // 6. Recommendation mode — non-routine modes never manufacture a schedule.
  if (rule.mode === 'SHARED_DECISION') {
    out.due_state = 'REVIEW_REQUIRED';
    out.explanation.push('Shared decision: discuss benefits/harms; never shown as overdue.');
    return out;
  }
  if (rule.mode === 'EVIDENCE_INSUFFICIENT' || rule.mode === 'AGAINST_ROUTINE') {
    out.due_state = 'NOT_APPLICABLE';
    out.explanation.push(rule.mode === 'AGAINST_ROUTINE' ? 'Source recommends against routine use (not a contraindication).' : 'Evidence insufficient; no schedule is invented.');
    return out;
  }
  // 7. History quality — unknown is not "never done".
  if (input.history === 'UNKNOWN') {
    out.due_state = 'UNKNOWN_HISTORY';
    out.explanation.push('History unknown; add or import records. Not treated as never done.');
    return out;
  }
  const done = [...input.completions].filter((d) => d <= input.as_of).sort();
  // 8a. Series logic.
  if (rule.series) {
    if (done.length >= rule.series.doses) {
      out.due_state = 'SERIES_COMPLETE';
      out.explanation.push(`${done.length}/${rule.series.doses} doses recorded; series is not restarted.`);
      return out;
    }
    if (!done.length) {
      out.due_state = 'DUE_NOW';
      out.next_due_date = input.as_of;
      return out;
    }
    const last = done[done.length - 1] as string;
    const earliest = addDays(last, rule.series.min_interval_days);
    out.next_due_date = earliest;
    out.due_state = input.as_of < earliest ? 'TOO_EARLY' : 'DUE_NOW';
    out.explanation.push(`Dose ${done.length + 1}/${rule.series.doses}: minimum interval ${rule.series.min_interval_days} days after ${last}.`);
    return out;
  }
  // 8b. Interval logic.
  if (!done.length) {
    out.due_state = 'DUE_NOW';
    out.next_due_date = input.as_of;
    out.explanation.push('Eligible, routine, known history with no completion.');
    return out;
  }
  if (rule.interval_days === null) {
    out.due_state = 'UP_TO_DATE';
    out.explanation.push('One-time service already completed.');
    return out;
  }
  const last = done[done.length - 1] as string;
  const next = addDays(last, rule.interval_days);
  out.next_due_date = next;
  const until = daysBetween(input.as_of, next);
  // 9. Due state. The UI notification window never changes the rule's due date.
  if (until > input.due_soon_window_days) out.due_state = 'UP_TO_DATE';
  else if (until > 0) out.due_state = 'DUE_SOON';
  else if (until === 0) out.due_state = 'DUE_NOW';
  else out.due_state = 'OVERDUE';
  if (out.due_state === 'OVERDUE') out.explanation.push('OVERDUE is a timing state, not blame; no backlog is stacked.');
  return out;
}
