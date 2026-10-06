// v0.24 Lab Interpretation Assessment Engine (docs: 177..185).
// Reference interval, decision limit, critical rule, method comparability, delta/RCV and personal baseline
// are SEPARATE channels. No real clinical threshold is bundled; all demo rules are synthetic.

import { MAD_SCALE, ROBUST_Z_MIN_SAMPLE, median } from './coreDerived.ts';
import { isPresent } from './result.ts';

export const LAB_ENGINE = { engineId: 'LAB-INTERPRETATION-ENGINE-1', version: '0.24.0' } as const;

export interface LabMethodContext {
  method_id: string | null;
  specimen: string | null;
  laboratory?: string | null;
}

export interface LabResultInput extends LabMethodContext {
  analyte_key: string;
  value: number | null;
  unit: string;
  observed_at: string;
  /** Laboratory-printed flag, preserved verbatim (AT-1091). */
  source_flag?: string | null;
}

export interface ReferenceIntervalSnapshot {
  interval_id: string;
  low: number | null;
  high: number | null;
  unit: string;
  specimen: string | null;
  method_id: string | null;
  source: string;
  version: string;
  /** Partition variables the source requires, e.g. ['age_years','source_sex_variable']. */
  required_context: string[];
}

export interface DecisionLimitRule {
  rule_id: string;
  label: string;
  threshold: number;
  direction: 'AT_OR_ABOVE' | 'BELOW';
  unit: string;
  source: string;
  version: string;
}

export interface CriticalRule {
  rule_id: string;
  low: number | null;
  high: number | null;
  unit: string;
  specimen: string | null;
  source: string;
  version: string;
  status: 'ACTIVE' | 'STALE' | 'RETIRED';
}

export interface MethodComparabilityRecord {
  from_method: string;
  to_method: string;
  source: string;
  version: string;
}

export interface RcvParams {
  cva: number | null;
  cvi: number | null;
  z: number | null;
  source: string;
}

export type ReferenceState =
  | 'BELOW_REFERENCE'
  | 'WITHIN_REFERENCE'
  | 'ABOVE_REFERENCE'
  | 'NO_REFERENCE'
  | 'INSUFFICIENT_REFERENCE_CONTEXT'
  | 'UNIT_NOT_COMPARABLE'
  | 'METHOD_NOT_COMPARABLE'
  | 'CONFLICTING_REFERENCE_SOURCES';

export type CriticalState =
  | 'NO_ACTIVE_RULE'
  | 'NO_MATCH'
  | 'SOURCE_DEFINED_CRITICAL_LOW_MATCHED'
  | 'SOURCE_DEFINED_CRITICAL_HIGH_MATCHED'
  | 'RULE_PACK_STALE'
  | 'UNIT_NOT_COMPARABLE';

export type ComparabilityState =
  | 'NO_PRIOR'
  | 'DIRECTLY_COMPARABLE'
  | 'COMPARABLE_WITH_METHOD_CHANGE_MARKER'
  | 'NOT_COMPARABLE'
  | 'UNKNOWN_COMPARABILITY';

export type RcvState =
  | 'NO_PRIOR'
  | 'BLOCKED_BY_COMPARABILITY'
  | 'NO_RCV_SOURCE'
  | 'INVALID_CV_INPUT'
  | 'ZERO_PRIOR'
  | 'WITHIN_RCV'
  | 'EXCEEDS_RCV';

export type BaselineState = 'INSUFFICIENT_HISTORY' | 'ZERO_MAD' | 'WITHIN_PERSONAL_BASELINE' | 'UNUSUAL_FOR_PERSON';

export type LabAssessmentStatus =
  | 'SUCCESS'
  | 'INSUFFICIENT_CONTEXT'
  | 'NO_APPLICABLE_REFERENCE'
  | 'UNIT_BLOCKED'
  | 'METHOD_BLOCKED'
  | 'RULE_PACK_STALE'
  | 'CONFLICTING_REFERENCE_SOURCES'
  | 'VALUE_NOT_REPORTED';

