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

export function ok<T>(ref: ModelRef, value: T, inputs: Record<string, unknown>): CalcResult<T> {
  return {
    status: 'OK',
    value,
    unit: ref.unit,
    modelId: ref.modelId,
    version: ref.version,
    resultClass: ref.resultClass,
    inputs,
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
    inputs,
    missingInputs,
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
