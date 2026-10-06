// Pack catalog, attribution manifest (Data Sources & Licenses) and synthetic rule packs.
// The Data Sources & Licenses UI in Site and Client is generated from ATTRIBUTION_MANIFEST.

import type { ExerciseProgram, InteractionRule, PreventiveRule, ProductConcept } from '@hhos/domain';
import medVectors from '../../../contracts/golden_vectors/medication_safety_vectors.json' with { type: 'json' };
import prevVectors from '../../../contracts/golden_vectors/preventive_vectors.json' with { type: 'json' };

export interface PackManifest {
  pack_id: string;
  kind: 'MODEL' | 'RULE' | 'REFERENCE' | 'EDUCATION';
  version: string;
  status: string;
  default_in: Array<'SITE' | 'CLIENT' | 'API'>;
  note: string;
}

export const PACK_CATALOG: PackManifest[] = [
  { pack_id: 'MP-CORE-DERIVED-1', kind: 'MODEL', version: '1.0.0', status: 'ACTIVE', default_in: ['SITE', 'CLIENT', 'API'], note: 'Transparent formulas; golden vectors in contracts/.' },
  { pack_id: 'APP-COMPOSITES-DEMO-1', kind: 'MODEL', version: '0.25.0', status: 'APP_DEFINED_DEMO', default_in: ['SITE', 'CLIENT', 'API'], note: 'Protection/Burden/Function/Coverage — app-defined, non-clinical.' },
  { pack_id: 'RP-CORE-INVARIANTS-1', kind: 'RULE', version: '1.0.0', status: 'ACTIVE', default_in: ['SITE', 'CLIENT', 'API'], note: 'missing≠zero, plan≠completion, scenario≠observation, reset≠delete.' },
  { pack_id: 'RP-MISSIONS-DEMO-1', kind: 'RULE', version: '0.25.0', status: 'ACTIVE', default_in: ['SITE', 'CLIENT', 'API'], note: 'Deterministic mission + progression rules.' },
  { pack_id: 'LAB-INTERPRETATION-ENGINE-1', kind: 'RULE', version: '0.24.0', status: 'ENGINE_ACTIVE_SYNTHETIC_RULES_ONLY', default_in: ['SITE', 'CLIENT', 'API'], note: 'No real clinical threshold table bundled.' },
  { pack_id: 'RP-PREVENTIVE-SYNTHETIC-1', kind: 'RULE', version: '1.0.0', status: 'SYNTHETIC_ONLY', default_in: ['SITE'], note: 'Fake services only; no national pack ACTIVE.' },
  { pack_id: 'SYNTHETIC-SAFETY-PACK-1', kind: 'RULE', version: '1.0.0', status: 'SYNTHETIC_TEST_ONLY', default_in: ['SITE'], note: 'Fake products/ingredients only.' },
  { pack_id: 'REF-SYNTHETIC-DEMO-1', kind: 'REFERENCE', version: '0.25.0', status: 'BUNDLE_DEFAULT', default_in: ['SITE'], note: 'Synthetic people, labs, wearables, timeline.' },
  { pack_id: 'EDU-HEALTH-LITERACY-FOUNDATION-1', kind: 'EDUCATION', version: '1.0.0', status: 'BUNDLE_DEFAULT', default_in: ['SITE', 'CLIENT'], note: '15 lessons, EN/TR.' },
  { pack_id: 'EXT-AHA-PREVENT', kind: 'MODEL', version: 'n/a', status: 'LICENSE_ACCEPTANCE_REQUIRED_NOT_BUNDLED', default_in: [], note: 'No coefficients bundled; no fake output.' },
  { pack_id: 'REF-WHO-GHE-LIFE-HALE', kind: 'REFERENCE', version: 'n/a', status: 'NOT_BUNDLED', default_in: [], note: 'Requires pinned dataset + attribution.' },
];

export interface AttributionEntry {
  name: string;
  purpose: string;
  version: string;
  license: string;
  disposition: string;
  active: boolean;
  attribution: string | null;
  endorsement_note: string | null;
}

/** ATTRIBUTION_MANIFEST — engineering register, not legal advice (checked 2026-10-06 in handoff v0.24). */
export const ATTRIBUTION_MANIFEST: AttributionEntry[] = [
  { name: 'Human Health OS synthetic demo data', purpose: 'Default Site/Client demo content', version: '0.25.0', license: 'App-authored', disposition: 'BUNDLE_DEFAULT', active: true, attribution: 'Synthetic — not real people.', endorsement_note: null },
  { name: 'USDA FoodData Central', purpose: 'Food nutrient provider (server-side adapter)', version: 'adapter not active in this build', license: 'Public domain / CC0 1.0', disposition: 'EXTERNAL_API', active: false, attribution: 'FoodData Central / USDA Agricultural Research Service', endorsement_note: 'API key never shipped in clients.' },
  { name: 'Open Food Facts', purpose: 'Barcode/package data', version: 'adapter not active', license: 'ODbL + DbCL; images CC BY-SA', disposition: 'VERIFY_BEFORE_BUNDLE', active: false, attribution: null, endorsement_note: null },
  { name: 'WHO GHE life expectancy / HALE', purpose: 'Population baseline', version: 'not bundled', license: 'CC BY 4.0 unless dataset says otherwise', disposition: 'BUNDLE_WITH_NOTICE after review', active: false, attribution: null, endorsement_note: 'No WHO endorsement implied.' },
  { name: 'UCUM', purpose: 'Unit terminology', version: 'not bundled', license: 'UCUM License v1.1 (June 2024)', disposition: 'BUNDLE_WITH_NOTICE after review', active: false, attribution: null, endorsement_note: null },
  { name: 'HL7 FHIR', purpose: 'Export adapter semantics', version: 'reference mapping only', license: 'CC0 (spec) + trademark rules', disposition: 'BUNDLE_DEFAULT for app-authored adapter code', active: false, attribution: null, endorsement_note: 'No HL7 endorsement implied.' },
  { name: 'AHA PREVENT', purpose: 'Cardiovascular risk (validated external)', version: 'not bundled', license: 'License agreement required', disposition: 'LICENSE_ACCEPTANCE_REQUIRED', active: false, attribution: null, endorsement_note: null },
];

export const SYNTHETIC_PREVENTIVE_RULES = prevVectors.rules as PreventiveRule[];
export const SYNTHETIC_PRODUCTS = medVectors.products as ProductConcept[];
export const SYNTHETIC_INTERACTION_RULES = medVectors.rules as InteractionRule[];
export const SYNTHETIC_SAFETY_PACK = medVectors.pack;

export const DEMO_PROGRAM: ExerciseProgram[] = [
  { exercise_id: 'EX-BENCH', label: 'Bench Press', sets: 3, reps: 10, start_load_kg: 30, increment_kg: 2.5 },
  { exercise_id: 'EX-SQUAT', label: 'Goblet Squat', sets: 2, reps: 12, start_load_kg: 16, increment_kg: 2 },
];