export interface LabInterpretationInput {
  result: LabResultInput;
  reference: ReferenceIntervalSnapshot[];
  /** Explicit partition context supplied by the user/report. Gender identity/profile labels never fill it. */
  context: Record<string, string | number | null>;
  decision_rules: DecisionLimitRule[];
  critical_rules: CriticalRule[];
  prior: LabResultInput | null;
  comparability_records: MethodComparabilityRecord[];
  rcv: RcvParams | null;
  /** Personal history (same analyte, comparable method). */
  baseline_points: Array<number | null>;
  /** Synthetic rule parameter for RULE-LAB-BASELINE-SYNTH-1. */
  baseline_threshold?: number;
}

export interface LabInterpretationAssessment {
  engine: typeof LAB_ENGINE;
  status: LabAssessmentStatus;
  value: number | null;
  unit: string;
  flags: Array<{ origin: 'SOURCE_REPORTED' | 'APP_REFERENCE_COMPARISON' | 'APP_RULE_MATCH'; label: string }>;
  reference: { state: ReferenceState; interval: ReferenceIntervalSnapshot | null };
  decision: Array<{ rule_id: string; label: string; matched: boolean; source: string; version: string }>;
  critical: {
    state: CriticalState;
    rule_id: string | null;
    /** Only an external integration receipt can make this true (AT-1071). */
    external_receipt_confirmed: false;
  };
  comparability: { state: ComparabilityState; trend_discontinuity: boolean; record: MethodComparabilityRecord | null };
  rcv: { state: RcvState; rcv_percent: number | null; observed_percent_change: number | null; source: string | null };
  baseline: { state: BaselineState; robust_z: number | null; n: number };
  limitations: string[];
}

/** RCV% = Z × √2 × √(CVa² + CVi²). Refuses negative/missing CV inputs (AT-1085). */
export function rcvPercent(p: RcvParams): number | null {
  if (!isPresent(p.cva) || !isPresent(p.cvi) || !isPresent(p.z)) return null;
  if (p.cva < 0 || p.cvi < 0 || p.z <= 0) return null;
  return p.z * Math.SQRT2 * Math.sqrt(p.cva * p.cva + p.cvi * p.cvi);
}

function assessComparability(
  cur: LabResultInput,
  prior: LabResultInput | null,
  records: MethodComparabilityRecord[],
): LabInterpretationAssessment['comparability'] {
  if (!prior || !isPresent(prior.value)) return { state: 'NO_PRIOR', trend_discontinuity: false, record: null };
  if (cur.specimen !== prior.specimen || cur.unit !== prior.unit)
    return { state: 'NOT_COMPARABLE', trend_discontinuity: true, record: null };
  if (cur.method_id && prior.method_id && cur.method_id === prior.method_id)
    return { state: 'DIRECTLY_COMPARABLE', trend_discontinuity: false, record: null };
  const rec =
    records.find(
      (r) =>
        (r.from_method === prior.method_id && r.to_method === cur.method_id) ||
        (r.from_method === cur.method_id && r.to_method === prior.method_id),
    ) ?? null;
  if (rec && rec.source && rec.version)
    return { state: 'COMPARABLE_WITH_METHOD_CHANGE_MARKER', trend_discontinuity: true, record: rec };
  return { state: 'UNKNOWN_COMPARABILITY', trend_discontinuity: true, record: null };
}

