// Results assembly: one deterministic function turns a profile into every result card.
// Used verbatim by the Site Lab, the production client (offline) and the API (server-side recompute).

import { balanceIndex, channelScore, type BalanceResult, type ChannelResult } from './composites.ts';
import { bmi, packYears, waistHeightRatio, MODELS } from './coreDerived.ts';
import type { BodyProfile, ModuleId } from './profile.ts';
import { type CalcResult, fail, isPresent } from './result.ts';

export type ExternalModelState =
  | 'LICENSE_ACCEPTANCE_REQUIRED_NOT_BUNDLED'
  | 'RESEARCH_ONLY_REGISTRY_EMPTY'
  | 'REGISTRY_EMPTY_NO_UNIVERSAL_SCORE'
  | 'REFERENCE_DATA_NOT_BUNDLED';

export interface ExternalModelCard {
  modelId: string;
  title: string;
  module: ModuleId | null;
  state: ExternalModelState;
  result: CalcResult;
  explanation: string;
}

/** External/validated models are never fabricated (FR-204, AT-780). */
export const EXTERNAL_MODELS: Array<Omit<ExternalModelCard, 'result'>> = [
  {
    modelId: 'EXT-AHA-PREVENT',
    title: 'Cardiovascular risk (AHA PREVENT)',
    module: 'cardiovascular',
    state: 'LICENSE_ACCEPTANCE_REQUIRED_NOT_BUNDLED',
    explanation:
      'Validated external model candidate. Coefficients/source code are not bundled until the AHA license is accepted, eligibility is implemented exactly and authoritative golden fixtures pass. No risk percentage is shown.',
  },
  {
    modelId: 'EXT-ONCOLOGY-MODEL-REGISTRY',
    title: 'Oncology model registry',
    module: 'oncology',
    state: 'REGISTRY_EMPTY_NO_UNIVERSAL_SCORE',
    explanation:
      'There is no universal cancer-risk equation. Future adapters are indexed by cancer type, purpose, population, endpoint and horizon. None is active.',
  },
  {
    modelId: 'EXT-BIOLOGICAL-CLOCK-REGISTRY',
    title: 'Biological age clocks',
    module: null,
    state: 'RESEARCH_ONLY_REGISTRY_EMPTY',
    explanation:
      'No clock is bundled as "the true biological age". Multiple clocks would be shown as independent versioned outputs, never averaged.',
  },
  {
    modelId: 'REF-WHO-GHE-LIFE-HALE',
    title: 'Population life expectancy / HALE baseline',
    module: null,
    state: 'REFERENCE_DATA_NOT_BUNDLED',
    explanation:
      'Population baselines require a pinned WHO dataset with source/geography/year metadata and attribution. Not bundled in this build, so no baseline age is shown.',
  },
];

export type LifespanProjectionState =
  | 'POPULATION_BASELINE_ONLY'
  | 'VALIDATED_PERSONAL_MODEL_AVAILABLE'
  | 'EXPERIMENTAL_MODEL_ENABLED'
  | 'INSUFFICIENT_DATA';

export interface ProfileResults {
  profileId: string;
  derived: { bmi: CalcResult; whtr: CalcResult; packYears: CalcResult };
  protection: ChannelResult;
  burden: ChannelResult;
  function: ChannelResult;
  balance: BalanceResult;
  coverage: CalcResult;
  external: ExternalModelCard[];
  lifespanProjection: LifespanProjectionState;
  hypothetical: boolean;
}

export function computeProfileResults(profile: BodyProfile): ProfileResults {
  const i = profile.inputs;
  const derived = {
    bmi: bmi({ weight_kg: i.weight_kg, height_m: isPresent(i.height_cm) ? i.height_cm / 100 : null }),
    whtr: waistHeightRatio({ waist: i.waist_cm, height: i.height_cm, waist_unit: 'cm', height_unit: 'cm' }),
    packYears:
      i.smoking_status === 'NEVER'
        ? { ...packYears({ packs_per_day: 0, years_smoked: 0 }), inputs: { smoking_status: 'NEVER' } }
        : i.smoking_status === 'UNKNOWN'
          ? fail(MODELS.PACK_YEARS, 'MISSING_INPUT', 'MISSING_REQUIRED_INPUT', { smoking_status: 'UNKNOWN' }, ['smoking_status'])
          : packYears({ packs_per_day: i.packs_per_day, years_smoked: i.years_smoked }),
  };
  const protection = channelScore(profile, 'PROTECTION');
  const burden = channelScore(profile, 'BURDEN');
  const fn = channelScore(profile, 'FUNCTION');
  const balance = balanceIndex(protection, burden);
  const covs = [protection, burden, fn].map((c) => c.coverage).filter((c): c is number => c !== null);
  const coverage: CalcResult = covs.length
    ? {
        status: 'OK',
        value: covs.reduce((a, b) => a + b, 0) / covs.length,
        unit: 'fraction',
        modelId: 'APP-COVERAGE-DEMO-1',
        version: '0.25.0',
        resultClass: 'COVERAGE',
        inputs: { protection: protection.coverage, burden: burden.coverage, function: fn.coverage },
        missingInputs: [],
        errorCode: null,
        limitations: ['Coverage describes input completeness. It is not health risk (AT-823).'],
      }
    : {
        status: 'MISSING_INPUT',
        value: null,
        unit: 'fraction',
        modelId: 'APP-COVERAGE-DEMO-1',
        version: '0.25.0',
        resultClass: 'COVERAGE',
        inputs: {},
        missingInputs: ['all'],
        errorCode: 'NO_ELIGIBLE_COMPONENTS',
        limitations: [],
      };
  const external: ExternalModelCard[] = EXTERNAL_MODELS.filter(
    (m) => m.module === null || profile.modules[m.module],
  ).map((m) => ({
    ...m,
    result: {
      status: 'UNAVAILABLE',
      value: null,
      unit: null,
      modelId: m.modelId,
      version: 'n/a',
      resultClass: m.modelId.startsWith('REF-') ? 'POPULATION_BASELINE' : m.modelId.includes('CLOCK') ? 'EXPERIMENTAL' : 'VALIDATED_RISK',
      inputs: {},
      missingInputs: [],
      errorCode: m.state,
      limitations: [m.explanation],
    },
  }));
  return {
    profileId: profile.id,
    derived,
    protection,
    burden,
    function: fn,
    balance,
    coverage,
    external,
    // No population pack and no validated survival model are active → no personalised age is manufactured.
    lifespanProjection: 'INSUFFICIENT_DATA',
    hypothetical: profile.profile_type === 'SCENARIO',
  };
}
