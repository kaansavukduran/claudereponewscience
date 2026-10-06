// @hhos/domain — the single deterministic core shared by:
//   apps/site    (Interactive Site Lab, synthetic-first)
//   apps/client  (production Android/iOS/Web client)
//   services/api (server recompute + persistence)
// Formula changes here propagate to every surface; golden vectors in /contracts guard parity.

export * from './result.ts';
export * from './coreDerived.ts';
export * from './profile.ts';
export * from './composites.ts';
export * from './results.ts';
export * from './compare.ts';
export * from './labInterpretation.ts';
export * from './nutrition.ts';
export * from './dates.ts';
export * from './preventive.ts';
export * from './medSafety.ts';
export * from './missions.ts';

export const DOMAIN_VERSION = '0.25.0';
export const HANDOFF_BASELINE = 'v0.24';