export function interpretLabResult(input: LabInterpretationInput): LabInterpretationAssessment {
  const r = input.result;
  const limitations = [
    'Reference interval ≠ optimal target ≠ clinical decision limit.',
    'Outside reference ≠ critical; within reference ≠ unchanged for this person.',
    'Software semantics only; fixtures do not validate medical thresholds.',
  ];
  const flags: LabInterpretationAssessment['flags'] = [];
  if (r.source_flag) flags.push({ origin: 'SOURCE_REPORTED', label: r.source_flag });

  const empty = (status: LabAssessmentStatus): LabInterpretationAssessment => ({
    engine: LAB_ENGINE,
    status,
    value: null,
    unit: r.unit,
    flags,
    reference: { state: 'NO_REFERENCE', interval: null },
    decision: [],
    critical: { state: 'NO_ACTIVE_RULE', rule_id: null, external_receipt_confirmed: false },
    comparability: { state: 'NO_PRIOR', trend_discontinuity: false, record: null },
    rcv: { state: 'NO_PRIOR', rcv_percent: null, observed_percent_change: null, source: null },
    baseline: { state: 'INSUFFICIENT_HISTORY', robust_z: null, n: 0 },
    limitations,
  });
  if (!isPresent(r.value)) return empty('VALUE_NOT_REPORTED');
  const x = r.value;

  // 3–4. Reference interval selection and comparison (only after safe unit compatibility).
  let refState: ReferenceState = 'NO_REFERENCE';
  let interval: ReferenceIntervalSnapshot | null = null;
  const candidates = input.reference.filter((ri) => ri.specimen === null || ri.specimen === r.specimen);
  if (candidates.length > 1) {
    const distinct = new Set(candidates.map((c) => `${c.low}|${c.high}|${c.unit}`));
    if (distinct.size > 1) refState = 'CONFLICTING_REFERENCE_SOURCES';
  }
  if (refState !== 'CONFLICTING_REFERENCE_SOURCES' && candidates.length) {
    interval = candidates[0] as ReferenceIntervalSnapshot;
    const missingCtx = interval.required_context.filter((k) => input.context[k] === null || input.context[k] === undefined || input.context[k] === '');
    if (interval.unit !== r.unit) refState = 'UNIT_NOT_COMPARABLE';
    else if (interval.method_id && r.method_id && interval.method_id !== r.method_id) refState = 'METHOD_NOT_COMPARABLE';
    else if (missingCtx.length) refState = 'INSUFFICIENT_REFERENCE_CONTEXT';
    else if (!isPresent(interval.low) && !isPresent(interval.high)) refState = 'NO_REFERENCE';
    else if (isPresent(interval.low) && x < interval.low) refState = 'BELOW_REFERENCE';
    else if (isPresent(interval.high) && x > interval.high) refState = 'ABOVE_REFERENCE';
    else refState = 'WITHIN_REFERENCE';
  }
  if (refState === 'BELOW_REFERENCE' || refState === 'ABOVE_REFERENCE')
    flags.push({ origin: 'APP_REFERENCE_COMPARISON', label: refState });

  // 5. Clinical decision limits — evaluated separately from the reference interval (AT-1089).
  const decision = input.decision_rules
    .filter((d) => d.unit === r.unit)
    .map((d) => ({
      rule_id: d.rule_id,
      label: d.label,
      matched: d.direction === 'AT_OR_ABOVE' ? x >= d.threshold : x < d.threshold,
      source: d.source,
      version: d.version,
    }));
  for (const d of decision) if (d.matched) flags.push({ origin: 'APP_RULE_MATCH', label: d.rule_id });

  // 6. Critical rules — independent of reference interval; never synthesised (AT-1067..1070, 1094).
  let critical: LabInterpretationAssessment['critical'] = { state: 'NO_ACTIVE_RULE', rule_id: null, external_receipt_confirmed: false };
  const crit = input.critical_rules.filter((c) => c.status !== 'RETIRED' && (c.specimen === null || c.specimen === r.specimen));
  const stale = crit.find((c) => c.status === 'STALE');
  const active = crit.filter((c) => c.status === 'ACTIVE');
  if (stale && !active.length) critical = { state: 'RULE_PACK_STALE', rule_id: stale.rule_id, external_receipt_confirmed: false };
  for (const c of active) {
    if (c.unit !== r.unit) {
      critical = { state: 'UNIT_NOT_COMPARABLE', rule_id: c.rule_id, external_receipt_confirmed: false };
      continue;
    }
    if (isPresent(c.low) && x < c.low) {
      critical = { state: 'SOURCE_DEFINED_CRITICAL_LOW_MATCHED', rule_id: c.rule_id, external_receipt_confirmed: false };
      break;
    }
    if (isPresent(c.high) && x > c.high) {
      critical = { state: 'SOURCE_DEFINED_CRITICAL_HIGH_MATCHED', rule_id: c.rule_id, external_receipt_confirmed: false };
      break;
    }
    critical = { state: 'NO_MATCH', rule_id: c.rule_id, external_receipt_confirmed: false };
  }
  if (critical.state.startsWith('SOURCE_DEFINED')) flags.push({ origin: 'APP_RULE_MATCH', label: critical.state });

  // 7. Longitudinal method comparability.
  const comparability = assessComparability(r, input.prior, input.comparability_records);

  // 8. Delta / RCV (blocked unless directly comparable, AT-1086).
  let rcv: LabInterpretationAssessment['rcv'] = { state: 'NO_PRIOR', rcv_percent: null, observed_percent_change: null, source: null };
  if (comparability.state !== 'NO_PRIOR') {
    if (comparability.state !== 'DIRECTLY_COMPARABLE') rcv = { ...rcv, state: 'BLOCKED_BY_COMPARABILITY' };
    else if (!input.rcv) rcv = { ...rcv, state: 'NO_RCV_SOURCE' };
    else {
      const pct = rcvPercent(input.rcv);
      const prior = input.prior?.value as number;
      if (pct === null) rcv = { ...rcv, state: 'INVALID_CV_INPUT', source: input.rcv.source };
      else if (prior === 0) rcv = { ...rcv, state: 'ZERO_PRIOR', rcv_percent: pct, source: input.rcv.source };
      else {
        const obs = ((x - prior) / prior) * 100;
        rcv = {
          state: Math.abs(obs) > pct ? 'EXCEEDS_RCV' : 'WITHIN_RCV',
          rcv_percent: pct,
          observed_percent_change: obs,
          source: input.rcv.source,
        };
      }
    }
  }

  // 9. Personal baseline — separate from population reference (AT-1087).
  const pts = input.baseline_points.filter(isPresent).sort((a, b) => a - b);
  let baseline: LabInterpretationAssessment['baseline'] = { state: 'INSUFFICIENT_HISTORY', robust_z: null, n: pts.length };
  if (pts.length >= ROBUST_Z_MIN_SAMPLE) {
    const med = median(pts);
    const mad = median(pts.map((p) => Math.abs(p - med)).sort((a, b) => a - b));
    if (mad === 0) baseline = { state: 'ZERO_MAD', robust_z: null, n: pts.length };
    else {
      const z = (x - med) / (MAD_SCALE * mad);
      const thr = input.baseline_threshold ?? 3.5;
      baseline = { state: Math.abs(z) >= thr ? 'UNUSUAL_FOR_PERSON' : 'WITHIN_PERSONAL_BASELINE', robust_z: z, n: pts.length };
    }
  }

  let status: LabAssessmentStatus = 'SUCCESS';
  if (refState === 'UNIT_NOT_COMPARABLE') status = 'UNIT_BLOCKED';
  else if (refState === 'METHOD_NOT_COMPARABLE') status = 'METHOD_BLOCKED';
  else if (refState === 'INSUFFICIENT_REFERENCE_CONTEXT') status = 'INSUFFICIENT_CONTEXT';
  else if (refState === 'CONFLICTING_REFERENCE_SOURCES') status = 'CONFLICTING_REFERENCE_SOURCES';
  else if (critical.state === 'RULE_PACK_STALE') status = 'RULE_PACK_STALE';
  else if (refState === 'NO_REFERENCE') status = 'NO_APPLICABLE_REFERENCE';

  return {
    engine: LAB_ENGINE,
    status,
    value: x,
    unit: r.unit,
    flags,
    reference: { state: refState, interval },
    decision,
    critical,
    comparability,
    rcv,
    baseline,
    limitations,
  };
}
