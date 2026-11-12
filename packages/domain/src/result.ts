// Shared result envelope for every calculation in Human Health OS.
// Invariants (Master Handoff v0.24): missing != zero, invalid calculation != fake zero,
// app score != validated clinical risk, every result carries model/rule ID + version.

export type ResultClass =
  | 'POPULATION_BASELINE' // R1
  | 'VALIDATED_RISK' // R2
  | 'APP_COMPOSITE' // R3 (APP_DEFINED, not clinical)
  | 'COVERAGE' // R4
  | 'ADHERENCE' // R5
  | 'DERIVED_MEASUREMENT' // R6
  | 'EXPERIMENTAL'; // R7

export type CalcStatus =
  | 'OK'
  | 'MISSING_INPUT'
  | 'INVALID_INPUT'
  | 'NOT_ELIGIBLE'
  | 'UNAVAILABLE';

export interface CalcResult<T = number> {
  status: CalcStatus;
  /** Present only when status === 'OK'. Never substituted with 0. */
  value: T | null;
  unit: string | null;
  modelId: string;
  version: string;
  resultClass: ResultClass;
  inputs: Record<string, unknown>;
  missingInputs: string[];
  errorCode: string | null;
  limitations: string[];
}

export interface ModelRef {
  modelId: string;
  version: string;
  resultClass: ResultClass;
  unit: string | null;
  limitations?: string[];
}

/** Error code of a calculation whose arithmetic gave NaN or an infinity (same code as the Dart engines). */
export const NON_FINITE_RESULT = 'NON_FINITE_RESULT';

/** A deep, frozen copy of a JSON-like input value (plain objects and arrays are copied; other values are kept). */
function freezeValue(v: unknown): unknown {
  if (Array.isArray(v)) return Object.freeze(v.map(freezeValue));
  if (v !== null && typeof v === 'object' && (Object.getPrototypeOf(v) === Object.prototype || Object.getPrototypeOf(v) === null)) {
    const out: Record<string, unknown> = {};
    for (const [k, x] of Object.entries(v as Record<string, unknown>)) out[k] = freezeValue(x);
    return Object.freeze(out);
  }
  return v;
}

/** The inputs a result keeps: a frozen deep copy, so changing the caller's object afterwards changes nothing. */
export function frozenInputs(inputs: Record<string, unknown>): Record<string, unknown> {
  return freezeValue(inputs ?? {}) as Record<string, unknown>;
}

/**
 * A successful calculation. A non-finite number (NaN or an infinity, e.g. from an overflow) is never
 * reported as a result: it becomes an INVALID_INPUT refusal with the code NON_FINITE_RESULT and no value.
 */
export function ok<T>(ref: ModelRef, value: T, inputs: Record<string, unknown>): CalcResult<T> {
  if (typeof value === 'number' && !Number.isFinite(value)) return fail<T>(ref, 'INVALID_INPUT', NON_FINITE_RESULT, inputs);
  return {
    status: 'OK',
    value,
    unit: ref.unit,
    modelId: ref.modelId,
    version: ref.version,
    resultClass: ref.resultClass,
    inputs: frozenInputs(inputs),
    missingInputs: [],
    errorCode: null,
    limitations: ref.limitations ?? [],
  };
}

export function fail<T = number>(
  ref: ModelRef,
  status: Exclude<CalcStatus, 'OK'>,
  errorCode: string,
  inputs: Record<string, unknown>,
  missingInputs: string[] = [],
): CalcResult<T> {
  return {
    status,
    value: null,
    unit: ref.unit,
    modelId: ref.modelId,
    version: ref.version,
    resultClass: ref.resultClass,
    inputs: frozenInputs(inputs),
    missingInputs: [...missingInputs],
    errorCode,
    limitations: ref.limitations ?? [],
  };
}

/** A value is "present" only if it is a finite number. null/undefined/NaN are MISSING, never 0. */
export function isPresent(v: unknown): v is number {
  return typeof v === 'number' && Number.isFinite(v);
}

export function missingKeys(inputs: Record<string, unknown>, keys: string[]): string[] {
  return keys.filter((k) => !isPresent(inputs[k]));
}
