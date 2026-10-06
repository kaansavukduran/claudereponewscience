# LONGEVITY APP / HUMAN HEALTH OS — MASTER HANDOFF v0.24

Zero-context implementation-ready specification. v0.24 adds laboratory reference/critical/method/delta governance and repairs historical identifier collisions into canonical unique IDs.


---

<!-- SOURCE: 00_READ_THIS_FIRST.md -->

# LONGEVITY APP — READ THIS FIRST

## Purpose of this package

This repository is a zero-context developer handoff for **Longevity App**.

A future developer, coding agent, or ChatGPT instance must be able to understand and build the product even if:

- all previous ChatGPT memory has been erased,
- none of the previous conversations are available,
- the developer has never heard the terms Human OS, Forge, Forge Donor, or Longevity App,
- no personal user profile is available.

Do not depend on conversational memory for any product-critical fact.

## Product in one sentence

**Longevity App is a general-purpose longitudinal health and longevity platform that lets any user record and review laboratory results, health conditions, symptoms, daily psychological self-ratings, food intake and nutrition data over time across Android, iOS and web.**

## Product scope

The product is for the general public. It is not a Kaan-specific application and must not embed one person's diet, diagnoses, routines, measurements, supplements, academic goals or private history as application defaults.

## Target clients

1. Android
2. iOS / iPhone
3. Web application

The architecture should use a shared product model and backend rather than three unrelated products.

## Current handoff status

This package is an **implementation-ready developer handoff specification**, not proof that a production app has been built.

Status:
- Product specification: DEFINED
- Cross-platform target: DEFINED
- Core data model: DEFINED
- API contract: DEFINED
- Human OS donor method: SELF-CONTAINED
- Acceptance tests: DEFINED
- Production implementation: NOT CLAIMED
- Android APK/AAB: NOT CLAIMED
- iOS/TestFlight build: NOT CLAIMED
- Web deployment: NOT CLAIMED

## Reading order

Read these files in order:

1. `00_READ_THIS_FIRST.md`
2. `01_MASTER_PRODUCT_SPEC.md`
3. `02_FEATURE_REQUIREMENTS.md`
4. `03_UI_UX_SPEC.md`
5. `04_DATA_MODEL.md`
6. `05_HEALTH_AND_TIMELINE.md`
7. `06_NUTRITION_AND_FOOD_DATA.md`
8. `07_LAB_RESULTS_ENGINE.md`
9. `08_MIND_CONDITIONS_SYMPTOMS.md`
10. `09_MEDICATIONS_VITALS_ACTIVITY_SLEEP.md`
11. `10_LONGEVITY_EVIDENCE_AND_DETERMINISTIC_INSIGHTS.md`
12. `11_API_AND_BACKEND_CONTRACT.md`
13. `12_SECURITY_PRIVACY_AND_OWNERSHIP.md`
14. `13_CROSS_PLATFORM_TECH_ARCHITECTURE.md`
15. `14_SYNC_OFFLINE_BACKUP_MIGRATION.md`
16. `15_ACCEPTANCE_TESTS.md`
17. `16_FAILURE_MODES_AND_SAFETY.md`
18. `17_DESIGN_SYSTEM.md`
19. `18_HUMAN_OS_DONOR_SPEC.md`
20. `19_BUILD_AND_DELIVERY_CONTRACT.md`
21. `BUILD_LONGEVITY_APP.txt`

`MASTER_HANDOFF.md` is a combined emergency copy of the key requirements.

## Authority

When files conflict:
1. explicit current user requirements in this package,
2. `01_MASTER_PRODUCT_SPEC.md`,
3. domain specification file,
4. technical implementation detail,
5. historical/donor material.

Human OS is a methodology donor, not a second product authority.

## Development behavior expected from an AI coding agent

Do not stop at:
- a product explanation,
- pseudocode,
- a UI mockup,
- a scaffold,
- a handful of example files.

Build as much of the real product as the environment permits, test what can actually be tested, fix observed failures, and report remaining gaps precisely.

Never claim BUILT, INSTALLED, DEPLOYED or VALIDATED without corresponding evidence.


## v0.5 execution files

After the original domain specifications, also read:

20. `20_IMPLEMENTATION_PHASES_AND_MVP.md`
21. `21_SCREEN_ROUTES_AND_USER_FLOWS.md`
22. `22_SYNC_PROTOCOL_AND_CONFLICTS.md`
23. `23_API_PAYLOAD_EXAMPLES.md`
24. `24_ARCHITECTURE_DECISIONS.md`
25. `25_REQUIREMENTS_TRACEABILITY.md`
26. `26_RELEASE_GATES_AND_DEFINITION_OF_DONE.md`
27. `27_IMPLEMENTATION_CHECKLIST.md`

Machine-readable execution aids:
- `IMPLEMENTATION_PLAN.json`
- `REQUIREMENTS_TRACEABILITY.json`
- `SYNTHETIC_TEST_FIXTURES.json`


## v0.7 product identity clarification

The product is now explicitly:
- observation/tracking,
- deterministic health/longevity calculation,
- comparison/simulation,
- offline education,
- daily mission planning.

Generative AI is NOT part of required scope.
Core functionality must work offline after local data/rules/content are installed.

Additional authoritative files:
- `34_COMPARISON_LAB_AND_BODY_PROFILES.md`
- `35_DAILY_MISSIONS_AND_RULE_ENGINE.md`
- `36_WEARABLE_AND_HEALTH_PLATFORM_INTEGRATION.md`
- `37_DEFAULTS_RESET_AND_PROFILE_TEMPLATES.md`
- `38_OFFLINE_EDUCATION_AND_LEARNING_MODE.md`
- `39_OFFLINE_DETERMINISTIC_CORE_CONTRACT.md`

## v0.8 conceptual core

The product must now be understood as a **Longevity ↔ Shortevity Health OS**.

Longevity = protective/resilience/healthspan-supporting direction.
Shortevity = adverse/risk/burden/function-loss direction.

Shortevity is a product umbrella term, not a universal clinical score.

Human OS is comprehensively integrated to the extent its reusable methodology is accessible in this package/project. Unseen standalone donor bytes remain explicitly UNKNOWN.

New authoritative files:
- `40_LONGEVITY_SHORTEVITY_BIDIRECTIONAL_ENGINE.md`
- `41_RISK_BURDEN_RESILIENCE_MATH.md`
- `42_CAUSAL_EVIDENCE_AND_INTERVENTION_GRAPH.md`
- `43_HUMAN_OS_FULL_DONOR_TRANSFER.md`
- `44_HUMAN_OS_STATE_EVENT_DECISION_MEMORY.md`
- `45_HUMAN_OS_DAILY_ORCHESTRATION_AND_RECOVERY.md`
- `46_SHORTEVITY_TRAJECTORY_AND_EARLY_WARNING.md`
- `HUMAN_OS_DONOR_TRANSFER_MAP.json`


## v0.9 maturity layer

v0.9 adds:
- whole-life health chronology,
- Episodes of Care,
- biological-aging model registry support,
- function/QoL/pain/rehabilitation,
- multimorbidity and interaction graph,
- environmental/social context,
- interoperability semantics,
- deterministic Digital Twin and scenario patches,
- personal baselines/anomalies/forecasts,
- full portable restore,
- explicit iterative Forge loop.

New authoritative files:
- `47_LIFE_COURSE_AND_EPISODES_OF_CARE.md`
- `48_BIOLOGICAL_AGE_AND_AGING_CLOCKS.md`
- `49_FUNCTION_QUALITY_OF_LIFE_PAIN_AND_REHABILITATION.md`
- `50_MULTIMORBIDITY_POLYPHARMACY_AND_INTERACTION_GRAPH.md`
- `51_EXPOSOME_ENVIRONMENT_AND_SOCIAL_CONTEXT.md`
- `52_INTEROPERABILITY_CLINICAL_CODES_AND_SEMANTICS.md`
- `53_DETERMINISTIC_DIGITAL_TWIN_AND_SCENARIO_ENGINE.md`
- `54_PERSONAL_BASELINE_ANOMALY_AND_FORECAST_ENGINE.md`
- `55_PORTABLE_EXPORT_BACKUP_AND_RESTORE_FORMAT.md`
- `56_CONTINUOUS_FORGE_DEVELOPMENT_LOOP.md`


## v0.10 trust layer

v0.10 strengthens whether health data and calculations can be trusted, reproduced and audited.

New authoritative files: `57_DATA_QUALITY_PROVENANCE_AND_UNCERTAINTY_ENGINE.md` through `67_TECHNICAL_STANDARDS_SOURCE_REGISTER.md`.


## v0.11 production shell

v0.11 adds the operational shell required to make the deterministic Human Health OS safer and usable in production:

- secure local key/storage architecture,
- authentication/session/device recovery,
- local reminders/scheduling,
- accessibility/aging-friendly UX,
- localization,
- clinician reports/controlled sharing,
- observability/crash recovery/support,
- deployment/release operations,
- threat model/security baseline,
- regulatory product-boundary/claim control.

New authoritative files:
- `68_SECURE_LOCAL_STORAGE_KEY_MANAGEMENT_AND_APP_LOCK.md`
- `69_AUTHENTICATION_SESSION_DEVICE_AND_ACCOUNT_RECOVERY.md`
- `70_NOTIFICATIONS_REMINDERS_SCHEDULER_AND_CALENDAR.md`
- `71_ACCESSIBILITY_INCLUSIVE_DESIGN_AND_AGING_UI.md`
- `72_LOCALIZATION_UNITS_TIMEZONES_AND_CULTURAL_FORMATTING.md`
- `73_CLINICIAN_VIEW_REPORTS_AND_CONTROLLED_SHARING.md`
- `74_OBSERVABILITY_CRASH_RECOVERY_AND_SUPPORT.md`
- `75_PRODUCTION_ENVIRONMENTS_DEPLOYMENT_AND_RELEASE_OPERATIONS.md`
- `76_THREAT_MODEL_AND_MOBILE_SECURITY_BASELINE.md`
- `77_REGULATORY_PRODUCT_BOUNDARY_AND_CLAIM_CONTROL.md`


## v0.12 implementation blueprint

v0.12 turns the mature specification into a lower-ambiguity coding handoff.

New authoritative files:
- `78_REFERENCE_IMPLEMENTATION_BLUEPRINT.md`
- `79_SCREEN_STATE_MACHINE_SPEC.md`
- `80_DATABASE_MIGRATION_AND_INVARIANT_FIXTURES.md`
- `81_CANONICAL_API_ENVELOPES_PAGINATION_AND_IDEMPOTENCY.md`
- `82_SYNTHETIC_DATA_GENERATOR_AND_SCENARIO_FIXTURES.md`
- `83_PERFORMANCE_BUDGETS_AND_SCALE_TARGETS.md`
- `84_END_TO_END_REFERENCE_SCENARIOS.md`
- `85_TEST_PYRAMID_CI_AND_RELEASE_MATRIX.md`
- `86_IMPLEMENTATION_AGENT_EXECUTION_PROTOCOL.md`

Machine-readable aids:
- `REFERENCE_IMPLEMENTATION_CONTRACT.json`
- `SCREEN_STATE_MACHINE.json`
- `MIGRATION_FIXTURES.json`
- `PERFORMANCE_BUDGETS.json`


## v0.13 implementation contracts

v0.13 reduces coding-agent ambiguity through:
- reusable UI behavioral contracts,
- singular module/entity ownership,
- repository bootstrap gate,
- API resource validation contracts,
- named synthetic fixture catalog,
- disaster-recovery drills,
- deterministic sync chaos tests,
- stable error/recovery semantics,
- final release artifact layout.

New authoritative files:
- `87_COMPONENT_LIBRARY_AND_INTERACTION_CONTRACTS.md`
- `88_MODULE_CONTRACTS_AND_DEPENDENCY_GRAPH.md`
- `89_REPOSITORY_BOOTSTRAP_AND_WORKSPACE_LAYOUT.md`
- `90_OPENAPI_RESOURCE_SCHEMAS_AND_VALIDATION_RULES.md`
- `91_FIXTURE_CATALOG_AND_TEST_PROFILE_LIBRARY.md`
- `92_DATA_INTEGRITY_AND_DISASTER_RECOVERY_DRILLS.md`
- `93_SYNC_CONFLICT_SIMULATOR_AND_CHAOS_TESTS.md`
- `94_ERROR_CATALOG_AND_USER_RECOVERY_COPY.md`
- `95_RELEASE_ARTIFACT_LAYOUT_AND_HANDOFF_INDEX.md`
- `96_BOOTSTRAP_ACCEPTANCE_AND_FIRST_COMMIT_CHECKLIST.md`


## v0.14 domain-completion layer

v0.14 closes implementation ambiguity around:
- domain-by-domain API/schema ownership,
- query/filter/sort/export contracts,
- responsive layout/density behavior,
- data retention/deletion/tombstones,
- typed domain events/invalidation,
- capability degradation,
- production acceptance evidence/signoff.

New authoritative files:
- `97_DOMAIN_API_AND_SCHEMA_CATALOG.md`
- `98_RESPONSIVE_LAYOUT_BLUEPRINT.md`
- `99_DATA_RETENTION_DELETION_AND_TOMBSTONE_MATRIX.md`
- `100_PRODUCTION_ACCEPTANCE_DOSSIER.md`
- `101_RESOURCE_OWNERSHIP_CRUD_AND_SYNC_MATRIX.md`
- `102_QUERY_FILTER_SORT_SEARCH_AND_EXPORT_CONTRACT.md`
- `103_DOMAIN_EVENT_CATALOG_AND_INVALIDATION_RULES.md`
- `104_PERMISSION_CAPABILITY_AND_DEGRADATION_MATRIX.md`
- `105_RELEASE_EVIDENCE_SCHEMA_AND_SIGNOFF.md`
- `106_SCREEN_BY_SCREEN_VISUAL_WIREFRAME_CONTRACT.md`


## v0.15 fourth direct build artifact

In addition to the production-app build prompt, v0.15 adds a dedicated Site/Web-App generation prompt:

`BUILD_HUMAN_HEALTH_OS_SITE.txt`

Its job is to build/publish a functional interactive Human Health OS laboratory, not the native production application.

Authoritative Site-specific files:
- `107_INTERACTIVE_SITE_PROTOTYPE_AND_PUBLISHING_CONTRACT.md`
- `SITE_BUILD_CONTRACT.json`
- `BUILD_HUMAN_HEALTH_OS_SITE.txt`


## v0.16 executable starter packs

v0.16 turns pack infrastructure into initial executable assets.

New authoritative files:
- `108_STARTER_MODEL_PACK_CATALOG.md`
- `109_STARTER_RULE_PACK_CATALOG.md`
- `110_REFERENCE_DATA_AND_PROVIDER_PACK_CATALOG.md`
- `111_EDUCATION_STARTER_PACK.md`
- `112_THIRD_PARTY_LICENSE_AND_ATTRIBUTION_MATRIX.md`
- `113_EXECUTABLE_SCHEMA_STARTER_SET.md`
- `114_PACK_FIXTURE_ACTIVATION_AND_LICENSE_GATES.md`
- `115_SITE_LAB_STARTER_PACK_AND_DEMO_DATA_CONTRACT.md`

Machine-readable:
- `MODEL_PACK_CATALOG.json`
- `RULE_PACK_CATALOG.json`
- `REFERENCE_PACK_CATALOG.json`
- `THIRD_PARTY_LICENSE_MATRIX.json`
- `EDUCATION_PACK_CATALOG.json`
- `EXECUTABLE_SCHEMA_STARTER_INDEX.json`
- `starter_packs/*`
- `starter_schemas/*`


## v0.17 implementation-hardening layer

New authoritative files:
- `116_GOLDEN_VECTORS_AND_REFERENCE_FIXTURES.md`
- `117_DATABASE_DDL_CONSTRAINT_INDEX_BLUEPRINT.md`
- `118_LOCAL_SQLITE_SERVER_POSTGRES_PARITY.md`
- `119_ZERO_KNOWLEDGE_ONBOARDING_HELP_MANUAL.md`
- `120_CLINICIAN_AND_EXPORT_REFERENCE_EXAMPLES.md`
- `121_ATTRIBUTION_NOTICE_AND_LICENSE_PAGE_GENERATOR.md`
- `122_SEED_MIGRATION_AND_REFERENCE_BOOTSTRAP.md`
- `123_CANONICAL_DATA_DICTIONARY.md`
- `124_TRANSACTION_INTEGRITY_AND_RECALCULATION_PROTOCOL.md`

Executable/reference assets:
- `golden_vectors/*`
- `reference_code/*`
- `database_blueprints/*`
- `help_content/*`
- `export_examples/*`
- `GOLDEN_VECTOR_CATALOG.json`
- `DATABASE_DDL_CONTRACT.json`
- `DATA_DICTIONARY.json`
- `ONBOARDING_FLOW.json`
- `ATTRIBUTION_MANIFEST.json`
- `EXPORT_EXAMPLE_CATALOG.json`


## v0.18 migration/authorization/interoperability layer

New authoritative files:
- `125_MIGRATION_SEQUENCE_AND_COMPATIBILITY_CONTRACT.md`
- `126_SERVER_AUTHORIZATION_AND_POSTGRES_RLS_BLUEPRINT.md`
- `127_EXECUTABLE_REPOSITORY_SCAFFOLD.md`
- `128_FHIR_EXPORT_MAPPING_AND_CLINICIAN_INTEROP_EXAMPLES.md`
- `129_AUTHORIZATION_GOLDEN_VECTORS_AND_CROSS_USER_TESTS.md`
- `130_CONTRACT_VERIFICATION_RUNNER.md`

Executable/reference assets:
- `migrations/sqlite/*`
- `migrations/postgres/*`
- `database_blueprints/postgres_rls_reference.sql`
- `repository_scaffold/*`
- `fhir_examples/*`
- `authorization_vectors.json`
- `MIGRATION_CONTRACT.json`
- `AUTHORIZATION_POLICY_MATRIX.json`
- `REPOSITORY_SCAFFOLD_CONTRACT.json`
- `FHIR_MAPPING_CATALOG.json`


## v0.19 contract-surface hardening

New authoritative files:
- `131_OPENAPI_STARTER_AND_ENDPOINT_AUTHORIZATION.md`
- `132_API_IDEMPOTENCY_REVISION_AND_ERROR_CONTRACT.md`
- `133_MIGRATION_ROLLBACK_AND_RECOVERY_DRILLS.md`
- `134_UI_DESIGN_TOKENS_AND_COMPONENT_STATE_CONTRACT.md`
- `135_VISUAL_INFORMATION_HIERARCHY_AND_CHART_SEMANTICS.md`
- `136_BUILD_AGENT_DELIVERY_CHECKLIST_AUTOMATION.md`

Machine-readable/executable:
- `OPENAPI_STARTER.json`
- `ENDPOINT_AUTHORIZATION_MATRIX.json`
- `API_ERROR_CATALOG.json`
- `API_RESPONSE_EXAMPLES_v0.19.json`
- `MIGRATION_ROLLBACK_DRILLS.json`
- `UI_DESIGN_TOKENS.json`
- `COMPONENT_STATE_MATRIX.json`
- `BUILD_DELIVERY_CHECKLIST.json`
- `reference_code/run_migration_rollback_drills.py`
- `repository_scaffold/scripts/validate_openapi_contract.py`
- `repository_scaffold/scripts/validate_ui_contracts.py`
- `repository_scaffold/scripts/verify_delivery_readiness.py`


## v0.20 health-platform and nutrition execution layer

New authoritative files:
- `137_HEALTH_PLATFORM_ADAPTER_CANONICALIZATION_CONTRACT.md`
- `138_ANDROID_HEALTH_CONNECT_ADAPTER_CONTRACT.md`
- `139_APPLE_HEALTHKIT_ADAPTER_CONTRACT.md`
- `140_NUTRITION_RECIPE_AND_PORTION_MATH_ENGINE.md`
- `141_NUTRITION_GOLDEN_VECTORS_AND_FIXTURE_CONTRACT.md`
- `142_FULL_DOMAIN_API_COVERAGE_MATRIX.md`
- `143_HEALTH_PROVIDER_DEDUPLICATION_AND_PROVENANCE.md`
- `144_HEALTH_ADAPTER_CONFORMANCE_AND_FIXTURES.md`

Machine/executable:
- `HEALTH_PLATFORM_MAPPING_CATALOG.json`
- `health_adapter_fixtures.json`
- `DOMAIN_API_COVERAGE_MATRIX.json`
- `golden_vectors/nutrition_vectors.json`
- `reference_code/nutrition_math_engine.py`
- `reference_code/validate_nutrition_vectors.py`
- `reference_code/validate_health_adapter_fixtures.py`


## v0.21 secure document ingestion layer

New authoritative files:
- `145_SECURE_ATTACHMENTS_AND_OBJECT_STORAGE_CONTRACT.md`
- `146_DOCUMENT_INGESTION_STATE_MACHINE_AND_QUARANTINE.md`
- `147_LAB_REPORT_EXTRACTION_REVIEW_AND_COMMIT.md`
- `148_DOCUMENT_TYPE_METADATA_AND_LINKING_MODEL.md`
- `149_ATTACHMENT_PRIVACY_EXIF_THUMBNAIL_AND_RETENTION.md`
- `150_DOCUMENT_PARSER_FIXTURES_AND_CONFORMANCE.md`
- `151_DOCUMENT_API_UPLOAD_DOWNLOAD_AND_ACCESS.md`
- `152_ATTACHMENT_DUPLICATE_HASH_VERSIONING_AND_INTEGRITY.md`
- `153_SITE_DOCUMENT_INGESTION_DEMO_CONTRACT.md`
- `154_DOCUMENT_SECURITY_AND_PARSER_THREAT_MODEL.md`

Machine/executable assets:
- `DOCUMENT_INGESTION_STATE_MACHINE.json`
- `DOCUMENT_TYPE_CATALOG.json`
- `ATTACHMENT_SECURITY_POLICY.json`
- `document_ingestion_fixtures.json`
- `starter_schemas/attachment.schema.json`
- `starter_schemas/lab_extraction_candidate.schema.json`
- `starter_schemas/extraction_review_receipt.schema.json`
- `synthetic_documents/lab_report_fixture.tsv`
- `reference_code/lab_report_staging_parser.py`
- `reference_code/validate_document_ingestion_fixtures.py`


## v0.22 medication/supplement safety knowledge layer

New authoritative files:
- `155_MEDICATION_SUPPLEMENT_PRODUCT_INGREDIENT_MODEL.md`
- `156_MEDICATION_PLAN_INTAKE_AND_EXPOSURE_ENGINE.md`
- `157_INTERACTION_CONTRAINDICATION_AND_SAFETY_KNOWLEDGE_ARCHITECTURE.md`
- `158_DUPLICATE_INGREDIENT_AND_STACKING_DETECTION.md`
- `159_DRUG_SUPPLEMENT_FOOD_LAB_AND_CONDITION_INTERACTION_TAXONOMY.md`
- `160_DRUG_KNOWLEDGE_SOURCES_RXNORM_DAILYMED_OPENFDA.md`
- `161_SUPPLEMENT_KNOWLEDGE_SOURCES_DSLD_ODS.md`
- `162_MEDICATION_SAFETY_RULE_PACK_AND_FIXTURE_CONTRACT.md`
- `163_MEDICATION_SUPPLEMENT_API_UI_AND_REVIEW_CONTRACT.md`
- `164_MEDICATION_INTERACTION_GOVERNANCE_AND_CLAIM_BOUNDARIES.md`
- `165_SITE_MEDICATION_AND_SUPPLEMENT_SAFETY_LAB.md`

Machine/executable:
- `MEDICATION_SUPPLEMENT_CANONICAL_MODEL.json`
- `MEDICATION_KNOWLEDGE_SOURCE_REGISTRY.json`
- `INTERACTION_RULE_AND_ASSESSMENT_TAXONOMY.json`
- `medication_safety_fixtures.json`
- `reference_code/medication_safety_engine.py`
- `reference_code/validate_medication_safety_fixtures.py`
- four medication/safety starter JSON Schemas.


## v0.23 preventive-care layer

New authoritative files:
- `166_PREVENTIVE_CARE_CANONICAL_MODEL.md`
- `167_JURISDICTION_GUIDELINE_SOURCE_PACK_ARCHITECTURE.md`
- `168_PREVENTIVE_ELIGIBILITY_DUE_AND_OVERDUE_ENGINE.md`
- `169_VACCINATION_SERIES_CATCHUP_VALIDITY_AND_IMMUNITY.md`
- `170_SCREENING_COUNSELING_AND_PREVENTIVE_SERVICE_MODEL.md`
- `171_PREVENTIVE_SOURCE_REGISTRY_CDC_USPSTF_WHO_TURKIYE.md`
- `172_PREVENTIVE_RULE_PACK_AND_SYNTHETIC_FIXTURES.md`
- `173_PREVENTIVE_API_UI_MISSIONS_AND_NOTIFICATIONS.md`
- `174_PREVENTIVE_CARE_CLAIM_BOUNDARIES_SHARED_DECISION_AND_HARMS.md`
- `175_SITE_PREVENTIVE_CARE_LAB.md`
- `176_GUIDELINE_REFRESH_DIFF_CONFLICT_AND_RETIREMENT.md`

Machine/executable:
- `PREVENTIVE_CARE_CANONICAL_MODEL.json`
- `PREVENTIVE_CARE_SOURCE_REGISTRY.json`
- `PREVENTIVE_RULE_PACK_CATALOG.json`
- `preventive_care_fixtures.json`
- `reference_code/preventive_care_engine.py`
- `reference_code/validate_preventive_care_fixtures.py`
- five preventive JSON Schemas.

## v0.24 lab interpretation governance + identifier repair

v0.24 adds source-aware laboratory reference intervals, clinical decision-limit separation, critical/significant-risk rule governance, method/specimen comparability, delta/RCV semantics and a separate personal-baseline channel.

It also repairs historical duplicate AT/ADR/FM/phase identifiers. `IDENTIFIER_MIGRATION_MAP_v0.24.json` preserves legacy aliases; new work must use canonical repaired IDs.

No real universal laboratory reference or critical-value table is bundled by default.


---

<!-- SOURCE: 01_MASTER_PRODUCT_SPEC.md -->

# MASTER PRODUCT SPECIFICATION

## 1. Product

Name: **Longevity App**

Project identity: `longevity-app`

The name may change later without changing the product architecture.

## 2. Mission

Provide a durable personal health timeline in which users can record, inspect and compare health-related data over days, months and years.

The product should help answer questions such as:

- When did I have laboratory tests?
- How has a biomarker changed over time?
- How did I report my mood or energy on a given date?
- Which symptoms occurred and when?
- What did I eat on a given day?
- What nutrient information was available for those foods?
- How have selected measurements changed over time?

The application is a tracking and analysis platform. It must not silently convert self-report into medical diagnosis.

## 3. Product principles

### P01 General-public product
No individual person's private profile is part of application defaults.

### P02 Longitudinal first
Time is a core dimension. Important records should preserve when something occurred, was observed, collected, reported or created.

### P03 Plan is not event
A planned action is not automatically considered completed.

### P04 Self-report is not diagnosis
Subjective state, symptoms and suspected conditions must remain distinguishable from confirmed diagnoses.

### P05 Raw data is not interpretation
Canonical user data must remain separate from calculated summaries and AI output.

### P06 Missing data is not zero
Absence of a nutrient or health value must not be silently converted to zero.

### P07 History must be auditable
Important corrections should not silently erase the previous historical state.

### P08 Cross-platform account
The same user should be able to use Android, iOS and web against the same account and health record.

### P09 Offline-capable mobile experience
Core entry flows should continue working when mobile connectivity is temporarily unavailable where practical.

### P10 Privacy and ownership
The user must have meaningful control over export, deletion, account security and access to personal data.

## 4. Minimum major modules

- Today
- Health Timeline
- Laboratory Results
- Conditions
- Symptoms
- Mind Check-in
- Food Diary
- Food/Nutrient Data
- Medication & Supplements
- Vitals & Body Measurements
- Sleep
- Activity / Exercise
- Insights / Trends
- Settings / Account / Export

## 5. Platform targets

### Android
Expected final outputs:
- source code,
- installable APK for testing,
- AAB for Play distribution,
- build instructions.

### iOS
Expected final outputs:
- source code,
- Xcode-compatible project,
- signing/TestFlight documentation,
- build instructions,
- TestFlight-ready configuration when credentials are available.

### Web
Expected final outputs:
- responsive web application,
- production web build,
- deployment instructions,
- environment configuration.

## 6. Shared architecture objective

Clients should share:
- domain concepts,
- API contracts,
- authentication model,
- data semantics,
- validation rules,
- synchronization semantics.

Do not create three unrelated data models.

## 7. Non-goals unless later requested

Do not assume the first production version requires:
- a social network,
- public leaderboards,
- medical diagnosis,
- clinician prescription,
- insurance billing,
- advertising,
- gamified lifespan promises,
- a fabricated “years added to life” score.

These may only be added by a later explicit specification.


## 8. Observation + education + simulation

Longevity App is simultaneously:
- a longitudinal observation tool,
- an offline education tool,
- a deterministic comparison/simulation tool,
- a daily rule-based action planner.

## 9. No generative-AI dependency

The required product contains no generative-AI dependency.

Its core intelligence is:
- formulas,
- validated calculators,
- deterministic rules,
- local content packs,
- local model packs.

## 10. Comparison mode

Users can create arbitrary numbers of self/synthetic/scenario comparison profiles and compare compatible calculated outputs.

## 11. Safe reset

Settings can be reset to defaults independently from personal health-data deletion.

## 12. Bidirectional Longevity ↔ Shortevity

The product must model both protective/resilience/healthspan-supporting trajectories and adverse/risk/burden/function-loss trajectories.

`Shortevity` is a product umbrella term, not a universal validated clinical metric. The Results screen must not imply that a Shortevity app score directly equals years of life lost.

## 13. Human OS donor integration

The receiver incorporates all reusable Human OS methodology available in the handoff: state/event/decision continuity, provenance, corrections, effective dates, failure memory, rollback/migration, dependency propagation, capacity/recovery orchestration, evidence hierarchy, education evidence and release honesty.

The application remains its own receiver-native product.


---

<!-- SOURCE: 02_FEATURE_REQUIREMENTS.md -->

# FEATURE REQUIREMENTS

## FR-01 Account
Users can create an account, authenticate, sign out and access their own records across supported clients.

## FR-02 Today
A daily home surface summarizes available records and provides fast entry points.

Today may show:
- latest mind check-in,
- food entries,
- recent measurements,
- due or planned items when those modules exist,
- recent health events.

It must not display unobserved actions as completed.

## FR-03 Health Timeline
A chronological feed combines dated events from multiple modules while preserving original source records.

## FR-04 Laboratory Results
Users can create a lab session and enter multiple analyte results with:
- collection/test date,
- reporting date when available,
- laboratory,
- fasting state,
- analyte name/code,
- value,
- unit,
- lab-provided reference interval/text,
- flag,
- notes,
- optional attachment reference.

## FR-05 Lab Trends
The same analyte can be viewed across multiple dates.
Incompatible units cannot be naively plotted together.

## FR-06 Conditions
Users can record health conditions with explicit state:
- confirmed diagnosis,
- self-reported history,
- suspected/evaluation pending,
- resolved,
- unknown.

## FR-07 Symptoms
Users can record symptom episodes with:
- symptom,
- start time/date,
- optional end time/date,
- severity 1–10,
- associated features,
- context,
- notes.

## FR-08 Mind Check-in
Users can record 1–10 self-ratings such as:
- mood,
- anxiety,
- stress,
- energy,
- motivation,
- focus,
- social energy,
- subjective sleep quality.

These are self-report dimensions, not automatically validated clinical instruments.

## FR-09 Food Diary
Users record what they actually ate, grouped into meals or eating events.

## FR-10 Food Amounts
Entries support quantities such as grams and other units only when conversion semantics are known.

## FR-11 Food Search
The system supports food discovery via one or more external food providers.

## FR-12 Barcode
Packaged products may be found by barcode when provider data exists.

## FR-13 Manual Food
Users can create custom foods when provider data is unavailable or inappropriate.

## FR-14 Recipes
A future-ready recipe model should permit ingredients, yield and serving calculation. It may be implemented after core food logging if necessary.

## FR-15 Nutrient Matrix
For a food, display the nutrient fields actually available from its source after normalization.

Potential categories include:
- energy,
- protein,
- carbohydrates,
- sugars,
- starch,
- fiber,
- total fat,
- saturated fat,
- mono/polyunsaturated fat,
- trans fat,
- vitamins,
- minerals,
- fatty acids,
- amino acids,
- other provider-supplied composition data.

Unavailable does not mean zero.

## FR-16 Medication & Supplements
Plans and actual intake events must be separate record types.

## FR-17 Vitals & Body
Support a generic measurement model for metrics such as:
- body weight,
- waist circumference,
- resting heart rate,
- temperature,
- SpO2,
plus a structured blood-pressure record.

## FR-18 Sleep
Support sleep episodes and subjective quality.

## FR-19 Activity
Support dated activity/exercise events.

## FR-20 Trends
Where meaningful, offer ranges such as:
- 7 days,
- 30 days,
- 3 months,
- 6 months,
- 1 year,
- all time.

## FR-21 Export
Users can export their own data in machine-readable form, at minimum JSON and practical tabular CSV exports.

## FR-22 Corrections
Important health records should support correction provenance rather than silent destructive editing where practical.

## FR-23 Data deletion
Users must have a clear mechanism for deletion according to the product's data-retention design and applicable requirements.

## FR-24 Accessibility
Core interaction must support readable typography, semantic controls and keyboard/web accessibility where practical.

## FR-25 Localization-ready
Text and units should not be hard-coded so deeply that localization becomes impractical.


## FR-26 Universal Health Fact
User can enter/select/write a dated health fact even when no dedicated screen exists.

## FR-27 Vaccination
Record dated immunization events.

## FR-28 Procedures & Treatment Courses
Record procedures and multi-event treatments.

## FR-29 Oncology Treatment
Oncology Advanced supports chemotherapy/radiation/immunotherapy/targeted therapy course/cycle records.

## FR-30 Health Products
Represent medicines, supplements, creams/topicals and other products without assuming catalog presence equals use.

## FR-31 Product Use
Record actual product use separately from plan/catalog.

## FR-32 Health Module Settings
Enable/disable Advanced modules without deleting data.

## FR-33 Scoring Engine
Support versioned typed results with transparent metadata.

## FR-34 Population Longevity Baseline
Show sourced population life-expectancy/HALE baselines when available.

## FR-35 Validated Risk Models
Run specialist validated model adapters only when eligibility is satisfied.

## FR-36 App Composite Scores
Transparent 0–100 app-defined domain scores with separate coverage/confidence.

## FR-37 Lifespan Safety
Do not convert arbitrary domain improvements/products/treatments into fabricated years of life.

## FR-38 Results Dashboard
Separate baselines, validated risks, app scores, coverage and experimental outputs.

## FR-39 Model Transparency
Expose model/version/inputs/source/limitations.

## FR-40 Historical Reproducibility
Preserve model version and input references for historical calculated results.


## FR-41 Comparison Profiles
User can create multiple SELF/REAL_OTHER/SYNTHETIC/SCENARIO profiles for deterministic comparison.

## FR-42 Scenario Clone
A profile can be cloned into a non-destructive scenario and independently modified.

## FR-43 Multi-profile Comparison
Compatible metrics/results can be compared side by side across an arbitrary list of profiles.

## FR-44 Comparison Eligibility
Ineligible model outputs remain NOT_ELIGIBLE instead of being fabricated for comparison symmetry.

## FR-45 Settings Reset
User can reset settings to defaults without deleting health records.

## FR-46 Module Reset
An individual Advanced module's settings can be reset independently.

## FR-47 Daily Missions
App generates deterministic day-specific missions from state/goals/history/rule packs.

## FR-48 Training Prescription
Rule-based training engine can create planned set/rep/load targets from an explicit program and prior completion data.

## FR-49 Mission Safety Gate
Active safety/contraindication flags can block or modify applicable missions according to explicit rules.

## FR-50 Offline Education
Installed lessons, quizzes and review scheduling work offline.

## FR-51 Contextual Education
Entered/imported data can deterministically trigger relevant educational cards.

## FR-52 Android Health Connect
With user permission, Android client can import supported Health Connect data.

## FR-53 Apple HealthKit
With user permission, iOS client can import supported HealthKit data.

## FR-54 Wearable Provenance
Imported wearable/health-store data retains platform/source/time/unit provenance and deduplication identity.

## FR-55 No-AI Offline Core
All required calculations, comparison, missions and installed education function without generative AI or network connectivity.

## FR-56 Longevity/Shortevity Dual Axis
Results distinguish protective/resilience signals from adverse/risk/burden signals.

## FR-57 Burden Score
App-defined domains may expose a transparent Burden Score separate from validated clinical risk.

## FR-58 Protection Score
App-defined domains may expose a transparent Protection/Resilience Score.

## FR-59 Function/Capacity Channel
Function/capacity can be tracked independently from disease risk.

## FR-60 Balance Visualization
A domain may visualize Protection minus Burden only as an app-defined balance, not life expectancy.

## FR-61 Trajectory
Domains can deterministically classify IMPROVING/STABLE/WORSENING/MIXED/INSUFFICIENT_DATA.

## FR-62 Cumulative Exposure
Appropriate domains can accumulate exposure using explicit domain units/formulas.

## FR-63 Causal/Evidence Graph
Results can trace observations/interventions/models/evidence without automatically inferring causation.

## FR-64 Treatment Burden
Treatment courses can record transient/persistent adverse burden and recovery separately from treatment efficacy.

## FR-65 Early Warning Rules
Versioned deterministic rules can detect configured worsening/recurrent/missing-follow-up patterns without diagnosing.

## FR-66 State/Event/Decision Continuity
Canonical current state, historical events and decision/config history remain separately recoverable.

## FR-67 Effective-Date Rules
Rule/model/default changes preserve effective dates and historical versions.

## FR-68 Dependency Recalculation
Corrections invalidate and recalculate affected derived outputs without rewriting unrelated raw history.

## FR-69 Human OS Donor Traceability
Transferred Human OS capabilities are explicitly mapped to receiver modules with exclusions/unknowns.

## FR-70 Recovery-Aware Orchestration
Daily Missions account for configured recovery/treatment/capacity state without interpreting missed tasks as automatic failure.


## FR-71 Life Course
The app represents health events across a whole-life chronology without inventing missing history.

## FR-72 Episode of Care
Related conditions, treatments, labs, symptoms and recovery events can be grouped into an EpisodeOfCare.

## FR-73 Biological Age Models
Multiple versioned biological-aging models can be calculated when eligible without being averaged into a fake universal age.

## FR-74 Functional Health
Function/capacity measurements are first-class healthspan data.

## FR-75 Quality of Life
Validated or transparent app-defined quality-of-life measures can be tracked separately from lifespan.

## FR-76 Pain
Pain can be tracked longitudinally with intensity, interference, location and treatment context.

## FR-77 Rehabilitation
Rehabilitation plans and actual sessions are separate and support recovery trajectories.

## FR-78 Multimorbidity
Multiple simultaneous conditions can be represented without collapsing burden to condition count.

## FR-79 Medication/Supplement Interaction Graph
Versioned interaction rules can connect medicines, supplements, conditions and monitoring requirements.

## FR-80 Environmental Exposures
Environmental/occupational exposures can be recorded with duration/intensity/source.

## FR-81 Social Context
Optional social/access/function context can inform mission feasibility and app-defined context without moral judgment.

## FR-82 Clinical Semantics
Canonical records may carry standardized codes while retaining original user/source wording.

## FR-83 Interoperability Adapters
Architecture supports standards/provider adapters without making the internal model dependent on one external format.

## FR-84 Digital Twin
A deterministic current-state Twin can be projected from canonical data and model versions.

## FR-85 Scenario Patch
Scenario changes modify the Twin without mutating canonical observations.

## FR-86 Scenario Evidence Labels
Scenario output distinguishes pure mathematical recalculation, validated model recalculation and evidence-supported intervention estimates.

## FR-87 Personal Baseline
The app can calculate versioned personal baselines/reference bands distinct from clinical reference ranges.

## FR-88 Anomaly Detection
Deterministic anomaly detection can flag deviation from a personal baseline without diagnosing.

## FR-89 Forecast
Versioned deterministic forecasts expose horizon, method and uncertainty and refuse insufficient data.

## FR-90 Portable Full-State Export
A full portable bundle preserves health data, provenance, corrections, model/rule versions and reproducible project-independent state.


## FR-91 Data Quality Profile
Canonical records and derived results can expose provenance, quality, conflict and missingness semantics.

## FR-92 Precision Preservation
Source precision is preserved and the UI does not fabricate extra measurement precision.

## FR-93 Canonical Units
Numeric health quantities can carry canonical machine-readable unit codes while preserving source units.

## FR-94 Safe Conversion
Unit conversions occur only when quantity compatibility and required context are known.

## FR-95 Device Registry
Measurements can retain device/calibration/source context.

## FR-96 Repeated Measurement Sessions
Multiple readings in one measurement session can be preserved and summarized only by explicit protocol.

## FR-97 Model Governance
Every calculation model has registry status, eligibility, validation metadata, intended/prohibited use and version.

## FR-98 Model Golden Fixtures
Deterministic mathematical models have reference fixtures verifying implementation arithmetic.

## FR-99 Model Retirement
Retired models remain interpretable for historical results and are blocked from new production calculations unless explicitly permitted.

## FR-100 Rule Governance
Daily mission/safety/education/interaction rules are versioned with explicit precedence and conflict behavior.

## FR-101 Benchmark Datasets
Population comparisons identify dataset, population, geography, period and applicability.

## FR-102 Consent & Access
Optional integrations/sharing can be represented by revocable purpose/data-category scoped consent.

## FR-103 Audit Ledger
Security-sensitive access/export/integration actions can be recorded without duplicating unnecessary health payloads.

## FR-104 Local-only Profile
A profile can operate without cloud sync while retaining deterministic offline functionality.

## FR-105 Personal Experiment
Users can define low-risk personal observational experiments with baseline/intervention/follow-up and explicit causal limitations.

## FR-106 Import Staging
Uncertain imported data can be staged before canonical commit.

## FR-107 Import Batch Receipt
Imports produce deterministic receipts with counts of committed/duplicate/conflict/failure records.

## FR-108 Offline Pack Updates
Model/rule/reference/education packs have versioned manifests, checksums, compatibility checks and rollback.

## FR-109 Dense Time Series
Wearable high-frequency data can be stored/aggregated efficiently while preserving provenance.

## FR-110 Standards Register
Technical standards used by the implementation are versioned, source-linked and re-verified at build time.


## FR-111 Secure Local Key Management
Sensitive local encryption/token keys use platform-appropriate secure key facilities rather than hard-coded secrets.

## FR-112 App Lock
Optional app lock can use platform authentication without replacing server authorization.

## FR-113 Session & Device Registry
Cloud accounts can view/revoke sessions/devices.

## FR-114 Local-to-Cloud Migration
Local-only profile can migrate to cloud with staged upload, deduplication and verification.

## FR-115 Reminder Scheduler
One-time/recurring reminders can be scheduled locally when platform capabilities permit.

## FR-116 Reminder ≠ Completion
Notification delivery/open/snooze never counts as health/task completion without a completion event.

## FR-117 Timezone-safe Scheduling
Reminder semantics explicitly distinguish local-clock schedules from fixed instants.

## FR-118 Accessibility
Core product targets accessible operation including text scaling, semantics, keyboard web flow and non-color-only meaning.

## FR-119 Aging-friendly Display
Optional large/high-contrast/simplified display preset can be enabled without changing health data.

## FR-120 Localization
User-visible text, dates, numbers and units are locale-aware and not embedded in domain logic.

## FR-121 Turkish & English Ready
Initial architecture supports Turkish and English language packs.

## FR-122 Clinician Report
User can generate a scoped read-only health report by section/date range.

## FR-123 Controlled Sharing
Share links/artifacts, if implemented, are revocable/scoped/expiring where applicable.

## FR-124 Privacy-first Observability
Crash/telemetry systems minimize sensitive health payloads.

## FR-125 Crash Recovery
Interrupted writes/imports/updates recover deterministically from transactional state.

## FR-126 Support Bundle
User can create a sanitized support bundle containing technical state without health payload by default.

## FR-127 Environment Separation
Dev/test/staging/production credentials and data are separated.

## FR-128 Release Provenance
Production release record ties source/build/backend/schema/model/rule/content versions together.

## FR-129 Threat-model Release Gate
Unresolved high-risk authorization/secret-leak findings block production release.

## FR-130 Claim Control
User-facing/marketing medical or longevity claims are registered and reviewed against actual evidence/product scope.


## FR-131 Reference Architecture
Handoff provides a concrete replaceable reference architecture while preserving normative product semantics.

## FR-132 Screen State Machines
Major screens explicitly define loading/empty/offline/stale/validation/conflict/permission/error behavior.

## FR-133 Stable Timeline Ordering
Timeline pagination uses deterministic ordering and stable tie-breakers.

## FR-134 Migration Fixtures
Every meaningful persisted-schema migration has representative pre/post fixtures and invariant assertions.

## FR-135 Migration Failure Safety
Failed migration does not mark schema current or leave silent partial success.

## FR-136 Canonical API Errors
Backend modules use consistent machine-readable error semantics.

## FR-137 Cursor Pagination
Large histories support stable cursor pagination.

## FR-138 Idempotent Mutation
Retry-prone creates/imports/sync mutations can be safely retried without duplication.

## FR-139 Optimistic Concurrency
Mutable server resources use revision/conflict semantics instead of silent overwrite.

## FR-140 Synthetic Data Generator
Tests can generate deterministic synthetic health histories from seeds without real-user data.

## FR-141 Failure Injection
Synthetic test infrastructure can inject timeout, duplicate, conflict, corruption and permission-denial conditions.

## FR-142 Performance Budgets
Release testing records performance against explicit reference budgets and dataset scales.

## FR-143 Dense-Series Scale Fixture
Performance suite includes at least one million synthetic time-series samples.

## FR-144 Comparison Scale Fixture
Comparison performance suite includes at least 20 profiles and 25 metrics.

## FR-145 End-to-End Reference Scenarios
Release testing contains coherent cross-module E2E scenarios, not only isolated unit tests.

## FR-146 Test Pyramid
CI separates static/unit/database/API/component/integration/E2E/platform/security/performance layers.

## FR-147 Flaky Test Governance
Flaky tests are tracked explicitly and cannot satisfy release-critical gates while quarantined.

## FR-148 Machine-readable Test Evidence
CI produces test evidence tied to commit/build/environment/test IDs.

## FR-149 Implementation Agent Protocol
Future coding agents follow a defined ingest→environment→architecture→vertical-slice→test→build→package execution protocol.

## FR-150 No Mock Completion
Mocks/stubs/screenshots cannot satisfy production completion until the real persistence/API/model path exists.


## FR-151 Component Contracts
Reusable health UI components define explicit states, semantics, accessibility and error behavior.

## FR-152 Typed Result Presentation
UI visually distinguishes validated risk, population baseline, app composite, burden/protection and experimental results.

## FR-153 Provenance Drilldown
Important observations/results can show source, unit conversion, correction and device/provider provenance.

## FR-154 Conflict Resolution UI
Sync/semantic conflicts preserve both versions and expose deterministic resolution paths.

## FR-155 Module Ownership
Each canonical entity has one authoritative owning module; other modules use contracts/projections.

## FR-156 Dependency Invalidation Graph
Corrections invalidate only declared dependent derived outputs rather than unrelated history.

## FR-157 Repository Bootstrap Contract
Implementation begins from a reproducible workspace with runnable client/backend/database/test shells.

## FR-158 Generated Contract Reproducibility
Generated OpenAPI/client/schema artifacts are reproducible from authoritative sources.

## FR-159 Resource Validation Schemas
Core API resources encode semantic constraints such as rating bounds, units, enum status and immutable snapshots.

## FR-160 Breaking API Change Detection
Release process detects and reviews breaking OpenAPI/schema changes.

## FR-161 Named Fixture Library
Test suite includes versioned named synthetic profiles spanning empty/basic/complex/conflict/restore/accessibility states.

## FR-162 Golden and Fuzz Separation
Stable golden fixtures are separated from property/fuzz generators; failing fuzz seeds are reproducible.

## FR-163 Disaster Recovery Drills
Data recovery is validated through explicit corruption/migration/restore/import/pack/session/key-loss drills.

## FR-164 Restore Integrity Verification
Restore verifies identity, corrections, tombstones, external IDs, model versions and checksums.

## FR-165 Sync Chaos Simulator
Sync tests can reproduce latency, timeout, duplicate, stale revision, clock skew and tombstone conflict conditions.

## FR-166 Semantic Correction Conflict
Independent competing corrections are surfaced as semantic conflict rather than resolved only by timestamp.

## FR-167 Stable Error Catalog
Machine error codes map to retryability, saved-state semantics and safe recovery actions.

## FR-168 Health Calculation Failure Safety
A failed calculation never silently substitutes zero/normal-looking output.

## FR-169 Release Artifact Layout
Final implementation delivery follows a predictable package layout with source/build/contracts/tests/docs/evidence.

## FR-170 Bootstrap Exit Gate
Broad feature development does not begin until foundation vertical slice, persistence, sync idempotency and authorization tests pass.


## FR-171 Domain API Catalog
Every major domain has an explicit owned-resource/API/validation/sync/error contract.

## FR-172 CRUD Ownership Matrix
Canonical resource create/update/correct/delete operations identify one owner module and projection consumers.

## FR-173 Query Semantics
Longitudinal queries define stable date boundaries, sorting, pagination and filter validation.

## FR-174 Search Projection Safety
Search indexes/projections update after correction/deletion and never become canonical health authority.

## FR-175 Responsive Layout Contract
Core screens have compact/medium/expanded behavior rather than a stretched single layout.

## FR-176 Density Modes
Comfortable, compact-data and aging-friendly display modes can change density without changing health semantics.

## FR-177 Result Visual Typing
Responsive Results layout preserves result-class labels and does not visually promote app composites over validated risk by ambiguity.

## FR-178 Retention Matrix
Each major data class has documented hide/archive/delete/tombstone/derived-invalidation semantics.

## FR-179 Tombstone Propagation
Synchronized deletion prevents stale-device resurrection and updates dependent projections.

## FR-180 Account Deletion State Machine
Account deletion exposes explicit workflow states and cannot report complete while accessible in-scope data remain outside documented exceptions.

## FR-181 Third-party Deletion Scope
Deleting imported local data clearly distinguishes local deletion from deletion at external providers.

## FR-182 Domain Events
Cross-module reactions use typed domain events with stable IDs/revisions and minimal sensitive payload.

## FR-183 Idempotent Event Consumers
Duplicate domain-event delivery cannot duplicate derived/projection effects.

## FR-184 Derived Projection Rebuild
Timeline/search/derived projections are rebuildable from canonical records and versioned policy where practical.

## FR-185 Capability Degradation
Denied/unavailable optional platform capability has an explicit safe fallback and never fabricates data/success.

## FR-186 Clinically Safe Offline Degradation
Loss of network/cloud/provider access preserves available local truth and clearly marks freshness/limitations.

## FR-187 Production Acceptance Dossier
Production readiness is supported by a structured evidence dossier rather than prose-only signoff.

## FR-188 Evidence-linked Release State
PASS/FAIL/BLOCKED/NOT_RUN states reference concrete reports/artifacts/commands and are platform-scoped.

## FR-189 Release-blocker Propagation
Release-critical failures automatically prevent aggregate production-ready status.

## FR-190 Screen Visual Blueprint
Core screens have implementation wireframe contracts covering primary task/action, destructive action, errors, accessibility and responsive behavior.


## FR-191 Interactive Site Lab Artifact
A separate Site/Web-App build prompt exists for a functional interactive Human Health OS laboratory.

## FR-192 Site Is Not Marketing-only
The Site output must contain working configurator/simulation interactions rather than only static marketing content.

## FR-193 Synthetic-first Demo
Public/unauthenticated Site defaults to clearly labeled synthetic data and does not require real health data.

## FR-194 Deterministic Site Calculations
Site calculations use deterministic rules/models and preserve the core health-semantics invariants.

## FR-195 Site Compare Lab
The Site supports 3+ comparison profiles/scenarios and non-destructive scenario cloning.

## FR-196 Site Reset Defaults
The Site exposes Reset Demo to Defaults without confusing it with deletion of real health history.

## FR-197 Site Responsive & Accessible
The Site provides responsive mobile/desktop behavior and accessible primary interactions.

## FR-198 Site Transparency
Result cards expose model/rule/version/input/coverage/limitations information.

## FR-199 Site Delivery Artifact
Site-building workflow returns source, lockfile, run/build instructions and a deployable or publishable artifact when environment permits.

## FR-200 Site/Product Semantic Parity
The Site may simplify scope but must not contradict the Master Handoff's hard semantic rules.


## FR-201 Starter Model Catalog
The handoff includes an initial model catalog separating app-owned derived calculations, app composites, external validated candidates and research-only models.

## FR-202 Core Derived Pack
Transparent calculations such as BMI, waist-height ratio, pack-years, deltas and deterministic trend helpers can be executed from a versioned local starter pack.

## FR-203 External Model License Gate
A third-party clinical model cannot become ACTIVE when required source-code/license acceptance is absent.

## FR-204 No Fake External Calculator
An unavailable external clinical model never returns fabricated clinical percentages in app or Site demo.

## FR-205 Starter Rule Catalog
Core product invariants are distributed as a versioned deterministic rule pack.

## FR-206 Rule Pack Traceability
A generated/blocked action can identify the rule pack, rule ID and version that caused it.

## FR-207 Starter Reference Catalog
WHO, USDA FDC, Open Food Facts, UCUM, HL7 FHIR and synthetic demo references have explicit integration and licensing dispositions.

## FR-208 Synthetic Demo Reference Pack
Public Site Lab can run from a bundled synthetic reference pack without real user data.

## FR-209 Health Literacy Education Pack
A bundled offline starter curriculum teaches measurement, provenance, units, risk, causality, scenarios and healthspan/lifespan distinctions.

## FR-210 Education Semantic Boundary
Lesson view/quiz/XP does not directly change canonical health state or clinical risk.

## FR-211 Third-party License Matrix
External datasets/models/standards have a checked-date license/attribution disposition in the handoff.

## FR-212 Attribution Surface
Production app/Site can expose active external data/model sources and required attribution/notice.

## FR-213 License-blocked Pack State
A pack with unresolved mandatory license/redistribution terms is BLOCKED_LICENSE rather than silently activated.

## FR-214 Executable JSON Schema Starter
The handoff includes machine-validatable JSON Schema starter files for core entities.

## FR-215 Schema Versioning
Starter schema IDs/versions are explicit and changes require migration/compatibility review.

## FR-216 Schema Missingness Safety
Executable schemas allow missing/null states without forcing numeric zero.

## FR-217 Pack Activation Fixtures
Model/rule/reference/education packs have fixture classes required before activation.

## FR-218 Active Pack Set Reproducibility
Calculated results can identify the relevant model/rule/reference pack versions.

## FR-219 Site Starter Pack
Interactive Site Lab has a defined synthetic profile, education and core-derived calculation starter set.

## FR-220 Site Third-party Safety
Site cannot expose secret provider keys or fake a blocked licensed clinical model.


## FR-221 Golden Vector Catalog
App-owned deterministic calculations have exact versioned input/output reference vectors.

## FR-222 Executable Reference Formula Engine
The handoff includes a runnable reference implementation for app-owned core-derived formulas.

## FR-223 Golden Error Vectors
Invalid mathematical inputs have explicit expected error codes rather than fake outputs.

## FR-224 SQLite Reference DDL
The handoff contains an executable local SQLite kernel schema with foreign keys, constraints and indexes.

## FR-225 PostgreSQL Reference DDL
The handoff contains a server PostgreSQL schema blueprint with equivalent core semantics.

## FR-226 Database Ownership Constraints
Private canonical health records carry profile ownership keys and stable identities.

## FR-227 Lab Missingness Constraint
A numeric lab result marked PRESENT requires a numeric value while non-present states may remain null.

## FR-228 Outbox Idempotency Constraint
Sync mutation IDs are unique.

## FR-229 Seed Safety
Reference seed data are synthetic/configuration data and do not become real-user health defaults.

## FR-230 Idempotent Demo Seed
The synthetic SQLite demo seed can be re-run without duplicating fixed demo identities.

## FR-231 Canonical Data Dictionary
Core time/source/model/rule/coverage field meanings are defined once and reused across modules.

## FR-232 Zero-Knowledge Onboarding
First-run education assumes no prior medical/statistical/app knowledge.

## FR-233 Local-only First-run Choice
Onboarding presents local-only and cloud modes without treating local-only as a broken demo.

## FR-234 Results Literacy
Onboarding/help explains raw fact, derived measurement, validated risk and app-defined score as different result classes.

## FR-235 Help for Non-eligibility
The UI can explain why a model is NOT_ELIGIBLE/MISSING_INPUTS without inventing output.

## FR-236 Clinician Export Example
The handoff contains a synthetic clinician report example preserving source/provenance and derived-result labels.

## FR-237 Portable Export Example
The handoff contains a synthetic portable-export example preserving pack/model/rule version metadata.

## FR-238 Attribution Manifest
Third-party sources/licenses are renderable from a machine-readable manifest.

## FR-239 Generated Data Sources Page
A reference generator can produce a Data Sources & Licenses page from the attribution manifest.

## FR-240 Attribution Release Gate
An active third-party source requiring notice/attribution cannot pass release when required attribution metadata are absent.

## FR-241 Transactional Canonical Write
Canonical writes commit before dependency invalidation/recalculation is published.

## FR-242 Derived Result Invalidation
Corrections can invalidate affected derived results while preserving historical result snapshots.

## FR-243 Stale Result State
Known-stale calculated results are labeled stale/pending rather than presented as freshly calculated.

## FR-244 SQLite/Postgres Semantic Parity
Local and server schemas preserve equivalent identity, provenance, missingness, correction and tombstone semantics.

## FR-245 PostgreSQL Runtime Evidence Honesty
PostgreSQL DDL remains NOT_RUN until executed against a real PostgreSQL runtime.


## FR-246 Ordered Migration Chain
Local and server schemas have ordered append-only migration assets rather than only a final DDL snapshot.

## FR-247 SQLite Migration Versioning
Local migration chain advances an explicit schema version and refuses partially migrated current state.

## FR-248 Upgrade Preservation
Supported migration upgrades preserve pre-existing canonical fixture data and identity.

## FR-249 Migration/Seed Separation
Synthetic demo seed failures are not treated as schema migration failures.

## FR-250 PostgreSQL Migration Honesty
PostgreSQL migration runtime remains NOT_RUN until executed against a real PostgreSQL instance.

## FR-251 Server-side Ownership Authorization
Private health resources are authorized server-side from trusted authenticated identity rather than client-supplied owner IDs.

## FR-252 Row-level Security Blueprint
PostgreSQL reference includes defense-in-depth row policies tied to profile ownership.

## FR-253 Cross-user Denial
User A cannot read/write User B private health resources by guessing identifiers.

## FR-254 Application Role Separation
Ordinary API traffic is not designed to run as database superuser/owner.

## FR-255 Authorization Golden Vectors
Owner/non-owner/unauthenticated access semantics have executable golden vectors.

## FR-256 Executable Repository Scaffold
The handoff contains a repository bootstrap separating API, client, site, contracts, domain and persistence concerns.

## FR-257 One-command Contract Verification
Repository scaffold includes a verification runner that fails nonzero on contract failures.

## FR-258 Migration Verification Runner
Verification runner executes fresh and upgrade SQLite migration paths.

## FR-259 FHIR Mapping Catalog
Internal canonical entities have explicit FHIR-style reference mappings without making FHIR the canonical schema.

## FR-260 Synthetic FHIR Bundle Example
The handoff contains a synthetic FHIR-style export example with source IDs and no real user data.

## FR-261 FHIR Validation Evidence Boundary
FHIR example cannot be labeled production-valid until an appropriate official/compatible validator is actually run.

## FR-262 Terminology License Firewall
FHIR support does not automatically license third-party terminology content.

## FR-263 Missing FHIR Value Safety
Missing laboratory data are never exported as numeric zero merely to satisfy a resource shape.

## FR-264 App-score Interoperability Label
App-defined scores, if exported, are explicitly app-specific and not disguised as laboratory observations.

## FR-265 Trusted Request User Context
Database RLS user context is set from authenticated server state, not directly from untrusted request payload.

## FR-266 RLS Coverage Matrix
Every private server resource has an explicit RLS/application-authorization disposition.

## FR-267 Connection-pool Context Safety
Production server design must reset/request-scope authorization context across pooled database connections.

## FR-268 Scaffold Placeholder Boundary
Repository placeholder files do not count as implemented features.

## FR-269 Contract Runner Prompt Presence
Verification checks both production-app and Site build prompts remain present.

## FR-270 Migration/RLS Release Evidence
Production release requires real runtime evidence for server migrations/RLS instead of static SQL presence alone.


## FR-271 OpenAPI Starter
The handoff contains a machine-readable OpenAPI 3.1 starter document for representative production API operations.

## FR-272 Unique Operation IDs
Every documented operation has a unique stable operationId.

## FR-273 Endpoint Authorization Matrix
Every private API operation has an explicit authorization class and profile-ownership requirement.

## FR-274 URL ID Is Not Authorization
A profile/resource identifier supplied by the client is never treated as proof of ownership.

## FR-275 API Idempotency Declaration
Mutation endpoints explicitly declare whether idempotency identity is required.

## FR-276 API Revision Declaration
Mutable endpoints explicitly declare revision/concurrency requirements.

## FR-277 Stable Error Catalog
API machine errors use a versioned catalog with retry semantics.

## FR-278 Idempotency Key Mismatch
Reusing an idempotency key for a materially different request returns a conflict instead of silently accepting it.

## FR-279 Request Correlation ID
API errors/responses can expose a sanitized request ID for support diagnostics.

## FR-280 OpenAPI Contract Validator
Repository scaffold can validate operation IDs, authorization coverage and schema references.

## FR-281 Migration Rollback Drill
SQLite migration recovery includes an executable deliberate-failure rollback drill.

## FR-282 Rollback Preserves Existing Data
Failed migration drill leaves pre-existing canonical fixture intact.

## FR-283 Rollback Preserves Schema Version
Failed migration drill does not advance local schema version.

## FR-284 Seed Failure Isolation
Synthetic seed failure does not invalidate a successful schema migration.

## FR-285 UI Design Tokens
Spacing, typography, radius, motion, breakpoints and semantic color roles are machine-readable.

## FR-286 Health Semantic Colors
Protection/burden/function/confidence have semantic roles while meaning remains available without color.

## FR-287 Component State Vocabulary
Core UI components share explicit loading/ready/empty/offline/stale/conflict/error state semantics.

## FR-288 Missing Metric Rendering
Missing/unknown MetricCard state cannot visually default to numeric zero.

## FR-289 Result Class Visibility
ResultCard visibly identifies validated risk, app composite, population baseline or derived measurement class.

## FR-290 Chart Semantic Contract
Charts expose units/range/text summary and do not fabricate continuity across missing intervals.

## FR-291 Conflict Resolver Transparency
Canonical-data conflicts expose source/time/revision rather than resolving randomly.

## FR-292 UI Contract Validator
Repository verification can validate design-token and component-state invariants.

## FR-293 Delivery Checklist Automation
Build agent has a machine-readable evidence checklist across source/tests/builds/security/accessibility/release artifacts.

## FR-294 Production Ready Truth Table
PRODUCTION_READY is false while any mandatory evidence group is FAIL, BLOCKED or NOT_RUN.

## FR-295 Site Build Prompt Continuity
Interactive Site Build Prompt remains a required standalone release output and shares API-independent UI semantics/golden calculations.


## FR-296 Health Platform Adapter Boundary
Apple HealthKit and Android Health Connect are adapters into the canonical model, not canonical storage authorities.

## FR-297 Platform Provenance Preservation
Imported health records preserve provider/source IDs, source app/device, original time/unit and adapter mapping version when available.

## FR-298 Provider Stable-ID Deduplication
Repeated import of the same provider stable record ID does not create duplicate canonical records.

## FR-299 Distinct-device Preservation
Different source devices can produce separate legitimate measurements even at the same timestamp/value.

## FR-300 Write-back Echo Prevention
Any future platform write-back must prevent app-authored records from re-importing as duplicates.

## FR-301 Health Connect Fine-grained Permissions
Android adapter requests only Health Connect data-type permissions required by product features.

## FR-302 Health Connect Historical/Background Permission Separation
Additional Health Connect history/background read access is treated as separate capability/permission when required.

## FR-303 Health Connect Recording Method Provenance
Health Connect recording-method metadata is preserved as canonical provenance when available.

## FR-304 HealthKit Fine-grained Type Permissions
Apple adapter requests only HealthKit types needed for the active feature.

## FR-305 HealthKit Empty-query Privacy Safety
An empty HealthKit query is not interpreted as proof of granted read permission or absence of health data.

## FR-306 HealthKit Limited-history Coverage
Limited authorized history can reduce coverage without converting unavailable history to zero.

## FR-307 Manual Fallback
Health platform unavailability/permission denial does not disable manual deterministic core.

## FR-308 Platform-import Offline Persistence
Previously imported canonical records remain available offline.

## FR-309 Platform SDK Runtime Evidence Boundary
Health Connect/HealthKit production integration remains NOT_RUN until tested in supported platform runtime/device environments.

## FR-310 Nutrition Mass Scaling
Nutrients can scale deterministically from reference mass to consumed mass.

## FR-311 Recipe Nutrient Summation
Recipe totals are deterministic sums of ingredient nutrient snapshots.

## FR-312 Recipe Portion Math
Recipe can calculate per-serving/per-gram values only when serving count/final mass is valid.

## FR-313 Missing Nutrient Propagation
Missing provider nutrient is not silently converted to zero in recipe/daily coverage.

## FR-314 Volume-to-mass Safety
mL↔g conversion requires density or an explicit provider/user measure mapping.

## FR-315 Recipe Snapshot Immutability
Historical logged meal retains the exact recipe/food nutrient snapshot used at log time.

## FR-316 Recipe Versioning
Editing a recipe creates a new version for future logs rather than rewriting historical meals.

## FR-317 Calculation-vs-display Precision
Nutrition calculations preserve internal precision and round only for display/export policy.

## FR-318 Nutrition Golden Vectors
Nutrition/recipe arithmetic has executable deterministic reference vectors.

## FR-319 Health Adapter Fixtures
Platform canonicalization/deduplication semantics have executable reference fixtures.

## FR-320 Domain API Coverage Matrix
Every major product domain has an explicit API/local-only/future coverage state.

## FR-321 Expanded OpenAPI Labs
OpenAPI starter includes lab collection operations.

## FR-322 Expanded OpenAPI Nutrition
OpenAPI starter includes nutrition-log collection operations.

## FR-323 Expanded OpenAPI Core Health Domains
OpenAPI starter includes conditions, symptoms, vitals, medication plans, sleep and activity collection operations.

## FR-324 Wearable Import API Receipt
OpenAPI includes a private owner-authorized idempotent wearable-import receipt operation.

## FR-325 Provider Overlap Safety
Steps/sleep/heart-rate provider overlap is resolved by explicit domain policy rather than blind summation/deduplication.


## FR-326 Attachment Source Entity
Health documents/photos are stored as versioned source attachments distinct from canonical health facts.

## FR-327 Secure Attachment Storage
Cloud attachment bytes use private authorized storage; no public bucket/container is required by default architecture.

## FR-328 Upload Quarantine
Cloud-uploaded files remain quarantined until configured type/security checks permit parsing/preview.

## FR-329 MIME and Signature Validation
Declared filename/MIME is not trusted as sole file-type evidence.

## FR-330 Configurable File Limits
Attachment ingestion enforces configurable supported-type and byte-size limits.

## FR-331 Parser Least Privilege
Document parser workers do not receive broad unrelated health-data write authority.

## FR-332 Content Hash Integrity
Attachment version stores a strong content checksum and upload receipt verifies content integrity.

## FR-333 Per-user Duplicate Detection
Exact same-profile/account content hash can surface a duplicate warning without disclosing cross-user hash matches.

## FR-334 Attachment Version Immutability
Replacing/correcting a file creates a new AttachmentVersion instead of mutating a source version referenced by health records.

## FR-335 EXIF Privacy
Image derivatives/shares strip unnecessary hidden metadata by default while original provenance policy remains explicit.

## FR-336 Document Type Catalog
Documents/photos have explicit type classification controlling parser/linking workflows without asserting medical truth.

## FR-337 Extraction Candidate Staging
Text/OCR/parser output becomes staged candidate data, not canonical health data.

## FR-338 Candidate Review Gate
Canonical structured records require accepted reviewed candidates or an explicitly approved deterministic review path.

## FR-339 Extraction Commit Receipt
Candidate commit creates an immutable receipt linking source version, decisions and created canonical record IDs.

## FR-340 Lab Extraction Fields
Lab candidate can preserve raw label/value/unit/reference/source flag/date and mapping state.

## FR-341 Unmapped Candidate Safety
Unknown analyte labels remain UNMAPPED/AMBIGUOUS rather than guessed into a canonical concept.

## FR-342 Missing Unit Safety
Missing lab unit remains missing unless an explicit safe mapping supplies it.

## FR-343 Source Reference Interval Preservation
Report-provided reference interval/text is preserved and is not replaced by an invented global app range.

## FR-344 Partial Candidate Commit
User can accept a subset of candidates without forcing rejected/ambiguous rows into canonical data.

## FR-345 Attachment Delete/Facts Separation
Deleting source bytes and deleting reviewed canonical facts are separate explicit operations.

## FR-346 Local-only Attachments
Local-only profiles can attach supported documents without cloud upload.

## FR-347 Attachment API Coverage
OpenAPI exposes owner-authorized attachment metadata/upload/extraction/review operations.

## FR-348 Upload Idempotency
Retrying a completed upload session does not create duplicate attachment versions.

## FR-349 Attachment Download Authorization
Binary preview/download requires server authorization or an appropriately scoped short-lived token.

## FR-350 Photo Metadata Boundary
Health/body/skin photos can store user-supplied body-region/context metadata without image-based diagnosis inference.

## FR-351 Timeline Document Linking
Documents can link to Timeline/health entities while preserving document date vs upload date.

## FR-352 Deterministic Offline Extraction Baseline
Core document flow does not require generative AI; text-layer/local deterministic parsing/OCR can be used when available.

## FR-353 Parser Confidence Boundary
Extraction confidence/quality metadata is not a diagnosis and cannot bypass review gates.

## FR-354 Document Ingestion Fixtures
Handoff contains executable synthetic fixtures validating hash, security-state and candidate-staging semantics.

## FR-355 Site Synthetic Document Demo
Interactive Site Build Prompt supports a synthetic document→candidate→review→commit demo without private real documents.


## FR-356 Medication Product/Ingredient Separation
Marketed product identity is separate from normalized ingredient identity.

## FR-357 Medication Plan vs Intake
Medication/supplement plan never implies actual intake.

## FR-358 Intake Event Snapshot
Actual intake stores historical product/ingredient snapshot and provenance.

## FR-359 Supplement Multi-ingredient Composition
One supplement product can map to multiple ingredient concepts with independent amounts/bases.

## FR-360 Ingredient Normalization States
Ingredient mapping explicitly distinguishes exact, reviewed, ambiguous, unmapped and unknown states.

## FR-361 Active-moiety/Elemental Basis Safety
Different chemical/elemental amount bases are not silently summed.

## FR-362 Route-aware Exposure
Oral/topical/inhaled/injected exposures are not treated as automatically equivalent.

## FR-363 Planned vs Observed Exposure
Planned exposure and observed intake exposure remain separate derived channels.

## FR-364 RxNorm Identity Adapter
Drug identity normalization can use versioned RxNorm/RxNav identifiers without making RxNorm an interaction database.

## FR-365 DailyMed Versioned Label Adapter
Medication label evidence retains DailyMed SPL set/version provenance.

## FR-366 openFDA Evidence Boundary
openFDA labeling is retrieval/support evidence and is not the sole unreviewed clinical safety-rule engine.

## FR-367 DSLD Supplement Label Adapter
Supplement product composition can retain DSLD label/version provenance.

## FR-368 ODS Supplement Evidence Adapter
ODS fact sheets can support curated supplement safety/interaction knowledge items.

## FR-369 Safety Knowledge Rule Lifecycle
Interaction/contraindication/precaution rules have explicit review/activation/deprecation states.

## FR-370 Safety Rule Provenance
Every active safety rule identifies source and source version.

## FR-371 Interaction Type Taxonomy
Engine distinguishes drug-drug, drug-supplement, supplement-supplement, food, substance, lab-test and condition interactions.

## FR-372 Action Category Boundary
Engine does not escalate an interaction to contraindicated without source-backed reviewed evidence.

## FR-373 Applicability Context
Route/dose/timing/condition and other required context can gate rule applicability.

## FR-374 Insufficient Context State
Missing required context returns INSUFFICIENT_CONTEXT rather than confident safe/unsafe output.

## FR-375 Duplicate Ingredient Detection
Reviewed same active ingredient across overlapping products can produce DUPLICATE_INGREDIENT finding.

## FR-376 Duplicate Ingredient Is Not Toxicity Claim
Duplicate ingredient finding does not automatically claim overdose/toxicity.

## FR-377 Unit-compatible Ingredient Aggregation
Exposure totals are combined only when ingredient identity, dimension and amount basis are compatible.

## FR-378 Unknown Proprietary Blend Amount
Undisclosed ingredient amount remains UNKNOWN and is not divided from blend total.

## FR-379 Medication Safety Fixture Pack
Engine ships synthetic deterministic fixtures without pretending to be a comprehensive real clinical interaction database.

## FR-380 No-match Wording Safety
"No applicable rule found" never means guaranteed safe and exposes knowledge-pack state.

## FR-381 Safety Pack Freshness
Outdated/expired medication safety packs can block or stale new safety conclusions.

## FR-382 Medication Knowledge API
OpenAPI includes owner-safe medication knowledge search and intake/assessment resources.

## FR-383 Safety Review API
OpenAPI includes owner-authorized deterministic medication safety review operation.

## FR-384 Site Medication Safety Lab
Interactive Site Build Prompt includes a synthetic medication/supplement safety demonstration.

## FR-385 Medication Claim Boundary
Default product does not prescribe, stop medication or change dose from interaction findings.


## FR-386 Preventive Service/Rule Separation
Preventive service definition is separate from jurisdiction/source-specific recommendation rule.

## FR-387 Explicit Preventive Jurisdiction
Preventive guideline jurisdiction is explicit and is not silently inferred from GPS/IP/current travel location.

## FR-388 No Silent U.S. Fallback
A profile without an active selected jurisdiction pack does not silently receive U.S. preventive rules.

## FR-389 Guideline Source Snapshot
Every activated preventive rule retains official source snapshot/version/checked date/effective state.

## FR-390 Guideline Calendar-Year Independence
Current active schedule version is not inferred from the current calendar year.

## FR-391 Preventive Eligibility State
Eligibility is represented separately from recommendation mode and due state.

## FR-392 Recommendation Mode State
Routine, shared-decision, against-routine, evidence-insufficient and reference-only modes remain distinct.

## FR-393 Preventive Due State
Due now, due soon, up to date, overdue, too early, series complete and unknown history remain distinct.

## FR-394 Unknown History Not Zero History
Unknown preventive history is never automatically interpreted as never vaccinated/screened.

## FR-395 Interval Due Calculation
Interval-based next due date derives from a valid completion and the exact active rule version.

## FR-396 Shared-decision Non-punitive UI
Shared-decision recommendations are not presented as mandatory overdue tasks.

## FR-397 Evidence-insufficient No Schedule
Evidence-insufficient recommendations do not generate an invented routine due interval.

## FR-398 Against-routine Distinction
Against-routine recommendation is distinct from individual contraindication.

## FR-399 Vaccination Series Validity
Vaccine series evaluation can distinguish minimum-valid intervals from recommended intervals.

## FR-400 Catch-up Rule Specificity
Catch-up behavior is source-rule-specific and does not automatically restart a series after long delay.

## FR-401 Evidence of Immunity
Rule packs can represent source-specific evidence-of-immunity logic without globally applying it.

## FR-402 Self-report Evidence Policy
Whether self-reported vaccination counts is source/rule-specific and provenance remains visible.

## FR-403 Screening vs Diagnosis Boundary
Screening completion or abnormal result does not automatically create a confirmed diagnosis.

## FR-404 Symptomatic Screening Context
A routine asymptomatic screening rule can return not-applicable/follow-up pathway when relevant symptoms are present.

## FR-405 Screening Method Variant
Screening method/variant can alter interval and validity rules.

## FR-406 Anatomy-aware Screening
Relevant anatomy can be an explicit eligibility input; gender identity alone is not used as anatomy proxy.

## FR-407 Prior Abnormal Follow-up
Prior abnormal screening can exit routine screening and require a follow-up/surveillance pathway.

## FR-408 Source-native Recommendation Grade
Native guideline grade/class is preserved instead of converted to one universal score.

## FR-409 Screening Benefit/Harm Context
Preventive education can present source-backed potential benefits and harms rather than gamifying maximum screening.

## FR-410 Guideline Pack Precedence
National/regional, overlay and global-reference packs have explicit precedence.

## FR-411 Preventive Pack Conflict
Equal-precedence conflicting active rules return PACK_CONFLICT rather than silent merge.

## FR-412 Preventive Pack Staleness
Stale/expired rule packs can stale or block new preventive assertions while preserving history.

## FR-413 Historical Preventive Reproducibility
Past preventive assessments retain old rule/pack/source versions after guideline updates.

## FR-414 Guideline Refresh Diff
Source refresh creates immutable snapshot and classified rule diff before activation.

## FR-415 CDC Immunization Source Adapter
Architecture supports versioned U.S. CDC immunization schedule source snapshots.

## FR-416 USPSTF Preventive Source Adapter
Architecture supports published USPSTF recommendations and native A/B/C/D/I classes.

## FR-417 WHO Preventive Reference Adapter
WHO routine immunization and screening-programme guidance remain global reference sources, not automatic national overrides.

## FR-418 Türkiye Preventive Source Adapter
Architecture supports Türkiye Ministry of Health preventive/vaccination sources only after current central source reconciliation and review.

## FR-419 Preventive API Coverage
OpenAPI exposes preventive events, assessment run/history, due projections, service catalog and guideline-pack catalog.

## FR-420 Preventive Site Lab
Fourth Site build target contains deterministic synthetic preventive-care laboratory without real clinical schedule dependency.

## FR-421 Reference Interval Snapshot
Lab results preserve the exact source reference interval/text, unit, method/context and source version when available.

## FR-422 Reference Interval Is Not Optimal Target
The product never labels a population reference interval as a universal optimal-health target.

## FR-423 Decision Limit Separation
Clinical decision limits are modeled separately from statistical reference intervals.

## FR-424 Critical Rule Separation
Critical/significant-risk rules are modeled independently from reference-range flags.

## FR-425 No Invented Critical Threshold
Absent an active applicable source rule, the app does not synthesize a critical threshold.

## FR-426 Critical Notification Honesty
A critical match does not imply a clinician/laboratory was notified unless an external receipt proves it.

## FR-427 Reference Context Applicability
Age/sex/source-defined physiological state/specimen/fasting/method qualifiers gate interval applicability when the source requires them.

## FR-428 No Identity Proxy for Lab Partition
Gender identity/profile labels are not silently used as a laboratory reference partition.

## FR-429 Missing Reference Context
Missing required partition context returns INSUFFICIENT_REFERENCE_CONTEXT rather than guessed comparison.

## FR-430 Method Context Preservation
LabResult can retain analyzer/method/reagent/specimen/lab metadata required for longitudinal interpretation.

## FR-431 Method Comparability State
Longitudinal comparison explicitly represents direct, converted, method-change, unknown or non-comparable states.

## FR-432 Method Change Chart Marker
Trend UI marks material/unknown method changes rather than implying continuous comparability.

## FR-433 Specimen Matrix Separation
Different specimen matrices are not automatically combined into one comparable series.

## FR-434 Method Bias Evidence
Cross-method bias/equivalence mappings require versioned study/source evidence.

## FR-435 No Personal Auto-calibration
A few personal points do not create a production clinical calibration between laboratory methods.

## FR-436 Delta Check Separation
Delta-check alerts are separate from diagnosis and reference-range status.

## FR-437 RCV Formula Transparency
Eligible RCV calculation exposes formula, CV inputs, Z factor and source/version.

## FR-438 No Invented Biological Variation
CVa/CVi values are never fabricated when source estimates are missing.

## FR-439 RCV Eligibility Gate
RCV runs only for compatible analyte/specimen/method contexts supported by its source assumptions.

## FR-440 Personal Baseline Separate Channel
Personal baseline deviation never overwrites population reference status.

## FR-441 Source-reported Flag Preservation
Original laboratory high/low/critical flags remain visible as source-reported metadata.

## FR-442 Flag Origin Label
UI distinguishes source-reported flag, app reference comparison and app rule match.

## FR-443 Reference Source Conflict
Conflicting equally authoritative applicable reference sources yield explicit conflict/review state.

## FR-444 Historical Range Immutability
Later reference-range changes do not rewrite historical LabResult interpretation snapshots.

## FR-445 Safe Unit Gate
Reference/critical/decision comparison requires safe unit compatibility/conversion.

## FR-446 Lab Interpretation Assessment
A typed LabInterpretationAssessment records separate reference, decision, critical, comparability and delta channels.

## FR-447 Critical Rule Freshness
Expired/stale critical packs cannot silently generate current urgent conclusions.

## FR-448 Lab Standards Source Registry
Reference/critical/method/delta governance sources are versioned and rechecked before activation.

## FR-449 Synthetic Lab Fixtures
Executable synthetic fixtures verify interpretation semantics without asserting real clinical thresholds.

## FR-450 Lab Interpretation Schemas
Machine-readable starter schemas exist for interval snapshots, method context, critical rules and interpretation assessments.

## FR-451 Site Lab Interpretation Demo
Interactive Site Build Prompt includes synthetic reference/critical/method/delta demonstrations.

## FR-452 Identifier Canonicality
Acceptance/ADR/FM/phase canonical identifiers are unique after v0.24 repair.

## FR-453 Identifier Migration Map
Historical colliding identifiers retain a machine-readable alias-to-canonical migration map.

## FR-454 Canonical Acceptance Traceability
Requirement traceability uses the repaired canonical acceptance IDs.

## FR-455 Release Identifier Gate
Future releases fail static audit when canonical identifier duplication is detected.


---

<!-- SOURCE: 03_UI_UX_SPEC.md -->

# UI / UX SPECIFICATION

## Core design goals

The interface should be:
- modern,
- calm,
- readable,
- data-dense without becoming cluttered,
- appropriate for repeated daily use,
- responsive across phone and desktop,
- accessible.

Avoid visual language that implies medical certainty where the data is only self-report.

## Mobile navigation

Recommended first-pass bottom navigation:

1. Today
2. Timeline
3. Add / quick action
4. Insights
5. More

Alternative direct tabs are acceptable if usability testing supports them.

`More` can contain:
- Labs
- Nutrition
- Mind
- Conditions
- Symptoms
- Medications
- Vitals
- Sleep
- Activity
- Settings

## Web navigation

Desktop may use a persistent left navigation rail/sidebar with a large dashboard workspace.

Suggested sections:
- Today
- Timeline
- Labs
- Nutrition
- Mind
- Symptoms
- Conditions
- Medications
- Activity
- Sleep
- Insights
- Settings

## Today screen

Provide:
- date,
- quick check-in,
- food entry shortcut,
- recent measurements,
- latest lab/health event summaries,
- optional due/planned items clearly labeled as plans.

## Lab screen

Primary views:
- sessions list,
- session detail,
- analyte history,
- chart,
- add/edit/correct result flow.

For every plotted value, retain date and unit.

## Food diary screen

Structure:
Day → Meal/eating event → Food entry → Quantity → Snapshot nutrient calculation.

User flow:
1. choose/add meal,
2. search food or scan barcode,
3. select exact result,
4. enter quantity,
5. preview calculated nutrients,
6. save.

Manual food creation must remain available.

## Mind screen

Fast daily check-in with sliders or similarly accessible 1–10 controls.
Always explain that values are self-ratings.

## Timeline

Each event card should communicate:
- event type,
- time/date,
- concise title/value,
- source or status where relevant.

Opening the event should reveal its canonical source record.

## Charts

Charts should:
- label units,
- label dates,
- not mix incompatible units silently,
- show missing gaps honestly,
- preserve access to raw points,
- avoid pseudo-precision.

## Empty states

Empty screens should explain:
- what can be added,
- how to add it,
- that absence of data is not a negative health judgment.

## Error states

Never replace failed data retrieval with a fake zero or “normal” value.
Show retry and source status.


## Health Modules settings
`Settings → Health Modules`: Basic / Advanced / Expert complexity controls. Modules are optional UI depth, not data silos.

## Results / Longevity
Dedicated surface separating Population Baseline, Validated Risks, App Domain/Healthspan Scores, Coverage/Confidence and Experimental outputs. Every result has definition, source/model, date, coverage, confidence/uncertainty and `How calculated?`.


## Comparison tab

Add `Compare` as a first-class surface.

Functions:
- add profile,
- clone scenario,
- pin baseline,
- choose metrics,
- compare N profiles horizontally,
- show delta,
- open each score/model definition.

## Daily Missions

Today should include a mission stack:
- Observe
- Train
- Recover
- Learn
- Prevention

Show planned vs completed distinctly.

## Education

Add `Learn` surface or contextual cards.

## Reset UX

Settings must contain:
- Reset settings to defaults,
- Reset module settings,
- Reset synthetic scenario,
- Delete data,
- Delete account.

Destructive actions must not be visually conflated with settings reset.


---

<!-- SOURCE: 04_DATA_MODEL.md -->

# CANONICAL DATA MODEL

This file defines conceptual entities. Concrete SQL/document schemas may refine them without losing the distinctions.

## Identity

### User
- id
- created_at
- account_status

### UserProfile
- user_id
- timezone
- locale
- preferred_units
- optional dietary preferences/restrictions
- privacy preferences

Dietary preference is optional metadata. It never replaces actual food intake.

## Timeline

### TimelineEvent
- id
- user_id
- event_type
- occurred_at
- status
- source_entity_type
- source_entity_id
- title
- note
- created_at

TimelineEvent is an index/representation of a canonical source record, not a replacement for it.

## Laboratory

### LabSession
- id
- user_id
- collected_at
- reported_at
- laboratory_name
- fasting_status
- notes
- attachment_ids
- created_at

### LabResult
- id
- lab_session_id
- analyte_code
- display_name
- numeric_value
- text_value
- unit
- reference_low
- reference_high
- reference_text
- flag
- measurement_method
- notes
- corrects_id
- created_at

Support numeric and textual results because not every lab result is purely numeric.

## Conditions

### Condition
- id
- user_id
- name
- status
- onset_date
- end_date
- severity_1_10 optional
- clinician optional
- notes
- created_at
- updated_at

## Symptoms

### SymptomEvent
- id
- user_id
- symptom
- start_at
- end_at optional
- severity_1_10
- associated_features
- context
- notes
- created_at

## Mind

### MindCheckin
- id
- user_id
- observed_at
- mood_1_10
- anxiety_1_10
- stress_1_10
- energy_1_10
- motivation_1_10
- focus_1_10
- social_energy_1_10
- sleep_quality_1_10
- tags
- note
- corrects_id
- created_at

## Food

### Meal
- id
- user_id
- occurred_at
- meal_type
- name optional
- notes
- created_at

### FoodEntry
- id
- meal_id
- food_snapshot_id
- quantity
- quantity_unit
- edible_amount_g optional
- calculation_version
- notes
- created_at

### FoodSnapshot
- id
- provider
- provider_food_id
- barcode optional
- display_name
- brand optional
- food_type
- source_retrieved_at
- source_revision optional
- basis_amount
- basis_unit
- ingredients optional
- allergens optional
- nutrients
- provenance
- immutable_after_use

### NutrientValue
- nutrient_code
- display_name
- amount
- unit
- data_status
- source_field
- basis_amount
- basis_unit

`data_status` must distinguish known value from missing/unknown.

### CustomFood
- id
- user_id
- name
- brand optional
- basis_amount
- basis_unit
- nutrients
- ingredients optional
- created_at
- updated_at

### Recipe
- id
- user_id
- name
- ingredient entries
- yield_g optional
- servings optional
- calculation_version
- notes

## Medication

### MedicationPlan
- id
- user_id
- name
- active_ingredient optional
- dose
- unit
- route
- schedule
- start_date
- end_date optional
- prescriber optional
- notes

### IntakeEvent
- id
- user_id
- medication_plan_id optional
- item_name
- taken_at
- dose
- unit
- status
- notes

## Vitals

### VitalMeasurement
- id
- user_id
- metric
- value
- unit
- measured_at
- device_or_source
- context
- corrects_id optional

### BloodPressureMeasurement
- id
- user_id
- systolic
- diastolic
- unit
- measured_at
- device_or_source
- context

## Sleep

### SleepEpisode
- id
- user_id
- start_at
- end_at
- duration_minutes
- source
- subjective_quality_1_10 optional
- notes

## Activity

### ActivityEvent
- id
- user_id
- activity_type
- start_at
- end_at optional
- duration_minutes optional
- metrics
- source
- notes

## Derived layer

### DerivedInsight
- id
- user_id
- insight_type
- generated_at
- source_record_ids
- algorithm_version
- result
- limitations
- provenance

DerivedInsight cannot overwrite canonical health records.


## Universal extensibility and advanced health

### HealthFact
Generic extensible health fact with domain/category/subtype, typed value, unit, dates, provenance, tags, notes, attachments and correction/deletion metadata.

### VaccinationEvent
Vaccine/target, administered_at, dose, manufacturer/lot/provider/source and optional reaction note.

### ProcedureEvent
Procedure type, date, provider/institution, indication, outcome/status, notes/documents.

### TreatmentCourse / TreatmentEvent
Domain-linked multi-event therapy with regimen/cycle/fraction/agent/dose metadata as applicable.

### HealthProduct / ProductUseEvent
Catalog product is separate from actual dated use.

### ScoreResult
Stores domain, result_class, model_id/version, calculation time, input_record_ids, output, coverage, confidence, uncertainty, limitations and source.

### ModelRegistryEntry
Stores domain, purpose, version, eligibility, required inputs, exclusions, output semantics, source/license, validation population and status.


## Comparison

### ComparisonProfile
- id
- owner_user_id
- profile_type
- name
- description
- source_profile_id optional
- settings/defaults_version
- created_at
- updated_at

### ComparisonProfileRecordLink
Allows a scenario/profile to own or reference cloned health inputs without mutating source data.

## Daily Missions

### Mission
- id
- profile_id
- mission_type
- title
- rationale
- target
- unit
- generated_for_date
- source_rule_id
- source_rule_version
- prerequisite_record_ids
- status
- completion_record_ids
- xp optional
- created_at

### RulePack
- rule_pack_id
- version
- locale
- rules
- source/reference metadata
- installed_at

## Education

### EducationContentPack
- pack_id
- version
- locale
- domain
- lesson IDs
- source/reference metadata

### LessonProgress
- user/profile ID
- lesson_id
- state
- attempts
- correct/incorrect counts
- review_due_at
- xp

## Wearables

### ExternalHealthRecordLink
- canonical_record_id
- platform
- source_app/device
- external_record_id
- import_cursor/version
- imported_at

## Defaults

### DefaultsProfile
- defaults_version
- settings
- module defaults
- scoring display defaults
- mission defaults

## Bidirectional health state

### DomainStateSnapshot
- id
- profile_id
- domain
- calculated_at
- protection_score optional
- burden_score optional
- function_score optional
- balance_index optional
- trajectory
- coverage
- confidence
- input_record_ids
- model/rule versions

### ExposureEpisode
- id
- profile_id
- domain
- exposure_type
- start_at
- end_at optional
- intensity/value
- unit
- source
- notes

### EvidenceClaim
- claim_id
- population
- exposure_or_intervention
- comparator
- outcome
- time_horizon
- evidence_class
- effect_estimate optional
- uncertainty optional
- source_reference
- review_date
- version

### DecisionRecord
- decision_id
- scope/profile/module
- question
- current_choice
- alternatives
- reason
- assumptions
- downsides
- dependencies
- switch_condition
- effective_at
- version

### FailureRecord
- failure_id
- module
- observed_behavior
- expected_behavior
- severity
- environment/context
- cause_status
- repair
- regression_test
- verification_status

### PolicyVersion
- policy_id
- version
- effective_from
- retired_at
- source_reason
- migration_recalculation_policy


## Life course / episodes

### EpisodeOfCare
- id
- profile_id
- domain
- title
- start_at
- end_at
- status
- primary_condition_id
- related_record_ids
- provider/care metadata
- outcome_state
- notes

### FunctionalMeasurement
- id
- profile_id
- instrument_or_metric
- domain
- value
- unit_or_scale
- measured_at
- source
- assistance_level
- instrument_version
- notes

### PainEvent
- id
- profile_id
- location
- quality
- intensity_1_10
- interference_1_10 optional
- start_at
- end_at
- triggers
- relieving_factors
- associated_features
- treatment_refs
- notes

### RehabPlan / RehabSession
Plan and actual session remain separate.

### EnvironmentalExposure
- id
- profile_id
- exposure_type
- start_at/end_at
- intensity
- unit
- source
- location_precision
- confidence
- notes

### CodedConcept
- system
- code
- display
- version
- user_label

### TwinSnapshot
- profile_id
- as_of_time
- source_event_cursor
- state_projection
- active_model_versions
- active_rule_versions
- unresolved_conflicts
- coverage

### ScenarioPatch
- scenario_id
- base_profile_id
- base_as_of
- patch_operations
- scenario_class
- rationale
- created_at

### PersonalBaseline
- id
- profile_id
- metric
- window_start/window_end
- estimator
- parameters
- source_filters
- version
- calculated_at

### ForecastResult
- id
- profile_id
- metric
- horizon
- method
- training_window
- prediction
- uncertainty
- model_version
- source_record_ids


## Data quality / measurement governance

### DataQualityProfile
record_or_result_id, source_quality, measurement_quality, recency, completeness, consistency, identity_match, unit_validity, plausibility, conflict_state, overall_quality_class, notes.

### MeasurementDevice
id, manufacturer, model, device_type, serial_hash, firmware, source_platform, calibration_state, calibration_date, notes.

### MeasurementSession
id, profile_id, metric, started_at, protocol_id, measurement_ids, summary_result_id.

### ConsentRecord
consent_id, profile_id, purpose, data_categories, recipient_or_integration, granted_at, expires_at, revoked_at, policy_version.

### AuditEvent
audit_id, actor, action, resource_type, resource_id, timestamp, session_device, result, purpose.

### PersonalExperiment
experiment_id, profile_id, question, hypothesis, intervention, baseline_window, intervention_window, followup_window, target_outcomes, confounders, stopping_safety_conditions, status.

### ImportBatch
batch_id, source, received_at, parsed_count, committed_count, duplicate_count, conflict_count, failure_count, schema_version, receipt_hash.

### PackManifest
pack_id, pack_type, version, created_at, effective_from, compatibility_range, checksum, dependencies, supersedes, source_reference, license, state.


## Production shell entities

### Reminder
- id
- profile_id
- type
- title
- schedule
- timezone
- source_plan_id
- enabled
- priority
- quiet_hours_policy
- platform_schedule_id
- created_at
- updated_at

### SessionRecord
- session_id
- user_id
- device_id
- created_at
- last_seen_at
- expires_at
- auth_strength
- revoked_at
- client_version
- risk_flags

### DeviceRegistration
- device_id
- user_id
- platform
- label
- first_seen_at
- last_seen_at
- status

### SupportBundleManifest
- bundle_id
- generated_at
- app_version
- schema_version
- pack_versions
- sanitized_log_ids
- user_selected_sensitive_inclusions
- checksum

### ReleaseRecord
- release_id
- app_version
- build_number
- source_commit
- backend_version
- schema_version
- model_versions
- rule_versions
- content_versions
- build_date
- artifact_checksums
- test_report_id
- rollout_state

### ClaimRecord
- claim_id
- user_facing_wording
- feature
- evidence_model_refs
- intended_market
- status
- review_state


---

<!-- SOURCE: 05_HEALTH_AND_TIMELINE.md -->

# HEALTH RECORD AND TIMELINE ENGINE

## Core rule

Health information must remain attached to:
- identity,
- time,
- type,
- source,
- status,
- unit when numeric,
- correction provenance when relevant.

## Timeline model

The timeline is a cross-domain view, not a second copy of all data.

Examples:
- mind check-in,
- lab session,
- symptom,
- food entry/meal summary,
- vital measurement,
- activity,
- medication intake.

Timeline entries should deep-link to their source record.

## Status semantics

Recommended shared states:
- OBSERVED
- SELF_REPORTED
- PLANNED
- COMPLETED
- CORRECTED
- UNKNOWN

Do not force every module to use every state.

## Corrections

For sensitive historical values:
1. preserve original record where feasible,
2. create corrected record or revision,
3. retain relationship to original,
4. recalculate dependent summaries,
5. preserve audit metadata.

## Date semantics

Use precise field names:
- `created_at`: when record entered into system,
- `observed_at`: when user observed/reported a state,
- `occurred_at`: when event happened,
- `collected_at`: when sample was collected,
- `reported_at`: when a result was reported.

Do not treat these as interchangeable.

## Time zone

Store canonical instants safely and preserve user timezone context where needed.
Daily grouping should respect the user's applicable timezone.

## Derived views

Daily, weekly, monthly and yearly summaries may be built from canonical events.
A summary is never evidence that a missing underlying event occurred.


---

<!-- SOURCE: 06_NUTRITION_AND_FOOD_DATA.md -->

# NUTRITION AND FOOD DATA SPECIFICATION

## Product behavior

The application asks what the user actually ate.
It does not require a fixed diet identity.

Optional dietary settings can help with:
- preferences,
- exclusions,
- search filters,
- warnings,
but never substitute for food records.

## Food Data Layer

Use a provider-neutral internal food model.

Recommended provider roles:

### USDA FoodData Central
Useful for:
- generic foods,
- foundation foods,
- survey foods,
- many branded items,
- structured nutrient composition.

### Open Food Facts
Useful for:
- barcode lookup,
- packaged/branded products,
- label nutrition,
- ingredients,
- allergens,
- product metadata.

### Manual / Custom
Required for:
- home recipes,
- restaurants,
- unavailable products,
- user-entered foods.

The implementation must verify current provider API contracts, licenses, usage requirements and rate limits at build time rather than assuming historical details remain unchanged.

## Provider adapter interface

Conceptually:

- `search(query, locale?)`
- `getById(providerId)`
- `getByBarcode(barcode)`
- `normalize(providerPayload)`

Provider-specific data must be mapped into a canonical `FoodSnapshot`.

## Snapshot rule

When a food is logged, persist the nutrient/source snapshot used for that calculation.

Reason:
Upstream provider data may change later. Historical meal totals should not silently mutate.

## Nutrient values

Each nutrient value must include:
- canonical code,
- display name,
- amount,
- unit,
- basis,
- source field,
- availability/status.

Missing data is not zero.

## Calculation

For mass-normalized source data:

`logged_amount / source_basis_amount × source_nutrient_amount`

Unit conversions must be explicit.

Do not assume:
- 1 mL = 1 g for every food,
- one “piece” has a universal mass,
- provider serving labels are identical across products.

## Daily totals

Aggregate compatible normalized nutrient values.
Expose data coverage when important fields are missing.

## Barcode flow

1. scan barcode,
2. request provider product,
3. show product identity,
4. user confirms,
5. choose quantity,
6. persist snapshot,
7. calculate entry,
8. aggregate.

## Food-search safety

Do not silently choose the first similarly named food.
Display enough context for selection:
- generic vs branded,
- brand,
- serving/basis,
- barcode when available,
- provider/source.


---

<!-- SOURCE: 07_LAB_RESULTS_ENGINE.md -->

# LAB RESULTS ENGINE

## Goals

- preserve dated laboratory history,
- preserve units,
- preserve lab reference metadata,
- allow longitudinal comparison,
- prevent false cross-unit comparison.

## Lab Session

A LabSession represents one collection/report context containing multiple results.

Fields should support:
- collection date/time,
- result/report date,
- laboratory,
- fasting status,
- notes,
- attachments.

## Lab Result

A LabResult should support:
- canonical or provider analyte identifier when known,
- display name,
- numeric value and/or textual result,
- unit,
- lab-provided reference low/high,
- free-text reference range,
- flag,
- method,
- note.

## Reference ranges

A lab-provided reference range is metadata from that laboratory/report.
Do not treat it as a universal health target.

## Longitudinal series

To graph an analyte:
1. identify comparable analyte,
2. validate units,
3. convert only with a defined conversion,
4. plot dated points,
5. retain access to raw records.

## Import readiness

Future versions may support PDF/image/manual import.
Any OCR/AI extraction must:
- preserve source attachment,
- mark extracted values as imported/unverified until appropriate confirmation,
- never silently invent unreadable values.

## Corrections

Incorrectly entered lab values must not silently rewrite historical provenance.

## Example

Session:
- collected_at: 2026-10-03
- laboratory: Example Lab

Results:
- LDL: 118 mg/dL
- HDL: 52 mg/dL
- HbA1c: 5.2 %
- B12: 430 pg/mL

These are examples only, not product defaults.

## v0.24 interpretation governance

Reference-range comparison, critical/significant-risk rules, clinical decision limits, method comparability, delta checks and personal baseline are separate interpretation channels.

Authoritative v0.24 contracts:
- `177_LAB_REFERENCE_INTERVAL_AND_DECISION_LIMIT_GOVERNANCE.md`
- `178_CRITICAL_SIGNIFICANT_RISK_RESULT_AND_ALERT_BOUNDARY.md`
- `179_LAB_METHOD_SPECIMEN_AND_LONGITUDINAL_COMPARABILITY.md`
- `180_DELTA_CHECK_REFERENCE_CHANGE_VALUE_AND_PERSONAL_BASELINE.md`
- `181_LAB_INTERPRETATION_ASSESSMENT_ENGINE.md`

A laboratory-provided range remains source metadata. It is not silently transformed into a universal optimal range or critical threshold.


---

<!-- SOURCE: 08_MIND_CONDITIONS_SYMPTOMS.md -->

# MIND, CONDITIONS AND SYMPTOMS

## Mind Check-in

The app may ask:
“Bugün kendini nasıl hissediyorsun?”

Default self-rating dimensions may include:
- mood,
- anxiety,
- stress,
- energy,
- motivation,
- focus,
- social energy,
- subjective sleep quality.

Scale:
1–10.

These values are subjective self-reports.

Do not label them as:
- diagnosis,
- validated psychiatric score,
- clinical severity,
unless a separately implemented validated instrument explicitly supports that interpretation.

## Notes and tags

Allow optional notes and descriptive tags.

## Conditions

Condition status must distinguish:
- CONFIRMED_DIAGNOSIS
- SELF_REPORTED_HISTORY
- SUSPECTED_OR_EVALUATION_PENDING
- RESOLVED
- UNKNOWN

A user's suspicion cannot become a confirmed diagnosis automatically.

## Symptoms

Symptom events support:
- name,
- start,
- optional end,
- severity 1–10,
- associated features,
- context,
- note.

## Trends

The app can show:
- frequency,
- date ranges,
- self-report trends,
- exploratory associations.

Do not automatically infer medical causality from co-occurrence.


---

<!-- SOURCE: 09_MEDICATIONS_VITALS_ACTIVITY_SLEEP.md -->

# MEDICATIONS, SUPPLEMENTS, VITALS, ACTIVITY AND SLEEP

## Medication / supplement model

Separate:
1. plan,
2. actual intake.

A schedule saying “take daily” does not prove the user took it.

### MedicationPlan
Defines intended use.

### IntakeEvent
Records an actual reported intake event.

## Vitals

Support a generic measurement entity for:
- weight,
- waist circumference,
- heart rate,
- temperature,
- SpO2,
- future metrics.

Store:
- value,
- unit,
- measured_at,
- source/device,
- context.

Blood pressure should use structured systolic/diastolic fields.

## Activity

Record actual activity events with:
- activity type,
- start/end or duration,
- metrics,
- source,
- notes.

## Sleep

Record sleep episodes with:
- start,
- end,
- duration,
- source,
- optional subjective quality,
- notes.

## External health platforms

Future implementations may integrate platform health stores.
Any integration must be source-labeled and must not duplicate data without deduplication logic.


---

<!-- SOURCE: 100_PRODUCTION_ACCEPTANCE_DOSSIER.md -->




---

<!-- SOURCE: 101_RESOURCE_OWNERSHIP_CRUD_AND_SYNC_MATRIX.md -->

# RESOURCE OWNERSHIP, CRUD AND SYNC MATRIX

## Purpose

Prevent shadow ownership and accidental mutation through projections.

| Resource | Owner module | Create | Update | Correct/append revision | Delete | Offline create | Sync | Projection consumers |
|---|---|---|---|---|---|---|---|---|
| UserProfile | PROFILE | yes | yes | revision | yes | yes | yes | all |
| TimelineEvent | TIMELINE projection | derived | derived | derived | derived | yes | yes | UI |
| LabSession | LABS | yes | limited | yes | yes | yes | yes | Timeline/Results/Compare |
| LabResult | LABS | yes | prefer correction | yes | yes | yes | yes | Results/Compare |
| Condition | CONDITIONS_SYMPTOMS | yes | status | yes | yes | yes | yes | Results/Missions |
| SymptomEvent | CONDITIONS_SYMPTOMS | yes | end/context | yes | yes | yes | yes | Timeline/Results |
| MindCheckin | MIND | yes | prefer correction | yes | yes | yes | yes | Timeline/Results |
| Meal | NUTRITION | yes | yes | revision | yes | yes | yes | Timeline/Nutrition |
| FoodEntry | NUTRITION | yes | replace/correct | yes | yes | yes | yes | totals/Timeline |
| FoodSnapshot | NUTRITION | yes | immutable after use | new snapshot | dependency-aware | yes | yes | FoodEntry |
| MedicationPlan | MEDICATION_TREATMENT | yes | yes | revision | yes | yes | yes | Missions/Reminders |
| IntakeEvent | MEDICATION_TREATMENT | yes | prefer correction | yes | yes | yes | yes | adherence/Timeline |
| TreatmentCourse | MEDICATION_TREATMENT | yes | state | revision | yes | yes | yes | Episode/Timeline |
| TreatmentEvent | MEDICATION_TREATMENT | yes | prefer correction | yes | yes | yes | yes | Episode/Results |
| VitalMeasurement | VITALS_FUNCTION | yes | prefer correction | yes | yes | yes | yes | Results/Models |
| SleepEpisode | SLEEP_ACTIVITY | yes/import | correct | yes | yes | yes | yes | Missions/Results |
| ActivityEvent | SLEEP_ACTIVITY | yes/import | correct | yes | yes | yes | yes | Missions/Results |
| ScoreResult | MODEL_RUNTIME | derived | no | recalc new snapshot | policy | local calc | optional sync | Results/Compare |
| Mission | MISSIONS_REMINDERS | generated/create | status | event history | archive/delete | yes | yes | Today |
| Reminder | MISSIONS_REMINDERS | yes | schedule | n/a | yes | yes | optional | OS scheduler |
| ComparisonProfile | COMPARE_TWIN | yes | yes | revision | yes | yes | optional | Compare |
| ScenarioPatch | COMPARE_TWIN | yes | append/replace | version | yes | yes | optional | Twin/Compare |
| ImportBatch | IMPORT_EXPORT | yes | staging state | receipt | rollback | yes | optional | audit |
| ConsentRecord | SECURITY_AUDIT | yes | revoke | history | policy | limited | server | integrations |
| AuditEvent | SECURITY_AUDIT | append | no | no | policy | local/server | server | security |
| PackManifest | PACKS | install | lifecycle | version | retire | yes | update service | engines |

## Mutation rule

A projection consumer may request an operation through the owner module, but may not mutate another module's persistence tables directly.

## Sync rule

Sync transports resource mutations but domain owner validates semantics before canonical commit.


---

<!-- SOURCE: 102_QUERY_FILTER_SORT_SEARCH_AND_EXPORT_CONTRACT.md -->

# QUERY, FILTER, SORT, SEARCH AND EXPORT CONTRACT

## Purpose

Make large longitudinal histories usable and deterministic.

## Date range

All temporal list/query endpoints that support ranges should define:
- inclusive/exclusive boundaries,
- timezone interpretation,
- maximum server page size,
- stable sort.

Preferred interval semantics for instants:
`start <= t < end`
when practical.

## Stable sort

Default chronological order should define tie-breaker:
- primary timestamp,
- stable canonical ID.

Do not rely on database insertion order.

## Cursor

Cursor should encode/reference enough state for stable pagination without exposing sensitive internals unnecessarily.
Clients treat cursors as opaque.

## Filters

Common dimensions:
- domain/type
- date range
- source/provider/device
- status
- active/resolved
- model/result class
- sync/conflict state.

Invalid filter combinations return documented validation error rather than silently ignoring filters.

## Search

Search classes:
- local entity search
- food/provider search
- terminology/concept search
- education search.

Health free-text search must respect owner authorization and local privacy.

## Sort

Supported sorts are allow-listed per resource.
Arbitrary SQL-like sort expressions are prohibited.

## Export

Every export declares:
- profile/scope
- included modules
- date range
- schema version
- generated_at
- unit/source preservation behavior.

CSV exports:
- one logical table per compatible resource class or documented flattened view,
- columns documented,
- timestamps and units explicit,
- missing values distinct from numeric zero.

JSON full export:
- preserves IDs/relationships/provenance/version semantics.

## Result reproducibility

A historical ScoreResult query can retrieve:
- model version,
- source input IDs,
- calculation time,
- output semantics.

## Search indexing

Search index is a projection.
Deletion/correction must propagate to the index; index is not canonical source.


---

<!-- SOURCE: 103_DOMAIN_EVENT_CATALOG_AND_INVALIDATION_RULES.md -->

# DOMAIN EVENT CATALOG AND INVALIDATION RULES

## Purpose

Make cross-module reactions explicit without creating recursive write coupling.

## Event envelope

- event_id
- event_type
- entity_type
- entity_id
- profile_id
- occurred_at/emitted_at
- entity_revision
- payload summary/minimal IDs
- source module
- causation_id optional
- correlation_id optional.

Events should not duplicate full sensitive records unnecessarily.

## Core events

### PROFILE_UPDATED
Consumers:
- UI preferences
- localization
- model applicability only when relevant profile input changed.

### LAB_RESULT_CREATED / LAB_RESULT_CORRECTED / LAB_RESULT_DELETED
Consumers:
- Timeline
- analyte projection
- relevant Model Runtime dependency graph
- Results
- Compare/Twin.

Invalidation:
only ScoreResults declaring that LabResult/analyte dependency.

### CONDITION_STATUS_CHANGED
Consumers:
- Timeline
- model eligibility
- mission safety/rules
- EpisodeOfCare.

### SYMPTOM_EVENT_CREATED/UPDATED
Consumers:
- Timeline
- configured early-warning rules
- EpisodeOfCare.

### FOOD_ENTRY_CHANGED
Consumers:
- day totals
- nutrition trends
- models declaring nutrition dependency.

### INTAKE_EVENT_RECORDED/CORRECTED
Consumers:
- adherence projection
- Timeline
- interaction/monitoring rules.

### TREATMENT_EVENT_RECORDED
Consumers:
- EpisodeOfCare
- Timeline
- treatment burden/recovery projections.

### VITAL_MEASUREMENT_CHANGED
Consumers:
- trends
- personal baseline
- relevant models
- early-warning rules.

### SLEEP_ACTIVITY_CHANGED
Consumers:
- daily summaries
- mission generation
- trend engine.

### IMPORT_BATCH_COMMITTED / ROLLED_BACK
Consumers:
- owning module projections
- audit
- sync/export.

### MODEL_PACK_ACTIVATED
Consumers:
- eligibility UI
- new calculations.

Historical results remain pinned to prior model version.

### RULE_PACK_ACTIVATED
Consumers:
- future mission/alert generation.

Historical mission decisions remain pinned to original rule version.

### CANONICAL_RECORD_TOMBSTONED
Consumers:
- Timeline/search projections
- derived result invalidation
- sync tombstone distribution.

## Idempotent consumption

Every event consumer must be safe against duplicate delivery or maintain a consumption receipt/version strategy.

## Failure isolation

A failed noncritical projection update must not roll back already-committed canonical health data.
It should enter retry/error state.

## Rebuildability

Derived projections should be rebuildable from canonical records/events + versioned policies where practical.


---

<!-- SOURCE: 104_PERMISSION_CAPABILITY_AND_DEGRADATION_MATRIX.md -->

# PERMISSION, CAPABILITY AND GRACEFUL-DEGRADATION MATRIX

## Purpose

The app must remain useful when optional OS/network/provider capabilities are unavailable.

| Capability | If available | If denied/unavailable | Forbidden fallback |
|---|---|---|---|
| Health Connect read | import authorized data | manual entry + explain permission | fake wearable values |
| HealthKit read | import authorized data | manual entry + explain permission | fake wearable values |
| Notifications | schedule local reminders | in-app due list/calendar | mark reminder delivered anyway |
| Exact alarms | exact only when justified | inexact/local scheduler or explicit limitation | silently promise exact delivery |
| Camera/barcode | scan product | manual barcode/search | invent barcode match |
| File/document access | import attachment | manual data entry | claim document imported |
| Biometric unlock | convenient app lock | device credential/app fallback per design | lock user out without recovery path |
| Network | sync/provider/update | offline local core | hide local records |
| Cloud backend | cross-device sync | local-only mode | fabricate successful sync |
| Food provider | fresh external search | cache/custom food | missing nutrient as zero |
| Pack update server | update models/rules/content | last verified pack | disable installed deterministic core |
| Location | optional exposure/local context | manual/coarse/no feature | infer precise location secretly |

## Capability state

Use explicit state:
- AVAILABLE
- DENIED
- UNAVAILABLE_PLATFORM
- TEMPORARILY_UNAVAILABLE
- RESTRICTED
- UNKNOWN.

## UI rule

Explain:
- what capability enables,
- whether it is optional,
- manual/offline alternative,
- how to change permission where appropriate.

Do not nag repeatedly after a user intentionally denies an optional permission.


---

<!-- SOURCE: 105_RELEASE_EVIDENCE_SCHEMA_AND_SIGNOFF.md -->

# RELEASE EVIDENCE SCHEMA AND SIGNOFF

## Purpose

Define machine-readable release evidence so future agents cannot summarize incomplete execution as full success.

## ReleaseEvidence

Required groups:
- identity
- source
- contracts
- migrations
- tests
- security
- accessibility
- performance
- recovery
- builds
- runtime
- deployment
- blockers
- claims/review.

## Evidence item

Fields:
- evidence_id
- gate_id
- scope/platform
- status: PASS | FAIL | BLOCKED | NOT_RUN | NOT_APPLICABLE
- command_or_method
- started_at/finished_at optional
- environment_id
- artifact/report references
- checksum(s)
- notes
- blocker_id optional.

## Signoff rule

No unsigned prose promotion.
Final aggregate state is computed from evidence items and gate policy.

## Required blocking examples

- cross-user authorization FAIL → production BLOCKED
- restore integrity FAIL → production BLOCKED
- Android APK build FAIL → Android release BLOCKED
- iOS NOT_RUN → iOS remains NOT_RUN, not PASS
- performance budget FAIL → corresponding release gate FAIL unless explicitly nonblocking policy says otherwise and reason is recorded.

## Human approval

If product governance requires human approval, store:
- approver role/name identifier,
- approved scope,
- date,
- evidence snapshot hash.

Do not fabricate human approval in an automated build.

## Dossier relationship

`100_PRODUCTION_ACCEPTANCE_DOSSIER.md` describes evidence content.
This file defines its machine-state semantics.


---

<!-- SOURCE: 106_SCREEN_BY_SCREEN_VISUAL_WIREFRAME_CONTRACT.md -->

# SCREEN-BY-SCREEN VISUAL WIREFRAME CONTRACT

## Purpose

Give the implementation agent enough visual structure to build coherent UI without freezing brand aesthetics.

## TODAY

Primary action:
`+ Add`

Primary sections:
- status/offline/sync strip only when relevant,
- Daily Missions,
- key current observations,
- recent changes,
- concise Results summary,
- education card.

Avoid:
- giant lifespan countdown,
- red alarm styling for ordinary missing data.

## RESULTS

Header:
- profile/scenario name,
- as-of timestamp,
- coverage/confidence.

Cards grouped by result class.
Each numeric card shows type badge before drilldown.

## COMPARE

Toolbar:
- add/clone profile,
- baseline selector,
- domain/metric filter.

Body:
- profile columns/cards,
- typed result rows,
- delta rows only where comparable.

## LABS

List:
- session date,
- lab/provider,
- result count,
- correction/source indicator.

Detail:
- session metadata,
- result table,
- add/correct action,
- linked source document.

Analyte:
- chart,
- raw table,
- units/source/reference layers.

## NUTRITION

Day screen:
- meal groups,
- daily totals,
- coverage/missingness.

Food add:
- search/cache/provider tabs or unified results,
- selected item identity,
- amount,
- nutrient preview.

## TIMELINE

Chronological list with domain icon/label, not color-only semantics.
Event inspector opens canonical details.

## DAILY MISSIONS

Each mission:
- category,
- target,
- rationale/source rule optional disclosure,
- status,
- Complete/Skip/Defer actions only when semantically allowed.

## SETTINGS

Top groups:
- Profile/Units/Locale
- Health Modules
- Integrations
- Notifications
- Privacy/Security
- Data Export/Backup
- Accessibility
- About/Versions.

Danger zone separated visually:
- delete module data
- delete profile/account.

## Global design rule

A screenshot is not an acceptance test.
The production UI must preserve semantic/state/accessibility contracts even if visual styling changes.


## v0.23 Preventive Care screen

Desktop:
`Due/Review summary | preventive service list | selected service explanation/source`

Mobile:
summary chips → service cards → detail sheet/page.

Each service card visibly separates:
- eligibility,
- recommendation mode,
- due state.

Do not use one red/green traffic-light state to represent all three.

Required empty/uncertain states:
- UNKNOWN_HISTORY
- NO_ACTIVE_JURISDICTION_PACK
- PACK_STALE
- PACK_CONFLICT
- INSUFFICIENT_CONTEXT.


---

<!-- SOURCE: 107_INTERACTIVE_SITE_PROTOTYPE_AND_PUBLISHING_CONTRACT.md -->

# INTERACTIVE SITE / WEB APP PROTOTYPE AND PUBLISHING CONTRACT

## Purpose

Human Health OS has two distinct implementation outputs:

1. the real cross-platform product, and
2. a polished interactive **web-based laboratory / demonstrator / configurator** that makes the product model explorable before or alongside the full application build.

The second output is the role of the **Site Build Prompt**.

It should resemble the interaction philosophy of a build laboratory:
- controls change the simulated body/profile,
- results recalculate immediately,
- multiple profiles can be compared,
- advanced modules can be toggled,
- defaults can be restored,
- the user can understand why an output changed.

It is not a static marketing landing page.
It is not a replacement for the production Android/iOS/Web application.

## Canonical name

Preferred artifact name:

`Human Health OS Interactive Lab`

Alternative labels:
- Human Health Build Lab
- Longevity ↔ Shortevity Lab
- Human Digital Twin Laboratory

The implementation may choose a final user-facing title, but the handoff concept is `INTERACTIVE_SITE_LAB`.

## Deployment target

The site should be able to be:
- published as a web experience / Site when the execution platform supports publishing,
- or exported as a normal deployable web application.

Do not depend on a proprietary publishing system for core functionality.

## Non-goal

This prompt does NOT ask the coding agent to build the native production app.
The native/cross-platform production app remains governed by `BUILD_LONGEVITY_APP.txt` and the Master Handoff.

## Required site character

The site should feel like an interactive scientific control room rather than a brochure.

Primary loop:

`SELECT / ENTER / SLIDE / TOGGLE → RECALCULATE → EXPLAIN → COMPARE`

## Main site areas

### 1. Human Profile Builder

Allow a synthetic profile to be configured with controls such as:
- age,
- height,
- weight,
- waist,
- body composition when enabled,
- blood pressure,
- resting heart rate,
- sleep,
- activity,
- smoking/alcohol exposure,
- selected lab values,
- conditions,
- medications/supplements,
- vaccination/prevention status,
- specialist advanced modules.

The first-load profile must be clearly synthetic/demo data.

### 2. Longevity ↔ Shortevity Dashboard

Show distinct channels:
- Protection / Resilience,
- Risk / Burden,
- Function / Capacity,
- Trajectory,
- Coverage / Confidence.

Validated clinical model outputs, if implemented in the site, must remain visually distinct from app-defined demo composites.

Never convert an app score directly into years of life gained/lost.

### 3. Compare Lab

Allow arbitrary comparison profiles in storage and practical multi-column comparison in UI.

Required actions:
- Add profile
- Clone scenario
- Rename
- Pin baseline
- Compare selected metrics
- Show absolute delta
- Reset scenario
- Delete scenario

Changing a scenario must not mutate the source profile.

### 4. Advanced Health Modules

Expose optional toggles for representative modules such as:
- Cardiovascular
- Oncology
- Metabolic/Endocrine
- Renal
- Respiratory
- Neurology/Cognition
- Dermatology
- Musculoskeletal
- Prevention
- Environment/Exposome

Turning a module off hides complexity. It does not imply deleting profile data.

### 5. Daily Missions Demo

Display deterministic tasks generated from installed demo rules.

Example:
`Bench Press — 3 × 10 @ 30 kg`

The UI must distinguish:
- PLAN
- ACTUAL COMPLETION

A notification or displayed mission is not completion.

### 6. Timeline

Display synthetic events such as:
- lab,
- vaccine,
- medication intake,
- workout,
- symptom,
- treatment,
- wearable measurement.

### 7. Labs / Trends

Allow demo lab values to be entered and charted with:
- units,
- dates,
- source/provenance,
- missingness,
- reference metadata.

Do not show missing values as zero.

### 8. Wearable Demo

Use generated local sample data for:
- sleep,
- steps,
- heart rate,
- resting heart rate,
- activity.

Do not require real HealthKit/Health Connect authorization for the public demo.
If real integrations are later added, they are separate authenticated/private capabilities.

### 9. Education

Add short contextual cards explaining:
- healthspan vs lifespan,
- risk vs score,
- personal baseline vs population reference,
- biological age limitations,
- correlation vs causation,
- data coverage/confidence.

### 10. Model Transparency

Every score/result card should offer a `How calculated?` view with:
- formula/model class,
- inputs,
- missing inputs,
- version,
- coverage,
- limitations.

## Reset behavior

Provide a prominent:

`Reset Demo to Defaults`

It resets only the synthetic site state.

If a future private/account-enabled version exists, settings reset must remain distinct from health-data deletion.

## Determinism

Core site calculations must be deterministic.

Same:
- profile inputs,
- rule version,
- model version

must produce the same outputs.

No LLM or generative-AI endpoint is required.

## Offline friendliness

For the standalone demo, prefer a client-side architecture where:
- synthetic profiles,
- formulas,
- rules,
- charts,
- education cards
can run without a backend after initial load.

A service worker/PWA is optional if it improves the implementation.

## Data policy

Public/demo site defaults to synthetic/local data.

Do not require users to enter real diagnoses, medication history or other sensitive health information into a public unauthenticated demo.

If a future authenticated version stores real health information, it becomes subject to the full security/privacy/account contracts in the Master Handoff.

## Design language

Desired feel:
- scientific,
- premium,
- dense but legible,
- modern dashboard,
- calm rather than alarmist,
- clear hierarchy,
- responsive,
- highly interactive.

Avoid:
- generic landing-page hero followed by feature cards only,
- fake medical certainty,
- neon casino-style health scores,
- red = death / green = healthy simplification,
- decorative controls that do not affect results.

## Responsive behavior

Mobile:
- stacked cards,
- bottom/compact navigation,
- compare via horizontal cards/tabs.

Desktop:
- persistent navigation,
- side-by-side profile editor and live results,
- wide comparison matrix,
- expandable model details.

## Accessibility

Target the same accessibility contract as the product handoff:
- keyboard web operation,
- semantic controls,
- accessible names,
- text scaling,
- non-color-only meaning,
- reduced-motion support.

## Required demo states

The site must demonstrate:
- empty/synthetic default,
- populated profile,
- comparison mode,
- offline/local state,
- missing input,
- not-eligible calculator,
- low coverage,
- reset-to-default.

## Technical freedom

The implementation agent may choose a modern web stack.

Reference preference:
- React/TypeScript, Next.js, Vite, or equivalent for a dedicated web lab,
- or Flutter Web if reusing the product code genuinely improves maintainability.

Do not choose a stack solely because it is fashionable.

## Deliverables

The Site-building agent should return:
- complete source,
- dependency lockfile,
- local run instructions,
- production build instructions,
- deployable web build or publishable Site artifact where supported,
- screenshots or preview only as supplemental evidence,
- test report,
- known limitations.

## Completion rule

A screenshot or static mockup is not completion.

PASS requires the controls to actually update deterministic site state and results in a running web build or publishing environment.


## v0.16 starter-pack integration

The Site Lab default runtime bundle is:
- REF-SYNTHETIC-DEMO-1
- MP-CORE-DERIVED-1
- RP-CORE-INVARIANTS-1
- EDU-HEALTH-LITERACY-FOUNDATION-1

Licensed external clinical models remain unavailable until their activation gates pass.
The Site must expose a Data Sources & Licenses panel.


## v0.17 help/golden-vector parity

The public Site must use the same app-owned CORE_DERIVED formula semantics and golden vectors as the production app contract.

The Site includes:
- zero-knowledge first-run tour,
- contextual help,
- generated Data Sources & Licenses page.

Site demonstration remains synthetic-first.


## v0.18 interoperability preview

The Site may expose a synthetic FHIR export preview for education.

It must label the asset:
`REFERENCE_MAPPING_EXAMPLE_NOT_PRODUCTION_VALIDATED`.

The Site does not require private-account RLS/database infrastructure for its synthetic local demo.


## v0.19 design-token parity

The Site Lab and production app share:
- semantic UI token roles,
- component state vocabulary,
- missing-not-zero behavior,
- result-class visibility.

The Site may implement a different visual composition, but it must preserve these semantics.


## v0.20 nutrition/platform demonstration

The Site Lab can demonstrate:
- synthetic wearable imports,
- source/provenance inspection,
- recipe/portion mathematics,
- missing nutrient coverage.

The Site must not imply HealthKit/Health Connect device integration is active unless real adapter/runtime work exists.


## v0.21 Document Lab

The Site Lab includes a synthetic source-document demonstration with separate attachment, staged-candidate, review and canonical-result layers. It must not silently turn parser output into health truth and requires no generative AI.\n

## v0.23 Preventive Care Lab

The Site Lab includes a synthetic deterministic preventive-care engine demonstrating jurisdiction, eligibility, due-state, series validity, shared-decision and pack-conflict semantics.

No real national preventive recommendation pack is required for the public demo.


---

<!-- SOURCE: 108_STARTER_MODEL_PACK_CATALOG.md -->

# STARTER MODEL PACK CATALOG

## Purpose

v0.16 changes pack infrastructure from an abstract concept into an initial, machine-readable starter catalog.

The catalog distinguishes:

1. **CORE_DERIVED** — transparent deterministic calculations owned by the app.
2. **APP_COMPOSITE** — app-defined scores with explicit non-clinical semantics.
3. **VALIDATED_EXTERNAL** — externally published clinical models that require source/license/eligibility review.
4. **RESEARCH_ONLY** — models that must not be presented as authoritative clinical output.
5. **REFERENCE_DATA** — datasets rather than prediction models.

A catalog entry is not proof that the model is clinically validated or legally bundleable.

---

# PACK MP-CORE-DERIVED-1

Status:
`BUNDLE_DEFAULT`

Purpose:
Basic transparent calculations that require no hidden coefficients.

Initial calculations:

### DERIVED-BMI-1
Formula:

`BMI = weight_kg / height_m²`

Output:
`kg/m²`

Important:
The number can be calculated without assigning a diagnostic category.
Population/clinical interpretation is a separate evidence/rule concern.

### DERIVED-WAIST_HEIGHT_RATIO-1

`WHtR = waist_same_length_unit / height_same_length_unit`

Output:
dimensionless ratio.

No universal “good/bad” threshold is bundled in this formula pack.

### DERIVED-PACK_YEARS-1

`pack_years = packs_per_day × years_smoked`

Requires:
- smoking exposure explicitly supplied,
- duration,
- packs/day or safely converted equivalent.

Output:
pack-years.

This is an exposure measure, not mortality probability.

### DERIVED-PERCENT_CHANGE-1

`percent_change = (new - baseline) / baseline × 100`

Guard:
baseline cannot be zero.

### DERIVED-ABSOLUTE_DELTA-1

`delta = comparison - baseline`

### DERIVED-TRAINING_VOLUME_LOAD-1

For external-load resistance exercise:

`volume_load = Σ(load × completed_reps)`

A planned set is excluded until completed.

### DERIVED-ROLLING_MEAN-1

Versioned rolling arithmetic mean over an explicitly declared time/window count.

### DERIVED-ROLLING_MEDIAN-1

Versioned rolling median.

### DERIVED-TREND-SLOPE-OLS-1

Simple ordinary least-squares slope for eligible clean numeric series.

Must declare:
- time axis,
- unit,
- number of observations,
- time window.

It is a trend estimator, not a clinical prediction.

### DERIVED-ROBUST_DEVIATION-MAD-1

When an eligible personal-baseline rule uses it:

`RobustZ = (x - median) / (1.4826 × MAD)`

Only when MAD > 0 and minimum-sample requirements are met.

---

# PACK MP-APP-COMPOSITES-1

Status:
`CANDIDATE`

Contains:
- ProtectionScore aggregation framework
- BurdenScore aggregation framework
- BalanceIndex
- Coverage
- data-quality aggregation hooks.

These are explicitly app-defined outputs.

They are NOT:
- mortality probabilities,
- diagnoses,
- life expectancy,
- validated clinical risk.

Activation requires:
- domain component definitions,
- source/evidence metadata,
- weight rationale,
- golden fixtures,
- UI labels.

---

# EXTERNAL MODEL CATALOG

## EXT-AHA-PREVENT

Type:
`VALIDATED_EXTERNAL_CANDIDATE`

Domain:
cardiovascular.

Current product interpretation:
AHA PREVENT equations can estimate cardiovascular risk for their documented eligible population.

Packaging state:
`LICENSE_ACCEPTANCE_REQUIRED_NOT_BUNDLED`

Requirements before activation:
- accept/currently satisfy AHA code license,
- retrieve approved implementation materials,
- pin version/source,
- implement eligibility exactly,
- build golden fixtures from authoritative examples,
- verify output semantics,
- document population transport limits,
- expose AHA attribution/trademark requirements if applicable.

No PREVENT coefficients are invented or copied into the handoff.

## EXT-BIOLOGICAL-CLOCK-REGISTRY

Type:
`RESEARCH_ONLY_REGISTRY`

No biological-age clock is bundled as “the true biological age”.

Individual future clock adapters require:
- publication/source,
- formula/weights legally available,
- validation population,
- required biomarkers,
- license,
- reproducibility fixtures,
- research/clinical label.

## EXT-ONCOLOGY-MODEL-REGISTRY

Type:
`VALIDATED_EXTERNAL_CANDIDATE_REGISTRY`

No universal cancer score is bundled.

Each future adapter is indexed by:
- cancer type,
- prediction purpose,
- population,
- endpoint,
- horizon,
- eligibility,
- license/source.

---

# ACTIVATION RULE

A model pack may be:
`DISCOVERED → REVIEWED → FIXTURE_VERIFIED → LICENSE_CLEARED → ACTIVE`

Where `LICENSE_CLEARED` is not required for wholly app-authored/public-domain calculations but is required when third-party rights/terms apply.

No model is ACTIVE merely because it appears in this catalog.


---

<!-- SOURCE: 109_STARTER_RULE_PACK_CATALOG.md -->




---

<!-- SOURCE: 10_LONGEVITY_EVIDENCE_AND_DETERMINISTIC_INSIGHTS.md -->

# LONGEVITY EVIDENCE AND DETERMINISTIC INSIGHTS

## Product rule

Longevity App does NOT require generative AI, an LLM, a chatbot, or a cloud inference service for its core functionality.

Core insights must be produced by:
- explicit formulas,
- validated clinical calculators,
- deterministic rule engines,
- local aggregations,
- versioned scoring models,
- curated educational content.

The application must remain useful offline.

## Evidence discipline

Longevity claims vary greatly in evidence strength.

Suggested evidence classes:

1. DIRECT_HUMAN_OUTCOME
2. VALIDATED_RISK_MARKER
3. HUMAN_OBSERVATIONAL
4. MECHANISTIC_HUMAN
5. ANIMAL_OR_CELL
6. EXPERT_OR_PRACTICE
7. PERSONAL_RESPONSE
8. SPECULATION

These classes must not be flattened into one certainty score.

## Deterministic insight examples

The app may calculate or display:
- rolling averages,
- trend slopes,
- percentage change,
- training volume,
- adherence,
- sleep regularity,
- resting heart-rate trend,
- weight/waist trend,
- laboratory trend,
- validated cardiovascular risk,
- preventive-care completion,
- task completion streak,
- data coverage.

Every derived result must identify:
- formula/model ID,
- version,
- source records,
- time window,
- limitations.

## No hidden model

If a result cannot be explained with a deterministic formula/rule or a documented validated model, it must not be shown as an authoritative calculated result.

## No fake longevity score

Do not claim:
- “this added 4.2 years to your life,”
- “this cream increased lifespan,”
- “your 83/100 score means you will live to 94,”
unless an applicable validated model explicitly supports that endpoint.

## Educational layer

Education is delivered through:
- curated offline lessons,
- glossary,
- source-linked explanation cards,
- deterministic “why this matters” templates,
- quizzes with authored answer keys,
- contextual educational prompts triggered by entered data.

Example:
A user logs blood pressure.
The app may show an offline card explaining what systolic and diastolic values mean.

The educational content must not convert itself into diagnosis or treatment instructions.

## Versioning

Derived deterministic results must store:
- calculation time,
- model/rule version,
- source record IDs,
- output,
- coverage,
- limitations.


---

<!-- SOURCE: 110_REFERENCE_DATA_AND_PROVIDER_PACK_CATALOG.md -->

# REFERENCE DATA AND PROVIDER PACK CATALOG

## Purpose

Define the initial external/reference packs and exactly how they enter the product.

## REF-SYNTHETIC-DEMO-1

Status:
`BUNDLE_DEFAULT`

Owner:
Longevity App / Human Health OS.

Contains:
- synthetic people,
- synthetic lab panels,
- synthetic wearable series,
- synthetic treatment/timeline records,
- synthetic comparison scenarios.

Public Site Lab should use this pack by default.

No record is a real person's health data.

## REF-WHO-GHE-LIFE-HALE

Type:
`REFERENCE_DATA_PACK`

Use:
- population life expectancy baseline,
- healthy life expectancy (HALE),
- geography/year metadata.

Status:
`EXTERNAL_DATA_ATTRIBUTION_REQUIRED`

Rules:
- pin dataset/version/retrieval date,
- preserve WHO metadata,
- display population-baseline label,
- never call it a personal prediction,
- include required attribution,
- re-check WHO dataset terms before each production data refresh.

## REF-USDA-FDC

Type:
`FOOD_PROVIDER_REFERENCE`

Use:
generic/foundation/survey/branded nutrient data.

Status:
`EXTERNAL_API_OR_CACHE_ALLOWED`

Rules:
- API key never shipped publicly,
- provider data normalized into canonical food model,
- logged FoodSnapshot remains immutable,
- source attribution retained.

## REF-OPEN-FOOD-FACTS

Type:
`FOOD_PROVIDER_REFERENCE`

Use:
barcode/package/ingredients/allergens/product data.

Status:
`LICENSED_EXTERNAL_PROVIDER`

Rules:
- comply with current ODbL/DbCL terms,
- images have separate CC BY-SA/third-party considerations,
- maintain attribution,
- do not casually rebundle a local database dump without license review,
- API/schema version is pinned.

## REF-UCUM

Type:
`UNIT_TERMINOLOGY_PACK`

Use:
canonical machine-readable unit representation.

Status:
`LICENSED_STANDARD`

Rules:
- preserve source units,
- comply with UCUM license conditions,
- do not modify/rebrand the UCUM specification as a new unit standard,
- include required notices when reproducing/distributing the Work.

## REF-HL7-FHIR

Type:
`INTEROPERABILITY_STANDARD_REFERENCE`

Use:
external adapter semantics only.

Status:
`STANDARD_REFERENCE`

Rules:
- internal schema remains independent,
- current published FHIR release is rechecked at implementation,
- third-party terminologies referenced by FHIR require their own license review,
- FHIR trademarks must not imply HL7 endorsement.

## REF-TERMINOLOGY-PLACEHOLDER

Type:
`TERMINOLOGY_PACK_REGISTRY`

Examples of future terminology systems may require separate licensing.

Default:
`DO_NOT_BUNDLE_UNTIL_LICENSE_REVIEW`

Unknown/unmapped clinical concepts remain UNMAPPED rather than guessed.


## v0.23 Preventive reference sources

Metadata/source adapters:
- `REF-US-CDC-IMMUNIZATION`
- `REF-US-USPSTF`
- `REF-WHO-PREVENTION`
- `REF-TR-MOH-VACCINATION`

They are not bundled clinical rules by default.


---

<!-- SOURCE: 111_EDUCATION_STARTER_PACK.md -->

# EDUCATION STARTER PACK

## Pack

`EDU-HEALTH-LITERACY-FOUNDATION-1`

Status:
`BUNDLE_DEFAULT`

Languages:
- English starter strings
- Turkish starter strings

The starter content is educational and non-diagnostic.

## Lesson sequence

### EDU-001 — Measurement, fact and interpretation
Teach:
- measured value
- source
- unit
- interpretation
- why they are separate.

### EDU-002 — Missing does not mean zero
Teach:
- missing,
- not measured,
- not applicable,
- zero are different states.

### EDU-003 — Source and provenance
Teach:
manual entry vs wearable vs laboratory vs imported document vs derived result.

### EDU-004 — Units matter
Teach:
why mg/dL, mmol/L, kg, cm and other units cannot be freely interchanged.

### EDU-005 — Reference interval vs personal baseline
Teach:
lab/provider reference interval is not the same as a person's historical baseline.

### EDU-006 — Population baseline vs personal prediction
Teach:
life expectancy/HALE population statistics are not guaranteed individual outcomes.

### EDU-007 — Risk probability
Teach:
a 10-year risk estimate has a defined endpoint, horizon and eligible population.

### EDU-008 — Validated clinical result vs app score
Teach:
app composite 0–100 is not automatically a clinical probability.

### EDU-009 — Correlation vs causation
Teach:
two things moving together or one occurring after another does not prove cause.

### EDU-010 — Plan vs completed behavior
Teach:
a scheduled workout/medicine/reminder is not proof that it happened.

### EDU-011 — Scenario vs observed body
Teach:
Digital Twin scenario patches are hypothetical calculations.

### EDU-012 — Healthspan vs lifespan
Teach:
living longer and living with preserved function/quality of life are related but distinct concepts.

### EDU-013 — Data coverage and confidence
Teach:
a precise-looking number can still be weak when inputs are incomplete or poor quality.

### EDU-014 — Wearable data
Teach:
sensor measurements, aggregates and clinical measurements have different contexts.

### EDU-015 — Why corrections preserve history
Teach:
correcting a wrong record should not erase that an earlier record existed.

## Quiz style

Each lesson may contain:
- 1 short explanation
- 1 concrete example
- 2 multiple-choice questions
- 1 transfer question
- authored answer/rationale.

## Example question

Question:
“A result is absent from a lab report. What value should the app store?”

Correct concept:
`NOT_REPORTED / missing state`, not `0`.

## Learning semantics

- viewed lesson ≠ understood
- quiz completed ≠ health improvement
- learning XP ≠ health score
- later review can test recall independently.

## Offline

The entire foundation pack is locally bundleable.


---

<!-- SOURCE: 112_THIRD_PARTY_LICENSE_AND_ATTRIBUTION_MATRIX.md -->

# THIRD-PARTY LICENSE AND ATTRIBUTION MATRIX

Checked: 2026-10-06

This is an engineering compliance register, not legal advice.
Terms must be reverified before production release or data refresh.

## Categories

- `BUNDLE_DEFAULT`
- `BUNDLE_WITH_NOTICE`
- `EXTERNAL_API`
- `LICENSE_ACCEPTANCE_REQUIRED`
- `VERIFY_BEFORE_BUNDLE`
- `DO_NOT_BUNDLE_BY_DEFAULT`

## USDA FoodData Central

Material:
FoodData Central data.

Observed terms:
Public domain / CC0 1.0 Universal.
USDA requests source citation.

Engineering disposition:
`EXTERNAL_API` and cached normalized data permitted subject to current API terms.

Important:
API key must not be exposed in distributed clients.

Suggested source attribution:
FoodData Central / U.S. Department of Agriculture, Agricultural Research Service.

## Open Food Facts

Material:
database, individual contents, product images.

Observed:
- database: Open Database License (ODbL)
- contents: Database Contents License
- images: CC BY-SA, with possible embedded third-party graphical rights.

Disposition:
`VERIFY_BEFORE_BUNDLE`

Preferred initial architecture:
provider API + local cache of user-used foods rather than redistributing a giant database snapshot.

Attribution/terms must be implemented.

## WHO data.who.int datasets

Observed default:
CC BY 4.0 unless a dataset says otherwise, plus WHO dataset terms.

Required:
- dataset-specific metadata/citation,
- no implication of WHO endorsement,
- do not use WHO name/emblem as product branding without permission,
- check whether individual dataset credits a third-party source.

Disposition:
`BUNDLE_WITH_NOTICE` only for deliberately versioned downloaded datasets after current-term review; otherwise external reference/provider.

## UCUM

Material:
UCUM specification/work.

Observed:
custom UCUM License Version 1.1, June 2024.

The license allows development/commercialization of software interoperating with the Work subject to conditions.

Important:
- do not modify the specification into a competing/altered standard,
- include required notices when reproducing/distributing the Work in its entirety,
- preserve license/disclaimer links.

Disposition:
`BUNDLE_WITH_NOTICE` only after implementation review of exactly what UCUM material is distributed.

## HL7 FHIR

Material:
FHIR specification developed by HL7.

Observed:
FHIR specification is made available under CC0, with trademark rules.
FHIR pages may contain third-party artifacts/terminologies not covered by that license.

Disposition:
`BUNDLE_DEFAULT` for app-authored adapter code referencing the standard; `VERIFY_BEFORE_BUNDLE` for copied specification/terminology artifacts.

Trademark:
do not imply HL7 endorsement or use FHIR as product branding contrary to trademark rules.

## American Heart Association PREVENT

Material:
PREVENT equation source code/implementation materials.

Observed:
AHA provides source-code access at no cost through a license agreement, including for companies providing health risk assessment tools.

Disposition:
`LICENSE_ACCEPTANCE_REQUIRED`

The handoff does NOT bundle coefficients/source code.
Implementation must obtain/accept current license terms before integrating code.

## Apple / Android platform APIs

Material:
HealthKit, UserNotifications, Keychain, Health Connect, Android Keystore and related SDK APIs.

Disposition:
`PLATFORM_SDK_TERMS`

Use supported platform SDKs under current developer/program terms.
Do not copy vendor documentation wholesale into app content.

## Unknown terminology systems

SNOMED CT and other third-party terminology content can have jurisdiction/licensing requirements.

Disposition:
`DO_NOT_BUNDLE_BY_DEFAULT`

Add only after explicit licensing review.

## Required attribution surface

Production app/site should provide:

`Settings / About → Data Sources & Licenses`

At minimum list every active third-party:
- name,
- purpose,
- version/data date,
- license/terms link or notice,
- attribution,
- no-endorsement statement where required.

## Build gate

If a pack has:
- `LICENSE_ACCEPTANCE_REQUIRED`,
- `VERIFY_BEFORE_BUNDLE`,
- unknown terms,

the build agent may implement an adapter interface and synthetic fixture,
but must not falsely mark third-party production integration `ACTIVE`.


---

<!-- SOURCE: 113_EXECUTABLE_SCHEMA_STARTER_SET.md -->

# EXECUTABLE SCHEMA STARTER SET

## Purpose

The handoff now includes actual JSON Schema starter files rather than prose-only entity descriptions.

Directory:
`starter_schemas/`

These schemas are an implementation bootstrap.
They do not replace the full canonical data model or API/OpenAPI generation.

## Included starter schemas

- `health_fact.schema.json`
- `lab_result.schema.json`
- `score_result.schema.json`
- `mission.schema.json`
- `comparison_profile.schema.json`
- `pack_manifest.schema.json`
- `import_batch.schema.json`

## Required behavior

A future implementation may:
- generate Dart/Python/TypeScript types,
- validate API fixtures,
- validate import payloads,
- validate local pack manifests,

from these schemas.

## Schema rules

- IDs are strings with stable identity semantics.
- UTC/offset-aware timestamps use ISO 8601 strings.
- enums are explicit.
- missing optional value is absent/null, not automatically zero.
- source/provenance fields remain available.
- schema version is explicit.
- unknown extra fields should be handled according to migration/version policy, not silently discarded without review.

## Evolution

When schema changes:
1. bump schema version,
2. add migration,
3. preserve old fixture,
4. run compatibility test,
5. update API/OpenAPI mapping,
6. update portable export/restore.

## Non-goal

These starter schemas are not a claim that the entire production database should be one JSON-document store.


---

<!-- SOURCE: 114_PACK_FIXTURE_ACTIVATION_AND_LICENSE_GATES.md -->




---

<!-- SOURCE: 115_SITE_LAB_STARTER_PACK_AND_DEMO_DATA_CONTRACT.md -->

# SITE LAB STARTER PACK AND DEMO DATA CONTRACT

## Purpose

Make the Interactive Site Lab useful immediately without real user health data or licensed clinical code.

## Required default demo set

### Synthetic profiles
At least:
- `SYNTH-BASIC-A`
- `SYNTH-HIGH-BURDEN-B`
- `SYNTH-ACTIVE-C`
- `SYNTH-SCENARIO-BASE`

All visibly labeled synthetic.

### Built-in calculations
The Site may execute starter `CORE_DERIVED` formulas:
- BMI
- waist-to-height ratio
- pack-years
- delta / percent change
- simple trend/rolling summaries
- training volume from completed sets.

### App-defined demonstration scores
If shown:
- label APP_DEFINED_DEMO,
- expose formula/weights,
- never call them clinical risk,
- resettable with the demo.

### External model cards
AHA PREVENT or future clinical models may appear only as:
- unavailable until licensed/implemented,
- or genuinely integrated after activation gates pass.

No fake clinical-risk percentage.

### Reference/demo data
Default public Site:
- synthetic population/reference tables may be bundled,
- any real WHO/reference dataset must include source/version/attribution.

### Education
Bundle `EDU-HEALTH-LITERACY-FOUNDATION-1`.

### Attribution
Site footer/About should expose:
- app-authored synthetic demo label,
- third-party source/license panel for actually active external data.

## Reset

`Reset Demo to Defaults`
restores:
- synthetic profiles,
- demo settings,
- starter pack selection.

It never claims to delete a real user's external/provider data.

## Persistence

Public demo may use local browser storage.
It must offer:
`Clear Local Demo Data`.

## Share

If scenario URL/share state is implemented:
- contain only synthetic/configuration state by default,
- warn before embedding real health data in a URL.

## Offline/publish behavior

Static-hosting-friendly implementation is preferred for the public demo where possible:
- client-side deterministic calculations,
- bundled synthetic packs,
- no secret API key in browser.

Provider-backed real data can be a separate server-side capability.


---

<!-- SOURCE: 116_GOLDEN_VECTORS_AND_REFERENCE_FIXTURES.md -->

# GOLDEN VECTORS AND REFERENCE FIXTURES

## Purpose

A formula is not implementation-ready until the handoff contains known inputs and expected outputs.

A **golden vector** is a deterministic test case:

`model/rule version + exact inputs → expected output`

Golden vectors verify arithmetic and semantics.
They do NOT prove clinical validity.

## Required properties

Each vector stores:
- vector_id
- model_id or rule_id
- version
- exact inputs
- expected output/state
- tolerance when numeric
- expected error when invalid
- note/rationale.

## Core derived vectors

v0.17 includes executable vectors for:

- BMI
- waist-to-height ratio
- pack-years
- absolute delta
- percentage change
- completed resistance-training volume load
- rolling mean
- rolling median
- OLS trend slope
- robust MAD-based deviation.

## Rule vectors

v0.17 also includes semantic rule fixtures for:

- missing ≠ zero
- reminder ≠ completion
- plan ≠ completion
- scenario ≠ observation
- invalid calculation ≠ fake zero
- reset ≠ delete
- tombstone no-resurrection.

## Reference implementation

Directory:

`reference_code/`

contains a small standard-library Python implementation of the app-owned CORE_DERIVED formulas.

Its purpose is:
- executable specification,
- golden-vector validation,
- coding-agent cross-check.

It is NOT the required production language/runtime.

A Flutter/Dart implementation may replace it while remaining mathematically equivalent.

## Tolerance

Floating-point comparisons declare tolerance explicitly.

Do not “fix” a failing golden vector by widening tolerance without recording a model/version decision.

## Clinical models

Third-party clinical models require authoritative golden/reference examples from their source/license package.

Do not invent reference vectors for a model whose implementation materials are unavailable.


---

<!-- SOURCE: 117_DATABASE_DDL_CONSTRAINT_INDEX_BLUEPRINT.md -->

# DATABASE DDL, CONSTRAINT AND INDEX BLUEPRINT

## Purpose

Translate the canonical health semantics into concrete persistence constraints.

v0.17 includes two reference schemas:

- `database_blueprints/postgres_reference.sql`
- `database_blueprints/sqlite_reference.sql`

These are implementation blueprints, not a claim that production migrations have been run against PostgreSQL.

SQLite schema execution is validated in this handoff.
PostgreSQL remains static blueprint until a PostgreSQL runtime is available.

## Core tables covered

- profiles
- health_facts
- lab_sessions
- lab_results
- score_results
- missions
- comparison_profiles
- scenario_patches
- reminders
- pack_manifests
- outbox_mutations
- sync_state
- audit_events
- import_batches

## Invariants encoded where practical

### Stable identity
Primary keys are explicit stable IDs.

### Profile ownership
Every private health resource carries `profile_id`.

### Missing != zero
Lab missingness uses a state field.
A missing state does not require a numeric value.

### PRESENT requires a value
For the numeric starter LabResult:
`PRESENT → numeric_value IS NOT NULL`.

### Plan != completion
Mission status is constrained to explicit lifecycle states.

### Scenario isolation
Scenario patches reference a comparison profile and source/base state rather than rewriting health history.

### Soft delete / tombstone
Canonical mutable/syncable tables carry `deleted_at` where applicable.

### Model reproducibility
ScoreResult stores model ID/version and input record IDs.

### Outbox idempotency
`mutation_id` is unique.

### Pack identity
Pack ID + version is unique.

## Index strategy

Minimum high-value indexes:

- `(profile_id, effective_at)`
- `(profile_id, observed_at)`
- `(profile_id, analyte_key, observed_at)`
- `(profile_id, calculated_at)`
- `(profile_id, generated_for_date)`
- external/source IDs where present
- outbox pending order
- sync revision/cursor fields.

## Delete policy

The reference kernel intentionally avoids broad cascading deletion of health history.

Account/profile erasure should be an explicit controlled workflow, not an accidental foreign-key cascade.

## JSON payloads

PostgreSQL may use JSONB for structured payloads.
SQLite reference stores equivalent payloads as TEXT containing JSON.

Domain-critical searchable fields should not be hidden exclusively inside opaque JSON.


---

<!-- SOURCE: 118_LOCAL_SQLITE_SERVER_POSTGRES_PARITY.md -->

# LOCAL SQLITE AND SERVER POSTGRES PARITY

## Goal

Mobile local-first and server canonical storage may use different database engines while preserving the same health semantics.

## Semantic parity

The following must mean the same on both sides:

- record identity
- profile ownership
- event time
- correction link
- source/provenance
- missingness
- soft-delete/tombstone
- model/rule version
- revision/idempotency.

## Differences are allowed

PostgreSQL may provide:
- JSONB
- richer indexing
- server-side constraints/triggers
- concurrent transaction capabilities.

SQLite may use:
- TEXT JSON
- application-assisted validation for features not expressible identically,
- local outbox state.

The product invariant is semantic equivalence, not SQL-text equivalence.

## Migration contract

Each server migration should have:
- compatible local migration decision,
- export/restore impact,
- fixture upgrade path,
- rollback strategy,
- schema version change.

## Foreign keys

SQLite connections must enable foreign-key enforcement.

A schema that declares foreign keys while runtime leaves them disabled does not satisfy the contract.

## Timestamps

Canonical transport uses unambiguous ISO 8601 timestamps.
PostgreSQL server storage should use timezone-aware timestamps where appropriate.
SQLite stores normalized textual timestamps plus application validation.

## JSON

Invalid JSON in structured fields must not silently become valid canonical data.

Production implementation should validate JSON payloads using generated types/schema before persistence.

## IDs

Production implementation may use UUIDv7 when reliable across target runtimes or another collision-resistant globally unique ID.

The DDL uses text/UUID-compatible IDs without requiring one generator in this blueprint.


---

<!-- SOURCE: 119_ZERO_KNOWLEDGE_ONBOARDING_HELP_MANUAL.md -->

# ZERO-KNOWLEDGE ONBOARDING AND HELP MANUAL

## Audience

Assume the user knows nothing about:
- biomarkers,
- medical risk,
- provenance,
- healthspan,
- lifespan,
- model eligibility,
- confidence,
- Digital Twin.

The app must teach these ideas as they become relevant.

## First-run path

### Step 1 — Choose storage/account mode

Explain:

**Local only**
Data stays on this device unless the user exports it.

**Cloud account**
Allows supported cross-device synchronization.

Do not imply local-only is an inferior demo mode.

### Step 2 — Create a profile

Minimum profile can be almost blank.

Do not require medical history merely to enter the app.

### Step 3 — Explain the core loop

`Enter / import → timeline → calculations → results → compare / act / learn`

### Step 4 — Add one fact

Suggested tutorial:
weight or a Mind Check-in.

Teach:
- value
- date
- unit/source
- save.

### Step 5 — Show provenance

“This value was entered manually.”

### Step 6 — Results literacy

Explain four separate concepts:

- raw fact
- derived measurement
- validated risk
- app-defined score.

### Step 7 — Longevity ↔ Shortevity

Explain:
- protective/resilience signals
- risk/burden signals
- function/capacity
- confidence/coverage.

Do not teach Shortevity as a standard medical diagnosis.

### Step 8 — Compare

Offer a SYNTHETIC profile first.

Teach that scenario changes do not rewrite the user's body/history.

### Step 9 — Daily Missions

Explain:
a mission is a plan.
Completion requires an actual completion event.

### Step 10 — Wearables

Permissions are optional.
Manual input remains available.

### Step 11 — Privacy and export

Show:
- local/cloud state
- permissions
- export
- delete
- Data Sources & Licenses.

## Help topics

Required evergreen help:

- What is healthspan?
- What is lifespan?
- What is Shortevity in this app?
- What is provenance?
- What does coverage mean?
- Why is a value UNKNOWN?
- Why is a calculator NOT_ELIGIBLE?
- App score vs clinical risk
- Population baseline vs personal prediction
- Scenario vs real data
- Plan vs completion
- Reset vs delete
- Why a correction preserves history
- What happens offline?
- What data leave my device?
- What is a model/rule pack?

## Error-oriented help

Help should answer:
1. What happened?
2. Was my data saved?
3. Can I safely retry?
4. What should I do next?

## Progressive disclosure

Basic user:
plain language.

Advanced:
inputs/formula/eligibility.

Expert:
model version, pack checksum, provenance graph, raw fixtures.

The same canonical result powers all three views.


---

<!-- SOURCE: 11_API_AND_BACKEND_CONTRACT.md -->

# API AND BACKEND CONTRACT

This is a functional contract, not a frozen framework choice.

## Responsibilities

Backend should provide:
- authentication/session services,
- account-scoped CRUD for health records,
- sync endpoints,
- food-provider proxy/adapters where secrets or rate control are required,
- export,
- deletion workflows,
- derived analytics when server-side,
- audit/security controls.

## API design requirements

- versioned API,
- authenticated user scoping,
- consistent error envelope,
- validation errors distinguishable from server errors,
- pagination for long history,
- idempotency strategy where duplicate writes are risky,
- explicit timestamps,
- stable IDs,
- optimistic concurrency or revision mechanism for sync-sensitive updates.

## Conceptual endpoints

Authentication details depend on chosen provider.

Examples:

- `GET /v1/me`
- `GET /v1/timeline`
- `POST /v1/mind-checkins`
- `POST /v1/lab-sessions`
- `POST /v1/lab-sessions/{id}/results`
- `GET /v1/analytes/{code}/series`
- `POST /v1/conditions`
- `POST /v1/symptoms`
- `POST /v1/meals`
- `POST /v1/meals/{id}/foods`
- `GET /v1/foods/search`
- `GET /v1/foods/barcode/{barcode}`
- `POST /v1/custom-foods`
- `POST /v1/vitals`
- `POST /v1/activity`
- `POST /v1/sleep`
- `GET /v1/export`

Exact route structure may be refined.

## Food provider boundary

Mobile/web clients should not contain provider secrets that must remain confidential.
Use backend mediation where needed.

## Error semantics

Examples:
- 400 malformed request,
- 401 unauthenticated,
- 403 authenticated but forbidden,
- 404 record not found,
- 409 revision/conflict,
- 422 validation,
- 429 provider/app rate limit,
- 5xx backend/provider failure.

Do not convert provider failures into zero-valued nutrition.

## API contracts

Generate OpenAPI or equivalent machine-readable documentation from implementation.


---

<!-- SOURCE: 120_CLINICIAN_AND_EXPORT_REFERENCE_EXAMPLES.md -->

# CLINICIAN AND EXPORT REFERENCE EXAMPLES

## Purpose

Remove ambiguity around what a shareable health summary actually looks like.

Machine-readable examples live in:

`export_examples/`

All v0.17 examples are synthetic.

## Clinician lab summary

Must show:
- profile label
- generated date
- selected date range
- analyte
- result
- source unit
- reference information when present
- source/provenance
- correction state.

It must not:
- call app interpretation a clinician diagnosis,
- hide that data were user-entered/imported,
- convert missing to zero.

## General clinician summary

May include:
- active conditions
- medications/supplements
- allergies
- recent labs
- vitals
- treatment episodes
- function/pain
- selected app-derived results.

App-derived results must identify their result class and model version.

## Portable export

The export envelope should identify:
- export schema version
- app version
- profile
- included modules
- time range
- records
- provenance
- model/rule/content versions
- checksums where used.

## Synthetic marker

Every reference example in this handoff includes:

`"synthetic": true`

A coding agent must never convert these examples into real-user defaults.

## Human-readable report

A future PDF/report renderer should be generated from canonical report data, not maintain a second hidden health database.


---

<!-- SOURCE: 121_ATTRIBUTION_NOTICE_AND_LICENSE_PAGE_GENERATOR.md -->




---

<!-- SOURCE: 122_SEED_MIGRATION_AND_REFERENCE_BOOTSTRAP.md -->

# SEED, MIGRATION AND REFERENCE BOOTSTRAP

## Seed rule

Production seed data must contain configuration/reference data, not invented personal health history.

Allowed:
- app-owned starter pack metadata
- synthetic demo profiles explicitly marked synthetic
- unit/terminology configuration as licensed
- education content
- model/rule metadata.

Not allowed as real-user defaults:
- diagnosis
- medication
- weight
- diet
- lab result
- treatment history.

## Synthetic demo seed

Reference:
`database_blueprints/seed_sqlite_demo.sql`

The seed can be run repeatedly without duplicating the fixed synthetic profile IDs.

## Migration order

Reference sequence:

1. schema metadata
2. profiles
3. canonical event/fact tables
4. specialized health tables
5. derived/model tables
6. orchestration/reminder tables
7. sync/outbox
8. import/audit/pack tables
9. indexes
10. starter reference metadata.

## Migration receipt

A migration run should record:
- from version
- to version
- started/finished
- result
- fixture counts
- error
- rollback/recovery state.

## Fixture gate

Before migration is called successful:
- old fixture loads,
- migration runs,
- invariant tests pass,
- record counts/links match expectations,
- export/restore still recognizes migrated records.

## Seed is not migration

Seed failures and schema migration failures are different classes.

Do not rerun destructive migration logic merely because demo seed failed.


---

<!-- SOURCE: 123_CANONICAL_DATA_DICTIONARY.md -->

# CANONICAL DATA DICTIONARY

## Purpose

Prevent different modules from assigning different meanings to the same field name.

Machine-readable source:
`DATA_DICTIONARY.json`

## Core semantic terms

### `profile_id`
The canonical subject/profile to whom a health record belongs.

### `user_id`
Authenticated account owner/actor. A user may own multiple comparison/synthetic profiles.

### `effective_at`
When a fact/event is considered true or occurred in the health timeline.

### `recorded_at`
When the system recorded the fact.

### `created_at`
Persistence creation timestamp.

### `updated_at`
Last persistence update timestamp.

### `deleted_at`
Soft-delete/tombstone timestamp. Presence does not erase history.

### `corrects_id`
Links a correction to an earlier record.

### `source_type`
How the record entered the system: manual/device/lab/provider/document/API/derived/synthetic/unknown.

### `source_unit`
The unit exactly as supplied by source.

### `canonical_unit_code`
Machine-readable normalized unit code when safely mapped.

### `model_id` / `model_version`
Exact mathematical model identity used for a result.

### `rule_id` / `rule_version`
Exact deterministic rule identity used for an action/decision.

### `coverage`
How much of an eligible calculation's expected input/domain coverage is available.
Coverage is not confidence and not health status.

### `confidence`
A declared data/model confidence class or metric.
Confidence is not risk.

### `status`
Must be interpreted in the entity's lifecycle.
Never reuse one global ambiguous status vocabulary.

### `synthetic`
Marks data/profile created for demo/test rather than a real person's observed health history.

## Time semantics

Do not overload:
- event time,
- source report time,
- import time,
- calculation time.

If multiple meanings matter, store separate fields.


---

<!-- SOURCE: 124_TRANSACTION_INTEGRITY_AND_RECALCULATION_PROTOCOL.md -->

# TRANSACTION, INTEGRITY AND RECALCULATION PROTOCOL

## Goal

A saved health fact and the calculations that depend on it must not drift into silently inconsistent states.

## Canonical write transaction

For a local canonical write:

1. validate input
2. write canonical record/correction
3. write local outbox mutation when syncable
4. commit
5. publish/invoke post-commit invalidation
6. recompute derived views asynchronously or deterministically on read.

Do not publish an event before the canonical transaction commits.

## Derived results

Derived ScoreResult is reproducible cache/history, not raw truth.

When an input is corrected:
- preserve old ScoreResult snapshot,
- mark current projection stale/invalidate,
- compute a new result with new input IDs/version.

## Dependency invalidation

Invalidation uses typed dependency edges.

Example:

`LabResult LDL corrected`
→ cardiovascular calculation invalidated
→ Results card stale
→ Compare/Twin affected scenarios recalculated.

It should not invalidate unrelated sleep history.

## Crash behavior

If crash occurs:
- before commit: no canonical write
- after commit but before derived recompute: canonical record survives; derived state is STALE and recoverable
- after server commit but before client response: idempotency resolves retry.

## Transaction boundary

Do not include unreliable remote network calls inside a local DB transaction.

Use outbox/saga-style coordination.

## Referential integrity

A correction must reference an existing visible/owned record unless an import/migration recovery workflow explicitly handles an orphan.

## Stale UI

UI may briefly display cached result with:
`STALE / recalculation pending`

It must not present a known-stale result as freshly calculated.

## Rebuild

The system must support rebuilding projections/derived results from:
- canonical events/facts
- corrections
- active policies
- model/rule versions.

This is a Human OS continuity requirement.


---

<!-- SOURCE: 125_MIGRATION_SEQUENCE_AND_COMPATIBILITY_CONTRACT.md -->

# MIGRATION SEQUENCE AND COMPATIBILITY CONTRACT

## Purpose

The project now includes an explicit migration chain instead of only a final-state DDL snapshot.

Migration assets:

- `migrations/sqlite/0001_profiles.sql`
- `migrations/sqlite/0002_health_core.sql`
- `migrations/sqlite/0003_models_missions_compare.sql`
- `migrations/sqlite/0004_sync_packs_audit.sql`

Server equivalents:

- `migrations/postgres/0001_profiles.sql`
- `migrations/postgres/0002_health_core.sql`
- `migrations/postgres/0003_models_missions_compare.sql`
- `migrations/postgres/0004_sync_packs_audit.sql`

## Rules

1. A migration is append-only after release.
2. Never edit an already released migration to “fix history”.
3. Corrections are added as a later migration.
4. Schema version changes are explicit.
5. A failed migration cannot mark the database current.
6. Old fixture data must survive supported upgrades.
7. Migration success requires integrity tests, not merely SQL execution.
8. Seed/demo data are separate from schema migrations.
9. Local SQLite and server PostgreSQL may use different SQL while preserving semantic parity.
10. Rollback strategy is explicit per migration.

## SQLite version tracking

Use `PRAGMA user_version` as a simple local schema-version signal.

Reference chain:

- 0001 → user_version 1
- 0002 → user_version 2
- 0003 → user_version 3
- 0004 → user_version 4

The production repository may additionally maintain a richer migration receipt table.

## Upgrade fixture

v0.18 validates:

`empty → 0001 → insert synthetic profile → 0002 → 0003 → 0004`

and verifies the pre-upgrade profile still exists.

It also validates:

`empty → 0001 → 0002 → 0003 → 0004`

as a fresh install.

## Failure behavior

If migration N fails:

- transaction rolls back where supported,
- schema version remains at the previous successful version,
- startup enters migration recovery/error state,
- app does not silently continue using partially migrated semantics.

## Destructive change

Dropping/renaming a canonical field requires:

- migration design,
- export/restore review,
- sync compatibility review,
- fixture upgrade test,
- rollback or recovery path,
- versioned API compatibility decision.

## Production truth

SQLite migration chain is executed during this handoff build.

PostgreSQL migrations are included as static reference assets only.
They remain `NOT_RUN` until a real PostgreSQL test environment executes them.


---

<!-- SOURCE: 126_SERVER_AUTHORIZATION_AND_POSTGRES_RLS_BLUEPRINT.md -->

# SERVER AUTHORIZATION AND POSTGRES ROW-LEVEL SECURITY BLUEPRINT

## Purpose

UI hiding is not authorization.

Every server request touching private health data must enforce ownership/permission server-side.

## Authorization layers

1. Authentication
   - Who is the account/session?

2. Request authorization
   - Is this user allowed to perform this action?

3. Database defense-in-depth
   - Row-level security (RLS) can restrict rows by owner/authorized profile.

RLS is defense-in-depth and does not replace application authorization logic.

## Ownership model

`profiles.owner_user_id` is the primary ownership anchor for ordinary private profiles.

Child resources reference `profile_id`.

Access rule concept:

`current user owns the profile that owns the resource`

Future shared/collaborator access requires explicit permission tables.
Do not silently overload `owner_user_id` to mean collaborator.

## PostgreSQL session context

Reference blueprint uses a transaction-scoped/request-scoped setting:

`app.user_id`

The production backend must:

- authenticate the request first,
- set user context only from trusted server-side authentication state,
- never accept raw user ID from client as authorization proof,
- clear/reset context through connection-pool transaction boundaries.

## RLS reference asset

`database_blueprints/postgres_rls_reference.sql`

The blueprint enables and forces RLS for selected user-owned tables.

It includes policies for:
- profiles
- health_facts
- lab_sessions
- lab_results
- score_results
- missions
- comparison_profiles
- scenario_patches
- reminders
- outbox_mutations
- sync_state
- audit_events
- import_batches.

`pack_manifests` are application/global configuration and use a separate administrative authorization model.

## Cross-user rule

User A must not be able to read or mutate User B's profile by guessing:
- profile ID
- lab ID
- fact ID
- score ID
- mission ID
- scenario ID.

Returning 404 vs 403 is an API information-disclosure design choice.
The important invariant is no cross-user data disclosure.

## Service/admin roles

Database owner/service migrations can bypass RLS depending on role configuration.

Production architecture must define:
- migration role,
- application runtime role,
- background worker role,
- support/admin access path.

Do not run ordinary API traffic as a superuser/database owner.

## Real-other profiles

A `REAL_OTHER` comparison profile still belongs to the creating account unless future explicit sharing semantics say otherwise.

It does not grant access to another person's real account.

## Audit

Sensitive authorization failures should emit sanitized audit/security events without copying health payload.

## Runtime evidence honesty

v0.18 validates authorization logic using machine-readable semantic vectors.

The PostgreSQL RLS SQL itself is `STATICALLY_VERIFIED / NOT_RUN`, because this handoff build does not run a PostgreSQL server.


---

<!-- SOURCE: 127_EXECUTABLE_REPOSITORY_SCAFFOLD.md -->

# EXECUTABLE REPOSITORY SCAFFOLD

## Purpose

The handoff now includes a concrete repository bootstrap under:

`repository_scaffold/`

It is intentionally small.
It demonstrates repository boundaries and verification wiring without pretending the production application has already been built.

## Layout

```text
repository_scaffold/
  README.md
  .env.example
  apps/
    api/
      README.md
    client/
      README.md
    site/
      README.md
  packages/
    contracts/
      README.md
    domain/
      README.md
    persistence/
      README.md
  scripts/
    verify_contracts.py
```

## Ownership

### apps/api
HTTP/auth/sync/server orchestration.

It does not own medical formulas.

### apps/client
Android/iOS/responsive authenticated application shell.

### apps/site
Published interactive Site Lab/demo.

### packages/contracts
JSON Schema, API envelopes and generated contract types.

### packages/domain
Deterministic domain calculations/rules.

### packages/persistence
Local/server repositories, migrations, outbox.

## Bootstrap command

Reference verification:

`python repository_scaffold/scripts/verify_contracts.py`

The script checks:
- core golden vectors,
- SQLite migration chain,
- required machine-readable catalogs,
- FHIR example JSON parsing,
- authorization vector semantics.

## Production repository

The future coding agent may choose a monorepo tool or standard workspace.

It must preserve the logical boundaries above even if the exact directory names change.

## No fake implementation

README placeholders in this scaffold are not feature completion.

A module becomes implemented only after:
- production code,
- persistence/API wiring,
- acceptance evidence,
- target-platform build/run evidence as required.


---

<!-- SOURCE: 128_FHIR_EXPORT_MAPPING_AND_CLINICIAN_INTEROP_EXAMPLES.md -->

# FHIR EXPORT MAPPING AND CLINICIAN INTEROPERABILITY EXAMPLES

## Purpose

Turn the earlier conceptual FHIR adapter description into concrete synthetic mapping examples.

Directory:

`fhir_examples/`

## Important scope

v0.18 examples are:
- synthetic,
- FHIR-style R5 reference examples,
- JSON-parse validated,
- NOT validated against an official FHIR validator in this handoff.

Therefore their evidence label is:

`REFERENCE_MAPPING_EXAMPLE_NOT_PRODUCTION_VALIDATED`

## Internal → FHIR-style mapping

### Profile
Internal profile metadata
→ Patient-like resource.

### LabResult / Vital
→ Observation-like resource.

### Condition
→ Condition-like resource.

### VaccinationEvent
→ Immunization-like resource.

### ProcedureEvent
→ Procedure-like resource.

### EpisodeOfCare
→ EpisodeOfCare-like resource.

### MedicationPlan
→ MedicationRequest-like representation.

### IntakeEvent
→ MedicationStatement/MedicationAdministration-like representation depending on actual source semantics.

The implementation agent must confirm exact target resource and current FHIR release semantics.

## Terminology safety

Examples prefer:
- local/internal code systems,
- plain `text`,
- UCUM unit system where safe.

They avoid pretending that a third-party terminology code is licensed merely because FHIR supports it.

## Source preservation

Export extension/identifier strategy should retain:
- internal record ID,
- source provenance,
- correction/version relation,
- source unit/value where relevant.

## Missing values

A missing LabResult does not become:

`valueQuantity = 0`.

It either:
- is omitted from numeric value,
- carries appropriate data-absence semantics in the production mapping,
- or is excluded from an export whose contract requires actual observations.

## Derived/app scores

App-defined composite scores must not masquerade as laboratory observations.

If exported, use an explicit app-specific code/system and label.

## Bundle provenance

Export bundle should identify:
- generator/app version,
- export date,
- synthetic flag for demo examples,
- profile scope.

## Production gate

Before declaring FHIR interoperability production-ready:

- choose exact FHIR release/profile/implementation guide,
- validate generated resources with an appropriate FHIR validator,
- run terminology/license checks,
- verify round-trip/import policy,
- add acceptance evidence.


---

<!-- SOURCE: 129_AUTHORIZATION_GOLDEN_VECTORS_AND_CROSS_USER_TESTS.md -->

# AUTHORIZATION GOLDEN VECTORS AND CROSS-USER TESTS

## Purpose

Authorization is tested as deterministic access semantics before a full backend exists.

Machine vectors:

`authorization_vectors.json`

Reference evaluator:

`reference_code/validate_authorization_vectors.py`

## Core access function

For ordinary private profile resources:

`allow = authenticated_user_id == profile.owner_user_id`

unless an explicit future permission/share record grants access.

## Vector classes

- owner read allowed
- owner write allowed
- different user read denied
- different user write denied
- missing authentication denied
- synthetic profile still has an owning account when stored in private app state
- public Site synthetic pack is not the same as private profile authorization.

## Important limitation

This evaluator is NOT a production authorization library.

It is a semantic golden test so:
- backend middleware,
- service methods,
- PostgreSQL RLS

can all be checked against the same expected decisions.

## Future sharing

When collaborator/shared profile support is added:

- add PermissionGrant entity,
- add vectors,
- update application authorization,
- update RLS,
- update audit behavior.

Do not weaken the owner-only rule through ad-hoc exceptions.


---

<!-- SOURCE: 12_SECURITY_PRIVACY_AND_OWNERSHIP.md -->

# SECURITY, PRIVACY AND DATA OWNERSHIP

Health information is sensitive. Security is a core product requirement.

## Required areas

### Authentication
Use a production-appropriate authentication system.
Protect against common session/token failures.

### Authorization
Every user-owned record must be scoped to its owner.
Do not rely on hidden UI alone for access control.

### Transport
Use encrypted transport in production.

### Secrets
API keys and server secrets must not be committed to source control or embedded in publicly recoverable client artifacts when confidentiality is required.

Use environment configuration and secret management.

### Storage
Evaluate encryption for:
- server-side data at rest,
- mobile sensitive local storage,
- secrets/tokens.

### Export
A user should be able to export their own data.

### Deletion
Provide account/data deletion semantics and document retention behavior.

### Logging
Application logs should avoid leaking raw sensitive health data unnecessarily.

### Backups
Backups must follow the same privacy and access-control expectations.

### Attachments
Health documents require access control and signed/authorized retrieval where cloud storage is used.

### Threat modeling
Before production release, review at minimum:
- account takeover,
- insecure direct object reference,
- token leakage,
- secret leakage,
- cross-user data access,
- backup exposure,
- provider abuse,
- malicious file upload,
- web session risks.

## Legal/regulatory review

The product team must review applicable privacy, consumer health, medical-device and data-protection obligations for intended markets before public production launch.

Do not claim regulatory compliance merely because this specification mentions security.
\n\n## v0.21 attachment security\nBinary health documents inherit the profile privacy class. Cloud storage is private; access tokens are scoped/short-lived; routine logs exclude document contents. Cross-user hash existence is never disclosed.\n


---

<!-- SOURCE: 130_CONTRACT_VERIFICATION_RUNNER.md -->

# CONTRACT VERIFICATION RUNNER

## Purpose

Give future coding agents one low-friction command to verify handoff executable assets.

Reference command:

`python repository_scaffold/scripts/verify_contracts.py`

## Current checks

1. Execute CORE_DERIVED golden vectors.
2. Execute SQLite migrations in order.
3. Verify migration upgrade preservation.
4. Verify SQLite foreign-key enforcement.
5. Parse machine-readable catalogs.
6. Validate authorization vectors.
7. Parse FHIR reference examples.
8. Check required build prompts exist.
9. Check Site prompt exists.
10. Check core semantic guard phrases remain present.

## Output classes

- PASS
- FAIL
- NOT_RUN

The script must return a nonzero exit code on a real failed check.

## Scope

The runner does not prove:
- mobile builds,
- server runtime,
- PostgreSQL RLS runtime,
- production security,
- clinical validity.

Those remain separate release evidence.


---

<!-- SOURCE: 131_OPENAPI_STARTER_AND_ENDPOINT_AUTHORIZATION.md -->

# OPENAPI STARTER AND ENDPOINT AUTHORIZATION

## Purpose

v0.19 turns the REST/API contract into a machine-readable starter document.

Primary asset:

`OPENAPI_STARTER.json`

Companion policy:

`ENDPOINT_AUTHORIZATION_MATRIX.json`

The OpenAPI document is an executable contract starter, not a deployed API.

## Design

Base API prefix:

`/v1`

Representative endpoints:

- `/health`
- `/profiles`
- `/profiles/{profileId}`
- `/profiles/{profileId}/health-facts`
- `/profiles/{profileId}/labs`
- `/profiles/{profileId}/scores`
- `/profiles/{profileId}/missions`
- `/profiles/{profileId}/compare`
- `/profiles/{profileId}/sync/push`
- `/profiles/{profileId}/sync/pull`
- `/packs`
- `/exports`

## Authorization classes

- `PUBLIC`
- `AUTHENTICATED_OWNER`
- `AUTHENTICATED_OWNER_OR_EXPLICIT_GRANT`
- `ADMIN_SERVICE`
- `LOCAL_ONLY_NO_SERVER`

Ordinary private health endpoints default to:
`AUTHENTICATED_OWNER`

## Request identity

`profileId` in the URL identifies the target resource.
It is NOT proof that the caller owns the profile.

Server authorization must resolve ownership from authenticated server identity.

## Idempotency

Mutating sync/API requests declare whether they require an idempotency key.

Recommended:

`Idempotency-Key`

or an explicit mutation ID in the request body where the domain already owns such identity.

## Revision control

Mutable resources may use:
- `If-Match` / ETag,
- base revision in payload,
- or an equivalent explicit revision token.

A stale writer must not silently overwrite newer canonical state.

## Error format

All API errors use a stable envelope:

- code
- message
- request_id
- retryable
- details
- field_errors optional.

Human text may change by locale.
Machine `code` remains stable within compatibility policy.

## Pagination

Collection endpoints use stable cursor pagination where large/unbounded history exists.

Response:

- items
- next_cursor
- has_more.

## OpenAPI evidence

v0.19 validates:
- JSON parse,
- required OpenAPI top-level fields,
- operation IDs are unique,
- documented private operations exist in authorization matrix,
- referenced reusable schemas exist.

This is contract validation, not server runtime validation.


---

<!-- SOURCE: 132_API_IDEMPOTENCY_REVISION_AND_ERROR_CONTRACT.md -->

# API IDEMPOTENCY, REVISION AND ERROR CONTRACT

## Idempotency

An idempotent mutation can be safely retried after an unknown delivery result without producing a duplicate semantic action.

Examples:
- create health fact using a stable mutation/request identity,
- sync push batch,
- import batch submission.

Do not use idempotency to hide a genuinely different user action.

## Idempotency receipt

Server may store:
- user/account
- idempotency key or mutation ID
- request fingerprint
- resulting resource/status
- first seen time
- expiry/retention.

Same key + materially different request:
`IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_REQUEST`

## Revision conflict

If a mutable resource changed after the client's base version:

return:
`REVISION_CONFLICT`

with enough metadata to:
- refresh,
- compare,
- resolve,
- retry explicitly.

Do not silently last-write-win historical health facts where correction semantics are required.

## Error catalog

Machine asset:
`API_ERROR_CATALOG.json`

Core classes:

- AUTH_REQUIRED
- ACCESS_DENIED
- NOT_FOUND
- VALIDATION_ERROR
- INVALID_UNIT
- MISSING_REQUIRED_INPUT
- NOT_ELIGIBLE
- REVISION_CONFLICT
- IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_REQUEST
- DUPLICATE_RESOURCE
- SYNC_CONFLICT
- PACK_BLOCKED
- LICENSE_BLOCKED
- RATE_LIMITED
- SERVICE_UNAVAILABLE
- INTERNAL_ERROR.

## Retry behavior

Every error catalog entry declares:
- retryable yes/no/conditional,
- whether user action is needed,
- whether canonical data may already have committed.

Example:
network timeout after server commit is not an API error body.
The client must resolve delivery uncertainty through idempotency/sync state.

## Validation

Field errors should identify:
- path/field
- machine code
- localized message key.

Never return a plausible numeric health output alongside a calculation validation error.

## Request ID

Every server response/error should expose a request/correlation ID suitable for support diagnostics without containing PHI/health payload.


---

<!-- SOURCE: 133_MIGRATION_ROLLBACK_AND_RECOVERY_DRILLS.md -->

# MIGRATION ROLLBACK AND RECOVERY DRILLS

## Purpose

A migration strategy is incomplete until failed-upgrade behavior is tested.

Machine drill catalog:

`MIGRATION_ROLLBACK_DRILLS.json`

Executable runner:

`reference_code/run_migration_rollback_drills.py`

## DRILL-DB-001 — Transactional failure

Starting state:
SQLite schema version 4.

Action:
begin a transaction, create a probe table, attempt an operation that deliberately violates a uniqueness constraint, then roll back.

Expected:
- schema version remains 4,
- probe table does not survive,
- existing profile fixture remains intact.

## DRILL-DB-002 — Interrupted app start

Simulate:
- database reports schema version 4,
- application expected version 5,
- migration 5 is absent/unavailable.

Expected:
- app enters migration-required/blocked state,
- does not mark schema 5,
- read-only export/recovery path may remain available if product policy permits.

## DRILL-DB-003 — Backup before destructive migration

Any future destructive migration requires:
- pre-migration backup/restore point,
- migration receipt,
- post-migration invariant verification.

v0.19 specifies this drill but does not invent a destructive production migration.

## DRILL-DB-004 — Seed failure is isolated

A failed synthetic/demo seed:
- does not roll back a successful schema migration,
- does not mark canonical schema invalid,
- produces a seed-specific receipt/error.

## DRILL-DB-005 — Recovery after stale derived data

A canonical migration succeeds but derived cache rebuild fails.

Expected:
- canonical records remain intact,
- derived views become STALE/REBUILD_REQUIRED,
- no raw data rollback is performed merely because cache rebuild failed.

## Evidence levels

SQLite rollback drill:
executed in v0.19.

PostgreSQL migration rollback:
`NOT_RUN` until PostgreSQL test infrastructure exists.


---

<!-- SOURCE: 134_UI_DESIGN_TOKENS_AND_COMPONENT_STATE_CONTRACT.md -->

# UI DESIGN TOKENS AND COMPONENT STATE CONTRACT

## Purpose

UI consistency should come from explicit tokens and semantic component states rather than one-off styling.

Machine assets:

- `UI_DESIGN_TOKENS.json`
- `COMPONENT_STATE_MATRIX.json`

## Token categories

### Spacing
Use a small monotonic scale.

### Radius
Use a small set of corner-radius roles.

### Typography
Roles:
- display
- title
- heading
- body
- body_small
- label
- numeric_metric
- mono/code.

### Color semantics

Tokens are semantic:
- surface
- text_primary
- text_secondary
- accent
- success
- warning
- danger
- info
- disabled
- focus
- protection
- burden
- function
- confidence.

Exact colors can vary by theme.

Health meaning cannot rely on color alone.

### Elevation
Small named levels only.

### Motion
Respect reduced-motion preference.

## Theme

Required:
- light
- dark
- aging-friendly/high-clarity preset.

Aging-friendly is not “old-person mode”.
It is a display preset.

## Component state vocabulary

Shared states:

- LOADING
- READY
- EMPTY
- OFFLINE_READY
- STALE
- VALIDATION_ERROR
- SYNC_CONFLICT
- PERMISSION_BLOCKED
- NOT_ELIGIBLE
- BLOCKED
- FATAL_ERROR.

## MetricCard

Must support:
- label
- value
- unit
- source/provenance affordance
- trend optional
- stale marker
- missing state
- accessible text summary.

Missing/unknown never renders as numeric `0` by visual default.

## ResultCard

Must distinguish:
- validated risk
- app-defined score
- population baseline
- derived measurement
- research/experimental result.

The result class is visible without opening developer diagnostics.

## ChartFrame

Required:
- title
- axes/units
- date range
- text summary
- loading/empty/error states
- accessible table/data alternative where practical.

## ConflictResolver

Never presents “server wins” / “device wins” without showing:
- source
- timestamps
- revision
- affected fields
when the conflict concerns canonical health data.

## Destructive actions

Delete/reset/account-delete use distinct visual and confirmation semantics.

## Snapshot contract

The production UI test suite should capture component-state snapshots/goldens for:
- READY
- EMPTY
- STALE
- OFFLINE
- ERROR
- accessibility text scale.

v0.19 supplies state definitions, not rendered production screenshots.


---

<!-- SOURCE: 135_VISUAL_INFORMATION_HIERARCHY_AND_CHART_SEMANTICS.md -->

# VISUAL INFORMATION HIERARCHY AND CHART SEMANTICS

## Goal

Health dashboards must prioritize meaning over decorative density.

## Priority hierarchy

1. immediate safety/review state
2. current factual state
3. validated clinical model output
4. function/capacity
5. trend/trajectory
6. app-defined composite
7. education/detail.

App-defined composite must not visually overpower a validated clinical result merely because its number is larger or more colorful.

## Longevity ↔ Shortevity

Recommended visual structure:

- protection/resilience
- burden/risk
- function
- trajectory
- coverage/confidence

Keep them separable.

Do not render one giant “health score” as the only primary output.

## Charts

### Time-series chart
Use for repeated measurements.

### Distribution/reference chart
Use when comparing to a defined population/reference.

### Before/after
Use for temporal observation, clearly label that it does not prove causation.

### Scenario compare
Show observed baseline separately from hypothetical scenario.

## Axis safety

- units always visible,
- truncated axes require careful review,
- log scale is explicitly labeled,
- time zones/date intervals are declared where relevant.

## Missingness

Do not connect a line through a long missing interval as if continuous observation occurred unless interpolation is explicitly intended and labeled.

## Uncertainty

When a validated model supplies interval/uncertainty:
render it separately from the point estimate.

App-defined confidence/coverage should not be styled as statistical confidence interval.

## Color

Protection/burden may use distinct semantic colors, but:
- text/icon labels remain,
- color-blind accessibility considered,
- dark/light themes preserve contrast.

## Comparison Lab

With many profiles:
- pin key metrics,
- horizontal/virtualized table,
- sort/filter,
- show NOT_ELIGIBLE distinctly from missing,
- never replace unavailable values with zero bars.


---

<!-- SOURCE: 136_BUILD_AGENT_DELIVERY_CHECKLIST_AUTOMATION.md -->

# BUILD AGENT DELIVERY CHECKLIST AUTOMATION

## Purpose

The future coding agent should not manually compose a “done” message from memory.

Machine delivery checklist:

`BUILD_DELIVERY_CHECKLIST.json`

Reference validator:

`repository_scaffold/scripts/verify_delivery_readiness.py`

## Required evidence groups

- source tree
- static checks
- unit tests
- database migrations
- API contract tests
- sync/conflict tests
- accessibility tests
- security tests
- Android build
- iOS build
- Web build
- backend build
- export/restore tests
- performance tests
- production acceptance dossier
- release checksums.

## Evidence status

- PASS
- FAIL
- BLOCKED
- NOT_RUN
- NOT_APPLICABLE.

## Readiness rule

`PRODUCTION_READY` can be emitted only when all mandatory evidence groups for the requested target are PASS or explicitly NOT_APPLICABLE by contract.

BLOCKED/NOT_RUN cannot be silently promoted.

## Artifact existence

A deliverable may be marked PASS only if:
- the file exists,
- the path is known,
- optional checksum/metadata match,
- applicable smoke/build evidence exists.

## Platform-specific honesty

If macOS/Xcode credentials are unavailable:

iOS:
`BLOCKED` or `NOT_RUN`

not:
`PASS`.

## Handoff-only use

In the current v0.19 handoff, the delivery checker validates the checklist schema and intentionally reports production runtime evidence as NOT_RUN.

It does not declare the app built.


---

<!-- SOURCE: 137_HEALTH_PLATFORM_ADAPTER_CANONICALIZATION_CONTRACT.md -->

# HEALTH PLATFORM ADAPTER AND CANONICALIZATION CONTRACT

## Purpose

Integrate Apple HealthKit and Android Health Connect without making either platform the canonical Human Health OS data model.

Architecture:

```text
HealthKit / Health Connect
        ↓
platform adapter
        ↓
source-preserving normalization
        ↓
deduplication / conflict checks
        ↓
canonical Human Health OS record
```

## Adapter responsibilities

Each platform adapter must preserve:

- platform/source identity
- platform record identifier where available
- source app/device identity where available
- measurement/event time
- time zone/offset where available
- original unit/value
- recording method/origin when available
- last-modified/version metadata when available
- import time
- canonical mapping version.

## Canonical identity

Do not use a display label such as `Apple Watch` as a unique identifier.

A canonical imported record should maintain a source key such as:

`platform + source_record_id + source_bundle/package/app + data_type`

when the platform exposes stable identity.

## Deduplication

Preferred order:

1. same platform + same stable platform record ID
2. explicit source provenance link
3. deterministic adapter fingerprint for platforms/data without stable IDs
4. cautious similarity candidate requiring reconciliation.

Two different devices measuring the same thing at the same time can be legitimate separate measurements.

## Provenance

An imported wearable record is not equivalent to:
- manually entered measurement,
- clinician-measured value,
- laboratory value.

Canonical `source_type` and provenance must retain this distinction.

## Write-back

Default initial product posture:
- read/import first,
- write-back disabled unless a specific feature has a clear user benefit and source-loop prevention design.

If write-back is enabled:
- tag records written by Human Health OS,
- detect own-source records on re-import,
- avoid sync echo loops.

## Platform permission boundary

Permission capability is not inferred from an empty query result.

Platform-specific privacy rules can make “no results” ambiguous.

The app should expose states such as:
- NOT_AVAILABLE
- NOT_REQUESTED
- REQUESTED_PARTIAL_OR_UNKNOWN
- AVAILABLE_FOR_REQUESTED_OPERATION
- PERMISSION_BLOCKED
- ERROR

without fabricating precision the platform does not expose.

## Offline behavior

Previously imported canonical records remain available offline.

Platform APIs may require the local device/platform service but should not require Human Health OS cloud connectivity.

## Initial canonical domains

v0.20 adapter catalog covers a practical first wave:

- weight
- height
- body mass index when provider supplies it
- heart rate
- resting heart rate
- blood pressure
- oxygen saturation
- respiratory rate
- body temperature / skin temperature when supported
- steps
- distance
- active energy
- workouts/exercise sessions
- sleep sessions/stages
- VO2 max when supported
- nutrition/hydration only where platform semantics are sufficiently mapped.

## Derived vs imported

If the source platform supplies a derived metric:
record it as source-derived/platform-provided.

Do not silently replace it with the app's own derived version.

The app can maintain both, with distinct provenance/model/source identity.


---

<!-- SOURCE: 138_ANDROID_HEALTH_CONNECT_ADAPTER_CONTRACT.md -->

# ANDROID HEALTH CONNECT ADAPTER CONTRACT

Checked against Android Developers documentation: 2026-10-06.

## Availability

The implementation must check Health Connect availability/capability before use.

Health Connect is an adapter source, not a requirement for the deterministic offline Human Health OS core.

## Permissions

Health Connect uses data-type-specific permissions.

Permissions required by the app must be:
- declared in the Android manifest,
- requested from the user,
- limited to actual product features.

Do not request every health data category simply because it exists.

## Additional read permission classes

Current Android documentation distinguishes additional access for:
- background health-data reading,
- historical data beyond the ordinary history window.

These permissions must be requested only if the feature actually requires them.

## User controls

The app should provide:
- Sync with Health Connect toggle
- Manage access link/action
- understandable insufficient-permission state.

Disabling Human Health OS sync should stop platform synchronization without deleting already imported canonical history.

## Recording method

Health Connect metadata can distinguish recording methods including:
- unknown
- manual entry
- automatically recorded
- actively recorded.

Map this metadata into canonical provenance rather than discarding it.

## Initial record mappings

Reference examples:

- `WeightRecord` → canonical weight measurement
- `HeartRateRecord` → dense heart-rate series
- `RestingHeartRateRecord` when supported/current → resting heart-rate derived/source record
- `BloodPressureRecord` → systolic/diastolic measurement set
- `OxygenSaturationRecord` → SpO2 measurement
- `RespiratoryRateRecord` → respiratory-rate measurement
- `StepsRecord` → interval step count
- `SleepSessionRecord` → sleep episode + stages
- `ExerciseSessionRecord` → activity/workout session
- `Vo2MaxRecord` → source VO2 max record
- `NutritionRecord` / hydration types → nutrition/hydration adapter when fields map safely.

Exact record classes/features must be rechecked against the current SDK before implementation.

## Time-series

For series/interval records:
- retain start/end time,
- zone offsets when available,
- samples where needed,
- aggregate only through declared rules.

## Health Connect ID

When the platform provides a unique record identifier, retain it in provider provenance.

Do not generate a new canonical duplicate every import.

## Deletion/change handling

Use the current platform change-tracking/deletion APIs when implementing sync.

A source deletion should not necessarily hard-delete Human Health OS history immediately.

Record:
- source deletion/tombstone event,
- provenance,
- user/product retention policy.

## Play distribution

Before production release:
- recheck current Play Console Health Connect declaration requirements,
- declare only actually used health data types/purposes,
- verify privacy disclosures match runtime behavior.

## Failure behavior

Permission denied:
manual input remains available.

Health Connect unavailable:
app core remains usable.

Unknown/new record type:
stage as unsupported/unmapped rather than guessing.


---

<!-- SOURCE: 139_APPLE_HEALTHKIT_ADAPTER_CONTRACT.md -->

# APPLE HEALTHKIT ADAPTER CONTRACT

Checked against Apple Developer documentation: 2026-10-06.

## Availability and capability

Before use:
- HealthKit capability is enabled for the target,
- `HKHealthStore.isHealthDataAvailable()` is checked,
- only needed HealthKit data types are requested.

Clinical Health Records capability must not be enabled merely “just in case”.

## Purpose strings

Production iOS configuration needs clear purpose strings for health-data access.

Read and write permission messages are separate platform configuration concerns.

## Fine-grained permission

Request only the HealthKit object/sample types needed for the feature.

Do not ask for all health data at onboarding.

Prefer contextual permission requests.

## Privacy nuance

HealthKit intentionally protects read-permission privacy.

The app must not conclude:

`query returned no data → user definitely granted read permission and has no records`

HealthKit can return limited/no readable samples depending on authorization and privacy behavior.

The adapter must represent uncertainty rather than fabricate permission certainty.

## Limited history

Current HealthKit documentation allows people to limit read access to a recent history window.

When available, preserve the earliest authorized sample date/scope metadata.

Historical incompleteness should affect coverage/provenance.

## Initial type mapping

Examples, subject to current SDK verification:

- body mass → canonical weight
- height → canonical height
- heart rate → dense heart-rate series
- resting heart rate → resting HR source metric
- blood pressure correlation → systolic/diastolic measurement session
- oxygen saturation → SpO2
- respiratory rate → respiratory-rate measurement
- body temperature → temperature
- step count → interval/aggregate steps
- distance walking/running → distance
- active energy burned → active energy
- workouts → exercise session
- sleep analysis → sleep episode/stages
- VO2 max → source VO2 max record.

## Source identity

Retain available:
- HealthKit UUID/identifier
- source revision
- device
- source bundle/app
- sample type
- original start/end timestamps
- metadata relevant to provenance.

## Observer/background updates

If implementing background/observer delivery:
- use current HealthKit-supported mechanisms,
- ensure idempotent import,
- handle app termination/relaunch,
- never assume one callback equals one new canonical record.

## Write-back

Initial default:
read/import first.

If Human Health OS later writes to HealthKit:
- request write permission only for supported types,
- mark own-source metadata,
- prevent re-import echo loops,
- preserve user's ability to revoke access.

## Failure behavior

HealthKit unavailable:
manual/local app still works.

Permission limited/unknown:
show platform-access state, not a fake “all synced” indicator.

Unsupported sample:
stage/unmapped with source metadata rather than coercing to a nearby canonical metric.


---

<!-- SOURCE: 13_CROSS_PLATFORM_TECH_ARCHITECTURE.md -->

# CROSS-PLATFORM TECHNICAL ARCHITECTURE

## Preferred client strategy

Flutter/Dart is the preferred starting point because the product targets:
- Android,
- iOS,
- web.

At implementation time, verify the current stable Flutter/Dart toolchain and package compatibility.

Do not freeze old package versions merely because an earlier draft used them.

## Shared layers

Recommended conceptual separation:

- Presentation/UI
- Application/use cases
- Domain models
- Repository interfaces
- Local persistence
- API client
- Sync engine
- Platform adapters

## Mobile local storage

Use a robust local database with:
- migrations,
- indexes,
- transactions,
- foreign-key integrity or equivalent,
- deterministic schema versioning.

Do not treat simple key-value preferences as the canonical health database.

## Web

The authenticated health dashboard can be implemented with the chosen cross-platform framework if it provides acceptable:
- accessibility,
- performance,
- responsive behavior,
- security.

A public marketing/SEO-heavy website may be implemented separately with conventional web technology if useful.

## Backend

Backend technology may be selected by the coding agent based on:
- maintainability,
- authentication integration,
- typed validation,
- migration tooling,
- testability,
- deployment simplicity.

The data semantics in this handoff take precedence over a specific framework.

## Build environments

Final implementation should document:
- Android SDK/Java requirements,
- Flutter/Dart version,
- iOS/Xcode requirements,
- backend runtime,
- web build/runtime,
- environment variables.


---

<!-- SOURCE: 140_NUTRITION_RECIPE_AND_PORTION_MATH_ENGINE.md -->

# NUTRITION, RECIPE AND PORTION MATH ENGINE

## Purpose

Make food/recipe calculation deterministic and testable.

## Core principle

A logged meal stores an immutable nutrient snapshot.

Later provider-data updates cannot rewrite historical intake.

## Food nutrient basis

A provider food can expose nutrients on a reference basis, commonly per:
- 100 g
- 100 mL
- serving
- unit/piece.

The adapter must identify the basis explicitly.

## Quantity scaling

For mass-based food:

`scaled_nutrient = reference_nutrient × consumed_g / reference_g`

Example:

100 g food contains 12 g protein.
Consumed: 150 g.

Protein:
`12 × 150 / 100 = 18 g`

## Missing nutrients

If provider does not report nutrient X:
- nutrient X remains MISSING/UNKNOWN,
- it does not contribute numeric zero to coverage-sensitive calculations.

Daily arithmetic can separately expose:
- known total
- coverage/incomplete flag.

## Recipe

Recipe contains ingredients with:
- food snapshot/reference
- quantity
- unit
- conversion context.

Recipe nutrient total:

`recipe_total[nutrient] = Σ ingredient_scaled[nutrient]`

only over known compatible nutrients.

## Yield

Recipe may declare:
- total cooked mass,
- serving count,
- portion mass,
- custom portion.

Per-serving calculation:

`recipe_total / serving_count`

when serving count > 0.

Per-gram calculation:

`recipe_total / final_recipe_mass_g`

when final mass is measured/known.

## Cooking yield

Do not assume raw mass = cooked mass.

If final cooked mass is unknown:
- per-recipe totals remain valid,
- per-100-g cooked density cannot be calculated safely.

## Volume ↔ mass

Never convert mL to g without:
- provider-defined measure mapping,
- density,
- or explicit user-entered conversion.

## Edible portion

If source provides edible-portion semantics:
preserve them.

Do not apply a second hidden edible-portion correction.

## Piece/unit conversion

A “banana”, “slice”, “cup”, etc. is not globally fixed.

Use:
- provider household measure,
- user saved measure,
- explicit mass.

## Daily total

Daily nutrient summary reports:

- known amount
- missing-source count/coverage
- source count
- unit
- calculation version.

## Macro energy

Do not reconstruct total food energy from macros when provider already gives energy and present it as the same source value.

If app computes macro-derived energy, label it `DERIVED`.

## Recipe versioning

Editing a recipe creates a new recipe version for future logs.

Past logged meals retain the exact historical recipe/food nutrient snapshot.

## Deterministic rounding

Store calculation precision higher than display precision.

Round only for display/export policy.

Do not repeatedly round ingredient intermediates if avoidable.


---

<!-- SOURCE: 141_NUTRITION_GOLDEN_VECTORS_AND_FIXTURE_CONTRACT.md -->

# NUTRITION GOLDEN VECTORS AND FIXTURE CONTRACT

## Machine assets

- `golden_vectors/nutrition_vectors.json`
- `reference_code/nutrition_math_engine.py`
- `reference_code/validate_nutrition_vectors.py`

## Covered vectors

1. simple mass scaling
2. multi-ingredient recipe sum
3. per-serving recipe
4. per-gram cooked recipe
5. missing nutrient propagation
6. volume-to-mass conversion blocked without density
7. known density conversion
8. recipe version/history isolation
9. display rounding separate from stored precision
10. daily known-total + incomplete coverage semantics.

## Evidence boundary

These vectors validate arithmetic/data semantics.

They do not prove:
- nutrient bioavailability,
- clinical adequacy,
- personalized dietary recommendations,
- provider nutrient accuracy.


---

<!-- SOURCE: 142_FULL_DOMAIN_API_COVERAGE_MATRIX.md -->

# FULL DOMAIN API COVERAGE MATRIX

## Purpose

v0.19 established representative OpenAPI endpoints.
v0.20 adds explicit coverage expectations across the product domain.

Machine asset:

`DOMAIN_API_COVERAGE_MATRIX.json`

## Domain groups

- profile/account
- timeline
- mind
- conditions
- symptoms
- labs
- vitals
- nutrition
- medications/supplements
- sleep
- activity/exercise
- treatments/vaccines/procedures
- function/pain/rehabilitation
- environment/exposome
- wearables/platform imports
- scores/results
- scenarios/compare
- missions/reminders
- education/progress
- documents/attachments
- packs/reference data
- export/backup
- sync
- consent/audit.

## Coverage states

- OPENAPI_OPERATION_PRESENT
- CONTRACT_ONLY
- LOCAL_ONLY
- FUTURE
- BLOCKED_DEPENDENCY.

A domain can be specification-complete even when server endpoints are unnecessary.

Example:
purely local display preferences do not need a server endpoint.

## Authorization

Private domain server operations default:
`AUTHENTICATED_OWNER`

Global public reference packs can use a different policy.

## Mutation behavior

Every mutation specifies:
- create/update/correction/delete semantics
- idempotency
- revision strategy
- offline outbox compatibility.

## v0.20 expansion

OpenAPI starter adds representative operations for:
- labs
- vitals
- nutrition logs
- conditions
- symptoms
- medication plans/intake
- sleep
- activity
- wearable import receipt.

This is broader coverage but still a starter document.
Full production code generation may expand additional specialized resources.


---

<!-- SOURCE: 143_HEALTH_PROVIDER_DEDUPLICATION_AND_PROVENANCE.md -->

# HEALTH PROVIDER DEDUPLICATION AND PROVENANCE

## Problem

Health platforms can contain the same physiological event from:
- watch
- phone
- another app
- manual entry
- imported clinical source.

Blind summation can double-count steps, energy, sleep and other metrics.

## SourceRecordIdentity

Store:

- provider
- provider_record_id
- provider_data_type
- source_app/package/bundle
- source_device
- source_version
- start/end/effective time
- recording_method
- imported_at
- canonical_record_id.

## Deduplication classes

### EXACT_SOURCE_ID
Same provider stable ID.
Safe idempotent duplicate.

### SELF_ECHO
Record originally written by Human Health OS and seen again from provider.
Do not duplicate.

### AGGREGATE_OVERLAP
Overlapping source intervals that may represent the same underlying activity.
Requires domain-specific handling.

### DISTINCT_MEASUREMENTS
Same time/metric but different legitimate devices/sources.
Preserve both unless explicit rule chooses a preferred source for a derived aggregate.

### POSSIBLE_DUPLICATE
Similarity detected but identity uncertain.
Stage/reconcile.

## Steps/activity

Do not blindly add:
phone steps + watch steps + provider aggregate.

Use provider aggregate semantics when authoritative for that platform, or a documented source-priority/merge policy.

## Heart rate

Multiple devices can produce simultaneous legitimate samples.

Do not deduplicate merely by equal timestamp/value unless source identity proves duplicate.

## Sleep

Overlapping sleep sessions from multiple apps may conflict.

Keep source episodes and derive a selected/current sleep summary using an explicit policy.

## Blood pressure

Two measurements seconds apart may be a deliberate repeated measurement session.

Do not deduplicate them as accidental copies based only on similarity.

## Provenance chain

A canonical aggregate can reference all source records used.

Example:

`DailyStepsSummary`
→ source Health Connect aggregate
→ contributing provider metadata.

## Deletion

Provider deletion:
- update source state,
- invalidate derived aggregates,
- preserve correction/audit semantics according to retention policy.

Do not silently delete unrelated manual/clinical measurements.


---

<!-- SOURCE: 144_HEALTH_ADAPTER_CONFORMANCE_AND_FIXTURES.md -->

# HEALTH ADAPTER CONFORMANCE AND FIXTURES

## Machine assets

- `HEALTH_PLATFORM_MAPPING_CATALOG.json`
- `health_adapter_fixtures.json`
- `reference_code/validate_health_adapter_fixtures.py`

## Fixture goals

Validate mapping semantics, not vendor SDK execution.

Covered:
- Android WeightRecord → canonical weight
- Android StepsRecord → interval steps
- Android recording method provenance
- Apple body mass → canonical weight
- Apple heart-rate sample → canonical dense HR
- Apple limited/unknown permission semantics
- no empty-result → permission-granted inference
- same source ID idempotency
- different device same timestamp remains distinct
- own-write echo suppression marker.

## Runtime evidence

SDK/device integration is NOT_RUN in the handoff environment.

Production proof requires:
- real Android Health Connect integration tests/device/emulator support
- real Apple HealthKit integration tests on supported Apple environment
- permission UX validation
- background/change-tracking validation where implemented.


---

<!-- SOURCE: 145_SECURE_ATTACHMENTS_AND_OBJECT_STORAGE_CONTRACT.md -->

# SECURE ATTACHMENTS AND OBJECT STORAGE CONTRACT

## Purpose

Human Health OS must support health documents and photos without turning file storage into an ungoverned side channel around the canonical health model.

An attachment is a binary source artifact such as:
- PDF laboratory report,
- imaging/pathology report,
- vaccination record,
- prescription or treatment document,
- discharge/procedure summary,
- skin/body progress photo,
- other user-selected health document.

## Core separation

`Attachment bytes` are not the same thing as `canonical health facts`.

The source file can support later extraction, review and provenance, but it never becomes a diagnosis or numeric health result merely because it was uploaded.

## Storage modes

### LOCAL_ONLY
The binary remains on the user's device/application storage.

### CLOUD_ENCRYPTED
The binary is stored in private object storage with server-side authorization and encryption-at-rest strategy appropriate to the selected infrastructure.

No attachment bucket/container is public by default.

## Identity

### Attachment
- attachment_id
- profile_id
- document_type
- display_name
- original_filename
- declared_mime_type
- detected_mime_type
- byte_size
- content_sha256
- capture_at optional
- document_effective_at optional
- uploaded_at / created_at
- source_type
- security_state
- extraction_state
- active_version_id
- deleted_at.

### AttachmentVersion
- version_id
- attachment_id
- content_sha256
- byte_size
- object_locator/internal local locator
- created_at
- supersedes_version_id
- security scan receipt
- parser receipt.

Replacing a source file creates a new version. It does not silently mutate a version already referenced by canonical health records.

## Object key

Use opaque identifiers rather than raw filenames as storage keys.

Example conceptual layout:

`users/{userId}/profiles/{profileId}/attachments/{attachmentId}/{versionId}/original`

This is a design example, not a required vendor-specific path.

## Access

Every download/preview request rechecks authorization.

If signed/temporary URLs are used:
- short expiry,
- narrow object scope,
- never indexable,
- never treated as authorization after expiry.

## Hashing

Calculate SHA-256 or equivalent strong content digest on the received bytes.

Uses:
- integrity verification,
- per-user duplicate detection,
- version identity,
- export/backup verification.

Hash equality is not permission to reveal that another user owns the same file.

## Deletion

Deleting an attachment and deleting structured health facts extracted from it are separate operations.

Default:
- attachment can be tombstoned/deleted according to retention policy,
- reviewed canonical records remain unless explicitly deleted,
- provenance can retain a deleted-source reference/receipt without retaining downloadable bytes when policy requires deletion.

## Backups

Attachment backups must preserve:
- attachment/version identity,
- checksum,
- metadata,
- structured-record provenance links,
- encryption/key recovery compatibility.

A backup that restores metadata without required bytes, or bytes without provenance links, must report partial restore.


---

<!-- SOURCE: 146_DOCUMENT_INGESTION_STATE_MACHINE_AND_QUARANTINE.md -->

# DOCUMENT INGESTION STATE MACHINE AND QUARANTINE

## Purpose

Treat every imported binary as untrusted until it passes the configured validation pipeline.

## Two independent state machines

### File security state

- LOCAL_DRAFT
- UPLOAD_PENDING
- QUARANTINED
- TYPE_VALIDATED
- SCAN_PENDING
- SAFE
- BLOCKED
- ERROR
- DELETED_TOMBSTONE

### Extraction state

- NOT_REQUESTED
- PENDING
- EXTRACTING_TEXT
- PARSING
- STAGED
- REVIEW_REQUIRED
- PARTIALLY_COMMITTED
- COMMITTED
- FAILED
- NOT_SUPPORTED

Security state and extraction state are separate.
A parser failure does not imply malware.
A malware block does not become a parsing error.

## Upload pipeline

1. create metadata/upload session,
2. stream/upload bytes,
3. verify received byte count,
4. compute/verify content hash,
5. detect file type from content/signature where practical,
6. compare declared extension/MIME with detected type,
7. enforce configurable size/type policy,
8. quarantine cloud upload,
9. malware/content safety scan when cloud pipeline is used,
10. only SAFE files become eligible for preview/parser workers.

## MIME

MIME means the machine-readable file/media type, for example `application/pdf` or `image/jpeg`.

A filename ending in `.pdf` is not sufficient evidence that the bytes are actually a PDF.

Mismatch behavior:
- reject clearly unsafe/disallowed content,
- otherwise require explicit validation/review,
- never execute embedded content merely because extension is trusted.

## Reference initial file classes

Configurable starting set:
- PDF
- JPEG
- PNG
- HEIC/HEIF where target platform support exists.

Other formats require explicit parser/security review before activation.

## Archive/container formats

Do not accept arbitrary ZIP/archive files as normal health-document input by default.

If introduced later, protect against:
- excessive decompression ratio,
- nested archives,
- path traversal,
- file-count bombs.

## Parser isolation

Parser workers should operate with least privilege.

A parser does not need:
- broad user-account access,
- write access to unrelated health records,
- long-lived credentials.

It returns staged candidates and receipts.

## Failure/retry

Upload retry uses a stable upload/session identity.

A retry must not create multiple attachment versions for one successfully completed upload unless the user intentionally creates another version.

## Local-only path

A local-only user can attach files without cloud upload.

Local parser path still validates:
- supported type,
- size,
- content integrity.

Cloud malware scan can be `NOT_APPLICABLE_LOCAL_ONLY`; this must not be mislabeled PASS.


---

<!-- SOURCE: 147_LAB_REPORT_EXTRACTION_REVIEW_AND_COMMIT.md -->

# LAB REPORT EXTRACTION, REVIEW AND COMMIT

## Core rule

`Extracted text ≠ canonical lab result.`

Document processing produces `ExtractionCandidate` records first.

Only reviewed/accepted candidates can create canonical LabSession/LabResult records.

## Extraction pipeline

```text
Attachment SAFE
    ↓
text-layer extraction when available
    ↓
optional OCR fallback
    ↓
layout/table parsing
    ↓
normalization candidates
    ↓
STAGED / REVIEW_REQUIRED
    ↓
user or approved deterministic review
    ↓
commit receipt
    ↓
LabSession / LabResult
```

**OCR** means optical character recognition: converting visible text in an image/scanned page into machine-readable text.

The deterministic offline core does not require generative AI.
A local OCR engine may be an optional implementation component.

## Candidate fields

### LabExtractionCandidate
- candidate_id
- attachment_id
- attachment_version_id
- page/region optional
- raw_label
- normalized_analyte_key optional
- mapping_state: MAPPED / UNMAPPED / AMBIGUOUS
- raw_value_text
- numeric_value optional
- value_state
- raw_unit
- normalized_unit optional
- reference_low optional
- reference_high optional
- reference_text optional
- source_flag optional
- observed_at candidate optional
- parser_id/version
- extraction_method
- confidence/quality metadata
- review_state
- notes.

## Review states

- UNREVIEWED
- ACCEPTED
- REJECTED
- EDITED_AND_ACCEPTED
- NEEDS_CLARIFICATION.

## Commit receipt

A canonical commit creates an immutable `ExtractionReviewReceipt`:
- receipt_id
- attachment/version
- accepted candidate IDs
- rejected candidate IDs
- edits applied
- created canonical record IDs
- reviewer actor/type
- committed_at
- parser/version.

## Unit safety

Never guess unit conversion merely to make a result fit a known analyte.

Example:
`5.2` with no unit remains missing/unknown unit unless source/context provides an unambiguous mapping permitted by the unit engine.

## Reference intervals

If the report supplies a reference interval:
- preserve the source interval and wording,
- do not replace it with a global app range.

If no interval is present:
- store absence,
- do not invent one.

## Flags

Source flags such as H/L/abnormal are source metadata.
They are not themselves a diagnosis.

## Dates

Separate:
- specimen/collection time,
- result/report time,
- upload/import time.

Do not substitute upload time as specimen time when the report date is unknown.

## Duplicate report

Same file checksum under the same user/profile should trigger duplicate review before creating duplicate LabSessions.

## Partial commit

User may accept only some candidates.

Rejected/ambiguous candidates remain staged or rejected and do not become zero/missing canonical labs unless that absence state is explicitly represented by source semantics.


---

<!-- SOURCE: 148_DOCUMENT_TYPE_METADATA_AND_LINKING_MODEL.md -->

# DOCUMENT TYPE, METADATA AND LINKING MODEL

## Document type catalog

Initial classes:

- LAB_REPORT
- IMAGING_REPORT
- PATHOLOGY_REPORT
- PRESCRIPTION
- VACCINATION_RECORD
- DISCHARGE_SUMMARY
- PROCEDURE_REPORT
- TREATMENT_RECORD
- CLINIC_NOTE
- DERMATOLOGY_PHOTO
- BODY_PROGRESS_PHOTO
- OTHER_HEALTH_DOCUMENT.

A document type controls available parser/linking workflows; it does not assert the document's medical truth.

## Document dates

Possible independent dates:
- capture_at
- authored_at
- specimen_collected_at
- service_at
- report_at
- uploaded_at.

Do not collapse all dates into upload time.

## Links

AttachmentLink can link a document/version to:
- LabSession
- ConditionRecord
- MedicationPlan
- VaccinationEvent
- ProcedureEvent
- TreatmentEpisode
- SymptomEpisode
- TimelineEvent
- custom note/observation.

Linking is many-to-many where necessary.

## Photos

For health/body/skin photos, optional metadata can include:
- body region
- laterality/side
- capture time
- user tags
- lighting setup note
- camera/device metadata when intentionally retained
- comparison series ID.

Photo metadata must not infer a diagnosis from appearance.

## Timeline

Documents can appear in Timeline as source artifacts.

Timeline entry should clearly distinguish:
- document uploaded,
- document authored/service date,
- structured facts extracted from the document.

## Replacement/version

A corrected report file is a new AttachmentVersion.

Previous version remains referenced by historical extraction receipts unless retention/deletion policy removes bytes.


---

<!-- SOURCE: 149_ATTACHMENT_PRIVACY_EXIF_THUMBNAIL_AND_RETENTION.md -->

# ATTACHMENT PRIVACY, EXIF, THUMBNAILS AND RETENTION

## EXIF

EXIF is image metadata that can include:
- capture time,
- device/camera,
- orientation,
- sometimes location coordinates.

Health photos can therefore leak information beyond the visible pixels.

## Default privacy posture

- original encrypted source may retain original metadata when needed for provenance,
- generated thumbnails/previews strip unnecessary metadata by default,
- exported/shared images should strip hidden metadata unless user explicitly chooses otherwise,
- location metadata is never promoted into health context silently.

## Thumbnails

Thumbnail/preview is a derivative, not a second authoritative source.

Store derivative metadata:
- derivative_id
- source_version_id
- dimensions
- transform/version
- checksum
- created_at.

A thumbnail parser must not replace original source provenance.

## Redaction

Future redaction workflow can create a derivative for sharing while preserving the private original.

Redaction does not modify source bytes in place.

## Retention

Retention classes may differ for:
- original attachment
- thumbnails
- extraction text cache
- staged candidates
- review receipt
- canonical health records.

Example:
parser scratch/OCR cache can have shorter retention than the original document.

## Access audit

Cloud attachment operations should be auditable at least for:
- upload completion
- download/share generation
- deletion
- extraction start/commit
- security block.

Routine audit logs must not copy document contents.

## Delete source, keep facts

If user deletes source bytes but keeps reviewed canonical facts:
- structured records remain,
- provenance indicates source attachment was deleted,
- report cannot be reopened,
- extraction receipt can remain without raw document content when policy permits.

## Delete facts, keep document

The inverse is also possible:
- user can remove canonical extracted facts while retaining the source document.

The UI must explain the difference before destructive action.


---

<!-- SOURCE: 14_SYNC_OFFLINE_BACKUP_MIGRATION.md -->

# SYNC, OFFLINE, BACKUP AND MIGRATION

## Local-first goal

Core mobile data entry should continue during temporary network loss where practical.

## Sync principles

- stable client/server IDs,
- timestamps,
- version/revision field,
- explicit conflict handling,
- idempotent/retry-safe writes where possible,
- no silent loss of newer data,
- no treating timeout as confirmed success.

## Conflict policy

Conflict behavior must be defined per entity.

Example:
- append-only events can merge,
- mutable profile settings can use revision conflict resolution,
- corrected health records should preserve both provenance and selected current state.

## Food snapshots

Logged food snapshots should remain immutable for historical calculations unless an explicit migration/recalculation is performed with audit history.

## Backup

Server-backed accounts need tested backup and restore procedures.

Mobile-only unsynced data must have a documented risk and recovery strategy.

## Database migrations

Every schema release should:
1. identify source schema version,
2. migrate forward,
3. preserve user data,
4. run migration tests,
5. provide recovery/rollback strategy,
6. verify post-migration invariants.

## Derived-data rebuild

If raw canonical data changes, dependent summaries may be invalidated and rebuilt.
Do not rewrite raw data to match old derived summaries.


---

<!-- SOURCE: 150_DOCUMENT_PARSER_FIXTURES_AND_CONFORMANCE.md -->

# DOCUMENT PARSER FIXTURES AND CONFORMANCE

## Purpose

Provide executable semantics without pretending that arbitrary real-world PDF/image parsing is solved.

Assets:
- `synthetic_documents/lab_report_fixture.tsv`
- `document_ingestion_fixtures.json`
- `reference_code/lab_report_staging_parser.py`
- `reference_code/validate_document_ingestion_fixtures.py`

## Synthetic normalized fixture

The TSV fixture represents text already extracted from a document.
It is deliberately simple so the handoff can test the stage/review/commit boundary.

This fixture is NOT evidence that production OCR or arbitrary PDF table extraction works.

## Conformance checks

- same bytes → same SHA-256
- unsupported/MIME mismatch stays blocked/reviewed
- quarantined file cannot be parsed
- SAFE file can enter parsing
- parser emits candidates, never canonical LabResults directly
- missing source value remains missing
- unknown analyte mapping remains UNMAPPED
- missing unit remains missing
- accepted candidates create a commit receipt before canonical IDs are returned
- duplicate content hash under same profile is surfaced.

## Production parser evidence

Production parser/OCR readiness requires:
- corpus of de-identified/licensed test documents,
- layout variants,
- multilingual reports,
- scanned vs text-layer PDFs,
- unit/reference-range variants,
- parser precision/recall or field-accuracy evaluation,
- manual-review usability testing,
- malformed/adversarial file testing.


---

<!-- SOURCE: 151_DOCUMENT_API_UPLOAD_DOWNLOAD_AND_ACCESS.md -->

# DOCUMENT API, UPLOAD, DOWNLOAD AND ACCESS

## Representative server operations

v0.21 expands OpenAPI with:
- list attachments
- initialize attachment upload
- complete attachment upload
- get attachment metadata
- delete/tombstone attachment
- request extraction
- list extraction candidates
- commit reviewed candidates.

## Upload session

Recommended flow:

1. client creates UploadSession metadata,
2. server authorizes profile ownership,
3. client transfers bytes using server-selected method,
4. client/server completes upload with expected checksum/size,
5. server verifies receipt and moves file to quarantine/security pipeline.

## Idempotency

Upload initialization/completion uses stable idempotency identity.

Completing the same already successful upload session should return the same attachment/version receipt rather than create another version.

## Download

Metadata access and binary download are separate operations.

A download token/URL, if used, is produced only after owner/grant authorization.

## Extraction

Request extraction is idempotent per attachment version + parser version unless an explicit reprocess action is requested.

## Commit

Commit reviewed candidates requires:
- candidate IDs from the same attachment/version,
- explicit review decisions,
- authorization,
- conflict/idempotency protection.

## Delete

Delete attachment endpoint must state whether action:
- tombstones metadata,
- schedules cloud byte deletion,
- deletes derivatives/cache,
- leaves structured canonical facts intact.

No endpoint silently deletes both bytes and health history unless the request explicitly targets both operations and confirmation contract permits it.


---

<!-- SOURCE: 152_ATTACHMENT_DUPLICATE_HASH_VERSIONING_AND_INTEGRITY.md -->

# ATTACHMENT DUPLICATE HASH, VERSIONING AND INTEGRITY

## Exact duplicate

If `content_sha256` matches an existing active attachment version for the same account/profile:
- show duplicate candidate,
- allow linking/reusing metadata where appropriate,
- do not silently create duplicate extracted health records.

Cross-user hash matches are never disclosed to users.

## Near duplicate

Different checksum with similar filename/date is not an exact duplicate.
It may be:
- corrected report,
- rescanned image,
- different compression,
- genuinely different document.

Near-duplicate heuristics must remain advisory.

## Integrity receipt

Upload completion receipt includes:
- expected byte size
- received byte size
- expected hash when client supplies one
- server-calculated hash
- verification status.

Hash mismatch:
`HASH_MISMATCH`

The object does not become SAFE/parseable.

## Version

New version requires explicit user/system reason such as:
- corrected source
- higher-quality scan
- redacted derivative is not source version
- re-upload after corruption.

## Provenance continuity

ExtractionCandidate and canonical records reference the exact AttachmentVersion used.

If active Attachment version changes later, historical provenance still resolves to the prior version receipt.


---

<!-- SOURCE: 153_SITE_DOCUMENT_INGESTION_DEMO_CONTRACT.md -->

# SITE DOCUMENT INGESTION DEMO CONTRACT

## Purpose

The published Site Lab can demonstrate document ingestion without collecting real private health documents.

## Default demo

Bundle synthetic artifacts only:
- synthetic normalized lab-report text fixture,
- synthetic extraction candidates,
- synthetic review/commit flow.

## Required interaction

User can:
1. choose the bundled synthetic report,
2. see source attachment metadata,
3. run deterministic staging parser,
4. inspect candidate rows,
5. accept/reject/edit candidates,
6. commit into a temporary synthetic profile,
7. see resulting Labs/Timeline changes,
8. reset demo.

## Safety

Site demo must state:
- parser output is staged candidate data,
- real documents may require review,
- demo does not diagnose,
- no generative AI is required.

## Optional real local file demo

If a future static Site allows a user to select a local file:
- processing should remain local by default,
- clearly disclose if bytes leave the browser,
- do not upload automatically,
- do not persist private document in URL/share state.

## Reset

`Reset Demo to Defaults` clears synthetic staged/committed demo data.
It does not claim to delete a remote user document because the default demo has none.


---

<!-- SOURCE: 154_DOCUMENT_SECURITY_AND_PARSER_THREAT_MODEL.md -->

# DOCUMENT SECURITY AND PARSER THREAT MODEL

## Threats

Treat external health documents as attacker-controlled input.

Threat classes include:
- MIME/extension spoofing
- malformed PDF/image parser exploits
- oversized files/resource exhaustion
- decompression bombs if archives are ever supported
- embedded scripts/active content
- path traversal through filenames/archive entries
- malicious metadata
- cross-user object ID guessing
- leaked signed URLs
- parser worker credential overreach
- sensitive OCR/extraction text in logs
- thumbnail cache exposure
- document-based prompt injection if a future AI parser is introduced.

## Defensive requirements

- no public object bucket
- content/type validation
- configurable file/size limits
- quarantine before cloud parsing
- malware/security scanning where applicable
- sandbox/least-privilege parser workers
- authorization on metadata and bytes
- sanitized filenames for display/logging
- no raw document contents in routine logs
- derived cache inherits source privacy class
- short-lived scoped share/download tokens.

## Future AI parser

If a future optional AI extraction module is added:
- document text is untrusted data, not instructions,
- model output remains staged candidate data,
- AI never gains authority to modify canonical health data directly,
- external provider data-sharing/retention must be disclosed and consented where applicable.

The deterministic local parser remains the baseline capability.


---

<!-- SOURCE: 155_MEDICATION_SUPPLEMENT_PRODUCT_INGREDIENT_MODEL.md -->

# MEDICATION, SUPPLEMENT, PRODUCT AND INGREDIENT MODEL

## Purpose

Represent what a person plans to use, what a product contains, and what was actually taken without collapsing these into one ambiguous "medication" string.

## Core layers

```text
Product
  ↓ contains
Ingredient / Active Ingredient
  ↓ normalized identity
Dose / Strength / Route / Form
  ↓ used by
Plan
  ↓ actual event
IntakeEvent
```

## ProductConcept

Represents a marketed or user-defined product.

Examples of product classes:
- prescription drug
- OTC drug
- dietary supplement
- compounded product
- custom product
- unknown/unmapped product.

Fields include:
- product_id
- display_name
- product_type
- brand/manufacturer when known
- external identifiers such as RxCUI/NDC/DSLD label ID when available
- dose form
- route
- country/market
- label/source version
- verification state.

A display name alone is never a stable drug identity.

## IngredientConcept

Represents an ingredient concept independently of a particular product.

Fields:
- ingredient_id
- canonical_name
- concept system
- external code when available
- ingredient class
- salt/ester/form details when relevant
- active moiety or elemental basis only when explicitly known
- normalization status.

Normalization states:
- EXACT
- MAPPED_REVIEWED
- AMBIGUOUS
- UNMAPPED
- UNKNOWN.

Do not silently equate:
- elemental mineral with its salt mass,
- different chemical forms,
- mixtures/blends with a single ingredient,
- brand names with active ingredient identity.

## ProductIngredient

Links product to ingredient.

Fields:
- ingredient_id
- labeled amount
- amount unit
- amount basis
- serving/unit basis
- active/inactive flag
- label wording
- source label version.

For supplements, amount basis can be:
- per capsule
- per tablet
- per scoop
- per serving
- per mL
- per packet
- other.

## MedicationPlan

Represents intended use, not proof of ingestion.

Fields:
- product/ingredient
- prescribed or user-entered
- dose
- dose unit
- route
- frequency
- schedule
- PRN/as-needed semantics
- start/end
- prescriber/source when known
- indication text when user chooses to store it.

## SupplementPlan

Same plan/completion separation as MedicationPlan.

Additional fields can include:
- serving definition
- multiple ingredient composition
- label serving size
- custom serving multiplier.

## IntakeEvent

Represents actual reported/administered use.

Fields:
- plan_id optional
- product_id
- ingredient snapshot
- amount actually taken
- route
- taken_at
- source/provenance
- adherence context.

A reminder, prescription, shopping record or plan never creates an IntakeEvent automatically.

## ExposureSnapshot

Derived from actual IntakeEvents or an explicitly requested plan projection.

Two distinct modes:
- OBSERVED_EXPOSURE
- PLANNED_EXPOSURE

Never merge them into one total.

## Historical immutability

If a product label changes later:
- old IntakeEvents retain the ingredient/strength snapshot active when logged,
- future plans may adopt the new label version,
- historical events are not rewritten.

## Unknowns

If product ingredient composition is unknown:
keep it UNKNOWN.

Do not infer active ingredients from a look-alike brand name.


---

<!-- SOURCE: 156_MEDICATION_PLAN_INTAKE_AND_EXPOSURE_ENGINE.md -->

# MEDICATION PLAN, INTAKE AND EXPOSURE ENGINE

## Principle

`PLAN != TAKEN`

The product distinguishes:
- intended regimen,
- reminder state,
- actual intake,
- derived exposure.

## Schedule representation

Support:
- fixed local clock time
- interval
- weekday pattern
- specific date
- PRN/as-needed
- taper or staged plan
- user-defined schedule.

A complex taper should be represented as versioned schedule segments, not overwritten free text alone.

## Intake completion

A plan occurrence becomes completed only when:
- an IntakeEvent is logged,
- a trusted imported administration event is mapped,
- or an equivalent explicit completion record exists.

Notification states do not complete medication intake.

## Planned dose projection

The engine may calculate:
`planned amount per day`

only from explicit schedule semantics.

It must label this as planned.

## Observed exposure

Observed daily ingredient amount is derived from actual IntakeEvents.

For a multi-ingredient supplement:
one intake can create multiple ingredient exposure contributions from the historical product snapshot.

## Unit compatibility

Amounts can be summed only when:
- ingredient identity is compatible,
- quantity dimension is compatible,
- amount basis is compatible.

Examples that require special handling:
- mcg vs mg can convert safely for the same ingredient quantity.
- mg compound vs mg elemental mineral cannot be converted without a known stoichiometric/label basis.
- IU conversions can be ingredient-specific and require a validated conversion rule.
- "1 tablet" cannot be summed with mg until tablet strength is known.

## Route

Route is part of exposure semantics.

Do not casually sum:
- topical amount,
- oral amount,
- inhaled amount,
- injected amount

into one biologically equivalent exposure.

## PRN

PRN plan does not project a fixed daily dose unless the user explicitly requests a maximum theoretical plan calculation.

Maximum allowed by label/prescription and actual observed intake are separate values.

## Correction

Correcting an IntakeEvent:
- preserves the original event/correction link,
- invalidates affected exposure summaries,
- creates new derived snapshots.

## Adherence

Adherence is a derived behavior metric, not proof of biological response.

Missed dose, late dose, or extra dose should remain observable events, not moralized scores.


---

<!-- SOURCE: 157_INTERACTION_CONTRAINDICATION_AND_SAFETY_KNOWLEDGE_ARCHITECTURE.md -->

# INTERACTION, CONTRAINDICATION AND SAFETY KNOWLEDGE ARCHITECTURE

## Goal

Detect and explain potential safety-relevant combinations while preserving evidence, uncertainty and source boundaries.

## Knowledge object classes

### InteractionKnowledgeItem
Represents a source-backed relationship involving two or more exposures.

Examples:
- drug ↔ drug
- drug ↔ supplement
- supplement ↔ supplement
- drug ↔ food
- drug ↔ alcohol/substance
- drug ↔ laboratory test
- drug ↔ disease/condition.

### ContraindicationKnowledgeItem
Represents source-backed contraindication information.

### PrecautionKnowledgeItem
Represents source-backed caution/monitoring information.

### DuplicateIngredientRule
Detects overlapping active ingredient identity.

### TimingSeparationRule
Represents source-backed timing separation instructions.

## Evidence is separate from conclusion

A label paragraph or fact sheet is an evidence source.

A deterministic product rule is a separately reviewed object that cites:
- source
- source version/date
- relevant section
- reviewer/mapping status
- rule version.

Raw label text is not automatically converted into an authoritative interaction rule by uncontrolled NLP.

## Rule states

- DISCOVERED
- CURATED
- REVIEWED
- ACTIVE
- DEPRECATED
- RETIRED
- BLOCKED
- RESEARCH_ONLY.

Only ACTIVE rules participate in user-facing deterministic safety checks.

## Action taxonomy

A rule can produce one or more structured actions:

- INFORMATION_ONLY
- DUPLICATE_INGREDIENT
- TIMING_SEPARATION
- USE_CAUTION
- MONITOR
- AVOID_COMBINATION
- CONTRAINDICATED
- REVIEW_WITH_CLINICIAN_OR_PHARMACIST
- EMERGENCY_WARNING_SOURCE_DEFINED.

These labels must not exceed the source evidence.

Do not infer `CONTRAINDICATED` merely because an interaction exists.

## Severity

Do not compress all safety knowledge into a universal 1–10 severity number.

If severity/classification comes from a validated licensed source, preserve that source's native class.

Otherwise use descriptive action/evidence categories.

## Applicability

Rules can depend on:
- ingredient identity
- route
- dose/range
- timing
- age
- pregnancy/lactation context
- renal/hepatic function
- condition
- laboratory value
- genetic marker
- formulation.

If required applicability data are absent:
return `INSUFFICIENT_CONTEXT` rather than pretending the rule definitely applies.

## Safety assessment

A user-facing InteractionAssessment stores:
- exposures evaluated
- rule IDs/versions
- source evidence IDs
- applicability result
- action category
- limitations
- generated_at.

It is a deterministic assessment artifact, not a diagnosis.


---

<!-- SOURCE: 158_DUPLICATE_INGREDIENT_AND_STACKING_DETECTION.md -->

# DUPLICATE INGREDIENT AND STACKING DETECTION

## Purpose

Catch a common class of avoidable mistakes before requiring a full clinical interaction database.

## Basic duplicate rule

Two active plans or observed intake events can trigger a duplicate-ingredient signal when:

1. normalized IngredientConcept identity is the same,
2. exposure windows overlap,
3. the products are distinct or the same product was taken more than once,
4. the ingredient relationship is not merely an ambiguous name match.

Output:
`DUPLICATE_INGREDIENT`

This does NOT automatically mean overdose or toxicity.

## Example

Product A:
Vitamin D3 25 mcg

Product B:
Multivitamin containing Vitamin D3 10 mcg

If both are active:
the engine may show:
- same normalized ingredient
- planned combined amount = 35 mcg/day if schedules support that calculation
- sources/products contributing to the total.

It must not declare the combined amount safe/unsafe without an applicable reference rule.

## Unit normalization

Safe:
`1000 mcg = 1 mg`

when quantity dimension and ingredient basis are identical.

Unsafe without explicit rule:
- calcium carbonate mg → elemental calcium mg
- retinyl palmitate mass → vitamin A activity unit
- vitamin D IU ↔ mcg if conversion rule/version is not installed
- herbal extract mg → raw herb equivalent.

## Blend/proprietary formula

If ingredient amount is undisclosed:
duplicate identity may still be detected,
but combined quantitative exposure can remain `UNKNOWN`.

## Same product repeat dose

The detector can distinguish:
- expected scheduled second dose
- duplicate accidental intake candidate.

This requires schedule/time context.

## Stacking categories

- EXACT_DUPLICATE_ACTIVE_INGREDIENT
- SAME_ACTIVE_DIFFERENT_PRODUCT
- SAME_PRODUCT_REPEAT_INTAKE
- OVERLAPPING_CLASS_SIGNAL
- POSSIBLE_NAME_DUPLICATE
- UNKNOWN_COMPOSITION.

Only exact/reviewed identity mappings should contribute to hard duplicate alerts.


---

<!-- SOURCE: 159_DRUG_SUPPLEMENT_FOOD_LAB_AND_CONDITION_INTERACTION_TAXONOMY.md -->

# DRUG, SUPPLEMENT, FOOD, LAB AND CONDITION INTERACTION TAXONOMY

## Interaction classes

### DRUG_DRUG
Two medication ingredients/products.

### DRUG_SUPPLEMENT
Medication with vitamin, mineral, botanical or other supplement ingredient.

### SUPPLEMENT_SUPPLEMENT
Two supplement ingredients or products.

### DRUG_FOOD
Food/beverage/nutrient context.

### DRUG_SUBSTANCE
Alcohol, tobacco/nicotine, recreational/other exposure where supported.

### DRUG_LAB_TEST
Medication can alter laboratory test measurement or interpretation.

### DRUG_CONDITION
Medication-related contraindication/precaution in a condition.

### SUPPLEMENT_CONDITION
Supplement-related caution in a condition.

### MULTI_FACTOR
Interaction depends on more than a pair.

## Mechanism fields

Optional structured mechanism categories:
- absorption
- metabolism
- transport
- pharmacodynamic_additive
- pharmacodynamic_opposing
- renal_elimination
- electrolyte
- bleeding/hemostasis
- CNS
- QT/electrophysiology
- laboratory_assay
- unknown/other.

Mechanism is explanatory metadata.
Clinical action must still come from reviewed evidence/rule.

## Timing

Interaction can be:
- concurrent
- within N hours
- persistent exposure
- chronic use
- unknown.

## Evidence direction

Source may say:
- interaction can increase exposure/effect
- decrease exposure/effect
- alter test result
- increase adverse effect risk
- unknown clinical significance.

The engine preserves this direction rather than replacing it with generic "bad interaction".

## Source confidence

Data-quality/evidence fields can include:
- regulatory label
- government evidence summary
- guideline
- systematic review
- controlled study
- observational evidence
- case report
- mechanistic/in vitro
- manufacturer label
- unknown.

Evidence rank does not automatically equal effect magnitude.


---

<!-- SOURCE: 15_ACCEPTANCE_TESTS.md -->

# ACCEPTANCE TESTS

These are product-level gates. Automated tests should cover as many as possible, supplemented by real device/browser tests.

## Account and isolation

AT-001 Create account and sign in.
AT-002 Same account can access its own records on two supported clients.
AT-003 User A cannot retrieve User B's health records.

## Mind

AT-010 Create today's mind check-in.
AT-011 All configured ratings accept only valid 1–10 values.
AT-012 Correct a check-in without silently destroying original provenance.
AT-013 UI states that ratings are self-report, not diagnosis.

## Laboratory

AT-020 Create a lab session.
AT-021 Add multiple lab results.
AT-022 Preserve value + unit + lab reference metadata.
AT-023 Add same analyte on a later date.
AT-024 Display comparable longitudinal series.
AT-025 Prevent/flag incompatible unit comparison.
AT-026 Correction preserves provenance.

## Conditions and symptoms

AT-030 Create suspected condition.
AT-031 Suspected condition does not display as confirmed diagnosis.
AT-032 Create confirmed diagnosis explicitly.
AT-033 Record symptom with severity and dates.

## Food diary

AT-040 Create meal.
AT-041 Search/select provider food.
AT-042 Log quantity and calculate nutrient contribution.
AT-043 Missing nutrient remains missing, not zero.
AT-044 Create custom food.
AT-045 Barcode lookup can select exact packaged product when provider has it.
AT-046 Logged food keeps historical snapshot after provider source changes.
AT-047 Daily totals aggregate compatible nutrients.

## Timeline

AT-050 Mind event appears on timeline.
AT-051 Lab event appears on timeline.
AT-052 Food event appears on timeline.
AT-053 Timeline event opens canonical source record.

## Medication / plan semantics

AT-060 Create medication/supplement plan.
AT-061 Plan alone does not produce completed intake.
AT-062 Create actual intake event.

## Vitals/activity/sleep

AT-070 Record a vital with unit/date/source.
AT-071 Record blood pressure with systolic/diastolic.
AT-072 Record sleep episode.
AT-073 Record activity event.

## Offline/sync

AT-080 Create supported record offline on mobile.
AT-081 Reconnect and synchronize without duplicate.
AT-082 Retry after network timeout does not duplicate an already accepted write.
AT-083 Conflict policy preserves newer/independent information according to entity rules.

## Export/deletion

AT-090 Export own data.
AT-091 Export contains documented units and timestamps.
AT-092 Account deletion behavior matches documented policy.

## Build and platform

AT-100 Android release build succeeds.
AT-101 APK installs on a supported Android device.
AT-102 iOS project builds on a supported Xcode environment when signing prerequisites are available.
AT-103 Web production build succeeds.
AT-104 Responsive web dashboard works on supported desktop and mobile browsers.

## Evidence honesty

AT-110 Build report separates:
- source written,
- static analysis,
- automated tests,
- build,
- installation,
- real runtime validation.

No stage may be promoted from assumption alone.


## Today / trends

AT-120 Today loads current-day canonical summaries without marking absent actions completed.
AT-121 Trend range switch changes the queried period while preserving raw point dates/units.

## Food edge cases

AT-048 Quantity conversion refuses an undefined conversion rather than guessing.
AT-049 A recipe can be created and its ingredient/yield calculation remains versioned when the recipe feature is implemented.

## Accessibility

AT-130 Core web flows can be completed with keyboard navigation.
AT-131 Interactive controls expose meaningful semantic labels and do not encode required meaning by color alone.

## Localization / units

AT-140 UI text is externalizable/localizable rather than deeply hard-coded into domain logic.
AT-141 Preferred display units do not rewrite canonical source values without explicit conversion/provenance.

## Security / privacy

AT-150 Unauthenticated request cannot read private health data.
AT-151 Authenticated User A cannot read/update/delete User B records by guessing IDs.
AT-152 Server/client distributable artifacts contain no committed production secret.
AT-153 Sensitive health payloads are not unnecessarily written to normal application logs.
AT-154 Export and deletion endpoints require authenticated ownership.

## Migration

AT-160 Fresh database applies all migrations successfully.
AT-161 Upgrade from previous supported schema preserves fixture records and relationships.
AT-162 Failed migration path does not silently mark database current.

## Backup / restore

AT-170 Restore a representative backup into a clean compatible environment and verify record counts/identities and critical relationships.


## Universal health input / advanced modules
AT-180 Add a generic dated HealthFact and retrieve it after restart/re-login.
AT-181 Correct HealthFact without silently destroying provenance.
AT-182 Record vaccination date/dose metadata.
AT-183 Record a procedure event.
AT-184 Oncology Advanced records chemotherapy course/cycle without converting the event itself into survival prediction.
AT-185 Record cream/topical use as ProductUseEvent distinct from product catalog.
AT-186 Disable Advanced module; UI hides while records remain intact.
AT-187 Re-enable module; records reappear.

## Scoring / longevity mathematics
AT-190 App domain score displays score + coverage + confidence + model version.
AT-191 Missing component does not become zero merely to complete a domain score.
AT-192 Validated risk retains its native output semantics and eligibility/version metadata.
AT-193 Ineligible user does not receive a normal-looking validated risk output.
AT-194 Population life expectancy displays source/geography/table year and population-baseline label.
AT-195 HALE, when available, is labeled population healthy-life-expectancy baseline.
AT-196 Lifespan output does not change merely because a skin-domain score changes unless an explicit applicable lifespan model uses that input.
AT-197 Oncology does not present a universal validated cancer-risk score across all cancer types.
AT-198 Score drilldown shows inputs and model/calculation metadata.
AT-199 Historical ScoreResult retains model version and source record IDs.


## Comparison

AT-200 Create at least 10 synthetic comparison profiles without a hard-coded 2–4 profile limit.
AT-201 Clone a source profile to a scenario; changing scenario weight does not mutate source profile.
AT-202 Compare compatible metrics across 3+ profiles.
AT-203 Pin one profile as baseline and calculate supported absolute deltas.
AT-204 Ineligible profile displays NOT_ELIGIBLE for a validated model.
AT-205 Same profile inputs + same model versions reproduce same comparison outputs.

## Reset/defaults

AT-210 Reset settings to defaults; health records remain unchanged.
AT-211 Reset one Advanced module; unrelated module settings remain unchanged.
AT-212 Reset scenario to source baseline when configured.
AT-213 Delete-data action is separate from settings reset and requires explicit destructive confirmation.

## Daily Missions / training

AT-220 Generate today's mission set offline from deterministic rule pack.
AT-221 Same inputs/date/rule version produce same missions.
AT-222 Planned workout prescription is not recorded as completed exercise.
AT-223 Completing prescribed sets records actual sets/reps/load separately.
AT-224 Safety flag can BLOCK a configured exercise mission.
AT-225 Mission streak/XP does not alter clinical risk output by itself.

## Education

AT-230 Open installed education lesson with network disabled.
AT-231 Complete quiz and receive authored deterministic feedback offline.
AT-232 Enter a supported health metric and receive its configured contextual education card.
AT-233 Learning XP does not directly change health score.

## Wearables / health stores

AT-240 Android permission denial leaves manual entry usable and creates no fake Health Connect data.
AT-241 Import Health Connect sleep record with source provenance.
AT-242 Import Health Connect heart-rate/resting-heart-rate data without duplicate on repeated import.
AT-243 iOS permission denial leaves manual entry usable and creates no fake HealthKit data.
AT-244 Import authorized HealthKit health sample with source provenance.
AT-245 Revoked health-store permission is handled without deleting already imported canonical history unless policy explicitly requires it.

## No-AI offline core

AT-250 Disable network and verify existing records, comparison, scores, Daily Missions and installed education still function.
AT-251 No required feature invokes an LLM/generative-AI endpoint.
AT-252 Core score can expose its local model/rule ID and version.

## Longevity / Shortevity
AT-260 Domain can show Protection and Burden simultaneously without collapsing either into the other.
AT-261 Burden Score does not display as mortality probability or years lost.
AT-262 BalanceIndex equals ProtectionScore minus BurdenScore and still exposes both original scores.
AT-263 Domain trajectory returns one explicit state and includes rule/model version.
AT-264 Insufficient repeated data returns INSUFFICIENT_DATA rather than invented trend.
AT-265 Cumulative exposure preserves domain-specific unit and time basis.
AT-266 Treatment burden event can be recorded without implying treatment failure.
AT-267 Improving recovery metric can coexist with active disease burden.

## Causal/evidence graph
AT-270 A temporal before/after observation is labeled temporal association unless stronger evidence is linked.
AT-271 Evidence-supported effect stores population/outcome/time/source metadata.
AT-272 Scenario recalculation is labeled hypothetical and not observed fact.
AT-273 Validated prediction model output is not automatically labeled causal treatment benefit.

## Human OS donor methods
AT-280 Current state can be rebuilt/projected from events + corrections + policies for a representative fixture.
AT-281 Plan remains distinct from actual completion across missions, medication and training.
AT-282 Historical correction remains linked after derived outputs are recalculated.
AT-283 New rule/model effective date does not silently relabel an old historical result.
AT-284 DecisionRecord preserves choice, reason, alternative and switch condition.
AT-285 Hypothetical failure mode is not stored as observed FailureRecord.
AT-286 Same imported event is deduplicated.
AT-287 Profile A private state does not become Profile B default.
AT-288 Missed optional mission does not automatically create double workload next day unless explicit rule says so.
AT-289 Recovery/treatment state can block or downscale an eligible mission according to a versioned rule.

## Early warning
AT-290 Configured worsening rule produces WATCH/REVIEW state with rule ID/version.
AT-291 Missing data does not trigger an invented worsening alert.
AT-292 Alert text names detected pattern without diagnosing a disease.


## Life course / episodes

AT-300 A health event can appear in whole-life chronology and retain its canonical source.
AT-301 Related diagnosis/treatment/lab/symptom records can be linked to one EpisodeOfCare.
AT-302 Closing an episode does not delete its component events.
AT-303 Unknown early-life history remains unknown rather than auto-filled.

## Biological age / function

AT-310 Two different biological-age models can coexist for the same date.
AT-311 Missing required clock input returns NOT_CALCULABLE unless the model defines an explicit missing-data method.
AT-312 Biological-age output is not displayed as life expectancy.
AT-313 FunctionalMeasurement trend remains separate from disease-risk probability.
AT-314 Validated functional/frailty instrument preserves native scoring.

## QoL / pain / rehabilitation

AT-320 Pain event stores intensity and function/interference independently when provided.
AT-321 Rehab plan does not create completed rehab session.
AT-322 Recovery view can compare baseline, acute/worst and current values without inventing a target.
AT-323 QoL result is labeled with instrument/model identity.

## Multimorbidity / interactions

AT-330 Two active conditions remain distinct while a multimorbidity view can display both.
AT-331 Medication/supplement interaction rule shows rule version/source.
AT-332 Interaction warning does not automatically change medication dose.
AT-333 Condition count alone is not presented as universal disease burden.

## Environment / social context

AT-340 Environmental exposure stores intensity/duration/unit/source.
AT-341 Coarse location can be used when precise location is not required.
AT-342 Social/access context remains optional and does not create moralized health score.
AT-343 Exposure scenario is labeled hypothetical.

## Interoperability

AT-350 Standardized code can be attached without deleting original wording.
AT-351 Unit normalization preserves original source value/unit.
AT-352 Imported external record retains external/source identifier.
AT-353 Unmapped external concept remains UNMAPPED/UNKNOWN rather than guessed.
AT-354 Export declares schema/format version.

## Digital twin / scenarios

AT-360 Twin snapshot can be regenerated from the same event cursor + model/rule versions.
AT-361 Scenario patch changes scenario output without changing canonical source record.
AT-362 Scenario result carries one of the defined evidence/recalculation labels.
AT-363 Mathematical biomarker scenario is not automatically labeled treatment-effect estimate.

## Personal baseline / forecast

AT-370 Personal baseline is labeled separately from laboratory reference range.
AT-371 Robust anomaly rule can detect configured deviation and exposes method/version.
AT-372 Insufficient baseline sample returns INSUFFICIENT_DATA.
AT-373 Forecast exposes method, horizon and source window.
AT-374 Insufficient forecast data returns NOT_CALCULABLE.

## Portable state

AT-380 Full export manifest contains schema/model/rule/content versions.
AT-381 Restore preserves event IDs and correction links.
AT-382 Restore verifies hashes before accepting bundle.
AT-383 Merge mode does not silently duplicate already-known records.
AT-384 Restored historical ScoreResult retains original model version.


## Data quality / provenance
AT-400 Imported/device/manual records expose distinct provenance.
AT-401 Missingness can distinguish NOT_MEASURED from IMPORT_FAILED.
AT-402 A low-quality measurement does not automatically worsen a health-risk score unless the model explicitly uses it.
AT-403 Source precision is preserved without fabricated decimal places.
AT-404 Conflicting records can remain unresolved without one being silently overwritten.

## Units / devices
AT-410 Source value/unit survives canonical-unit normalization.
AT-411 Incompatible quantities cannot be converted.
AT-412 mL-to-g conversion is blocked without density/context.
AT-413 Analyte-specific mass↔molar conversion requires analyte context.
AT-414 Repeated measurement session preserves every reading.
AT-415 Session mean/median appears only under an explicit protocol.
AT-416 Device/calibration metadata remains UNKNOWN when unavailable.

## Model governance
AT-420 Model with missing required input returns MISSING_INPUTS.
AT-421 Ineligible model returns NOT_ELIGIBLE.
AT-422 Golden fixture reproduces expected deterministic output within declared tolerance.
AT-423 Retired model remains interpretable for historical ScoreResult.
AT-424 Retired model is not silently used for new production result.
AT-425 Two models with different endpoints are not ranked as direct equivalents.

## Rule governance
AT-430 Safety-block rule takes precedence over optional optimization rule when configured.
AT-431 Two conflicting rules without defined precedence produce REVIEW/BLOCK rather than random selection.
AT-432 Historical mission retains the rule version originally used.
AT-433 Missing safety-critical input produces documented insufficient-data behavior.

## Benchmarks
AT-440 Percentile output names dataset/version/population.
AT-441 Out-of-scope profile receives LOW_APPLICABILITY/NOT_APPLICABLE rather than silent extrapolation.
AT-442 Updated benchmark dataset does not silently rewrite historical benchmark snapshots.

## Consent / privacy / audit
AT-450 Revoking an integration consent stops future authorized reads according to platform capability.
AT-451 Local-only profile can create/view/calculate records with network disabled.
AT-452 Export action produces an audit event without copying full exported health payload into ordinary logs.
AT-453 Another-real-person comparison profile defaults to private/local behavior.

## Personal experiments
AT-460 PersonalExperiment can compare baseline/intervention/follow-up without automatically claiming causality.
AT-461 High-risk prescription treatment change is not generated as an app experiment instruction.
AT-462 Experiment result stores data IDs and analysis method/version.

## Import pipeline
AT-470 Unknown unit import is staged instead of canonicalized incorrectly.
AT-471 Same authoritative external record ID is deduplicated.
AT-472 Similar timestamp/value from different devices is not automatically assumed duplicate.
AT-473 Import batch reports committed/duplicate/conflict/failure counts.
AT-474 Bad import batch can be rolled back without deleting unrelated prior records.

## Packs / scaling
AT-480 Corrupt pack checksum blocks activation.
AT-481 Incompatible pack dependency blocks activation.
AT-482 Rollback restores previous verified pack version.
AT-483 Historical result keeps old pack/model version after update.
AT-484 Long-range wearable chart may use aggregates while short-range raw samples remain queryable according to retention policy.


## Secure local storage / auth

AT-500 Production secret is not embedded in client source/package.
AT-501 Authentication token is stored through platform-appropriate secure storage.
AT-502 App-lock failure does not corrupt/logout canonical local data.
AT-503 Revoked device/session can no longer perform authenticated server actions.
AT-504 Local-only to cloud migration preserves record IDs/provenance and produces verified counts.
AT-505 Key-loss/reinstall behavior matches documented recovery limitations.

## Reminder scheduling

AT-510 Delivered notification does not mark underlying mission complete.
AT-511 Opening notification does not mark medication as taken.
AT-512 Snooze changes reminder schedule without changing original due/completion history.
AT-513 Plan edit cancels/replaces obsolete scheduled reminder without duplicate.
AT-514 Timezone change follows declared schedule semantics.
AT-515 Permission denial leaves app usable and shows reminder capability state.
AT-516 Exact-timing requirement is not assumed available without platform capability/permission.

## Accessibility / localization

AT-520 Core web flow works keyboard-only.
AT-521 Screen reader exposes useful names for primary controls.
AT-522 200% text scaling does not make critical mobile flow unusable.
AT-523 Health meaning remains understandable without color.
AT-524 Reduced-motion preference is respected by nonessential animations.
AT-525 Turkish and English locale can switch without changing canonical data.
AT-526 Locale-specific decimal/date formatting does not corrupt stored numeric/timestamp semantics.
AT-527 RTL-capable layout does not rely on hard-coded left/right assumptions for critical navigation.

## Clinician/report sharing

AT-530 User can generate lab-only report for a selected date range.
AT-531 Report distinguishes validated risk from app-defined score.
AT-532 User-entered data are not labeled clinician-certified.
AT-533 Expiring share, when implemented, becomes inaccessible after expiry/revocation.
AT-534 Report includes generation/version/provenance metadata.

## Observability / recovery

AT-540 Crash telemetry omits configured sensitive payload fields.
AT-541 Failed transaction does not leave half-created canonical record set.
AT-542 Interrupted import/update is detected on startup and resumes/rolls back deterministically.
AT-543 Support bundle excludes health payload by default.
AT-544 User can identify an error/support ID without exposing health details.
AT-545 Safe mode can open enough of app to export/support when optional pack failure blocks normal startup.

## Deployment / security / claim control

AT-550 Staging and production use distinct secrets/configuration.
AT-551 Release record links build artifact to source/schema/model/rule/content versions.
AT-552 Known unresolved cross-user authorization vulnerability blocks production release.
AT-553 Secret-scanning fixture detects committed test-secret pattern.
AT-554 Mobile security checklist maps relevant controls to MASVS categories.
AT-555 Diagnostic/treatment claim cannot be promoted to public product copy without required review status.
AT-556 App-store/web claim text does not promise lifespan extension unsupported by product evidence.


## Reference architecture / screen states

AT-560 Reference implementation can be replaced without violating canonical product invariants.
AT-561 Today loading state never displays fake zero/normal health values.
AT-562 Labs validation error preserves repairable user input.
AT-563 Compare renders NOT_COMPARABLE for incompatible result semantics.
AT-564 Permission-blocked wearable screen keeps manual entry available.
AT-565 Timeline with equal timestamps has stable deterministic order across pagination.

## Migration fixtures

AT-570 MIG-F01 correction relationship survives migration.
AT-571 MIG-F02 food snapshot identity survives migration without provider requery.
AT-572 MIG-F03 does not fabricate completion from plan during migration.
AT-573 MIG-F04 preserves MISSING nutrient state.
AT-574 MIG-F05 preserves original source value/unit.
AT-575 MIG-F06 preserves scenario/source isolation.
AT-576 MIG-F07 preserves historical model version.
AT-577 MIG-F08 preserves deletion tombstone against stale resurrection.
AT-578 Failed migration leaves schema version at prior valid version.
AT-579 Migration fixture suite runs from fresh supported prior versions.

## API contracts

AT-580 Validation failure uses documented machine-readable error code.
AT-581 Cursor pagination returns no duplicate/skip for stable test fixture.
AT-582 Same idempotency key and same create request returns original accepted identity.
AT-583 Same idempotency key with materially different request returns IDEMPOTENCY_CONFLICT.
AT-584 Stale mutable update returns REVISION_CONFLICT instead of overwriting.
AT-585 Production API error does not expose stack trace/secret.

## Synthetic generators

AT-590 Same seed + generator version creates identical golden synthetic dataset.
AT-591 Generated fixtures are marked SYNTHETIC and contain no known real-user identifiers.
AT-592 Failure injection can simulate timeout after server commit and retry remains idempotent.
AT-593 Invalid-import generator produces staged/rejected records rather than canonical corruption.
AT-594 Compare generator creates at least 12 profiles with mixed eligibility.

## Performance / scale

AT-600 Reference benchmark records actual device/browser/build and p95 metrics.
AT-601 Timeline fixture with 10,000 events meets or reports against current budget without hiding failure.
AT-602 Dense-series fixture contains at least 1,000,000 samples and long-range chart uses aggregate path.
AT-603 Compare benchmark uses at least 20 profiles × 25 metrics without UI freeze on reference environment.
AT-604 Daily mission generation benchmark reports p95 against current target.
AT-605 Benchmark failure does not get converted to PASS by changing the report after execution.

## E2E / CI / agent execution

AT-610 E2E-01 local-only daily flow passes end-to-end.
AT-611 E2E-02 lab correction/trend flow passes end-to-end.
AT-612 E2E-05 scenario comparison does not mutate observed profile.
AT-613 E2E-07 local-to-cloud retry does not duplicate accepted record.
AT-614 E2E-08 notification open does not create IntakeEvent.
AT-615 E2E-09 export/restore preserves IDs, corrections and model versions.
AT-616 E2E-10 cross-user guessed-ID access is denied.
AT-617 Quarantined flaky test cannot satisfy a release-critical acceptance requirement.
AT-618 CI report identifies commit/build/environment/test IDs.
AT-619 Stubbed provider/model/persistence path is reported incomplete, not production-complete.
AT-620 Implementation agent continues independent READY platforms when another platform is BLOCKED.


## Component contracts
AT-630 MetricCard renders MISSING without numeric zero.
AT-631 ResultCard labels validated risk and app composite as different result classes.
AT-632 ProvenanceDrawer preserves original value/unit alongside normalized representation.
AT-633 MissionCard notification-delivered state does not render mission COMPLETED.
AT-634 CompareGrid renders mixed NOT_ELIGIBLE/NOT_COMPARABLE states without invented values.
AT-635 ErrorBanner states whether user data were saved and exposes a safe recovery action.
AT-636 Core component accessibility test exposes semantic labels for screen reader/keyboard flow.

## Module ownership / dependencies
AT-640 Timeline deletion request cannot directly delete canonical LabResult through projection storage.
AT-641 Compare scenario write cannot mutate source LabResult/Condition/Vital entities.
AT-642 Wearable import commits through owning domain semantics rather than creating opaque shadow health copies.
AT-643 Lab correction invalidates dependent ScoreResult but leaves unrelated sleep history unchanged.
AT-644 Module dependency graph contains no uncontrolled recursive canonical-write cycle.

## Repository bootstrap / contracts
AT-650 Fresh repository bootstrap can launch client shell, backend health endpoint and database migration 1.
AT-651 `.env.example` contains placeholders and no production secret.
AT-652 Generated OpenAPI is reproducible from implementation/contract source with no manual drift.
AT-653 Numeric API input rejects NaN/Infinity.
AT-654 Lab numeric result without required unit fails validation unless explicitly unitless.
AT-655 Nutrient MISSING remains null+semantic status, not zero.
AT-656 OpenAPI release diff detects a deliberately introduced breaking response-field removal.

## Fixture library
AT-660 FIX-P01 drives documented empty states without fake health values.
AT-661 FIX-P05 synthetic oncology episode contains no real-user identifiers and exercises treatment/recovery links.
AT-662 FIX-P08 dense wearable fixture preserves external IDs and duplicate cases.
AT-663 Golden fixture with same seed/version is byte/semantic reproducible according to generator contract.
AT-664 Fuzz/property failure reports the seed required to reproduce it.

## Disaster recovery
AT-670 DR-02 interrupted migration does not mark target schema complete.
AT-671 DR-03 restored database preserves correction links, tombstones and historical model versions.
AT-672 DR-04 missing attachment does not delete its canonical health record.
AT-673 DR-05 import rollback removes only the targeted batch effects.
AT-674 DR-07 stale offline update cannot resurrect tombstoned record.
AT-675 DR-09 key-loss behavior matches documented recoverability limitations.
AT-676 DR-10 tampered portable export fails checksum validation before canonical restore.

## Sync chaos / error catalog
AT-680 Timeout-after-server-commit retry resolves the same canonical record identity.
AT-681 Two-device stale mutable edit produces REVISION_CONFLICT.
AT-682 Independent append events from two offline devices both survive merge.
AT-683 Competing corrections of the same historical record surface semantic conflict.
AT-684 Client clock skew does not become sole ordering authority.
AT-685 PACK_INVALID leaves previous verified pack active when possible.
AT-686 Calculation failure renders error/insufficient state rather than a normal-looking zero.
AT-687 AUTH_EXPIRED preserves local offline access according to configured policy while blocking server action.

## Release / bootstrap
AT-690 Final release manifest references only artifacts that actually exist.
AT-691 Release checksum verification passes against final artifact bytes.
AT-692 START_HERE states tested platforms and blockers without promotion by assumption.
AT-693 Bootstrap vertical slice persists MindCheckin across restart and projects it into Timeline.
AT-694 Bootstrap sync retry is idempotent.
AT-695 Bootstrap owner-authorization test denies cross-user access.
AT-696 Broad feature implementation is not marked foundation-complete while bootstrap gates fail.


## Domain API / ownership
AT-700 Every module in DOMAIN_API_CATALOG has at least one owned resource or explicit projection-only declaration.
AT-701 A projection module cannot directly mutate another module's canonical persistence in integration tests.
AT-702 LabResult correction API preserves source result and creates/links correction semantics.
AT-703 FoodSnapshot referenced by historical FoodEntry rejects in-place nutrient/provider mutation.
AT-704 ScoreResult API returns model/result-class/eligibility/version metadata.

## Query / search / pagination
AT-710 Timeline date-range boundary behavior is deterministic and documented.
AT-711 Equal-timestamp pagination remains stable with canonical ID tie-breaker.
AT-712 Unsupported sort/filter expression returns validation error rather than being silently ignored.
AT-713 Deleted/corrected canonical record propagates to search projection.
AT-714 Full JSON export preserves IDs, relations, provenance and model versions.
AT-715 CSV missing numeric field remains empty/semantic-missing rather than zero.

## Responsive UI / visual semantics
AT-720 Today compact layout preserves primary action and does not hide blocked/review state.
AT-721 Expanded web Results layout preserves typed result sections and source/model drilldown.
AT-722 Compare compact layout supports horizontal multi-profile access without truncating semantic values into ambiguity.
AT-723 Aging-friendly density increases readability/control size without modifying canonical data or scores.
AT-724 Chart has accessible textual/table alternative for representative trend fixture.

## Retention / deletion
AT-730 Settings reset leaves canonical health record counts unchanged.
AT-731 Tombstoned synchronized LabResult cannot be resurrected by stale offline device mutation.
AT-732 Deleting a source record invalidates declared dependent ScoreResult/projection without deleting unrelated history.
AT-733 Deleting MedicationPlan does not silently delete historical IntakeEvent unless explicitly selected by policy/action.
AT-734 Account deletion cannot report COMPLETED while test fixture still exposes in-scope cloud health record outside documented retention exception.
AT-735 Local imported-record deletion UI states that upstream HealthKit/Health Connect/provider source is outside local deletion scope when applicable.

## Domain events / degradation
AT-740 Duplicate LAB_RESULT_CORRECTED domain event produces one effective projection/invalidation result.
AT-741 Failed noncritical timeline projection update does not roll back committed canonical LabResult.
AT-742 MODEL_PACK_ACTIVATED does not relabel historical ScoreResult to new model version.
AT-743 Notification permission denial falls back to in-app due list without fake delivery state.
AT-744 Network-offline state retains local records/calculations and marks remote freshness appropriately.
AT-745 Food-provider outage preserves cached/custom-food path and never converts missing nutrients to zero.

## Production dossier / release evidence
AT-750 Production dossier cannot resolve PRODUCTION_READY when any release-blocking evidence item is FAIL/BLOCKED/NOT_RUN.
AT-751 Android PASS and iOS NOT_RUN remain platform-scoped and do not promote iOS or whole-platform matrix by assumption.
AT-752 Every PASS evidence item references at least one concrete report/artifact/method identifier.
AT-753 Release dossier identity matches final artifact manifest/version/checksums.
AT-754 Core screen wireframe contract identifies primary action, error/offline state and accessibility behavior.


## Interactive Site / Web Lab

AT-755 Site build prompt exists as a standalone artifact and is referenced by handoff state.
AT-756 Default public Site profile is explicitly synthetic/demo data.
AT-757 Adjusting a supported profile control changes a deterministic derived result.
AT-758 Repeating identical inputs/model version reproduces identical result.
AT-759 Missing input remains missing/unknown rather than zero.
AT-760 Ineligible calculator displays NOT_ELIGIBLE or equivalent explicit state.
AT-761 Compare Lab supports at least three simultaneous profiles in a tested UI flow.
AT-762 Scenario clone modification does not mutate source profile.
AT-763 Reset Demo to Defaults returns synthetic state to declared defaults.
AT-764 Reset Demo does not invoke account/real-health-data deletion semantics.
AT-765 Protection/Burden/Function/Coverage remain visually and semantically distinct.
AT-766 App-defined Site score is not displayed as validated mortality probability or life expectancy.
AT-767 Site works without a generative-AI endpoint.
AT-768 Site primary demo remains usable without account creation.
AT-769 Mobile viewport supports profile edit + result review without desktop-only dependency.
AT-770 Desktop viewport supports wide compare/results layout.
AT-771 Primary controls are keyboard-operable.
AT-772 `How calculated?` exposes model/rule ID/version and relevant input/coverage metadata.
AT-773 Delivery includes source + lockfile + run/build instructions.
AT-774 Static screenshot/mockup alone cannot satisfy Site completion.


## Starter model/rule packs

AT-775 Core-derived BMI fixture reproduces weight/(height²) without assigning an unrequested clinical category.
AT-776 Waist-height calculation refuses incompatible dimensional inputs.
AT-777 Percent-change calculation rejects zero baseline.
AT-778 Planned resistance-training sets do not contribute to completed volume load.
AT-779 External PREVENT adapter remains unavailable when required license integration is not cleared.
AT-780 Blocked external model produces no fabricated risk percentage.
AT-781 ScoreResult stores model/pack version for starter calculation.
AT-782 Core invariant rule prevents missing value from becoming numeric zero.
AT-783 Notification OPENED state does not complete mission under starter rule pack.
AT-784 Scenario rule prevents scenario patch from mutating canonical observed record.
AT-785 Rule execution explanation includes rule ID and version.

## Reference/licensing

AT-786 WHO reference entry carries dataset/source/version/retrieval/attribution metadata when activated.
AT-787 USDA FoodData Central adapter does not expose API key in distributed public client.
AT-788 Open Food Facts integration exposes required source/license attribution metadata.
AT-789 UCUM-distributed material carries required license notice according to chosen distribution scope.
AT-790 FHIR adapter does not treat third-party terminology referenced by FHIR as automatically licensed.
AT-791 A pack with unresolved required license acceptance returns BLOCKED_LICENSE.
AT-792 About/Data Sources view can list active third-party source, purpose, version and attribution.

## Education starter pack

AT-793 Foundation education pack parses all 15 stable lesson IDs.
AT-794 Quiz completion changes learning progress but not health risk/ScoreResult.
AT-795 Education pack works with network disabled.
AT-796 “Missing does not mean zero” quiz answer key rejects zero substitution.

## Executable schemas

AT-797 HealthFact starter schema accepts a valid minimal manual fact.
AT-798 LabResult starter schema accepts missing NOT_REPORTED with numeric_value null.
AT-799 ScoreResult schema permits MISSING_INPUTS with numeric_output null.
AT-800 Mission schema keeps PLANNED distinct from COMPLETED.
AT-801 ComparisonProfile scenario schema preserves source_profile_id without mutating source fixture.
AT-802 PackManifest schema rejects malformed checksum.
AT-803 Schema version mismatch enters migration/compatibility path rather than silent field loss.
AT-804 Site starter pack runs without any real user health data or secret API key.


## Golden vectors

AT-805 Reference engine passes every v0.17 core-derived golden vector.
AT-806 Re-running the same golden vector produces the same result.
AT-807 Percent-change zero baseline returns ZERO_BASELINE rather than numeric output.
AT-808 MAD vector with zero MAD returns ZERO_MAD.
AT-809 Training-volume golden vector ignores planned-but-uncompleted set.

## Database DDL

AT-810 SQLite reference schema executes with foreign-key enforcement enabled.
AT-811 Duplicate profile primary key is rejected.
AT-812 HealthFact with unknown profile_id is rejected by foreign key.
AT-813 LabResult NOT_REPORTED can store numeric_value NULL.
AT-814 LabResult PRESENT with numeric_value NULL is rejected.
AT-815 Soft-deleted canonical record remains present with deleted_at rather than disappearing automatically.
AT-816 Duplicate outbox mutation_id is rejected.
AT-817 Duplicate pack_id+version is rejected.
AT-818 ScenarioPatch with missing base profile is rejected.
AT-819 Synthetic demo seed can be run twice without duplicating fixed profile IDs.
AT-820 PostgreSQL reference DDL includes profile ownership foreign keys for canonical health resources.
AT-821 PostgreSQL runtime validation status remains NOT_RUN when no PostgreSQL execution occurred.

## Data dictionary / onboarding

AT-822 Data dictionary distinguishes effective_at, recorded_at and created_at.
AT-823 Data dictionary states coverage is not health risk.
AT-824 First-run flow presents Local Only and Cloud Account choice.
AT-825 First-run tutorial can create a profile with no invented diagnosis/medication.
AT-826 Results-literacy help distinguishes validated risk from app-defined score.
AT-827 NOT_ELIGIBLE help explains applicability without displaying fabricated numeric result.
AT-828 Reset help states settings reset does not delete canonical health history.

## Export / attribution

AT-829 Clinician report example is marked synthetic.
AT-830 Clinician report example labels app-derived score as non-clinician-certified/app-defined.
AT-831 Portable export example preserves active model/rule pack versions.
AT-832 Attribution generator produces a Data Sources & Licenses page from ATTRIBUTION_MANIFEST.json.
AT-833 AHA PREVENT appears as BLOCKED_LICENSE in attribution/developer state until licensed activation.
AT-834 Public/provider secret is absent from generated attribution/help/export examples.
AT-835 Active attribution entry can expose checked date/license/disposition.
AT-836 Missing mandatory attribution metadata blocks release gate by rule/spec.

## Transaction / parity

AT-837 Canonical write protocol publishes invalidation only after commit.
AT-838 Correction can mark affected current derived result stale without deleting old ScoreResult snapshot.


## Migration chain

AT-839 Fresh SQLite migration chain 0001→0004 reaches user_version 4.
AT-840 SQLite upgrade fixture inserted after 0001 survives migrations through 0004.
AT-841 Migration files are ordered and uniquely numbered.
AT-842 Demo seed is not embedded inside schema migration files as real-user health defaults.
AT-843 PostgreSQL migration status remains NOT_RUN in handoff evidence when no PostgreSQL runtime was used.
AT-844 Failed migration cannot be recorded as current schema by contract.

## Authorization / RLS

AT-845 Owner READ authorization vector returns allow.
AT-846 Owner WRITE authorization vector returns allow.
AT-847 Cross-user READ authorization vector returns deny.
AT-848 Cross-user WRITE authorization vector returns deny.
AT-849 Unauthenticated READ authorization vector returns deny.
AT-850 Unauthenticated WRITE authorization vector returns deny.
AT-851 PostgreSQL RLS blueprint enables+forces RLS for profiles and core private health tables.
AT-852 RLS child-resource policy derives access through owning profile.
AT-853 RLS context helper reads server-set app.user_id rather than a row/client-provided owner parameter.
AT-854 Server authorization design explicitly forbids ordinary API execution as database superuser.
AT-855 PostgreSQL RLS runtime status remains NOT_RUN until executed in a PostgreSQL test environment.

## Repository scaffold

AT-856 Repository scaffold contains api/client/site/contracts/domain/persistence boundaries.
AT-857 Verification runner exits successfully when v0.18 executable contracts pass.
AT-858 Verification runner executes core golden vectors.
AT-859 Verification runner executes authorization vectors.
AT-860 Verification runner executes fresh SQLite migration chain.
AT-861 Verification runner executes upgrade-preservation migration fixture.
AT-862 Verification runner checks both build prompts exist.
AT-863 Placeholder README does not satisfy implementation evidence by itself.

## FHIR interoperability

AT-864 Synthetic FHIR reference file parses as JSON and has Bundle resourceType.
AT-865 Synthetic FHIR bundle contains only synthetic/local reference identifiers and no real user data.
AT-866 Internal Profile mapping targets Patient-like semantics.
AT-867 Internal LabResult mapping targets Observation-like semantics.
AT-868 Missing-lab mapping contract forbids numeric zero substitution.
AT-869 App-defined score mapping contract requires app-specific labeling.
AT-870 FHIR mapping catalog labels examples as NOT production validator evidence.
AT-871 FHIR production gate requires validator/profile/terminology review.
AT-872 FHIR mapping does not claim third-party terminology licensing automatically.
AT-873 Site/demo build remains independent of FHIR/provider secrets.


## OpenAPI / API semantics

AT-874 OPENAPI_STARTER.json parses and declares OpenAPI 3.1.
AT-875 Every documented HTTP operation has an operationId.
AT-876 Operation IDs are unique.
AT-877 Every non-public operation is present in ENDPOINT_AUTHORIZATION_MATRIX.json.
AT-878 Private profile endpoints require authenticated owner authorization by contract.
AT-879 profileId URL/path field is explicitly not ownership proof.
AT-880 createHealthFact declares idempotency identity requirement.
AT-881 updateProfile declares revision concurrency requirement.
AT-882 Stable error catalog includes REVISION_CONFLICT.
AT-883 Stable error catalog includes IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_REQUEST.
AT-884 API error examples contain sanitized request_id.
AT-885 OpenAPI reusable schema references all resolve.
AT-886 OpenAPI contract validator exits PASS.

## Rollback / recovery

AT-887 SQLite rollback drill deliberately fails inside transaction and rolls back.
AT-888 Failed rollback drill leaves schema user_version 4.
AT-889 Failed rollback drill removes uncommitted probe table.
AT-890 Failed rollback drill preserves pre-existing profile fixture.
AT-891 Duplicate synthetic seed failure leaves successful schema version unchanged.
AT-892 PostgreSQL rollback drill remains NOT_RUN without PostgreSQL infrastructure.

## UI tokens / state contracts

AT-893 Spacing token scale is monotonic.
AT-894 Minimum touch-target token is at least 44 px.
AT-895 Reduced-motion support token is enabled.
AT-896 Protection/burden/function/confidence semantic roles exist.
AT-897 MetricCard contract includes missing_not_zero guard.
AT-898 ResultCard contract includes visible result class guard.
AT-899 ChartFrame contract includes units and missing-gap semantics.
AT-900 ConflictResolver contract requires source/timestamp/revision transparency.
AT-901 UI contract validator exits PASS.
AT-902 Delivery readiness validator keeps production_ready false when mandatory evidence is NOT_RUN.


## Health platform adapters

AT-903 Health platform mapping catalog parses and identifies Android/Apple mappings separately.
AT-904 Android WeightRecord fixture maps to canonical weight with provider record ID preserved.
AT-905 Android StepsRecord fixture preserves interval semantics.
AT-906 Android recording method is available for provenance mapping.
AT-907 Apple body-mass fixture maps to canonical weight.
AT-908 Apple heart-rate fixture maps to canonical dense heart-rate metric.
AT-909 Empty HealthKit query fixture does not infer permission granted.
AT-910 Empty HealthKit query fixture does not infer user has no health data.
AT-911 Same provider stable ID imported twice produces one canonical identity.
AT-912 Two different devices with same HR timestamp/value remain two source records.
AT-913 Own-write echo fixture does not create a new canonical duplicate.
AT-914 Health platform adapter fixture validator exits PASS.
AT-915 Health platform permission denial leaves manual input path available by contract.
AT-916 Platform SDK runtime integration status remains NOT_RUN in handoff evidence.

## Nutrition/recipe math

AT-917 12 g/100 g protein scaled to 150 g yields 18 g.
AT-918 Multi-ingredient recipe sums known protein/fiber correctly.
AT-919 Three-serving recipe divides totals by three.
AT-920 Per-gram recipe uses measured final cooked mass.
AT-921 Missing ingredient fiber marks fiber total incomplete rather than imputing zero.
AT-922 mL→g without density returns DENSITY_REQUIRED.
AT-923 100 mL at 1.03 g/mL yields 103 g.
AT-924 Zero serving count returns SERVINGS_MUST_BE_POSITIVE.
AT-925 Zero final recipe mass returns FINAL_MASS_MUST_BE_POSITIVE.
AT-926 Stored calculation precision remains finer than two-decimal display example.
AT-927 Nutrition golden-vector validator exits PASS.

## API coverage expansion

AT-928 DOMAIN_API_COVERAGE_MATRIX lists all major product domain groups.
AT-929 OpenAPI includes list/create lab operations.
AT-930 OpenAPI includes list/create nutrition-log operations.
AT-931 OpenAPI includes list/create conditions operations.
AT-932 OpenAPI includes list/create symptoms operations.
AT-933 OpenAPI includes list/create vitals operations.
AT-934 OpenAPI includes medication-plan, sleep and activity collection operations.
AT-935 OpenAPI includes idempotent owner-authorized wearable-import operation.
AT-936 Every new private OpenAPI operation has endpoint authorization matrix entry.
AT-937 Expanded OpenAPI contract validator exits PASS.


## Attachment security and storage

AT-938 Attachment starter schema validates required profile/source/security/extraction metadata.
AT-939 Same synthetic file bytes produce the stored SHA-256 fixture hash.
AT-940 Cross-user hash match is never surfaced as existence disclosure by contract.
AT-941 Cloud attachment policy forbids public bucket/container by default.
AT-942 QUARANTINED/BLOCKED attachment cannot enter parser path.
AT-943 SAFE attachment can enter parser path.
AT-944 Declared PDF with detected JPEG enters mismatch review/block state rather than trusted parsing.
AT-945 Hash mismatch prevents attachment from becoming SAFE.
AT-946 Replacing source file creates new AttachmentVersion semantics.
AT-947 Thumbnail/preview remains derivative linked to exact source version.
AT-948 Default derivative/share policy strips unnecessary hidden image metadata.

## Extraction/review

AT-949 Synthetic lab staging parser emits three candidates from normalized fixture.
AT-950 Mapped numeric candidate preserves numeric value and raw unit.
AT-951 NOT_REPORTED candidate preserves NULL numeric value rather than zero.
AT-952 Unknown label remains UNMAPPED.
AT-953 Missing unit remains NULL rather than guessed.
AT-954 All parser candidates begin UNREVIEWED.
AT-955 UNREVIEWED candidate cannot directly create canonical LabResult by contract.
AT-956 ACCEPTED candidate requires review/commit receipt before canonical IDs are returned.
AT-957 ExtractionReviewReceipt schema requires accepted/rejected candidate IDs and created record IDs.
AT-958 Partial commit can leave rejected/ambiguous candidate uncommitted.
AT-959 Source reference range fields remain source metadata.
AT-960 Upload/import time is not substituted for unknown specimen time.
AT-961 Parser confidence does not bypass review state.
AT-962 Document ingestion fixture validator exits PASS.

## Attachment lifecycle / API

AT-963 Document type catalog includes lab, imaging, pathology, prescription, vaccination, discharge/procedure and photo classes.
AT-964 Deleting attachment does not automatically delete extracted canonical facts.
AT-965 Deleting canonical extracted facts does not automatically delete source attachment.
AT-966 Local-only attachment mode does not require cloud malware-scan PASS claim.
AT-967 OpenAPI includes listAttachments operation.
AT-968 OpenAPI includes initialize/complete upload operations.
AT-969 OpenAPI includes request extraction and list candidates operations.
AT-970 OpenAPI includes commit reviewed candidates operation.
AT-971 Every new attachment operation has owner authorization matrix entry.
AT-972 Mutation attachment operations declare idempotency where required.
AT-973 DOMAIN_API_COVERAGE_MATRIX marks documents as OPENAPI_OPERATION_PRESENT.
AT-974 API error catalog includes FILE_TYPE_NOT_ALLOWED and FILE_TOO_LARGE.
AT-975 API error catalog includes HASH_MISMATCH and MALWARE_DETECTED.
AT-976 API error catalog includes CANDIDATE_REVIEW_REQUIRED.
AT-977 Site Build Prompt specifies synthetic document ingestion/review demo and no mandatory generative AI.


## Medication/supplement canonical model

AT-978 ProductConcept and IngredientConcept are separate schema entities.
AT-979 Active MedicationPlan without IntakeEvent yields zero observed intake events.
AT-980 One supplement product can contain two normalized ingredient concepts.
AT-981 AMBIGUOUS ingredient mapping cannot trigger exact hard interaction rule.
AT-982 Unknown product composition returns insufficient ingredient-level context.
AT-983 Route mismatch can make a route-specific synthetic rule not applicable.
AT-984 Same reviewed ingredient across two active products produces duplicate-ingredient finding.
AT-985 Duplicate-ingredient finding does not assert toxicity.
AT-986 500 mcg + 1 mg same compatible ingredient combines to 1.5 mg.
AT-987 Elemental vs compound amount basis mismatch blocks quantitative sum.
AT-988 Historical intake snapshot remains tied to original product label version by contract.

## Knowledge/evidence governance

AT-989 Medication knowledge source registry includes RxNorm, DailyMed and openFDA.
AT-990 Supplement knowledge source registry includes DSLD and ODS fact sheets.
AT-991 RxNorm source role is identity normalization rather than authoritative interaction rule source.
AT-992 DailyMed rule evidence is versioned by label/SPL provenance.
AT-993 openFDA source is not configured as sole unreviewed production rule source.
AT-994 DSLD is composition/label source rather than complete interaction database.
AT-995 ODS fact-sheet source can support curated supplement interaction evidence.
AT-996 Every synthetic ACTIVE interaction rule carries source version.
AT-997 Deprecated/retired rule states are representable.
AT-998 Missing applicability context can return INSUFFICIENT_CONTEXT.
AT-999 CLEAR_NO_MATCH_FOUND fixture explicitly has guaranteed_safe=false.
AT-1000 Safety pack freshness/version is stored on InteractionAssessment.

## Synthetic safety engine

AT-1001 Medication safety fixture validator passes all synthetic cases.
AT-1002 Pair interaction fixture matches only when required participants exist.
AT-1003 Route-specific pair fixture rejects incompatible route.
AT-1004 Plan-not-taken fixture preserves plan/completion boundary.
AT-1005 Ambiguous identity fixture returns UNKNOWN_INGREDIENT.
AT-1006 Unknown composition fixture returns INSUFFICIENT_CONTEXT.
AT-1007 Rule-version fixture confirms source/version provenance.
AT-1008 Synthetic rule/product IDs are marked test-only and not production knowledge.

## API / schemas / site

AT-1009 ProductConcept JSON Schema validates a minimal valid product.
AT-1010 IngredientConcept JSON Schema validates explicit normalization state.
AT-1011 IntakeEvent JSON Schema requires actual taken_at timestamp.
AT-1012 InteractionAssessment schema supports CLEAR_NO_MATCH_FOUND and INSUFFICIENT_CONTEXT.
AT-1013 OpenAPI includes list/create intake operations.
AT-1014 OpenAPI includes list/create interaction-assessment operations.
AT-1015 OpenAPI includes medication knowledge product search.
AT-1016 OpenAPI includes owner-authorized safety-review operation and endpoint authorization entry.
AT-1017 Site Build Prompt contains synthetic medication/supplement safety lab requirement.


## Preventive care core

AT-1018 PreventiveServiceDefinition and PreventiveRule are separate schema concepts.
AT-1019 Jurisdiction mismatch returns NOT_APPLICABLE_JURISDICTION.
AT-1020 No active jurisdiction pack can be represented without silent U.S. fallback.
AT-1021 Source registry stores checked_at/current-status metadata.
AT-1022 Source registry can represent current schedule version different from current calendar year.
AT-1023 Age-eligible no-history synthetic interval rule returns DUE_NOW.
AT-1024 Recent completion synthetic interval rule returns UP_TO_DATE.
AT-1025 Completion approaching due date returns DUE_SOON.
AT-1026 Completion beyond interval returns OVERDUE.
AT-1027 Unknown history returns UNKNOWN_HISTORY rather than DUE_NOW.
AT-1028 Age outside rule returns NOT_ELIGIBLE.
AT-1029 Risk-required rule without risk returns NOT_ELIGIBLE.
AT-1030 Risk-required rule with matching risk returns ELIGIBLE/DUE_NOW.
AT-1031 Shared-decision rule returns SHARED_DECISION and no routine due state.
AT-1032 Evidence-insufficient rule returns EVIDENCE_INSUFFICIENT and no routine due state.
AT-1033 Against-routine rule remains distinct from contraindication.
AT-1034 Contraindication fixture returns BLOCKED_CONTRAINDICATION/REVIEW_REQUIRED.
AT-1035 Required-anatomy missing returns NOT_ELIGIBLE.
AT-1036 Required-anatomy present can enable eligibility.

## Vaccination series / guideline governance

AT-1037 Partial series before minimum interval returns TOO_EARLY.
AT-1038 Partial series after minimum interval returns DUE_NOW.
AT-1039 Completed synthetic series returns SERIES_COMPLETE.
AT-1040 Preventive fixture engine does not restart a completed series.
AT-1041 Preventive source registry distinguishes national and GLOBAL_REFERENCE sources.
AT-1042 Global WHO reference is not configured as national override.
AT-1043 Equal-precedence conflict fixture returns PACK_CONFLICT.
AT-1044 Stale pack fixture returns PACK_STALE.
AT-1045 Historical PreventiveAssessment schema stores pack/rule versions.
AT-1046 GuidelinePack schema stores jurisdiction, precedence, effective date and checksum.
AT-1047 PreventiveRule schema stores source_snapshot_id and recommendation mode.
AT-1048 PreventiveEvent schema requires actual completed_at timestamp.
AT-1049 Preventive fixture validator passes all synthetic cases.
AT-1050 Synthetic preventive pack is explicitly non-clinical/SYNTHETIC_ONLY.

## Source/governance semantics

AT-1051 Preventive source registry includes CDC immunization source.
AT-1052 Preventive source registry includes USPSTF recommendation/grade source.
AT-1053 Preventive source registry includes WHO immunization/screening reference sources.
AT-1054 Preventive source registry includes Türkiye Ministry of Health candidate source.
AT-1055 CDC source snapshot metadata can record 2025 schedule as current when checked in 2026.
AT-1056 USPSTF C/shared-decision and I/evidence-insufficient semantics are representable without inventing due dates.
AT-1057 No real national preventive rules are activated by the synthetic foundation handoff.

## API / UI / site

AT-1058 OpenAPI includes list/create preventive event operations.
AT-1059 OpenAPI includes preventive assessment history and run operations.
AT-1060 OpenAPI includes preventive due-item projection.
AT-1061 OpenAPI includes preventive service and guideline-pack catalog operations.
AT-1062 Every new private preventive profile operation has owner authorization matrix entry.
AT-1063 Site Build Prompt includes synthetic Preventive Care Lab and explains eligibility vs due state.

## Lab interpretation / reference / critical / method governance

AT-1064 Lab reference fixture classifies a synthetic value within interval as WITHIN_REFERENCE.
AT-1065 Lab reference fixture classifies a synthetic value below interval as BELOW_REFERENCE.
AT-1066 Lab reference fixture classifies a synthetic value above interval as ABOVE_REFERENCE.
AT-1067 Outside-reference state alone does not produce a critical-result state.
AT-1068 Synthetic critical-low rule matches independently of reference interval.
AT-1069 Synthetic critical-high rule matches independently of reference interval.
AT-1070 Absence of a critical rule produces NO_ACTIVE_RULE/NO_MATCH rather than an invented threshold.
AT-1071 Critical match does not set external provider notification receipt without evidence.
AT-1072 Missing source reference interval produces NO_REFERENCE.
AT-1073 Unit mismatch produces UNIT_NOT_COMPARABLE before numeric reference comparison.
AT-1074 Missing required reference partition context returns INSUFFICIENT_REFERENCE_CONTEXT.
AT-1075 Gender/profile label alone cannot satisfy a source-defined lab reference partition.
AT-1076 Method M1 vs M1 is directly comparable in the synthetic fixture.
AT-1077 Method M1 vs M2 is UNKNOWN_COMPARABILITY without a reviewed mapping.
AT-1078 Trend contract marks unknown method change rather than drawing an unqualified continuous trend.
AT-1079 Different specimen matrices are not directly comparable by default.
AT-1080 Method comparability record requires source/version metadata.
AT-1081 Personal observations alone cannot create production method-calibration coefficients.
AT-1082 RCV formula fixture reproduces the expected transparent synthetic percentage.
AT-1083 RCV fixture below threshold returns WITHIN_RCV.
AT-1084 RCV fixture above threshold returns EXCEEDS_RCV.
AT-1085 RCV engine refuses negative CV inputs.
AT-1086 RCV assessment does not run when method/specimen comparability is blocked by contract.
AT-1087 Personal-baseline channel remains separate from population reference status.
AT-1088 Historical range snapshot remains tied to the original LabResult after a later range change.
AT-1089 Clinical decision rule can be evaluated separately from reference status.
AT-1090 Reference interval is explicitly labeled non-equivalent to optimal target.
AT-1091 Source-reported laboratory flag remains preserved when app has no applicable interval.
AT-1092 Flag origin distinguishes SOURCE_REPORTED from APP_REFERENCE_COMPARISON and APP_RULE_MATCH.
AT-1093 Conflicting equally authoritative applicable interval sources can return conflict/review state.
AT-1094 Stale critical-rule pack cannot silently present a fresh current critical conclusion.
AT-1095 Lab source registry includes CLSI EP28/EP28IG, GP47, EP09, EP33 and IFCC C-RIDL roles.
AT-1096 Lab source registry bundles no real numerical clinical threshold table by default.
AT-1097 Lab interpretation synthetic fixture validator passes all cases.
AT-1098 LabReferenceIntervalSnapshot JSON Schema validates a minimal valid interval snapshot.
AT-1099 LabMethodContext JSON Schema validates a minimal method context.
AT-1100 LabCriticalRule JSON Schema validates source/version metadata.
AT-1101 LabInterpretationAssessment JSON Schema validates separate reference/critical/comparability channels.
AT-1102 Site Build Prompt includes synthetic reference/critical/method/delta lab demo requirement.
AT-1103 Acceptance test canonical identifiers contain no duplicates.
AT-1104 Architecture decision canonical identifiers contain no duplicates.
AT-1105 Failure-mode canonical identifiers contain no duplicates.
AT-1106 Implementation-phase canonical identifiers contain no duplicates.
AT-1107 Identifier migration map records every repaired historical collision.
AT-1108 Requirements traceability references only canonical acceptance IDs.


---

<!-- SOURCE: 160_DRUG_KNOWLEDGE_SOURCES_RXNORM_DAILYMED_OPENFDA.md -->

# DRUG KNOWLEDGE SOURCES: RXNORM, DAILYMED AND OPENFDA

Checked: 2026-10-06.

## RxNorm / RxNav

Role:
normalized medication identity.

Use for:
- normalized names
- RxCUI identity
- ingredient/product relationships
- prescribable content lookup.

Do not use RxNorm itself as a complete interaction knowledge base.

Current official RxNorm API exposes current RxNorm data and reports dataset/API version.
The full monthly release has UMLS licensing requirements, while current prescribable content is distributed separately under its published terms.

Implementation:
- pin dataset/API version,
- cache identifiers and normalized names,
- preserve original user/product wording,
- include NLM attribution/no-endorsement notice required by the service terms.

## DailyMed

Role:
versioned Structured Product Labeling (SPL) source.

Use for:
- active ingredient/strength/form
- contraindications
- warnings/precautions
- drug interactions
- dosage/administration
- label version history.

DailyMed v2 web services provide current SPL access and historical label versions.

Important:
A DailyMed label section is evidence.
A product rule still requires deterministic parsing/curation and versioned provenance.

## openFDA Drug Labeling

Role:
searchable public FDA labeling API and label-field discovery.

Useful fields include:
- active_ingredient
- contraindications
- drug_interactions
- dosage_and_administration
- warnings and other labeling sections.

openFDA itself warns that its data should not be relied on to make medical-care decisions.

Therefore:
- use as retrieval/indexing/support source,
- retain FDA/openFDA metadata,
- do not make it the sole unreviewed safety-rule generator.

## NDC

NDC can help identify marketed products but does not replace normalized ingredient identity.

NDC format/version rules can change over time.
Store source/version and reverify current FDA format requirements.

## Source refresh

Medication-source refresh pipeline:

`retrieve → verify source/version → stage → diff → review mappings/rules → fixture test → activate`

A source refresh does not silently rewrite historical InteractionAssessments.


---

<!-- SOURCE: 161_SUPPLEMENT_KNOWLEDGE_SOURCES_DSLD_ODS.md -->

# SUPPLEMENT KNOWLEDGE SOURCES: DSLD AND NIH ODS

Checked: 2026-10-06.

## Dietary Supplement Label Database (DSLD)

Role:
product label/composition source.

The NIH Office of Dietary Supplements DSLD catalogs information printed on dietary supplement labels, including:
- product label images
- ingredient names/forms
- ingredient amounts
- label statements.

Use for:
- supplement product identification
- ingredient composition
- serving definitions
- label/version provenance.

Do NOT treat DSLD as a complete interaction or efficacy database.

A label can describe what the product claims/contains; it is not automatically evidence that every claim is clinically established.

## ODS Dietary Supplement Fact Sheets

Role:
government evidence summaries for supplement ingredients.

Fact sheets can include:
- health effects
- safety
- recommended amounts/context
- interactions with medications.

Use for:
- evidence-linked safety/interaction knowledge items
- educational content
- rule curation references.

Do not automatically scrape prose into active rules without review.

## Ingredient normalization

Supplement ingredients can have:
- salts
- chelates
- extracts
- standardized constituents
- elemental amounts
- proprietary blends
- botanical species/parts.

The canonical model preserves these details when known.

## Product change

Supplement formulations can change while product branding remains similar.

Therefore:
- store label/version identity,
- snapshot composition into historical IntakeEvents,
- do not assume same brand name means same formula forever.

## Missing amount

If a proprietary blend does not disclose a component quantity:
preserve the ingredient presence and `amount=UNKNOWN`.

Do not invent a per-ingredient amount by dividing the blend total.


---

<!-- SOURCE: 162_MEDICATION_SAFETY_RULE_PACK_AND_FIXTURE_CONTRACT.md -->

# MEDICATION SAFETY RULE PACK AND FIXTURE CONTRACT

## Pack

`RP-MEDICATION-SAFETY-FOUNDATION-1`

Status:
`CANDIDATE`

The starter pack validates engine behavior with synthetic rules.
It does NOT ship an authoritative comprehensive clinical interaction database.

## Safe built-in deterministic rules

### RULE-MED-DUPLICATE-INGREDIENT
Detect reviewed same IngredientConcept across overlapping plans/intakes.

### RULE-MED-PLAN-NOT-TAKEN
MedicationPlan does not imply IntakeEvent.

### RULE-MED-UNKNOWN-COMPOSITION
Unknown product composition blocks ingredient-level interaction inference.

### RULE-MED-UNIT-BASIS-MISMATCH
Do not sum incompatible amount bases.

### RULE-MED-EVIDENCE-VERSION
Every active safety rule stores source/version.

### RULE-MED-AMBIGUOUS-MAPPING-BLOCK
AMBIGUOUS/UNMAPPED ingredient identity cannot trigger an exact hard interaction rule.

## Synthetic interaction fixtures

Synthetic concepts are used to verify:
- pair matching
- condition-dependent matching
- route dependence
- timing separation
- insufficient context
- rule versioning
- deprecation
- source provenance.

Synthetic rules are visibly `SYNTHETIC_TEST_ONLY`.

No synthetic pair should appear in production user-facing knowledge packs.


---

<!-- SOURCE: 163_MEDICATION_SUPPLEMENT_API_UI_AND_REVIEW_CONTRACT.md -->

# MEDICATION, SUPPLEMENT, SAFETY API AND UI CONTRACT

## API resources

v0.22 expands the OpenAPI starter with:

- medication products
- supplement products
- ingredient concepts
- medication/supplement plans
- intake events
- interaction assessments
- duplicate-ingredient assessments
- knowledge-source status.

Private user resources:
`AUTHENTICATED_OWNER`

Global knowledge catalogs:
can use authenticated/public cache policy depending deployment.

## UI sections

### Medications & Supplements

Tabs:
- Active plans
- Taken history
- Products
- Safety review
- Source details.

### Plan card

Show:
- product
- normalized ingredient(s)
- strength/serving
- route
- schedule
- source
- plan status.

Never show a green checkmark meaning "taken" merely because plan is active.

### Intake timeline

Actual IntakeEvents only.

### Safety review

Group findings:

1. duplicate ingredient
2. source-defined interaction
3. contraindication/precaution
4. timing separation
5. unresolved/insufficient context.

Each finding exposes:
- involved products/ingredients
- rule ID/version
- evidence source
- applicable context
- limitation
- recommended action category.

## Review states

- CLEAR_NO_MATCH_FOUND
- FINDINGS_PRESENT
- INSUFFICIENT_CONTEXT
- UNKNOWN_INGREDIENT
- KNOWLEDGE_PACK_OUTDATED
- SAFETY_ENGINE_BLOCKED.

`CLEAR_NO_MATCH_FOUND` does not mean "guaranteed safe".
It means the installed active knowledge set found no applicable rule.

## Update state

When safety knowledge pack is stale/expired:
display it.

Do not silently continue presenting old "no interaction" output as current.

## Site Lab

Public Site can demonstrate:
- synthetic medicine products
- duplicate ingredient
- synthetic interaction rule
- timing separation rule
- evidence provenance.

No real-person medication profile is required.


---

<!-- SOURCE: 164_MEDICATION_INTERACTION_GOVERNANCE_AND_CLAIM_BOUNDARIES.md -->

# MEDICATION INTERACTION GOVERNANCE AND CLAIM BOUNDARIES

## Default product boundary

Human Health OS may:
- track medication/supplement plans
- track actual intake
- normalize ingredient/product identity
- show source-backed safety knowledge
- flag duplicate ingredients
- surface interaction/contraindication/timing findings
- explain evidence/provenance.

It must not default to:
- prescribing
- starting/stopping medication
- changing dose
- replacing pharmacist/clinician review
- emergency triage
without a separately governed product scope.

## "No interaction found"

This is a dangerous phrase if interpreted absolutely.

Preferred wording:
`No applicable interaction rule was found in the active knowledge set.`

Also expose:
- knowledge pack version/date
- unresolved ingredients
- missing context.

## Source hierarchy

Regulatory/product label and authoritative government/guideline evidence may support stronger rule categories than mechanistic speculation.

However:
source type alone does not determine clinical magnitude.

## Rule review

Every production safety rule should have:
- author/reviewer process
- evidence source
- effective date
- version
- test fixture
- applicability logic
- UI wording
- retirement/deprecation path.

## Safety-pack freshness

Medication knowledge can change.

Pack metadata includes:
- source versions
- checked date
- refresh policy
- expiry/review date.

Expired safety packs can still preserve historical assessments,
but new "clear" assessments may be blocked or labeled stale according to policy.

## User corrections

If a product/ingredient mapping is corrected:
- preserve old mapping history,
- invalidate affected InteractionAssessments,
- recompute using new reviewed mapping,
- retain old assessment for audit/history.

## High-risk ambiguity

Unknown ingredient, unknown dose basis, ambiguous identity or missing critical patient context should bias toward:
`REVIEW_REQUIRED` / `INSUFFICIENT_CONTEXT`

not a confident safety conclusion.


---

<!-- SOURCE: 165_SITE_MEDICATION_AND_SUPPLEMENT_SAFETY_LAB.md -->

# SITE MEDICATION AND SUPPLEMENT SAFETY LAB

## Purpose

Add a synthetic-only interactive Safety Lab to the fourth build target.

## Demo flow

```text
Choose synthetic products
        ↓
Show ingredients
        ↓
Create plan / log intake
        ↓
Run safety engine
        ↓
Show:
  duplicate ingredient
  synthetic interaction
  timing rule
  insufficient context
        ↓
Open evidence/provenance
```

## Synthetic products

Use clearly fake names and ingredient IDs.

Do not use a real medicine pair to imply production clinical coverage unless an activated real evidence pack exists.

## Controls

- product selector
- dose/serving
- route
- timing
- plan vs taken toggle
- add second product
- add condition context
- clear/reset.

## Results

Always show:
- rule class
- action category
- source/evidence state
- knowledge-pack status
- limitations.

## Educational panels

Explain:
- brand vs active ingredient
- plan vs actual intake
- duplicate ingredient vs drug interaction
- interaction evidence vs diagnosis
- no rule found ≠ guaranteed safe.

## Offline

Synthetic Site lab is client-side deterministic and needs no secret API key.


---

<!-- SOURCE: 166_PREVENTIVE_CARE_CANONICAL_MODEL.md -->

# PREVENTIVE CARE CANONICAL MODEL

## Purpose

Represent vaccinations, screening, preventive counseling and periodic preventive services without turning a generic calendar into universal medical advice.

## Core objects

### PreventiveServiceDefinition
A stable definition of a preventive service.

Service types:
- VACCINATION
- SCREENING
- PREVENTIVE_COUNSELING
- PREVENTIVE_MEASUREMENT
- CHEMOPREVENTION_DISCUSSION
- DENTAL_PREVENTION
- VISION_HEARING_PREVENTION
- OTHER.

A service definition is not itself a recommendation.

### PreventiveRule
A jurisdiction/source-specific rule that determines:
- who is eligible,
- recommendation mode,
- timing/interval/series logic,
- contraindication/precaution gates,
- evidence/history requirements,
- effective date,
- source/version.

### PreventiveEvent
An actual completed preventive event.

Examples:
- vaccine dose administered,
- screening performed,
- preventive counseling completed.

`PreventiveEvent` means completion, not reminder delivery.

### PreventiveAssessment
A deterministic evaluation of a profile against one rule version.

Separate outputs:
- eligibility_state
- recommendation_mode
- due_state
- assessment_status
- reasons
- source/rule version
- missing context.

### GuidelinePack
A versioned set of rules scoped to a jurisdiction and source set.

## Eligibility states

- ELIGIBLE
- NOT_ELIGIBLE
- INSUFFICIENT_CONTEXT
- NOT_APPLICABLE_JURISDICTION
- BLOCKED_CONTRAINDICATION
- REVIEW_REQUIRED.

## Recommendation modes

- ROUTINE
- SHARED_DECISION
- AGAINST_ROUTINE
- EVIDENCE_INSUFFICIENT
- REFERENCE_ONLY.

## Due states

- DUE_NOW
- DUE_SOON
- UP_TO_DATE
- OVERDUE
- TOO_EARLY
- SERIES_COMPLETE
- UNKNOWN_HISTORY
- NOT_APPLICABLE
- REVIEW_REQUIRED.

## Assessment status

- SUCCESS
- PACK_STALE
- PACK_CONFLICT
- PACK_BLOCKED
- RULE_RETIRED
- INPUTS_MISSING.

These dimensions must not be collapsed into a single ambiguous `status`.

## Jurisdiction

Preventive recommendations depend on the selected guideline jurisdiction.

Store:
- jurisdiction code
- selection source
- effective date
- pack version.

Do not silently infer preventive-care jurisdiction from GPS, IP address or current travel location.

## Relevant anatomy and rule-specific variables

A screening rule may require:
- relevant organ/anatomy,
- prior organ-removing surgery,
- pregnancy status,
- sex-related evidence variable used by the source guideline,
- age,
- risk factor,
- family history,
- prior result,
- immunocompromising condition,
- smoking/exposure history.

Gender identity alone must not be used as a proxy for anatomy or a guideline-specific biological input.

## Screening vs diagnosis

A screening event is not a diagnosis.

An abnormal screen can create:
- follow-up recommendation,
- diagnostic work-up link,
- new episode of care,

but not an automatic confirmed condition.

## Historical reproducibility

Every assessment stores:
- rule ID/version
- pack ID/version
- source snapshot/version
- input record IDs
- evaluated date.

Updating the guideline pack does not rewrite the old assessment.


---

<!-- SOURCE: 167_JURISDICTION_GUIDELINE_SOURCE_PACK_ARCHITECTURE.md -->

# JURISDICTION AND GUIDELINE SOURCE PACK ARCHITECTURE

## Problem

Preventive care recommendations vary by:
- country/jurisdiction,
- source organization,
- age/risk context,
- effective date,
- health-system programme,
- current evidence.

Therefore Human Health OS must not ship one unqualified global "preventive schedule".

## Pack identity

A GuidelinePack includes:
- pack_id
- jurisdiction
- source organizations
- source snapshot IDs
- effective_from / effective_to
- checked_at
- pack_status
- precedence
- checksum
- rules.

## Jurisdiction precedence

Default:
1. user/provider-selected national or regional pack
2. explicitly selected specialty/health-system overlay
3. global reference pack for education/comparison only.

WHO reference material does not silently override a national schedule.

## Source status

A source snapshot stores:
- official URL
- title
- publication/update date
- checked_at
- current-status text
- source version
- hash/etag if available
- extraction/review receipt.

The calendar year is not assumed to equal the active schedule version.

## Conflict

If two active rules at the same precedence level conflict:
return:
`PACK_CONFLICT`

Do not:
- pick the newest date blindly,
- average recommendations,
- merge intervals,
- hide the conflict.

A curator/release update must resolve it.

## No jurisdiction pack

If the user's selected jurisdiction has no reviewed pack:
show:
`NO_ACTIVE_JURISDICTION_PACK`

The app can still track preventive events and show source-agnostic history.

It must not silently fall back to U.S. rules merely because those are available.

## Effective-date semantics

A new guideline update applies prospectively according to its effective date.

Historical assessments keep the old rule version.

## Local overlays

A health system or clinician may use an overlay pack.

Overlay must:
- identify the base pack,
- state which rule it supersedes,
- preserve provenance,
- never silently mutate base rules.


---

<!-- SOURCE: 168_PREVENTIVE_ELIGIBILITY_DUE_AND_OVERDUE_ENGINE.md -->

# PREVENTIVE ELIGIBILITY, DUE AND OVERDUE ENGINE

## Evaluation order

```text
1 jurisdiction
2 rule/pack status
3 applicability inputs
4 eligibility
5 contraindication/precaution
6 recommendation mode
7 history quality
8 series/interval timing
9 due state
10 explanation/provenance
```

## Why order matters

A person outside the rule's jurisdiction should not be marked "overdue".

A rule with insufficient evidence should not manufacture a due date.

A contraindication can block routine scheduling even if age criteria match.

## Interval rule

For a routine interval-based service:

`next_due_date = last_valid_completion + interval`

Then:

- before `next_due_date - due_soon_window` → UP_TO_DATE
- within due-soon window → DUE_SOON
- on due date → DUE_NOW
- after due date → OVERDUE.

This is only valid when the source rule actually defines an interval.

## Never-completed

If:
- eligible,
- recommendation mode ROUTINE,
- history is known and no valid completion exists,

the rule may return DUE_NOW if source logic supports initial screening/vaccination.

## Unknown history

Unknown is not "never done".

Return:
`UNKNOWN_HISTORY`

unless source explicitly says how unknown history should be handled.

## Shared decision

A source-defined shared-decision recommendation returns:
- recommendation_mode = SHARED_DECISION
- due_state = NOT_APPLICABLE or REVIEW_REQUIRED.

Do not color it as "overdue".

## Evidence insufficient

Returns:
- recommendation_mode = EVIDENCE_INSUFFICIENT
- due_state = NOT_APPLICABLE.

Do not invent a schedule from neighboring guidelines.

## Against routine

Returns:
- recommendation_mode = AGAINST_ROUTINE
- due_state = NOT_APPLICABLE.

This is not the same as contraindication.

## Due-soon window

The UI notification window is separate from the clinical interval.

Example:
a rule can be due in 365 days,
while UI can choose to surface "due soon" 30 days before.

The notification preference does not change the rule due date.

## Overdue tone

OVERDUE is a timing state, not blame.

Missed preventive items must not create punitive backlog stacking.

## Reassessment

Trigger reassessment when relevant:
- birthday/age boundary,
- new risk factor,
- pregnancy state change,
- organ/anatomy update,
- new preventive event,
- guideline pack update,
- corrected history,
- contraindication/precaution change.


---

<!-- SOURCE: 169_VACCINATION_SERIES_CATCHUP_VALIDITY_AND_IMMUNITY.md -->

# VACCINATION SERIES, CATCH-UP, VALIDITY AND IMMUNITY

## Vaccine service model

Vaccination rules may contain:
- dose count
- minimum intervals
- recommended intervals
- age windows
- risk indications
- booster logic
- seasonal logic
- shared decision logic
- catch-up logic
- contraindications/precautions
- evidence-of-immunity rules.

## Minimum vs recommended interval

These are different.

A dose can be:
- too early to count under the selected rule,
- valid but earlier/later than preferred,
- due now,
- overdue.

Do not substitute recommended interval for minimum-validity interval.

## Dose validity

DoseValidity:
- VALID
- INVALID_TOO_EARLY
- INVALID_WRONG_CONTEXT
- UNKNOWN_VALIDITY
- NOT_EVALUATED.

A dose validity decision stores rule/version.

## Series progress

Series state:
- NOT_STARTED
- IN_PROGRESS
- COMPLETE
- UNKNOWN_HISTORY
- REVIEW_REQUIRED.

Series completion is derived from valid dose history, not raw dose count alone.

## Catch-up

Catch-up is rule-pack-specific.

Do not restart a series merely because a long interval elapsed unless the source rule explicitly requires restart.

## Unknown history

Unknown history can require:
- vaccination,
- records search,
- serologic evidence,
- clinician review,

depending on source.

The engine stores the source-defined handling instead of assuming "zero doses".

## Evidence of immunity

Some rules can treat evidence of immunity as satisfying a preventive need.

Immunity evidence must store:
- evidence type
- source
- observed date
- rule applicability.

Do not generically apply immunity evidence across all vaccines.

## Self-report

Whether self-reported previous vaccination is acceptable is rule-specific.

Source/provenance quality remains visible.

## Contraindication vs precaution

A contraindication can block or require clinician review.

A precaution may produce:
`REVIEW_REQUIRED`

rather than automatic denial.

## Product/formulation

Vaccine formulation/product relationships can matter.

The rule pack, not free-text similarity, determines interchangeability and validity.


---

<!-- SOURCE: 16_FAILURE_MODES_AND_SAFETY.md -->

# FAILURE MODES AND SAFETY

## FM-01 False completion
Planned action becomes “done” because time passed.
Prevention: plan and event are distinct.

## FM-02 Unit collision
Values using incompatible units are compared directly.
Prevention: unit-aware series and explicit conversions.

## FM-03 Missing-as-zero
Unavailable nutrient is treated as zero.
Prevention: explicit missing state and coverage reporting.

## FM-04 Silent history rewrite
Edit destroys previous important health value.
Prevention: revision/correction provenance.

## FM-05 Duplicate sync
Retry creates duplicate health record.
Prevention: stable IDs/idempotency/deduplication.

## FM-06 Provider drift
External food data changes past meal totals.
Prevention: immutable logged snapshots.

## FM-07 Wrong food match
Search silently selects a similar but different food.
Prevention: explicit selection with brand/source/basis.

## FM-08 API secret leak
Provider/backend secret is shipped in client.
Prevention: secret management and server mediation.

## FM-09 Reference-range confusion
Lab interval is shown as universal target.
Prevention: label as lab-provided metadata.

## FM-10 Self-report becomes diagnosis
Mood or symptom is promoted to clinical diagnosis.
Prevention: explicit data types/status.

## FM-11 Correlation becomes causation
Two trends move together and AI asserts causal relationship.
Prevention: association language and evidence discipline.

## FM-12 AI overwrites record
Generated interpretation mutates canonical fact.
Prevention: derived layer is separate.

## FM-13 Migration data loss
Schema update deletes or corrupts user history.
Prevention: migrations, tests, backups, recovery.

## FM-14 Cross-user data exposure
Authorization bug exposes another user's data.
Prevention: server-side ownership checks + security tests.

## FM-15 Time-zone day shift
Daily event appears on wrong day.
Prevention: timezone-aware storage and grouping.

## FM-16 Fake validation
Source creation is reported as deployed/validated behavior.
Prevention: explicit evidence stages.

## FM-17 Shortevity becomes fake years-lost
Prevention: typed result classes; validated survival model required.

## FM-18 Net score hides simultaneous burden and protection
Prevention: always show component channels.

## FM-19 Rule update rewrites history
Prevention: effective-date/versioned policies.

## FM-20 Correction fails to propagate
Prevention: dependency graph + invalidation tests.

## FM-21 Donor identity/private state leakage
Prevention: Human OS transfer firewall.

## FM-22 Early warning becomes diagnosis
Prevention: pattern language + source rule metadata.

## FM-23 Missed mission punishment spiral
Prevention: no automatic backlog stacking; capacity/recovery replan.


## FM-24 Biological age becomes fake truth
Prevention: multiple model outputs, model/version/population labels, no default averaging.

## FM-25 Personal baseline confused with clinical reference
Prevention: separate labels/data types.

## FM-26 Scenario mutates real history
Prevention: immutable canonical data + explicit ScenarioPatch.

## FM-27 Interoperability normalization destroys source semantics
Prevention: preserve original labels/values/units and mapping provenance.

## FM-28 Multimorbidity reduced to disease count
Prevention: condition status/function/treatment burden and typed graph.

## FM-29 Forecast shown despite insufficient data
Prevention: minimum sample/quality rule and NOT_CALCULABLE.

## FM-30 Restore duplicates or loses correction history
Prevention: stable IDs, checksum validation, merge/dedup tests.


## FM-41 Encryption key shipped with app
Prevention: platform-native secure key storage + secret scan.

## FM-42 Reminder becomes false completion
Prevention: notification state separated from completion event.

## FM-43 Timezone travel shifts critical reminder unexpectedly
Prevention: explicit fixed-local vs fixed-instant semantics.

## FM-44 Accessibility blocks older/disabled user
Prevention: accessibility release gates + aging-friendly mode.

## FM-45 Locale changes numeric meaning
Prevention: locale-neutral canonical storage + explicit parsing.

## FM-46 Shared report overexposes data
Prevention: section/date scoping + user preview + revocation.

## FM-47 Crash logs leak health data
Prevention: telemetry minimization/redaction.

## FM-48 Staging config reaches production
Prevention: environment separation and release provenance.

## FM-49 Marketing exceeds evidence/product boundary
Prevention: Claim Registry + launch review.


## FM-50 UI hides stale/offline/conflict state
Prevention: explicit screen-state machine.

## FM-51 Migration passes syntax but corrupts semantics
Prevention: invariant fixtures.

## FM-52 Retry duplicates event
Prevention: idempotency identity + retry tests.

## FM-53 Pagination reorders/skips same-timestamp events
Prevention: stable ordering + tie-break IDs.

## FM-54 Synthetic fixture leaks real-user data
Prevention: dedicated generator namespace/privacy test.

## FM-55 Performance problem discovered only after release
Prevention: explicit scale fixtures and budgets.

## FM-56 Flaky test is repeatedly rerun until green
Prevention: flaky-test governance; quarantined test cannot satisfy release gate.

## FM-57 Stubbed integration is called complete
Prevention: No Mock Completion acceptance gate.


## FM-106 UI component mutates canonical data directly
Prevention: component/application/repository boundary contracts.

## FM-107 Two modules become competing authorities
Prevention: singular canonical entity ownership map.

## FM-108 Generated OpenAPI drifts from implementation
Prevention: reproducible generation + release diff.

## FM-109 Backup exists but cannot restore relationships
Prevention: disaster-recovery drills verifying IDs/corrections/tombstones/model versions.

## FM-110 Sync happy-path hides retry corruption
Prevention: deterministic chaos suite.

## FM-111 Error message hides save state
Prevention: error catalog requires data_saved_state and recovery actions.

## FM-112 Feature sprawl before product spine works
Prevention: bootstrap exit gate.


## FM-60 Domain API shadow ownership
Prevention: ownership/CRUD matrix + integration guard.

## FM-61 Responsive redesign changes result semantics
Prevention: shared typed-result/state contracts across breakpoints.

## FM-62 Delete means different things in different modules
Prevention: retention/deletion matrix with explicit operation type.

## FM-63 Stale device resurrects deleted health record
Prevention: tombstones + revision/sync tests.

## FM-64 Duplicate domain event doubles projection/mission/result invalidation
Prevention: idempotent event consumers.

## FM-65 Permission denial produces fabricated health data/success
Prevention: capability degradation matrix.

## FM-66 Release prose says production-ready while platform/gate is NOT_RUN
Prevention: machine-readable acceptance dossier/signoff policy.


## FM-113 Site becomes static marketing page
Prevention: functional-interaction acceptance tests and completion rule.

## FM-114 Demo asks for unnecessary real health data
Prevention: synthetic-first default and no-account core demo.

## FM-115 Site contradicts product math semantics
Prevention: Master Handoff invariants + semantic-parity tests.

## FM-116 Scenario editor mutates source body
Prevention: explicit scenario clone isolation test.

## FM-117 Published URL is claimed without deployment evidence
Prevention: delivery contract requires actual publishing/deploy evidence or explicit blocker.


## FM-118 Licensed clinical model bundled without clearance
Prevention: license gate + BLOCKED_LICENSE status.

## FM-119 Demo fakes unavailable clinical risk
Prevention: external-model unavailable card; no fabricated percent.

## FM-120 External data attribution disappears from UI
Prevention: attribution registry + acceptance test.

## FM-121 Schema generator turns missing into zero/default
Prevention: explicit nullable/missing-state schemas and fixtures.

## FM-122 Site exposes provider API secret
Prevention: synthetic/client-side default; provider secrets server-side only.


## FM-123 Formula implementation drifts from specification
Prevention: executable golden vectors + reference runner.

## FM-124 SQLite declares FK but runtime disables enforcement
Prevention: PRAGMA foreign_keys=ON acceptance gate.

## FM-125 Demo seed becomes user's fake medical history
Prevention: fixed synthetic marker + no health seed for real profile.

## FM-58 Help text collapses clinical risk and app score
Prevention: results-literacy onboarding acceptance.

## FM-59 Attribution footer drifts from active pack state
Prevention: machine attribution manifest + generator.

## FM-126 Canonical write commits but UI shows old result as current
Prevention: explicit stale/invalidation state and recovery.


## FM-127 Migration history edited in place
Prevention: append-only released migration rule.

## FM-128 API trusts client-supplied user/profile ownership
Prevention: authenticated server identity + authorization vectors.

## FM-129 Connection pool leaks previous request's RLS user context
Prevention: transaction/request-scoped set_config and pool reset tests.

## FM-130 API runs as PostgreSQL owner and bypasses RLS
Prevention: separate runtime/migration roles.

## FM-131 FHIR demo JSON mistaken for validated interoperability
Prevention: explicit NOT_PRODUCTION_VALIDATED evidence label.

## FM-132 Repository scaffold mistaken for completed application
Prevention: placeholder boundary + implementation release gates.


## FM-67 API docs and server authorization diverge
Prevention: endpoint authorization matrix + OpenAPI validator.

## FM-68 Retry duplicates a health mutation
Prevention: endpoint idempotency declaration + stable mutation identity.

## FM-69 Stale writer silently overwrites newer canonical state
Prevention: revision/If-Match conflict semantics.

## FM-70 Failed migration leaves schema half-upgraded
Prevention: transactional rollback drill + schema-version verification.

## FM-71 Missing UI state displayed as zero
Prevention: MetricCard missing_not_zero component guard.

## FM-72 App score visually impersonates clinical risk
Prevention: ResultCard visible result-class contract + hierarchy rules.

## FM-73 Build agent claims production-ready with NOT_RUN platform
Prevention: machine delivery checklist truth table.


## FM-74 Health platform becomes hidden canonical database
Prevention: explicit adapter boundary and canonical import records.

## FM-75 Empty HealthKit query misread as “permission granted/no data”
Prevention: privacy-safe unknown/limited state.

## FM-76 Watch+phone step counts blindly summed
Prevention: provider overlap/dedup policy.

## FM-77 Re-import of app-written provider record creates echo duplicate
Prevention: own-source identity/metadata.

## FM-78 Recipe missing nutrient becomes zero
Prevention: missingness propagation fixture.

## FM-79 mL converted to g without density
Prevention: DENSITY_REQUIRED calculation error.

## FM-80 Recipe edit rewrites historical meal
Prevention: immutable FoodSnapshot/recipe version linkage.


## FM-81 Parser output becomes diagnosis/lab fact automatically
Prevention: staged candidates + review receipt gate.

## FM-82 Malicious/malformed file reaches parser directly
Prevention: type validation, quarantine and security state.

## FM-83 Public attachment URL leaks health document
Prevention: private storage + authorization + short-lived scoped links.

## FM-84 EXIF location leaks through shared health photo
Prevention: derivative/share metadata stripping by default.

## FM-85 Duplicate lab report creates duplicate lab history
Prevention: per-user checksum duplicate warning + commit review.

## FM-86 Attachment deletion silently erases reviewed health history
Prevention: separate destructive operations and provenance tombstones.

## FM-87 Missing lab unit guessed by parser
Prevention: missing-unit remains missing; unit engine explicit mapping only.


## FM-88 Brand name treated as stable active ingredient
Prevention: ProductConcept → IngredientConcept normalization layer.

## FM-89 Prescription/plan treated as actual ingestion
Prevention: Plan != IntakeEvent invariant.

## FM-90 Proprietary blend amount divided among ingredients
Prevention: unknown amount remains UNKNOWN.

## FM-91 Compound mass summed with elemental amount
Prevention: amount-basis compatibility gate.

## FM-92 Raw label NLP becomes authoritative interaction rule
Prevention: evidence → curated/reviewed rule lifecycle.

## FM-93 “No interaction found” interpreted as guaranteed safe
Prevention: active-knowledge-set wording + pack version + unresolved context.

## FM-94 Stale interaction pack silently used as current
Prevention: pack freshness state and stale/block behavior.

## FM-95 Ambiguous supplement ingredient triggers hard interaction
Prevention: exact/reviewed normalization required.


## FM-96 U.S. guideline silently applied to non-U.S. user
Prevention: explicit jurisdiction pack and no silent fallback.

## FM-97 Current year assumed to equal active guideline year
Prevention: SourceSnapshot current-status/version metadata.

## FM-98 Unknown vaccine history treated as zero doses
Prevention: UNKNOWN_HISTORY state and source-specific handling.

## FM-99 Shared-decision service shown as red overdue task
Prevention: separate recommendation_mode and due_state.

## FM-100 Evidence-insufficient service receives invented interval
Prevention: no routine due state for EVIDENCE_INSUFFICIENT.

## FM-101 Abnormal screening automatically becomes diagnosis
Prevention: screening/follow-up/diagnosis entity separation.

## FM-102 Gender identity used as anatomy proxy
Prevention: explicit relevant-anatomy/rule-input contract.

## FM-103 WHO reference silently overrides national schedule
Prevention: jurisdiction precedence and REFERENCE_ONLY source role.

## FM-104 Conflicting guideline packs silently merged
Prevention: PACK_CONFLICT state and curator resolution.

## FM-105 Stale preventive pack continues declaring up-to-date
Prevention: PACK_STALE state and configurable block/stale policy.


## FM-133 — Universal normal range silently applied to incompatible laboratory method
Prevention: source/method/context-specific ReferenceIntervalSnapshot.

## FM-134 — Out-of-range result escalated to critical without source rule
Prevention: separate reference and critical channels.

## FM-135 — Critical match falsely shown as clinician notified
Prevention: external receipt requirement.

## FM-136 — Trend bridges incompatible assay methods
Prevention: method-comparability gate and discontinuity marker.

## FM-137 — Delta alert treated as diagnosis
Prevention: delta/RCV semantic boundary.

## FM-138 — CVi/CVa values invented for RCV
Prevention: versioned biological/analytical variation source requirement.

## FM-139 — Later lab reference range rewrites old result
Prevention: historical interval snapshot immutability.

## FM-140 — Duplicate identifiers make release evidence ambiguous
Prevention: identifier uniqueness release gate.


---

<!-- SOURCE: 170_SCREENING_COUNSELING_AND_PREVENTIVE_SERVICE_MODEL.md -->

# SCREENING, COUNSELING AND PREVENTIVE SERVICE MODEL

## Screening is a programme/service, not a generic test menu

A screening rule must identify:
- target population
- asymptomatic/symptomatic scope
- age/risk criteria
- method/variant
- interval or one-time logic
- prior-result dependencies
- stopping conditions
- follow-up boundary
- evidence/recommendation class.

## Symptomatic person

If a rule is explicitly for asymptomatic screening and the person has relevant symptoms:
the screening rule can return:
`NOT_APPLICABLE_SCREENING_CONTEXT`

This does not mean "do nothing".
It means diagnostic evaluation belongs to another care pathway.

## Method-specific intervals

Different screening methods can have different intervals.

Store:
- service_variant
- method
- completion qualifier
- result category only when needed by the rule.

Do not treat all tests for one organ as interchangeable.

## Organ/anatomy inventory

Rules can require explicit relevant anatomy.

Examples of data inputs:
- organ present
- organ surgically removed
- unknown.

Do not infer anatomy solely from gender identity.

## Prior abnormal result

A prior abnormal screening result may move the user out of routine screening into surveillance/follow-up.

Rule can return:
`FOLLOW_UP_PATHWAY_REQUIRED`

instead of applying a generic routine interval.

## Counseling/intervention services

Preventive counseling can have:
- eligibility
- recommendation mode
- completion event
- recurrence only if source defines it.

Attendance/completion is not equivalent to behavior change or clinical benefit.

## Evidence grades

If a source uses native grades/classes, preserve them.

Example:
USPSTF A/B/C/D/I semantics should remain native source metadata.

Do not convert every source into one universal 1–5 score.

## Potential harms

Preventive UI should not imply "more screening is always better".

Source content can include:
- false positives
- overdiagnosis
- procedure harms
- anxiety/burden
- opportunity cost.

The app explains source-supported benefit/harm context rather than gamifying maximum screening volume.


---

<!-- SOURCE: 171_PREVENTIVE_SOURCE_REGISTRY_CDC_USPSTF_WHO_TURKIYE.md -->

# PREVENTIVE SOURCE REGISTRY: CDC, USPSTF, WHO AND TÜRKİYE

Checked: 2026-10-06.

Machine source:
`PREVENTIVE_CARE_SOURCE_REGISTRY.json`

## U.S. CDC immunization schedules

Official:
- https://www.cdc.gov/vaccines/hcp/imz-schedules/
- https://www.cdc.gov/vaccines/hcp/imz-schedules/adult-age-compliant.html
- https://www.cdc.gov/vaccines/hcp/imz-schedules/adult-medical-condition-compliant.html

Role:
U.S. immunization-rule source.

Important current-version lesson:
the official CDC pages checked on 2026-10-06 identify the July 2, 2025 schedule as the current compliant adult schedule and describe a 2026 court order affecting later votes/changes.

Architecture consequence:
never infer guideline version from current calendar year.
Store explicit source status/version/effective date.

## USPSTF

Official:
- https://www.uspreventiveservicestaskforce.org/uspstf/recommendation-topics
- https://www.uspreventiveservicestaskforce.org/uspstf/about-uspstf/methods-and-processes/grade-definitions

Role:
U.S. primary-care preventive service recommendations.

Preserve native grades:
A, B, C, D, I statement.

The Task Force scope applies to specific populations/primary-care preventive services; eligibility and clinical considerations remain part of each rule.

## WHO routine immunization

Official:
https://www.who.int/teams/immunization-vaccines-and-biologicals/policies/who-recommendations-for-routine-immunization---summary-tables

Role:
global reference for programme managers and country schedule design.

It is not an automatic replacement for the selected national schedule.

## WHO screening guidance

Official:
https://www.who.int/publications/i/item/9789289054782

Role:
screening-programme evidence/governance principles.

The source emphasizes balancing benefit and harm and the need for quality assurance.

## Türkiye Ministry of Health

Official adult vaccination portal:
https://asi.saglik.gov.tr/kimlere-asi-yapilir/eriskin-asilama.html

Role:
candidate Türkiye-specific vaccination source.

Recent 2026 Ministry-affiliated pages also show active updates to the childhood immunization schedule.

Implementation rule:
activate a Türkiye pack only after the exact current central schedule/source versions are retrieved, reconciled and reviewed.

Do not silently use U.S. rules for a Türkiye-selected profile.

## Licensing / redistribution

This handoff stores source metadata and links.

Before bundling/caching source text or tables:
verify current copyright, attribution, API and redistribution terms for each source.


---

<!-- SOURCE: 172_PREVENTIVE_RULE_PACK_AND_SYNTHETIC_FIXTURES.md -->

# PREVENTIVE RULE PACK AND SYNTHETIC FIXTURES

## Foundation pack

`RP-PREVENTIVE-FOUNDATION-1`

Status:
`CANDIDATE_ENGINE_FOUNDATION`

Purpose:
engine semantics only.

It contains no real clinical schedule.

## Synthetic demo pack

`RP-PREVENTIVE-SYNTHETIC-1`

Status:
`SYNTHETIC_ONLY`

Rules test:
- age eligibility
- risk eligibility
- interval due logic
- unknown history
- shared decision
- evidence insufficient
- against routine
- contraindication block
- vaccine series minimum interval
- series completion
- anatomy requirement
- jurisdiction mismatch
- stale pack
- pack conflict.

## Production rule requirements

Every real rule must include:
- rule_id
- service_id
- jurisdiction
- source_snapshot_id
- source recommendation/grade
- effective date
- eligibility expression
- recommendation mode
- schedule logic
- contraindication/precaution logic
- history/evidence requirements
- user-facing explanation
- test fixtures.

## Activation

Real rule activation requires:
`source snapshot → curator mapping → review → fixture tests → pack checksum → activation`

A web scrape alone is never ACTIVE clinical logic.


---

<!-- SOURCE: 173_PREVENTIVE_API_UI_MISSIONS_AND_NOTIFICATIONS.md -->

# PREVENTIVE API, UI, MISSIONS AND NOTIFICATIONS

## API

v0.23 adds:
- preventive events
- preventive assessments
- due-item projection
- preventive service catalog
- guideline pack catalog.

Private profile resources:
`AUTHENTICATED_OWNER`

Knowledge pack metadata:
authenticated/global policy by deployment.

## Preventive dashboard

Sections:
- Due now
- Due soon
- Up to date
- Shared decision / review
- Unknown history
- Not eligible / not applicable
- History
- Sources.

Do not hide unknown history inside "up to date".

## Service card

Show:
- service name
- service type
- eligibility
- recommendation mode
- due state
- next due date when valid
- reason
- source organization
- source/pack version
- missing context.

## Shared decision

Use neutral presentation.

Do not display shared-decision recommendations as red overdue tasks.

## Evidence insufficient

Display uncertainty and source-native grade/class.

Do not create pressure/gamification for an evidence-insufficient service.

## Missions

Preventive due items can produce a mission such as:
- review vaccination record,
- schedule screening,
- discuss shared-decision service,
- upload missing history.

Mission is still a plan.

Completion of the mission does not mark the medical preventive service completed unless a valid PreventiveEvent exists.

## Notifications

A due-state notification:
- is informational/reminder state,
- never proves completion,
- follows quiet hours and preferences,
- does not repeatedly punish an overdue user.

## History import

Provider/document-imported vaccination or screening records can create candidate PreventiveEvents after normal import/review provenance rules.

## Timeline

Actual PreventiveEvent appears on timeline.

Due projection is derived state and should not masquerade as a historical event.


---

<!-- SOURCE: 174_PREVENTIVE_CARE_CLAIM_BOUNDARIES_SHARED_DECISION_AND_HARMS.md -->

# PREVENTIVE CARE CLAIM BOUNDARIES, SHARED DECISION AND HARMS

## Default product scope

Human Health OS may:
- track preventive history,
- evaluate versioned guideline rules,
- show eligibility and timing,
- show source-native recommendation classes,
- remind users of due items,
- explain benefit/harm context.

It does not default to:
- diagnosing disease,
- replacing clinician judgment,
- choosing a screening test when source requires individualized selection,
- administering vaccines,
- declaring a person permanently "cleared".

## Shared decision

A shared-decision source recommendation requires:
- user values/preferences,
- context,
- clinician discussion where appropriate.

The app can facilitate the discussion.

It should not algorithmically convert shared decision into mandatory care.

## Evidence insufficient

`EVIDENCE_INSUFFICIENT` means the source does not establish a clear benefit-harm recommendation for the defined population.

It does not mean:
- the service is useless,
- the service is safe,
- the service is harmful.

## Against routine

`AGAINST_ROUTINE` is a source recommendation class.

It is not a contraindication for every individual circumstance.

## Screening harms

The UI should acknowledge source-supported potential harms such as:
- false positives
- false negatives
- overdiagnosis
- unnecessary procedures
- anxiety/burden.

## Age boundary

Crossing an age boundary can change rule applicability.

The app recomputes prospectively and preserves old assessment history.

## Risk-factor changes

A new risk factor can change eligibility without rewriting old data.

## Source disagreement

When applicable trusted sources disagree:
show source-specific results or `PACK_CONFLICT`.

Do not hide disagreement behind a synthetic universal "consensus score".


---

<!-- SOURCE: 175_SITE_PREVENTIVE_CARE_LAB.md -->

# SITE PREVENTIVE CARE LAB

## Purpose

Add a synthetic preventive-care laboratory to the fourth build target.

## Demo controls

- synthetic jurisdiction
- age
- risk factor toggle
- relevant anatomy toggle
- vaccination/screening history state
- last completion date
- dose-series history
- contraindication toggle
- guideline pack version.

## Demo services

Use fake service names:
- Synthetic Vaccine Alpha
- Synthetic Screening Beta
- Synthetic Counseling Gamma.

No real clinical schedule is required for default demo.

## Demonstrations

1. no history → DUE_NOW
2. recent completion → UP_TO_DATE
3. approaching interval → DUE_SOON
4. missed interval → OVERDUE
5. unknown history → UNKNOWN_HISTORY
6. shared decision → no red overdue treatment
7. evidence insufficient
8. against routine
9. contraindication review
10. series too early / due / complete
11. jurisdiction mismatch
12. pack conflict.

## Explain panel

Teach:
- eligibility vs due state
- guideline jurisdiction
- source version
- screening vs diagnosis
- shared decision
- why "more screening" is not automatically better.

## Offline

Synthetic engine runs locally and deterministically with no provider API key.


---

<!-- SOURCE: 176_GUIDELINE_REFRESH_DIFF_CONFLICT_AND_RETIREMENT.md -->

# GUIDELINE REFRESH, DIFF, CONFLICT AND RETIREMENT

## Refresh pipeline

```text
retrieve official source
→ verify identity/version/current status
→ create immutable SourceSnapshot
→ diff against previous snapshot
→ classify changes
→ map affected rules
→ curator review
→ fixtures/regression
→ stage pack
→ activate
→ retain old pack
```

## Diff classes

- TEXT_ONLY
- ELIGIBILITY_CHANGED
- AGE_RANGE_CHANGED
- INTERVAL_CHANGED
- DOSE_SERIES_CHANGED
- CONTRAINDICATION_CHANGED
- RECOMMENDATION_CLASS_CHANGED
- SOURCE_STATUS_CHANGED
- WITHDRAWN
- UNKNOWN_REVIEW_REQUIRED.

## Current-status change

A source can change which older schedule is legally/officially current.

Therefore:
source snapshot stores both:
- document publication/update date
- current-status/effective interpretation.

## Pack retirement

A retired pack remains available for:
- historical assessment reconstruction,
- audit/export.

It is not used for new assessments.

## Stale pack

If refresh deadline passes:
- existing history remains visible,
- new "up to date" assertions may be labeled stale or blocked according to risk policy.

## Conflict

Conflict types:
- same jurisdiction, same precedence, different rule
- national pack vs health-system overlay
- source correction after release
- duplicated imported pack IDs with different hashes.

Resolution is explicit and auditable.

## Emergency source update

Urgent source change can activate a replacement pack through an accelerated review path.

It still requires:
- source identity
- rule diff
- minimum fixtures
- checksum
- activation receipt.

"Emergency" does not permit silent live editing of rule bytes.


---

<!-- SOURCE: 177_LAB_REFERENCE_INTERVAL_AND_DECISION_LIMIT_GOVERNANCE.md -->

# LAB REFERENCE INTERVAL AND DECISION-LIMIT GOVERNANCE

## Purpose

Prevent the app from treating every laboratory number as if one universal "normal range" existed.

## Three different concepts

### Reference interval
A statistical interval associated with a defined reference population and measurement procedure.

It is not automatically:
- an optimal range,
- a treatment target,
- a diagnostic cut-off,
- a critical-risk threshold.

### Clinical decision limit
A threshold used for a specific clinical decision, diagnostic pathway, risk classification or treatment context.

A clinical decision limit can differ from a laboratory reference limit.

### Critical / significant-risk limit
A source-defined result threshold or rule that requires urgent review/communication in a clinical laboratory workflow.

A reference-range flag must never silently become a critical alert.

## LabReferenceIntervalSnapshot

Every interval attached to a LabResult should preserve:
- analyte/measurand identity,
- lower/upper/text limits,
- unit,
- source laboratory/provider,
- specimen/matrix,
- method/analyzer/reagent when known,
- population/context qualifiers,
- age/sex/hormonal/pregnancy/fasting/time qualifiers when explicitly supplied,
- source/version/date,
- whether it came directly from the report or an external verified dataset.

Historical results keep their original interval snapshot even if a later laboratory changes ranges.

## Source priority

Preferred interpretation source order:
1. interval/decision information supplied with the exact result and method,
2. verified local laboratory interval for the same method/context,
3. manufacturer/laboratory-transferred interval verified for use,
4. curated external reference source with clear applicability,
5. no interval.

Do not invent a range merely to color a result.

## Reference context

The app never infers a laboratory reference partition from gender identity, profile name or appearance.

Use only explicit variables actually required by the source, for example:
- age,
- sex variable defined by the source,
- pregnancy state,
- hormonal state,
- specimen type,
- fasting state,
- collection time,
- method.

If a required partition variable is missing:
`INSUFFICIENT_REFERENCE_CONTEXT`.

## Flags

Possible reference comparison states:
- BELOW_REFERENCE
- WITHIN_REFERENCE
- ABOVE_REFERENCE
- NO_REFERENCE
- INSUFFICIENT_REFERENCE_CONTEXT
- UNIT_NOT_COMPARABLE
- METHOD_NOT_COMPARABLE.

These states describe comparison mechanics, not diagnosis.


---

<!-- SOURCE: 178_CRITICAL_SIGNIFICANT_RISK_RESULT_AND_ALERT_BOUNDARY.md -->

# CRITICAL / SIGNIFICANT-RISK RESULT AND ALERT BOUNDARY

## Goal

Represent source-defined urgent laboratory findings without pretending that the consumer app is a hospital critical-result notification system.

## CriticalRule

A critical/significant-risk rule stores:
- analyte,
- specimen/matrix,
- low/high or categorical criterion,
- unit,
- population/applicability,
- source organization/laboratory,
- source/version/effective date,
- action class,
- expiration/review state.

No universal critical-value table is hard-coded by default.

## Separation

`outside reference interval` does not imply `critical`.

`critical source rule matched` does not imply `clinician successfully notified`.

The app can truthfully say:
- `SOURCE_DEFINED_CRITICAL_RESULT_MATCHED`
- `URGENT_REVIEW_RECOMMENDED_BY_SOURCE_RULE`

It cannot say:
- "your clinician was notified"
unless a real delivery/receipt integration proves it.

## Source-defined communication

Clinical laboratories define local policies and processes for urgent result communication.
Human Health OS stores the source rule and result state but does not replace the originating laboratory's notification obligations.

## Safety behavior

If an active critical rule is absent, incompatible or stale:
- do not synthesize a threshold,
- do not downgrade an externally flagged critical result,
- preserve the laboratory-provided critical flag/text as provenance.

## Alert acknowledgement

User app acknowledgement is not clinical resolution.

States may include:
- SHOWN
- OPENED
- ACKNOWLEDGED_BY_USER
- EXTERNAL_PROVIDER_RECEIPT_CONFIRMED

Only the last requires an actual external integration receipt.


---

<!-- SOURCE: 179_LAB_METHOD_SPECIMEN_AND_LONGITUDINAL_COMPARABILITY.md -->

# LAB METHOD, SPECIMEN AND LONGITUDINAL COMPARABILITY

## Problem

Two results with the same display name and unit are not automatically methodologically comparable.

## LabMethodContext

Preserve when available:
- analyte/measurand code,
- specimen/matrix,
- laboratory,
- analyzer/platform,
- measurement principle/method,
- reagent/assay version,
- calibration/traceability metadata,
- unit,
- collection context.

## Comparability states

- DIRECTLY_COMPARABLE
- CONVERTIBLE_AND_COMPARABLE
- COMPARABLE_WITH_METHOD_CHANGE_MARKER
- NOT_COMPARABLE
- UNKNOWN_COMPARABILITY.

## Trend behavior

When method comparability is unknown:
- raw points remain visible,
- the chart marks a method/lab discontinuity,
- a single smooth biological trend must not be implied.

A method change can be clinically irrelevant for one analyte and important for another. Therefore the app does not globally decide comparability from identical units alone.

## Measurement-procedure comparison

A verified method-equivalence/bias record can support cross-method interpretation.

Such a record should identify:
- procedures compared,
- study/source,
- concentration range,
- estimated bias/difference,
- uncertainty,
- date/version.

No ad-hoc regression from a user's few personal points is allowed to "calibrate" one laboratory to another as a production clinical conversion.

## Specimen

Serum, plasma, whole blood, urine and other matrices are separate contexts unless an explicit mapping says otherwise.


---

<!-- SOURCE: 17_DESIGN_SYSTEM.md -->

# DESIGN SYSTEM

This is a functional design direction, not a final brand identity.

## Tone

- calm
- modern
- scientific without looking clinical or frightening
- friendly without childish gamification
- clear hierarchy
- low cognitive load

## Layout

Mobile:
- cards/sections,
- quick-entry actions,
- large touch targets,
- bottom navigation or similarly reachable structure.

Web:
- responsive grid,
- sidebar/rail,
- larger analytic surfaces,
- comparison tables and charts.

## Typography

Prioritize legibility and accessibility.
Do not encode health meaning by color alone.

## Color

Final palette can be selected during implementation.
Support light and dark mode if practical.

## Components

Reusable:
- metric card,
- timeline card,
- 1–10 rating control,
- food result card,
- nutrient matrix table,
- lab result row,
- chart container,
- source/provenance badge,
- missing-data indicator,
- status badge,
- correction-history view.

## Health status presentation

Avoid alarmist styling.
Flags from a lab should be displayed as source metadata, not as an automatic diagnosis.

## Missing data

Use clear labels such as:
- Not available
- Not measured
- Unknown
instead of showing `0`.


---

<!-- SOURCE: 180_DELTA_CHECK_REFERENCE_CHANGE_VALUE_AND_PERSONAL_BASELINE.md -->

# DELTA CHECK, REFERENCE CHANGE VALUE AND PERSONAL BASELINE

## Three related but distinct concepts

### Delta check
A rule comparing a current result with a prior result for the same person to detect a potentially important change or possible sample/process issue.

### Reference change value (RCV)
A statistical threshold based on analytical and within-person biological variation when the method/data assumptions are appropriate.

### Personal baseline
The person's observed historical distribution/trajectory.

None replaces the laboratory's population reference interval.

## Symmetric RCV starter formula

For a source-approved context using coefficient-of-variation inputs:

`RCV% = Z × sqrt(2) × sqrt(CVa² + CVi²)`

where:
- `CVa` = analytical variation percentage,
- `CVi` = within-person biological variation percentage,
- `Z` = source-selected probability factor.

The formula is transparent, but the CV inputs and applicability are evidence/version dependent.

Do not invent CVi/CVa values.

## Delta rule

A delta alert stores:
- current result,
- prior result,
- elapsed time,
- method/specimen compatibility,
- delta method,
- threshold source/version,
- outcome.

A delta alert is not automatically a diagnosis or deterioration.
Possible explanations include biological change, sampling/preanalytical problems, method changes or misidentification.

## Personal baseline

Personal-baseline deviation can coexist with population reference status.

Example states can include:
- within population interval but unusual for this person,
- outside population interval but stable personal baseline,
- both changed.

The UI must show these as separate channels rather than overwrite one with the other.


---

<!-- SOURCE: 181_LAB_INTERPRETATION_ASSESSMENT_ENGINE.md -->

# LAB INTERPRETATION ASSESSMENT ENGINE

## Output object

`LabInterpretationAssessment` contains:
- lab_result_id,
- reference comparison state,
- decision-limit findings,
- critical-rule findings,
- method-comparability state,
- delta/RCV finding when eligible,
- personal-baseline finding when available,
- source IDs/versions,
- limitations,
- evaluated_at.

## Evaluation order

1. validate analyte/value/unit/specimen,
2. preserve source reference metadata,
3. choose an applicable reference snapshot,
4. compare only after safe unit compatibility,
5. evaluate clinical decision rules separately,
6. evaluate critical/significant-risk rules separately,
7. assess longitudinal method comparability,
8. run eligible delta/RCV rules,
9. optionally compare personal baseline,
10. present separate labeled channels.

## Example display

```text
Current result: 12.0 synthetic units
Lab reference: Above reference
Clinical decision rule: No active rule
Critical rule: No active rule
Compared with prior result: Method changed, trend caution
Personal baseline: Insufficient history
```

No single red/green label collapses these channels.

## Interpretation states

Assessment can return:
- SUCCESS
- INSUFFICIENT_CONTEXT
- NO_APPLICABLE_REFERENCE
- UNIT_BLOCKED
- METHOD_BLOCKED
- RULE_PACK_STALE
- CONFLICTING_REFERENCE_SOURCES.

## Source flags

A report's original high/low/critical flag is retained even when the app cannot independently reproduce it.

The app labels whether a displayed flag is:
- SOURCE_REPORTED
- APP_REFERENCE_COMPARISON
- APP_RULE_MATCH.


---

<!-- SOURCE: 182_LAB_REFERENCE_CRITICAL_AND_METHOD_SOURCE_REGISTRY.md -->

# LAB REFERENCE, CRITICAL AND METHOD SOURCE REGISTRY

Checked: 2026-10-06.

This is a standards/source registry, not a bundled table of patient-specific thresholds.

## CLSI EP28 / EP28IG

Role:
reference-interval establishment, transfer and verification architecture.

Use:
- ReferenceIntervalSource metadata
- local/method applicability
- provenance requirements.

Do not reproduce paywalled standard content or numerical tables without rights.

## CLSI GP47

Role:
management of critical- and significant-risk laboratory results and communication processes.

Use:
- CriticalRule governance
- communication/receipt boundary
- source-defined urgent-result classes.

No universal critical threshold is inferred from this standard.

## CLSI EP09

Role:
measurement-procedure comparison and bias estimation.

Use:
- MethodComparabilityRecord architecture
- bias/difference provenance
- cross-method trend caution.

Current source status must be rechecked at implementation because CLSI has an active revision process for EP09.

## CLSI EP33

Role:
delta-check program design and evaluation.

Use:
- delta-rule metadata
- comparison interval/source
- alert-vs-diagnosis boundary.

The current second edition was published in 2023.

## IFCC C-RIDL

Role:
reference intervals and decision limits scientific reference architecture.

Use:
- distinction between reference intervals and decision limits
- global/local population variability
- research/source discovery.

## Source activation

A laboratory interpretation pack can become ACTIVE only when:
- source identity/version is known,
- applicability context is encoded,
- unit/measurand mapping is reviewed,
- fixtures pass,
- license/redistribution constraints are satisfied.


---

<!-- SOURCE: 183_LAB_API_UI_AND_EXPLANATION_CONTRACT.md -->

# LAB API, UI AND EXPLANATION CONTRACT

## API resources

v0.24 defines:
- reference interval snapshots,
- lab method contexts,
- lab interpretation assessments,
- source-defined critical rules,
- method comparability records,
- delta/RCV evaluations.

## UI

### Result row
Show separately:
- measured value + unit,
- source-reported flag,
- app reference comparison,
- critical rule state,
- method/source badge.

### Detail drawer
Show:
- exact laboratory/report reference interval,
- method/specimen/lab metadata,
- source and version,
- reason for no/limited interpretation.

### Trend chart
Must mark:
- method changes,
- specimen changes,
- unit conversion,
- missing intervals,
- source reference range changes when shown.

Do not paint a continuous "normal band" across years if the source interval/method changed without explanation.

### Critical result
A source-defined critical match gets a high-salience presentation, but the app never falsely claims clinical notification or resolution.

### Reference interval education
Contextual help explains:
- reference interval ≠ optimal target,
- reference interval ≠ decision limit,
- source flag ≠ app diagnosis,
- delta alert ≠ diagnosis.


---

<!-- SOURCE: 184_SITE_LAB_INTERPRETATION_AND_METHOD_COMPARISON_LAB.md -->

# SITE LAB INTERPRETATION AND METHOD-COMPARISON LAB

## Purpose

Extend the fourth output, the interactive Site Lab, with a synthetic laboratory interpretation playground.

## Synthetic controls

User can change:
- result value,
- reference low/high,
- synthetic critical low/high,
- specimen,
- method A/B,
- prior result,
- CVa/CVi for an explicitly synthetic RCV demo,
- personal-baseline points.

## Live outputs

Show independently:
- reference interval status,
- critical-rule match,
- method comparability,
- delta/RCV status,
- personal-baseline deviation.

## Required teaching moments

Demonstrate:
1. outside range but not critical,
2. critical threshold independent of range,
3. method change breaking naive trend continuity,
4. result within reference interval but unusual personal delta,
5. unknown context causing no interpretation.

All values/rules are visibly synthetic.

No real clinical threshold table is bundled merely for the demo.


---

<!-- SOURCE: 185_LAB_INTERPRETATION_SYNTHETIC_FIXTURES_AND_GOLDEN_VECTORS.md -->

# LAB INTERPRETATION SYNTHETIC FIXTURES AND GOLDEN VECTORS

Machine assets:
- `LAB_INTERPRETATION_TAXONOMY.json`
- `LAB_SOURCE_REGISTRY.json`
- `lab_interpretation_fixtures.json`
- `reference_code/lab_interpretation_engine.py`
- `reference_code/validate_lab_interpretation_fixtures.py`

Fixture set is deliberately synthetic.

It validates:
- below/within/above reference comparison,
- independent critical-low/high matching,
- no-reference state,
- unit mismatch,
- context mismatch,
- method comparability state,
- RCV calculation,
- delta below/above RCV,
- source-range snapshot preservation,
- decision-limit separation,
- personal baseline independence.

Fixture PASS validates software semantics, not medical threshold validity.


---

<!-- SOURCE: 186_IDENTIFIER_INTEGRITY_REPAIR_v0.24.md -->

# IDENTIFIER INTEGRITY REPAIR — v0.24

## Problem discovered

The v0.23 package contained historical ID collisions caused by multiple Forge increments reusing identifier ranges.

Affected namespaces:
- Acceptance tests (`AT-*`)
- Architecture decisions (`ADR-*`)
- Failure modes (`FM-*`)
- Implementation phases (`P4G`, `P4H`).

Feature requirement IDs were already unique.

## Repair policy

1. Preserve the first historical use of an identifier.
2. Renumber only later colliding occurrences.
3. Update requirement traceability to the new canonical acceptance IDs.
4. Update implementation-phase acceptance ranges.
5. Preserve a machine-readable migration map.
6. Rebuild Master Handoff after repair.
7. Audit for zero duplicate canonical IDs before release.

## Authoritative machine files

- `IDENTIFIER_MIGRATION_MAP_v0.24.json`
- `IDENTIFIER_AUDIT_v0.24.json`
- `ACCEPTANCE_TEST_REGISTRY.json`
- `REQUIREMENTS_TRACEABILITY.json`

Legacy IDs in the migration map are historical aliases only.
New implementation/test evidence must use canonical IDs.


---

<!-- SOURCE: 18_HUMAN_OS_DONOR_SPEC.md -->

# HUMAN OS DONOR SPECIFICATION

This file exists so a future developer does not need any previous memory of “Human OS”.

## Definition

Within this project, **Human OS** means a broader methodology for representing a person's evolving state through time.

Human OS is not required to be installed as a separate application.

For Longevity App, Human OS is a **donor of reusable methodology**.

## Forge Donor definition

- **Donor**: source of a potentially useful method.
- **Receiver**: project being improved.

Here:
- donor = Human OS
- receiver = Longevity App

The developer must inspect donor ideas and classify them before transfer.

Allowed dispositions:
- TRANSFER: directly useful.
- ADAPT: useful after receiver-specific adjustment.
- PRESERVE: receiver already implements the need.
- SUPERSEDE: explicitly replace an old receiver rule with documented mapping/rollback.
- EXCLUDE: irrelevant, conflicting or private.
- UNKNOWN: insufficient evidence.

## Non-copy rule

Do not import:
- donor identity,
- personal user history,
- private dates,
- unrelated academic/projects data,
- donor persona,
- irrelevant commands,
- fictional completion/progress.

Transfer methods, not foreign identity.

## Human OS principles required in Longevity App

### HOS-01 State continuity
Preserve actual current and historical state.

### HOS-02 Event orientation
Represent meaningful changes as dated events/measurements.

### HOS-03 Plan != completion
Plans do not become completed events automatically.

### HOS-04 Provenance
Track where important data came from.

### HOS-05 Correction history
Corrections preserve the relationship to prior data where appropriate.

### HOS-06 Raw != derived
Canonical observations are separate from summaries.

### HOS-07 AI != canonical fact
Generated interpretation cannot silently become the health record.

### HOS-08 Multi-timescale review
Support day/week/month/year/all-time views where meaningful.

### HOS-09 Decision memory
Important engineering decisions record reason, alternatives and switch condition.

### HOS-10 Failure-mode design
Model how the system can fail and how to detect/prevent/repair it.

### HOS-11 Migration/rollback
Version changes preserve user history and have recovery strategy.

### HOS-12 Evidence discipline
Mechanism, human outcome, observation and speculation remain distinguishable.

## Receiver rule

Longevity App owns its own product identity and data model.
Human OS cannot override explicit Longevity App requirements simply because an older donor implementation differs.

## Future donor files

If actual Human OS files are supplied later:
1. inspect Longevity App current baseline first,
2. inspect donor files,
3. map useful deltas,
4. exclude private/irrelevant state,
5. record transfer decisions,
6. test receiver behavior,
7. do not replace current receiver data blindly.


---

<!-- SOURCE: 19_BUILD_AND_DELIVERY_CONTRACT.md -->

# BUILD AND DELIVERY CONTRACT

## Required development outcome

A coding agent should attempt to produce a real repository, not merely suggestions.

## Recommended repository structure

Example only:

```text
longevity-app/
  apps/
    mobile/
    web/             # if separate from Flutter web
  services/
    api/
  packages/
    domain/
    api_client/
  docs/
  infra/
  tests/
```

A different structure is acceptable if responsibilities remain clear.

## Required deliverables

### Source
- complete source tree,
- lockfiles,
- migrations,
- tests,
- config templates,
- documentation.

### Android
- successful release build evidence,
- APK,
- AAB,
- build instructions.

### iOS
- buildable iOS project,
- signing/TestFlight setup instructions,
- real build evidence if environment allows,
- never claim TestFlight deployment without actual credentials/upload.

### Web
- production build,
- deployment documentation.

### Backend
- source,
- migration system,
- environment template,
- OpenAPI or equivalent,
- tests,
- deployment guide.

## Development sequence

1. Read all specification files.
2. Identify contradictions/gaps.
3. Resolve noncritical gaps with documented engineering decisions.
4. Define architecture.
5. Create repository.
6. Implement backend/domain model.
7. Implement local persistence/sync.
8. Implement mobile/web features.
9. Implement tests.
10. Run tests.
11. Fix failures.
12. Build Android.
13. Build/test iOS when environment supports it.
14. Build web.
15. Run acceptance smoke tests.
16. Generate release report.
17. Package deliverables.

## Do not stop early

Do not consider the task complete after:
- creating a skeleton,
- implementing one screen,
- showing a mock screenshot,
- generating a plan.

Continue until the environment or a concrete blocker prevents further verified progress.

## Evidence stages

Report separately:

- SPECIFIED
- CODED
- STATICALLY_CHECKED
- TESTED
- BUILT
- INSTALLED
- BEHAVIORALLY_VALIDATED
- DEPLOYED

Never promote one stage into another without evidence.

## Build-time research

Before implementation, verify current:
- Flutter/Dart stable versions,
- Android build requirements,
- iOS/Xcode requirements,
- key package maintenance status,
- USDA FoodData Central API contract,
- Open Food Facts API contract/licensing,
- authentication/backend dependencies.

Record versions actually used.

## Final report

Provide:
- what was built,
- repo tree,
- architecture,
- commands executed,
- test results,
- build artifacts,
- known limitations,
- setup steps,
- next recommended fixes only if something remains incomplete.


---

<!-- SOURCE: 20_IMPLEMENTATION_PHASES_AND_MVP.md -->

# IMPLEMENTATION PHASES AND MVP EXECUTION ORDER

This file is an execution plan. It does not reduce the final product scope.

The future coding agent should use phases to avoid building isolated screens without a coherent system.

## Definition of MVP in this project

“MVP” means the first end-to-end version that demonstrates the core Longevity App model across account, health records, nutrition, synchronization and at least Android + web.

It does NOT mean a disposable prototype.

The MVP architecture must be compatible with the full product.

## P0 — Foundation

Build first:

- repository/monorepo structure,
- environment/config system,
- backend application,
- relational server database and migrations,
- authentication,
- owner-scoped authorization,
- API error model,
- generated OpenAPI or equivalent,
- mobile application shell,
- web application shell,
- local mobile database,
- sync/outbox foundation,
- CI/static analysis/test commands.

Exit criteria:

- account can be created/authenticated,
- authenticated request is owner-scoped,
- local mobile database initializes,
- server migrations run from an empty database,
- automated test command runs,
- Android and web development apps launch in an available environment.

## P1 — Core longitudinal health

Implement:

- Today,
- Timeline,
- Mind Check-in,
- Conditions,
- Symptoms,
- Vitals,
- Laboratory Session,
- Laboratory Result,
- analyte longitudinal series,
- correction provenance.

Exit criteria:

- all corresponding AT-010 through AT-033 and AT-050/051/070/071 pass where applicable,
- same canonical record can be read after re-login,
- lab units are preserved,
- suspected condition cannot silently become confirmed.

## P2 — Nutrition / Food Matrix

Implement:

- meals,
- food entries,
- custom food,
- normalized nutrient model,
- provider-neutral Food Data Layer,
- food search,
- packaged-food barcode flow,
- immutable FoodSnapshot,
- amount-based calculation,
- daily totals,
- missing nutrient coverage.

Exit criteria:

- AT-040 through AT-047 pass,
- provider response can change without rewriting an old logged meal,
- missing nutrient is not displayed or aggregated as a measured zero.

## P3 — Medication, sleep, activity and synchronization

Implement:

- MedicationPlan,
- IntakeEvent,
- SleepEpisode,
- ActivityEvent,
- robust mobile offline outbox,
- push/pull synchronization,
- conflict handling,
- deletion tombstones,
- cross-client refresh.

Exit criteria:

- AT-060 through AT-083 pass,
- timeout/retry does not duplicate accepted append-only event,
- plan does not become intake,
- same account is coherent on Android/web and iOS when available.

## P4 — Insights, export, security and production hardening

Implement:

- trend ranges,
- derived insight boundary,
- export,
- account/data deletion,
- audit/security review,
- backup/restore procedure,
- release logging/observability,
- error monitoring without leaking unnecessary health data.

Exit criteria:

- AT-090 through AT-092,
- security acceptance tests,
- restore test,
- representative derived insight references source records.

## P5 — Platform release completion

### Android
- release build,
- APK,
- AAB,
- install/run smoke test on a supported real device or emulator.

### iOS
- Xcode-compatible release configuration,
- build on supported macOS/Xcode environment,
- TestFlight-ready setup.
- Actual TestFlight upload requires real Apple credentials and must not be claimed without execution.

### Web
- production build,
- deployable configuration,
- responsive browser smoke tests.

Exit criteria:
- AT-100 through AT-104 pass to the extent the execution environment permits.
- Any unavailable platform gate remains explicitly NOT_RUN/BLOCKED, never silently PASS.

## P6 — Optional public website

A public marketing/documentation site may be added separately from the authenticated health dashboard.

This phase is optional unless the user later makes it a release requirement.

## Development rule

Do not start with AI features.

Canonical health records, sync, data integrity and export must work before AI analysis becomes a release-critical dependency.


## P4A — Universal Health Graph + Advanced Modules + Results Engine
Implement HealthFact, vaccination, procedures/treatment courses, product use, module settings, Model Registry, ScoreResult, population longevity baseline, healthspan composites and Results dashboard. Exit criteria: AT-180 through AT-199 as applicable.


## P4B — Comparison / Daily Missions / Education / Wearables

Implement:
- ComparisonProfile and scenario cloning,
- N-profile comparison UI,
- settings/default reset system,
- deterministic Daily Missions engine,
- deterministic exercise prescription rules,
- offline education packs/quizzes,
- Android Health Connect adapter,
- Apple HealthKit adapter,
- wearable provenance/deduplication,
- no-AI offline-core verification.

Exit criteria:
- AT-200 through AT-252 pass as applicable to the platform.

## P4C — Longevity ↔ Shortevity + Human OS Core

Implement:
- Protection/Burden/Function channels,
- trajectory engine,
- cumulative exposure records,
- causal/evidence graph,
- treatment-burden tracking,
- deterministic early-warning rules,
- state/event/decision continuity,
- effective-date policy engine,
- dependency invalidation/recalculation,
- Human OS donor traceability.

Exit criteria: AT-260 through AT-292 pass as applicable.


## P4D — Life Course / Twin / Interoperability

Implement:
- whole-life timeline,
- EpisodeOfCare,
- biological-age Model Registry support,
- function/QoL/pain/rehab,
- multimorbidity/interaction graph,
- exposome/context,
- semantic coding/interoperability adapters,
- deterministic Digital Twin,
- personal baseline/anomaly/forecast,
- portable full-state export/restore.

Exit criteria:
- AT-300 through AT-384 pass as applicable.


## P4F — Production Shell / Accessibility / Operations

Implement:
- secure platform-native key/token storage,
- app lock,
- session/device registry,
- local→cloud migration,
- local reminder scheduler,
- timezone-safe reminders,
- accessibility and aging-friendly presets,
- localization architecture,
- clinician/scoped reports,
- privacy-minimized observability,
- crash/startup recovery,
- support bundle/safe mode,
- environment separation,
- release provenance,
- threat-model security gate,
- claim-control registry.

Exit criteria:
- AT-500 through AT-556 pass as applicable.


## P4G — Implementation Blueprint / E2E Proof

Implement/establish before mature release:
- concrete reference architecture,
- explicit screen state machines,
- migration fixture harness,
- canonical API envelope/idempotency/concurrency behavior,
- deterministic synthetic data generator,
- failure injection,
- performance scale fixtures/budgets,
- end-to-end reference scenarios,
- layered CI/test matrix,
- implementation-agent execution protocol.

Exit criteria:
- AT-560 through AT-620 pass as applicable.


## P0A — Bootstrap Contract Gate

Before broad P1+ feature work, prove:
- repository/workspace bootstrap,
- runnable client shell,
- runnable API shell,
- migration 1,
- profile/auth ownership,
- outbox + idempotent sync spine,
- one canonical MindCheckin vertical slice,
- restart persistence,
- authorization regression test.

Exit criteria:
AT-650, AT-693, AT-694, AT-695 and related bootstrap checks PASS.

## P4O — Contracts / Recovery / Chaos Hardening

Implement:
- component contracts,
- module ownership/dependency graph,
- generated API/resource schemas,
- named fixture library,
- DR drill harness,
- sync chaos simulator,
- stable error catalog,
- final release artifact layout.

Exit criteria:
AT-630 through AT-696 pass as applicable.


## P4H — Domain Completion / Responsive / Retention / Acceptance Dossier

Implement:
- domain API/schema catalog,
- resource ownership CRUD/sync matrix,
- query/filter/sort/search/export semantics,
- responsive compact/medium/expanded layout contracts,
- data retention/deletion/tombstone state machine,
- typed domain-event catalog and invalidation,
- capability degradation matrix,
- production acceptance dossier/release evidence schema.

Exit criteria:
- AT-700 through AT-754 pass as applicable.


## P4P — Starter Packs / Schemas / Licensing

Implement:
- MP-CORE-DERIVED-1
- RP-CORE-INVARIANTS-1
- synthetic demo reference pack
- foundation health-literacy education pack
- pack catalogs and activation/license states
- Data Sources & Licenses UI
- starter JSON Schema validation/type-generation pipeline
- pack fixture runner
- Site starter-pack integration.

Exit criteria:
- AT-775 through AT-804 pass.


## P4Q — Golden Vectors / Database Kernel / User Help

Implement:
- reference CORE_DERIVED formula runner in production language,
- v0.17 golden vectors,
- local SQLite kernel schema/migrations,
- server PostgreSQL schema/migrations,
- seed/reference bootstrap,
- canonical data dictionary,
- onboarding/help content,
- clinician/export structures,
- attribution-manifest renderer,
- transactional invalidation/recalculation protocol.

Exit criteria:
- AT-805 through AT-838 pass as applicable.


## P4I — Migration / Authorization / Interop / Repo Bootstrap

Implement:
- production migration runner using ordered local/server migrations,
- PostgreSQL application roles and row-level security,
- cross-user authorization integration tests,
- repository workspace bootstrap,
- one-command contract verification,
- FHIR export adapter using selected current release/profile,
- official validator integration for production interoperability.

Exit criteria:
- AT-839 through AT-873 pass as applicable.
- PostgreSQL-specific tests remain BLOCKED/NOT_RUN until PostgreSQL test infrastructure exists.


## P4J — OpenAPI / Rollback / UI Contract / Delivery Evidence

Implement:
- generated/maintained OpenAPI document,
- endpoint authorization middleware mapped to operation IDs,
- idempotency/revision/error handling,
- SQLite/PostgreSQL rollback drills,
- UI design token package,
- component-state golden/snapshot tests,
- delivery evidence checklist automation.

Exit criteria:
- AT-874 through AT-902 pass as applicable.


## P4K — Health Platform Adapters / Nutrition Math / Domain API Coverage

Implement:
- Health Connect adapter with permission/provenance/change tracking,
- HealthKit adapter with privacy-aware permission semantics,
- provider source identity/deduplication,
- local persisted imported health records,
- nutrition/recipe deterministic engine,
- recipe version/snapshot semantics,
- expanded domain API operations,
- platform and nutrition fixture tests.

Exit criteria:
- AT-903 through AT-937 pass as applicable.
- Real HealthKit/Health Connect SDK/device integration remains NOT_RUN until target environments exist.


## P4L — Secure Documents / Attachments / Lab Extraction

Implement:
- local/cloud attachment repository,
- private object storage and upload sessions,
- type/hash/size/quarantine/security pipeline,
- versioned attachment metadata,
- preview/thumbnail derivatives and metadata stripping,
- deterministic text/OCR parser adapter interface,
- staged lab extraction candidates,
- review/commit receipt,
- attachment/health-entity linking,
- document API operations,
- synthetic Site ingestion demo.

Exit criteria:
- AT-938 through AT-977 pass as applicable.
- Real arbitrary PDF/image parser accuracy remains separate runtime/corpus evidence.


## P4M — Medication / Supplement / Safety Knowledge

Implement:
- product/ingredient normalization service,
- MedicationPlan / SupplementPlan / IntakeEvent separation,
- exposure aggregation,
- duplicate-ingredient engine,
- safety knowledge registry and pack lifecycle,
- RxNorm identity adapter,
- DailyMed/openFDA versioned label adapters,
- DSLD supplement-label adapter,
- ODS evidence references,
- InteractionAssessment UI/API,
- synthetic safety fixtures in CI.

Exit criteria:
- AT-978 through AT-1017 pass as applicable.
- Real comprehensive clinical interaction coverage remains NOT_CLAIMED until an appropriate maintained evidence/rule source is activated and reviewed.


## P4N — Preventive Care / Vaccination / Screening Engine

Implement:
- PreventiveServiceDefinition / PreventiveRule / PreventiveEvent / PreventiveAssessment,
- explicit jurisdiction/profile guideline selection,
- due/overdue/unknown-history engine,
- vaccination series/minimum interval/catch-up validity,
- screening method/anatomy/follow-up logic,
- guideline source snapshot + refresh/diff/conflict pipeline,
- preventive API/dashboard/missions/notifications,
- CDC/USPSTF/WHO/Türkiye source adapters as separately reviewed packs,
- synthetic preventive fixtures in CI.

Exit criteria:
- AT-1018 through AT-1063 pass as applicable.
- No real jurisdictional clinical preventive pack is considered ACTIVE merely because a source URL exists.

## P4R — Lab Interpretation Governance + Identifier Integrity

Implement:
- reference interval snapshot/source selection,
- decision-limit and critical-rule separation,
- method/specimen comparability,
- delta-check/RCV engine with sourced inputs,
- personal-baseline separate channel,
- lab interpretation UI/Site demo,
- canonical identifier uniqueness gate.

Exit criteria:
- AT-1064 through AT-1108 pass as applicable,
- zero canonical AT/ADR/FM/phase duplicates,
- no real critical/reference threshold is activated without source/version/applicability evidence.


---

<!-- SOURCE: 21_SCREEN_ROUTES_AND_USER_FLOWS.md -->

# SCREEN ROUTES AND USER FLOWS

The names below are canonical concepts, not mandatory visible labels.

## Application route map

### Public / unauthenticated
- `/welcome`
- `/login`
- `/register`
- `/forgot-password` when supported
- `/privacy`
- `/terms`

### Authenticated
- `/today`
- `/timeline`
- `/labs`
- `/labs/new`
- `/labs/:sessionId`
- `/labs/analytes/:analyteKey`
- `/mind`
- `/mind/checkin`
- `/conditions`
- `/conditions/:id`
- `/symptoms`
- `/symptoms/new`
- `/nutrition`
- `/nutrition/day/:date`
- `/nutrition/food-search`
- `/nutrition/custom-food`
- `/medications`
- `/vitals`
- `/sleep`
- `/activity`
- `/insights`
- `/settings/profile`
- `/settings/units`
- `/settings/privacy`
- `/settings/export`
- `/settings/account`

Route syntax may vary by framework. Conceptual coverage should remain.

## Flow UF-01 — First launch

1. User opens app.
2. User can sign in or create account.
3. After authentication, user chooses basic preferences:
   - timezone,
   - locale,
   - preferred units.
4. Dietary preferences are optional.
5. User lands on Today.
6. Empty state explains what can be recorded without suggesting that missing data is a health problem.

## Flow UF-02 — Mind check-in

1. Today → “How do you feel today?”
2. Show 1–10 controls.
3. User enters selected ratings.
4. Optional note/tags.
5. Save.
6. Create canonical MindCheckin.
7. Add/derive TimelineEvent referencing that record.
8. Show current-day value.
9. If user corrects it later, preserve correction provenance.

## Flow UF-03 — Add laboratory session

1. Labs → Add.
2. Enter collection date/time.
3. Optional report date, laboratory, fasting status, note.
4. Save session.
5. Add one or more LabResult records.
6. Every numeric result requires explicit unit unless truly unitless.
7. Reference interval is stored as report metadata.
8. Save.
9. Timeline references session.
10. Analyte history becomes available when comparable previous results exist.

## Flow UF-04 — Review analyte history

1. Labs → analyte/history.
2. Fetch records for the same normalized analyte identity.
3. Group only comparable units.
4. If conversion exists, explicitly convert with provenance/version.
5. Display chart and raw points.
6. Allow opening original lab session.

## Flow UF-05 — Add condition

1. Conditions → Add.
2. Enter condition name.
3. Explicitly choose:
   - confirmed diagnosis,
   - self-reported history,
   - suspected/evaluation pending,
   - resolved,
   - unknown.
4. Optional onset/end date, clinician, notes.
5. Save.
6. UI must visibly preserve status.

## Flow UF-06 — Add symptom

1. Symptoms → Add.
2. Select/enter symptom.
3. Set start date/time.
4. Optional end.
5. Severity 1–10.
6. Associated features/context/note.
7. Save and add timeline representation.

## Flow UF-07 — Log a provider food

1. Nutrition → add food.
2. Search text or scan barcode.
3. Query provider-neutral backend.
4. Display candidate identity, provider, brand/barcode/basis.
5. User explicitly selects result.
6. Enter quantity.
7. App calculates nutrients from normalized source basis.
8. Preview.
9. Persist immutable FoodSnapshot + FoodEntry.
10. Update meal/day totals.

## Flow UF-08 — Log custom food

1. Nutrition → custom food.
2. Enter name and basis.
3. Enter only known nutrients.
4. Unknown nutrients remain absent/missing.
5. Save custom food.
6. Log quantity like other foods.

## Flow UF-09 — Medication plan vs intake

1. Medication/Supplement → create plan.
2. Plan appears as intended schedule.
3. Time passing does not create intake.
4. User explicitly records actual intake.
5. IntakeEvent is created.
6. Timeline may show actual intake according to privacy/UX settings.

## Flow UF-10 — Offline create and sync

1. User has no network.
2. User creates supported local record.
3. Local canonical record receives stable client-generated ID.
4. Outbox mutation is queued.
5. UI displays local saved state.
6. Network returns.
7. Client sends mutation with idempotency identity/base revision.
8. Server acknowledges canonical revision.
9. Client marks outbox item acknowledged.
10. Pull phase fetches remote changes.
11. No duplicate record appears.

## Flow UF-11 — Export

1. Settings → Export.
2. User selects supported export scope/format.
3. Server/client generates export.
4. Export contains timestamps, units and record identities/provenance where appropriate.
5. User receives/downloads own export.

## Flow UF-12 — Delete account/data

1. Settings → Account/Delete.
2. Explain effect and applicable retention constraints.
3. Require deliberate confirmation.
4. Execute authenticated deletion workflow.
5. Record completion state without leaving accessible user health data outside documented retention policy.


## v0.23 Preventive Care route

Suggested route:
`/preventive`

Primary child views:
- Due / Review
- Vaccinations
- Screening & Prevention
- History
- Guideline Sources.

Flow:
`Preventive dashboard → service detail → source/eligibility explanation → mission/reminder or record completion → PreventiveEvent → reassessment`.

Shared-decision/evidence-insufficient items route to review/explanation rather than mandatory completion UI.


---

<!-- SOURCE: 22_SYNC_PROTOCOL_AND_CONFLICTS.md -->

# SYNC PROTOCOL AND CONFLICT RULES

This file makes offline/mobile synchronization implementation-specific enough to build while remaining framework-neutral.

## Record identity

Use globally unique stable IDs generated before server submission where offline creation is supported.

Recommended:
- UUIDv7 or another collision-resistant sortable UUID strategy if current platform libraries support it reliably.
- UUIDv4 is acceptable.

Do not use a temporary local integer ID as the only identity for an offline-created server record.

## Common sync metadata

Server-synchronized records should support equivalent semantics to:

- `id`
- `user_id`
- `created_at`
- `updated_at`
- `server_revision`
- `deleted_at` or tombstone state when deletion must synchronize

Clients may additionally store:
- `sync_state`
- `last_synced_revision`
- `local_updated_at`
- `sync_error`

## Client sync states

Suggested:

- CLEAN
- PENDING_CREATE
- PENDING_UPDATE
- PENDING_DELETE
- SYNCING
- CONFLICT
- ERROR

These are implementation states, not user health statuses.

## Outbox

Mobile maintains a durable outbox.

Each mutation contains:
- mutation_id,
- entity_type,
- entity_id,
- operation,
- payload,
- base_revision when relevant,
- created_at,
- retry_count,
- last_error.

The same mutation ID must be safe to retry.

## Push then pull cycle

Recommended cycle:

1. Load pending outbox mutations.
2. Push in dependency-safe order.
3. Server performs ownership + validation + idempotency check.
4. Server returns accepted revision or conflict.
5. Client marks acknowledged mutations.
6. Client pulls changes after last sync cursor.
7. Apply server changes transactionally.
8. Advance sync cursor only after successful local apply.

## Append-oriented event records

Examples:
- symptom event,
- mind check-in,
- intake event,
- vital measurement,
- activity event.

Creation should be idempotent by stable record ID/mutation ID.

A network timeout after server acceptance must not produce a second event on retry.

## Corrections

For records where historical provenance matters, prefer:
- new correction/revision record,
- link to corrected record,
- deterministic “current” projection.

Do not rely on blind last-write-wins for critical historical values.

## Mutable profile/settings

For truly mutable single-state objects such as locale/unit preference:
- send `base_revision`,
- server rejects stale update with conflict response,
- client can refresh and reapply or present user resolution.

## Conflict response

Conceptual HTTP:
`409 Conflict`

Payload should contain enough information to resolve:
- entity ID,
- submitted base revision,
- current server revision,
- current server representation or safe resolution data,
- conflict type.

## Deletes

Use tombstones where deletion must propagate to offline clients.

Do not resurrect a deleted server record because another device later uploads a stale copy.

Deletion policy for health data must also follow account/privacy requirements.

## Sync cursor

Server should support incremental pull through an opaque monotonic cursor or equivalent change feed.

Do not use client wall-clock time as the sole source of truth for “changes since”.

## Timeouts

Timeout means UNKNOWN DELIVERY STATE until idempotent retry/status resolution.

Do not tell the user an upload failed and then create a duplicate if the server actually accepted it.

## Multi-device example

Device A creates symptom offline.
Device B edits profile online.
Device A reconnects:
- symptom create is pushed idempotently,
- profile change is pulled,
- independent changes merge.

## Invariants

- user ownership is checked on server,
- IDs are stable,
- accepted retry cannot duplicate,
- cursor advances only after local transaction success,
- stale mutable write cannot silently overwrite newer server state,
- correction history is preserved.


---

<!-- SOURCE: 23_API_PAYLOAD_EXAMPLES.md -->

# API PAYLOAD EXAMPLES

These are semantic examples. The implementing agent may refine exact JSON naming while preserving meaning.

## Common error envelope

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable summary",
    "fields": {
      "unit": "Unit is required for numeric lab result."
    },
    "request_id": "..."
  }
}
```

## Create mind check-in

`POST /v1/mind-checkins`

```json
{
  "id": "client-generated-uuid",
  "observed_at": "2026-10-03T09:30:00+03:00",
  "mood_1_10": 7,
  "anxiety_1_10": 4,
  "stress_1_10": 5,
  "energy_1_10": 6,
  "motivation_1_10": 7,
  "focus_1_10": 8,
  "social_energy_1_10": 6,
  "sleep_quality_1_10": 7,
  "note": "Example self-report"
}
```

Response includes canonical server revision.

## Create lab session

`POST /v1/lab-sessions`

```json
{
  "id": "client-generated-uuid",
  "collected_at": "2026-10-03T08:15:00+03:00",
  "reported_at": "2026-10-03T13:00:00+03:00",
  "laboratory_name": "Example Laboratory",
  "fasting_status": "FASTING",
  "notes": null
}
```

## Add numeric lab result

`POST /v1/lab-sessions/{sessionId}/results`

```json
{
  "id": "client-generated-uuid",
  "analyte_code": "ldl_cholesterol",
  "display_name": "LDL Cholesterol",
  "numeric_value": 118.0,
  "text_value": null,
  "unit": "mg/dL",
  "reference_low": null,
  "reference_high": 130.0,
  "reference_text": "<130",
  "flag": null,
  "measurement_method": null,
  "notes": null
}
```

The example value/range is synthetic and must not become a universal health target.

## Create suspected condition

`POST /v1/conditions`

```json
{
  "id": "client-generated-uuid",
  "name": "Example condition",
  "status": "SUSPECTED_OR_EVALUATION_PENDING",
  "onset_date": "2026-10-03",
  "end_date": null,
  "notes": "Example only"
}
```

## Create symptom

`POST /v1/symptoms`

```json
{
  "id": "client-generated-uuid",
  "symptom": "Headache",
  "start_at": "2026-10-03T14:20:00+03:00",
  "end_at": "2026-10-03T16:40:00+03:00",
  "severity_1_10": 6,
  "associated_features": ["light sensitivity"],
  "context": null,
  "notes": null
}
```

## Food search response

`GET /v1/foods/search?q=oats`

```json
{
  "items": [
    {
      "provider": "provider-name",
      "provider_food_id": "abc123",
      "display_name": "Oats",
      "brand": null,
      "barcode": null,
      "basis_amount": 100,
      "basis_unit": "g",
      "summary_nutrients": [
        {
          "nutrient_code": "energy_kcal",
          "amount": 389,
          "unit": "kcal",
          "data_status": "KNOWN"
        }
      ]
    }
  ],
  "next_cursor": null
}
```

Provider facts are examples, not pinned provider contracts.

## Log food entry

`POST /v1/meals/{mealId}/foods`

```json
{
  "id": "client-generated-uuid",
  "selected_food": {
    "provider": "provider-name",
    "provider_food_id": "abc123"
  },
  "quantity": 60,
  "quantity_unit": "g"
}
```

Server may resolve/normalize provider food and return the immutable snapshot used.

## Nutrient missing example

```json
{
  "nutrient_code": "fiber_g",
  "display_name": "Fiber",
  "amount": null,
  "unit": "g",
  "data_status": "MISSING"
}
```

This must not be converted to `"amount": 0`.

## Create medication plan

```json
{
  "id": "client-generated-uuid",
  "name": "Example supplement",
  "dose": 1,
  "unit": "capsule",
  "route": "oral",
  "schedule": {
    "type": "DAILY"
  },
  "start_date": "2026-10-03"
}
```

This request does not create an IntakeEvent.

## Record actual intake

```json
{
  "id": "client-generated-uuid",
  "medication_plan_id": "plan-uuid",
  "item_name": "Example supplement",
  "taken_at": "2026-10-03T09:00:00+03:00",
  "dose": 1,
  "unit": "capsule",
  "status": "TAKEN"
}
```

## Conflict response

```json
{
  "error": {
    "code": "REVISION_CONFLICT",
    "message": "The record changed on another client.",
    "entity_id": "uuid",
    "submitted_base_revision": 3,
    "server_revision": 4
  }
}
```

## Incremental sync pull

Conceptual:

`GET /v1/sync/changes?cursor=opaque-cursor`

```json
{
  "changes": [],
  "next_cursor": "opaque-next-cursor",
  "has_more": false
}
```

Cursor semantics must be server-defined and monotonic for this purpose.


---

<!-- SOURCE: 24_ARCHITECTURE_DECISIONS.md -->

# ARCHITECTURE DECISION RECORDS

These are current default decisions. Future implementation may change a decision only with a documented reason and migration impact.

## ADR-001 — General-public identity

Decision:
Longevity App is a general-purpose product, not a single-person app.

Reason:
The product must work for different users and cannot embed one person's private defaults.

Switch condition:
None. Personalization belongs to account data.

## ADR-002 — Cross-platform clients

Decision:
Prefer a shared cross-platform client strategy, currently Flutter/Dart as the first choice.

Reason:
Android, iOS and web are explicit targets.

Alternative:
Separate native/web stacks.

Switch condition:
Change only if current toolchain evidence shows materially better maintainability, accessibility or platform capability without fragmenting product semantics.

## ADR-003 — Relational canonical backend

Decision:
Prefer a relational server database with migration tooling for canonical account/health data.

Reason:
The domain has clear ownership, relationships, constraints, transactions and longitudinal queries.

Preferred class:
PostgreSQL or an equivalent production relational database.

Switch condition:
A different store must demonstrate equivalent integrity, migrations, querying and operational safety.

## ADR-004 — Mobile local database

Decision:
Use a real local database, preferably SQLite or a robust compatible abstraction.

Reason:
Offline entry, migrations, transactions and durable outbox require more than simple preferences storage.

## ADR-005 — REST + machine-readable schema

Decision:
Use versioned HTTP API with OpenAPI or equivalent machine-readable contract.

Reason:
Simple cross-client interoperability and testability.

Switch condition:
A different API architecture may replace it only while preserving contract/versioning and client support.

## ADR-006 — Stable client-generated IDs

Decision:
Offline-creatable entities receive globally unique IDs before server submission.

Reason:
Supports idempotent retries and cross-device reconciliation.

## ADR-007 — Event/correction semantics

Decision:
Health facts that need provenance favor append/correction relationships over blind destructive overwrite.

Reason:
Historical integrity.

## ADR-008 — Provider-neutral food model

Decision:
USDA/Open Food Facts or future providers are adapters, not the application's canonical schema.

Reason:
Provider independence and consistent nutrient calculations.

## ADR-009 — Immutable logged food snapshot

Decision:
A logged food retains the source/nutrient snapshot actually used.

Reason:
Provider updates must not rewrite historical meals.

## ADR-010 — Missing != zero

Decision:
Unknown/missing nutrient or health values remain explicit.

Reason:
Zero is a measurement/value, not a synonym for missing.

## ADR-011 — AI is derived

Decision:
AI-generated content stays outside canonical health facts.

Reason:
Model output may be uncertain/version-dependent.

## ADR-012 — Sync uses durable outbox + server cursor

Decision:
Mobile sync uses durable queued mutations and incremental server changes.

Reason:
Handles offline use and retry ambiguity.

## ADR-013 — Secrets stay outside distributable clients

Decision:
Confidential provider/server secrets are stored server-side or in appropriate secret stores.

Reason:
Client packages are recoverable by end users/attackers.

## ADR-014 — Public site can be separate

Decision:
Authenticated health web app and optional marketing/SEO website may use separate presentation technology.

Reason:
Interactive app and content-heavy public site have different needs.

## ADR-015 — Implementation evidence is staged

Decision:
SPECIFIED/CODED/TESTED/BUILT/INSTALLED/DEPLOYED are separate statuses.

Reason:
Prevents artifact creation from being mistaken for runtime success.


## ADR-016 — Universal HealthFact + specialized entities
Use an extensible HealthFact envelope plus typed entities when stronger semantics are needed.

## ADR-017 — Advanced modules are UI complexity controls
Disabling a specialist module hides UI, never deletes its data.

## ADR-018 — Scores are typed
Validated risk, app composites, adherence, coverage, population baselines and experimental models are distinct result classes.

## ADR-019 — Lifespan is not a weighted domain score
Never derive expected lifespan by arbitrary +/- years from 0–100 domain scores.

## ADR-020 — Model Registry
All mathematical/clinical models are versioned with eligibility, inputs, outputs, source and limitations.

## ADR-021 — Oncology model specificity
Select cancer models by cancer/purpose/population. No universal cancer score is treated as validated risk.


## ADR-022 — No generative AI in required scope

Decision:
Core product is deterministic and offline-capable. No LLM is required.

Reason:
Reproducibility, privacy, offline operation and transparent mathematics.

## ADR-023 — Comparison profiles are separate state containers

Decision:
Scenario/comparison bodies are explicit profiles, not temporary UI variables.

Reason:
Reproducibility and unlimited reusable comparisons.

## ADR-024 — Daily Missions use versioned rule packs

Decision:
Missions are deterministic outputs of local state + goals + rule version.

## ADR-025 — Platform health stores are adapters

Decision:
Use Android Health Connect and Apple HealthKit as import adapters with provenance, not as the canonical app schema.

## ADR-026 — Reset settings is non-destructive

Decision:
“Reset to defaults” never deletes health history. Data deletion is a separate flow.

## ADR-027 — Education is packaged offline content

Decision:
Lessons/quizzes are authored/versioned content packs and contextual deterministic triggers.

## ADR-028 — Longevity and Shortevity are dual conceptual axes
Decision: Track protective/resilience and adverse/risk/burden separately.

## ADR-029 — Shortevity is not life-years-lost
Decision: Shortevity app scores never directly become lifespan subtraction without a validated survival model.

## ADR-030 — Human OS comprehensive accessible-method transfer
Decision: Integrate all reusable Human OS methodology accessible in current sources; mark unseen standalone donor bytes UNKNOWN.

## ADR-031 — Current state is a projection, history remains canonical
Decision: Current dashboards derive from event history + corrections + active rule versions.

## ADR-032 — Deterministic early warnings are pattern detectors, not diagnoses
Decision: Alerts name detected configured patterns and their source rule.


## ADR-033 — Life course is the top-level time model
Decision:
Individual modules project into one life course and optional Episodes of Care.

## ADR-034 — Biological age is a model family, not one truth
Decision:
Store multiple clock outputs independently with model/version/population metadata.

## ADR-035 — Function and QoL are first-class healthspan outputs
Decision:
Do not reduce healthspan to biomarkers or lifespan alone.

## ADR-036 — Multimorbidity uses graph semantics
Decision:
Conditions/treatments/interactions can connect through typed edges rather than isolated lists.

## ADR-037 — Internal model remains provider/standard neutral
Decision:
FHIR/clinical terminologies/platform stores are adapters to canonical entities.

## ADR-038 — Digital Twin is a deterministic projection
Decision:
Twin/scenario state is derived from canonical records and never replaces them.

## ADR-039 — Personal baseline != clinical reference
Decision:
Always label and store them separately.

## ADR-040 — Full portable state is a core ownership feature
Decision:
Users and future systems can restore/export state without relying on ChatGPT memory.

## ADR-041 — Forge continuity is explicit-call iterative
Decision:
Each explicit Forge call performs one bounded highest-value increment; no background development is claimed.


## ADR-042 — Data quality is separate from health status
A low-quality measurement reduces confidence; it does not automatically imply poor health.

## ADR-043 — Canonical unit codes preserve original units
Store source unit plus canonical machine-readable unit representation.

## ADR-044 — Model availability requires governance
A formula entering the codebase is insufficient. Production calculations require registry status, eligibility and deterministic fixtures.

## ADR-045 — Safety rules use explicit precedence
Rule conflicts never resolve randomly.

## ADR-046 — Population benchmarks name their population
No unlabeled percentile or peer comparison.

## ADR-047 — Local-only profile is supported
Cloud sync is optional to the product architecture, not required for deterministic core.

## ADR-048 — Imports stage uncertainty
Ambiguous data are staged rather than forced into canonical history.

## ADR-049 — Offline intelligence ships as versioned packs
Models/rules/reference data/education can update independently with checksums and rollback.

## ADR-050 — Dense sensor series and canonical events use different storage/query strategies
Do not force high-frequency sensor samples into the same access pattern as sparse health events.


## ADR-051 — Platform-native key stores protect cryptographic key material
Decision:
Use Android Keystore / Apple Keychain-compatible architecture instead of hard-coded application secrets.

## ADR-052 — Reminder state is not completion state
Decision:
Notifications never satisfy mission/intake/workout completion by themselves.

## ADR-053 — Accessibility is a release concern, not decoration
Decision:
Web targets WCAG 2.2 AA; mobile uses semantic/platform accessibility and aging-friendly options.

## ADR-054 — Localization is domain-independent
Decision:
Locale affects presentation/parsing, not canonical numeric semantics.

## ADR-055 — Sharing is export/scoped access, not account credential sharing
Decision:
Clinician/trusted-person views are read-only scoped artifacts or permissions.

## ADR-056 — Observability is privacy-minimized
Decision:
Telemetry uses technical metadata and sanitized identifiers rather than routine raw health payloads.

## ADR-057 — Production environments are separated
Decision:
Dev/test/staging/prod data and secrets do not share casual configuration.

## ADR-058 — Product claims are governed
Decision:
A new diagnostic/treatment/lifespan claim triggers evidence/regulatory boundary review.


## ADR-059 — Reference architecture is concrete but replaceable
Decision:
Provide a preferred implementation stack/layering while keeping semantic contracts normative.

## ADR-060 — UI state is explicit
Decision:
Major screens model offline/stale/conflict/permission/error states instead of inferring them ad hoc.

## ADR-061 — Migration behavior is fixture-driven
Decision:
Critical invariants have pre/post migration fixtures and automated assertions.

## ADR-062 — Idempotency is a server contract
Decision:
Retry-prone mutations use stable identity/idempotency rather than client hope.

## ADR-063 — Performance budgets are measured evidence
Decision:
Targets are engineering budgets until real reference-device evidence exists.

## ADR-064 — E2E scenarios prove product coherence
Decision:
A module cannot be considered integrated solely because isolated unit tests pass.

## ADR-065 — Mock paths cannot satisfy production completion
Decision:
Mocks are temporary development tools and are reported distinctly from production paths.


## ADR-108 — UI components have behavioral contracts
Decision:
Reusable visual components own presentation state, not canonical health mutation.

## ADR-109 — Canonical entity ownership is singular
Decision:
One module owns writes for each canonical entity; projections/adapters do not create shadow authorities.

## ADR-110 — Generated contracts are reproducible artifacts
Decision:
OpenAPI/schema/client generation is source-driven and release-diffed.

## ADR-111 — Recovery is proven by drills
Decision:
Backup documentation alone cannot satisfy restore/recovery claims.

## ADR-112 — Sync correctness requires chaos testing
Decision:
Timeout/duplicate/stale/tombstone/clock-skew scenarios are release-test inputs.

## ADR-113 — Error codes include data-saved semantics
Decision:
User recovery copy must communicate whether data are saved/pending/staged/unknown.

## ADR-114 — Bootstrap vertical slice precedes feature sprawl
Decision:
Persistence, authorization, sync idempotency and restart survival must work before broad UI implementation.


## ADR-067 — Domain API completeness is explicit
Decision:
Every canonical domain has a resource/API/validation/sync/error contract before production completion.

## ADR-068 — Responsive behavior is semantic
Decision:
Compact/medium/expanded layouts may change arrangement, not result meaning/state.

## ADR-069 — Data retention is typed
Decision:
Hide/archive/tombstone/hard-delete/account-delete are separate operations.

## ADR-070 — Domain events connect modules
Decision:
Cross-module reactions use idempotent typed events/projections rather than direct foreign-table writes.

## ADR-071 — Optional capability failure degrades safely
Decision:
Denied network/device/provider permission exposes supported fallback instead of fabricated success/data.

## ADR-072 — Production readiness requires dossier evidence
Decision:
Aggregate production state is computed from platform-scoped evidence/gates, not prose confidence.


## ADR-115 — Interactive Site Lab is a separate delivery artifact
Decision:
Maintain a dedicated web-laboratory generation prompt distinct from the production app build prompt.

Reason:
The Lab serves rapid visual/configurator exploration and publishing, while the production app has stronger account/sync/platform requirements.

## ADR-116 — Public Site defaults to synthetic data
Decision:
The interactive public demo should not require real private health data.

## ADR-117 — Site semantic parity is mandatory
Decision:
A simplified demo may omit modules, but it may not violate core invariants such as missing != zero or score != lifespan.


## ADR-118 — Starter packs are executable, third-party models are gated
Decision:
Bundle transparent app-authored formulas/rules/education; keep externally licensed clinical model code inactive until license/source/fixture gates pass.

## ADR-119 — License state is part of pack state
Decision:
A technically functional pack can still be BLOCKED_LICENSE.

## ADR-120 — Public Site defaults synthetic-first
Decision:
The Site Lab needs no real health data or provider secret to demonstrate core product semantics.

## ADR-121 — JSON Schema starter set is normative bootstrap, not entire storage architecture
Decision:
Use starter schemas for validation/type generation while preserving relational/event/time-series architecture choices.

## ADR-122 — Attribution is a product surface
Decision:
Active third-party datasets/models/standards must be visible under Data Sources & Licenses.


## ADR-123 — Golden vectors are executable product evidence
Decision:
App-owned formula implementations must pass exact versioned vectors.

## ADR-124 — SQLite and PostgreSQL target semantic parity, not SQL-text parity
Decision:
Local/server persistence may differ technically while preserving canonical health semantics.

## ADR-066 — Production seed never invents personal health history
Decision:
Only configuration/reference/synthetic demo data can be seeded globally.

## ADR-125 — Help content is part of semantic safety
Decision:
Users must be taught result types, missingness and model non-eligibility before precise-looking outputs are treated as self-explanatory.

## ADR-126 — Attribution is generated from machine state
Decision:
Data Sources & Licenses surfaces derive from a manifest rather than hand-maintained footer text.

## ADR-127 — Derived state can become stale without corrupting canonical truth
Decision:
Canonical commit survives; dependent views/results can be invalidated and recomputed.


## ADR-128 — Released migrations are append-only
Decision:
Never rewrite historical migration semantics after release.

## ADR-129 — Server authorization derives from trusted authenticated identity
Decision:
Client-supplied owner IDs are not authorization proof.

## ADR-130 — PostgreSQL RLS is defense-in-depth
Decision:
Use RLS alongside application authorization; ordinary API traffic does not run as DB owner/superuser.

## ADR-073 — Repository bootstrap has explicit module boundaries
Decision:
API/client/site/contracts/domain/persistence responsibilities are separated even if future tooling renames folders.

## ADR-074 — FHIR is an adapter/export language
Decision:
Concrete FHIR examples exist, but production validity requires target-release/profile validation and terminology review.

## ADR-075 — Static SQL is not runtime security evidence
Decision:
PostgreSQL migration/RLS assets remain NOT_RUN until exercised in a real PostgreSQL environment.


## ADR-076 — OpenAPI is a generated/validated boundary contract
Decision:
API implementation must remain compatible with a machine-readable contract rather than prose-only endpoints.

## ADR-077 — Authorization is operation-specific
Decision:
Every endpoint declares auth class and ownership behavior; URL resource ID is not proof of authorization.

## ADR-078 — API errors are machine-stable
Decision:
Localized messages may change, stable error codes do not silently change meaning.

## ADR-079 — Migration rollback is executable evidence
Decision:
A deliberate SQLite migration failure must demonstrate transactional recovery.

## ADR-080 — UI semantics are token/state driven
Decision:
Visual components share semantic tokens and state vocabulary; missing/stale/conflict are not improvised per screen.

## ADR-081 — Production readiness is machine-evaluable
Decision:
A delivery checklist prevents build agents from converting NOT_RUN/BLOCKED into PASS prose.


## ADR-082 — HealthKit and Health Connect are adapters
Decision:
Platform health stores never become the canonical product schema.

## ADR-083 — Empty platform query is not permission certainty
Decision:
Provider privacy behavior is represented conservatively; no-data and denied/limited access are not collapsed when platform cannot distinguish them.

## ADR-084 — Provider record identity drives idempotent import
Decision:
Stable provider IDs are retained and preferred for deduplication.

## ADR-085 — Nutrition math is deterministic and snapshot-based
Decision:
Scale/sum/portion calculations operate on immutable source nutrient snapshots with missingness preserved.

## ADR-086 — Recipe edits are versioned
Decision:
Historical logged meals never change because a recipe/provider definition was edited later.

## ADR-087 — Domain API coverage is explicit
Decision:
Every major domain declares server/local/future coverage instead of silently accumulating ad-hoc endpoints.


## ADR-088 — Attachments are source artifacts, not canonical health facts
Decision:
Binary source files and structured health records have separate lifecycles and ownership semantics.

## ADR-089 — Document extraction is staged and review-gated
Decision:
Parser/OCR output cannot directly overwrite/create canonical medical facts without a review/commit receipt.

## ADR-090 — Attachment versions are immutable provenance targets
Decision:
Replacement creates a new version so historical extraction remains reproducible.

## ADR-091 — File security and extraction state are separate
Decision:
Malware/type safety, parser progress and review state are modeled independently.

## ADR-092 — Private object storage is the cloud default
Decision:
Binary health attachments are never intentionally served from a public bucket/container.

## ADR-093 — Generative AI is not required for document ingestion
Decision:
Text-layer extraction, OCR and deterministic parsing can support the baseline pipeline; future AI extraction remains optional/staged.


## ADR-094 — Product identity and ingredient identity are separate
Decision:
Brand/product strings never substitute for normalized active ingredient identity.

## ADR-095 — Medication plans and actual intake are separate event classes
Decision:
Observed exposure derives from IntakeEvents, not reminders or plans.

## ADR-096 — Medication safety knowledge is curated/versioned
Decision:
Raw labels/fact sheets are evidence sources; ACTIVE rules are separately versioned reviewed objects.

## ADR-097 — No-match is not guaranteed safety
Decision:
The UI reports active-knowledge-set coverage and unresolved context.

## ADR-098 — Duplicate ingredient is a deterministic foundation signal
Decision:
Exact/reviewed same-ingredient stacking can be detected before a comprehensive clinical interaction database exists.

## ADR-099 — Third-party source roles are explicit
Decision:
RxNorm normalizes identity; DailyMed/openFDA support label evidence; DSLD supports supplement composition; ODS supports curated supplement evidence.


## ADR-100 — Preventive service and recommendation rule are separate
Decision:
A generic service concept does not imply a recommendation; jurisdiction/source rules supply eligibility and timing.

## ADR-101 — Preventive jurisdiction is explicit
Decision:
Do not infer national guideline pack from GPS/IP/current travel location and never silently fall back to U.S. rules.

## ADR-102 — Eligibility, recommendation mode and due state are separate dimensions
Decision:
SHARED_DECISION, EVIDENCE_INSUFFICIENT, NOT_ELIGIBLE and OVERDUE cannot share one ambiguous status.

## ADR-103 — Unknown history remains unknown
Decision:
Unknown vaccine/screening history is not treated as zero prior doses/tests unless a source rule explicitly defines handling.

## ADR-104 — Screening is not diagnosis
Decision:
Screening completion/abnormality can trigger follow-up but does not create a confirmed condition automatically.

## ADR-105 — Guideline source current status is versioned
Decision:
Calendar year does not determine the active schedule; official source current/effective status is stored explicitly.

## ADR-106 — Global preventive references do not override national packs
Decision:
WHO reference content informs programme design/education unless explicitly activated in a jurisdiction-specific reviewed pack.

## ADR-107 — Guideline conflicts are surfaced, not averaged
Decision:
Equal-precedence conflicting rules return PACK_CONFLICT and require reviewed resolution.


## ADR-131 — Reference intervals, decision limits and critical limits are different semantic objects.
Decision:
Reference intervals, decision limits and critical limits are different semantic objects.

## ADR-132 — Historical LabResult retains the source reference-interval snapshot.
Decision:
Historical LabResult retains the source reference-interval snapshot.

## ADR-133 — Longitudinal lab trend requires explicit method/specimen comparability.
Decision:
Longitudinal lab trend requires explicit method/specimen comparability.

## ADR-134 — Delta/RCV alerts remain separate from diagnosis and population reference status.
Decision:
Delta/RCV alerts remain separate from diagnosis and population reference status.

## ADR-135 — Personal baseline is an independent interpretation channel.
Decision:
Personal baseline is an independent interpretation channel.

## ADR-136 — Critical-result matching never implies provider notification without receipt.
Decision:
Critical-result matching never implies provider notification without receipt.

## ADR-137 — Real numerical lab thresholds require source/version/applicability activation.
Decision:
Real numerical lab thresholds require source/version/applicability activation.

## ADR-138 — Canonical release IDs must be unique and checked before packaging.
Decision:
Canonical release IDs must be unique and checked before packaging.


---

<!-- SOURCE: 25_REQUIREMENTS_TRACEABILITY.md -->

# REQUIREMENTS TRACEABILITY

This matrix connects feature requirements to acceptance evidence.

| Requirement | Primary acceptance evidence |
|---|---|
| FR-01 Account | AT-001, AT-002, AT-003 |
| FR-02 Today | AT-120 |
| FR-03 Health Timeline | AT-050, AT-051, AT-052, AT-053 |
| FR-04 Laboratory Results | AT-020, AT-021, AT-022 |
| FR-05 Lab Trends | AT-023, AT-024, AT-025, AT-026 |
| FR-06 Conditions | AT-030, AT-031, AT-032 |
| FR-07 Symptoms | AT-033 |
| FR-08 Mind Check-in | AT-010, AT-011, AT-012, AT-013 |
| FR-09 Food Diary | AT-040, AT-047 |
| FR-10 Food Amounts | AT-042, AT-048 |
| FR-11 Food Search | AT-041 |
| FR-12 Barcode | AT-045 |
| FR-13 Manual Food | AT-044 |
| FR-14 Recipes | AT-049 |
| FR-15 Nutrient Matrix | AT-042, AT-043, AT-047 |
| FR-16 Medication & Supplements | AT-060, AT-061, AT-062 |
| FR-17 Vitals & Body | AT-070, AT-071 |
| FR-18 Sleep | AT-072 |
| FR-19 Activity | AT-073 |
| FR-20 Trends | AT-121 |
| FR-21 Export | AT-090, AT-091 |
| FR-22 Corrections | AT-012, AT-026 |
| FR-23 Data deletion | AT-092 |
| FR-24 Accessibility | AT-130, AT-131 |
| FR-25 Localization-ready | AT-140, AT-141 |

Cross-cutting:
- authorization/privacy → AT-003, AT-150 through AT-154
- offline/sync → AT-080 through AT-083
- cross-platform build → AT-100 through AT-104
- evidence honesty → AT-110
- migration integrity → AT-160 through AT-162
- backup/restore → AT-170


| FR-26 Universal Health Fact | AT-180, AT-181 |
| FR-27 Vaccination | AT-182 |
| FR-28 Procedures & Treatment Courses | AT-183, AT-184 |
| FR-29 Oncology Treatment | AT-184 |
| FR-30 Health Products | AT-185 |
| FR-31 Product Use | AT-185 |
| FR-32 Health Module Settings | AT-186, AT-187 |
| FR-33 Scoring Engine | AT-190, AT-191, AT-198, AT-199 |
| FR-34 Population Longevity Baseline | AT-194, AT-195 |
| FR-35 Validated Risk Models | AT-192, AT-193, AT-197 |
| FR-36 App Composite Scores | AT-190, AT-191 |
| FR-37 Lifespan Safety | AT-196 |
| FR-38 Results Dashboard | AT-190, AT-194, AT-195 |
| FR-39 Model Transparency | AT-192, AT-198, AT-199 |
| FR-40 Historical Reproducibility | AT-199 |


| FR-41 Comparison Profiles | AT-200, AT-201, AT-202, AT-203, AT-205 |
| FR-42 Scenario Clone | AT-201 |
| FR-43 Multi-profile Comparison | AT-202, AT-203 |
| FR-44 Comparison Eligibility | AT-204 |
| FR-45 Settings Reset | AT-210, AT-213 |
| FR-46 Module Reset | AT-211 |
| FR-47 Daily Missions | AT-220, AT-221 |
| FR-48 Training Prescription | AT-222, AT-223 |
| FR-49 Mission Safety Gate | AT-224 |
| FR-50 Offline Education | AT-230, AT-231 |
| FR-51 Contextual Education | AT-232 |
| FR-52 Android Health Connect | AT-240, AT-241, AT-242 |
| FR-53 Apple HealthKit | AT-243, AT-244 |
| FR-54 Wearable Provenance | AT-241, AT-242, AT-244, AT-245 |
| FR-55 No-AI Offline Core | AT-250, AT-251, AT-252 |

| FR-56 Longevity/Shortevity Dual Axis | AT-260, AT-267 |
| FR-57 Burden Score | AT-260, AT-261 |
| FR-58 Protection Score | AT-260 |
| FR-59 Function/Capacity Channel | AT-267 |
| FR-60 Balance Visualization | AT-262 |
| FR-61 Trajectory | AT-263, AT-264 |
| FR-62 Cumulative Exposure | AT-265 |
| FR-63 Causal/Evidence Graph | AT-270, AT-271, AT-272, AT-273 |
| FR-64 Treatment Burden | AT-266, AT-267 |
| FR-65 Early Warning Rules | AT-290, AT-291, AT-292 |
| FR-66 State/Event/Decision Continuity | AT-280, AT-282, AT-284 |
| FR-67 Effective-Date Rules | AT-283 |
| FR-68 Dependency Recalculation | AT-282 |
| FR-69 Human OS Donor Traceability | AT-280–AT-289 |
| FR-70 Recovery-Aware Orchestration | AT-288, AT-289 |


| FR-71 Life Course | AT-300, AT-303 |
| FR-72 Episode of Care | AT-301, AT-302 |
| FR-73 Biological Age Models | AT-310, AT-311, AT-312 |
| FR-74 Functional Health | AT-313, AT-314 |
| FR-75 Quality of Life | AT-323 |
| FR-76 Pain | AT-320 |
| FR-77 Rehabilitation | AT-321, AT-322 |
| FR-78 Multimorbidity | AT-330, AT-333 |
| FR-79 Medication/Supplement Interaction Graph | AT-331, AT-332 |
| FR-80 Environmental Exposures | AT-340, AT-343 |
| FR-81 Social Context | AT-342 |
| FR-82 Clinical Semantics | AT-350, AT-353 |
| FR-83 Interoperability Adapters | AT-351, AT-352, AT-354 |
| FR-84 Digital Twin | AT-360 |
| FR-85 Scenario Patch | AT-361 |
| FR-86 Scenario Evidence Labels | AT-362, AT-363 |
| FR-87 Personal Baseline | AT-370, AT-372 |
| FR-88 Anomaly Detection | AT-371, AT-372 |
| FR-89 Forecast | AT-373, AT-374 |
| FR-90 Portable Full-State Export | AT-380, AT-381, AT-382, AT-383, AT-384 |


| FR-91 Data Quality Profile | AT-400, AT-401, AT-402, AT-404 |
| FR-92 Precision Preservation | AT-403 |
| FR-93 Canonical Units | AT-410 |
| FR-94 Safe Conversion | AT-411, AT-412, AT-413 |
| FR-95 Device Registry | AT-416 |
| FR-96 Repeated Measurement Sessions | AT-414, AT-415 |
| FR-97 Model Governance | AT-420, AT-421, AT-423, AT-424, AT-425 |
| FR-98 Model Golden Fixtures | AT-422 |
| FR-99 Model Retirement | AT-423, AT-424 |
| FR-100 Rule Governance | AT-430, AT-431, AT-432, AT-433 |
| FR-101 Benchmark Datasets | AT-440, AT-441, AT-442 |
| FR-102 Consent & Access | AT-450 |
| FR-103 Audit Ledger | AT-452 |
| FR-104 Local-only Profile | AT-451 |
| FR-105 Personal Experiment | AT-460, AT-461, AT-462 |
| FR-106 Import Staging | AT-470 |
| FR-107 Import Batch Receipt | AT-471, AT-472, AT-473, AT-474 |
| FR-108 Offline Pack Updates | AT-480, AT-481, AT-482, AT-483 |
| FR-109 Dense Time Series | AT-484 |
| FR-110 Standards Register | AT-410, AT-480 |


| FR-111 Secure Local Key Management | AT-500, AT-501, AT-505 |
| FR-112 App Lock | AT-502 |
| FR-113 Session & Device Registry | AT-503 |
| FR-114 Local-to-Cloud Migration | AT-504 |
| FR-115 Reminder Scheduler | AT-513, AT-515, AT-516 |
| FR-116 Reminder ≠ Completion | AT-510, AT-511, AT-512 |
| FR-117 Timezone-safe Scheduling | AT-514 |
| FR-118 Accessibility | AT-520–AT-524 |
| FR-119 Aging-friendly Display | AT-522, AT-523 |
| FR-120 Localization | AT-525, AT-526, AT-527 |
| FR-121 Turkish & English Ready | AT-525 |
| FR-122 Clinician Report | AT-530, AT-531, AT-532, AT-534 |
| FR-123 Controlled Sharing | AT-533 |
| FR-124 Privacy-first Observability | AT-540, AT-543, AT-544 |
| FR-125 Crash Recovery | AT-541, AT-542, AT-545 |
| FR-126 Support Bundle | AT-543, AT-544 |
| FR-127 Environment Separation | AT-550 |
| FR-128 Release Provenance | AT-551 |
| FR-129 Threat-model Release Gate | AT-552, AT-553, AT-554 |
| FR-130 Claim Control | AT-555, AT-556 |


| FR-131 Reference Architecture | AT-560 |
| FR-132 Screen State Machines | AT-561–AT-564 |
| FR-133 Stable Timeline Ordering | AT-565 |
| FR-134 Migration Fixtures | AT-570–AT-577, AT-579 |
| FR-135 Migration Failure Safety | AT-578 |
| FR-136 Canonical API Errors | AT-580, AT-585 |
| FR-137 Cursor Pagination | AT-581 |
| FR-138 Idempotent Mutation | AT-582, AT-583, AT-592, AT-613 |
| FR-139 Optimistic Concurrency | AT-584 |
| FR-140 Synthetic Data Generator | AT-590, AT-591, AT-594 |
| FR-141 Failure Injection | AT-592, AT-593 |
| FR-142 Performance Budgets | AT-600, AT-601, AT-604, AT-605 |
| FR-143 Dense-Series Scale Fixture | AT-602 |
| FR-144 Comparison Scale Fixture | AT-603 |
| FR-145 End-to-End Reference Scenarios | AT-610–AT-616 |
| FR-146 Test Pyramid | AT-617, AT-618 |
| FR-147 Flaky Test Governance | AT-617 |
| FR-148 Machine-readable Test Evidence | AT-618 |
| FR-149 Implementation Agent Protocol | AT-620 |
| FR-150 No Mock Completion | AT-619 |


| FR-151 Component Contracts | AT-630, AT-636 |
| FR-152 Typed Result Presentation | AT-631 |
| FR-153 Provenance Drilldown | AT-632 |
| FR-154 Conflict Resolution UI | AT-635, AT-683 |
| FR-155 Module Ownership | AT-640, AT-641, AT-642 |
| FR-156 Dependency Invalidation Graph | AT-643, AT-644 |
| FR-157 Repository Bootstrap Contract | AT-650, AT-651 |
| FR-158 Generated Contract Reproducibility | AT-652 |
| FR-159 Resource Validation Schemas | AT-653, AT-654, AT-655 |
| FR-160 Breaking API Change Detection | AT-656 |
| FR-161 Named Fixture Library | AT-660, AT-661, AT-662 |
| FR-162 Golden and Fuzz Separation | AT-663, AT-664 |
| FR-163 Disaster Recovery Drills | AT-670–AT-676 |
| FR-164 Restore Integrity Verification | AT-671, AT-676 |
| FR-165 Sync Chaos Simulator | AT-680, AT-681, AT-682, AT-684 |
| FR-166 Semantic Correction Conflict | AT-683 |
| FR-167 Stable Error Catalog | AT-635, AT-685, AT-687 |
| FR-168 Health Calculation Failure Safety | AT-686 |
| FR-169 Release Artifact Layout | AT-690, AT-691, AT-692 |
| FR-170 Bootstrap Exit Gate | AT-693, AT-694, AT-695, AT-696 |


| FR-171 Domain API Catalog | AT-700, AT-702, AT-703, AT-704 |
| FR-172 CRUD Ownership Matrix | AT-700, AT-701 |
| FR-173 Query Semantics | AT-710, AT-711, AT-712 |
| FR-174 Search Projection Safety | AT-713 |
| FR-175 Responsive Layout Contract | AT-720, AT-721, AT-722 |
| FR-176 Density Modes | AT-723 |
| FR-177 Result Visual Typing | AT-721 |
| FR-178 Retention Matrix | AT-730, AT-732, AT-733, AT-735 |
| FR-179 Tombstone Propagation | AT-731, AT-732 |
| FR-180 Account Deletion State Machine | AT-734 |
| FR-181 Third-party Deletion Scope | AT-735 |
| FR-182 Domain Events | AT-740, AT-741, AT-742 |
| FR-183 Idempotent Event Consumers | AT-740 |
| FR-184 Derived Projection Rebuild | AT-741 |
| FR-185 Capability Degradation | AT-743, AT-745 |
| FR-186 Clinically Safe Offline Degradation | AT-744, AT-745 |
| FR-187 Production Acceptance Dossier | AT-750, AT-752, AT-753 |
| FR-188 Evidence-linked Release State | AT-751, AT-752 |
| FR-189 Release-blocker Propagation | AT-750, AT-751 |
| FR-190 Screen Visual Blueprint | AT-720–AT-724, AT-754 |


| FR-191 Interactive Site Lab Artifact | AT-755, AT-773, AT-774 |
| FR-192 Site Is Not Marketing-only | AT-757, AT-774 |
| FR-193 Synthetic-first Demo | AT-756, AT-768 |
| FR-194 Deterministic Site Calculations | AT-757, AT-758, AT-759, AT-760, AT-767 |
| FR-195 Site Compare Lab | AT-761, AT-762 |
| FR-196 Site Reset Defaults | AT-763, AT-764 |
| FR-197 Site Responsive & Accessible | AT-769, AT-770, AT-771 |
| FR-198 Site Transparency | AT-772 |
| FR-199 Site Delivery Artifact | AT-773, AT-774 |
| FR-200 Site/Product Semantic Parity | AT-759, AT-765, AT-766, AT-767 |


| FR-201 Starter Model Catalog | AT-775, AT-779, AT-781 |
| FR-202 Core Derived Pack | AT-775–AT-778 |
| FR-203 External Model License Gate | AT-779, AT-791 |
| FR-204 No Fake External Calculator | AT-780 |
| FR-205 Starter Rule Catalog | AT-782–AT-784 |
| FR-206 Rule Pack Traceability | AT-785 |
| FR-207 Starter Reference Catalog | AT-786–AT-790 |
| FR-208 Synthetic Demo Reference Pack | AT-804 |
| FR-209 Health Literacy Education Pack | AT-793, AT-795, AT-796 |
| FR-210 Education Semantic Boundary | AT-794 |
| FR-211 Third-party License Matrix | AT-786–AT-791 |
| FR-212 Attribution Surface | AT-792 |
| FR-213 License-blocked Pack State | AT-791 |
| FR-214 Executable JSON Schema Starter | AT-797–AT-802 |
| FR-215 Schema Versioning | AT-803 |
| FR-216 Schema Missingness Safety | AT-798, AT-799 |
| FR-217 Pack Activation Fixtures | AT-775, AT-782, AT-793 |
| FR-218 Active Pack Set Reproducibility | AT-781, AT-785 |
| FR-219 Site Starter Pack | AT-793, AT-804 |
| FR-220 Site Third-party Safety | AT-780, AT-787, AT-804 |


| FR-221 Golden Vector Catalog | AT-805, AT-806 |
| FR-222 Executable Reference Formula Engine | AT-805 |
| FR-223 Golden Error Vectors | AT-807, AT-808 |
| FR-224 SQLite Reference DDL | AT-810–AT-818 |
| FR-225 PostgreSQL Reference DDL | AT-820, AT-821 |
| FR-226 Database Ownership Constraints | AT-812, AT-820 |
| FR-227 Lab Missingness Constraint | AT-813, AT-814 |
| FR-228 Outbox Idempotency Constraint | AT-816 |
| FR-229 Seed Safety | AT-825 |
| FR-230 Idempotent Demo Seed | AT-819 |
| FR-231 Canonical Data Dictionary | AT-822, AT-823 |
| FR-232 Zero-Knowledge Onboarding | AT-824–AT-826 |
| FR-233 Local-only First-run Choice | AT-824 |
| FR-234 Results Literacy | AT-826 |
| FR-235 Help for Non-eligibility | AT-827 |
| FR-236 Clinician Export Example | AT-829, AT-830 |
| FR-237 Portable Export Example | AT-831 |
| FR-238 Attribution Manifest | AT-832, AT-833, AT-835 |
| FR-239 Generated Data Sources Page | AT-832 |
| FR-240 Attribution Release Gate | AT-836 |
| FR-241 Transactional Canonical Write | AT-837 |
| FR-242 Derived Result Invalidation | AT-838 |
| FR-243 Stale Result State | AT-838 |
| FR-244 SQLite/Postgres Semantic Parity | AT-810, AT-820 |
| FR-245 PostgreSQL Runtime Evidence Honesty | AT-821 |


| FR-246 Ordered Migration Chain | AT-839, AT-841 |
| FR-247 SQLite Migration Versioning | AT-839, AT-844 |
| FR-248 Upgrade Preservation | AT-840 |
| FR-249 Migration/Seed Separation | AT-842 |
| FR-250 PostgreSQL Migration Honesty | AT-843 |
| FR-251 Server-side Ownership Authorization | AT-845–AT-850 |
| FR-252 Row-level Security Blueprint | AT-851–AT-853 |
| FR-253 Cross-user Denial | AT-847, AT-848 |
| FR-254 Application Role Separation | AT-854 |
| FR-255 Authorization Golden Vectors | AT-845–AT-850, AT-859 |
| FR-256 Executable Repository Scaffold | AT-856, AT-863 |
| FR-257 One-command Contract Verification | AT-857 |
| FR-258 Migration Verification Runner | AT-860, AT-861 |
| FR-259 FHIR Mapping Catalog | AT-866, AT-867 |
| FR-260 Synthetic FHIR Bundle Example | AT-864, AT-865 |
| FR-261 FHIR Validation Evidence Boundary | AT-870, AT-871 |
| FR-262 Terminology License Firewall | AT-872 |
| FR-263 Missing FHIR Value Safety | AT-868 |
| FR-264 App-score Interoperability Label | AT-869 |
| FR-265 Trusted Request User Context | AT-853 |
| FR-266 RLS Coverage Matrix | AT-851, AT-852 |
| FR-267 Connection-pool Context Safety | AT-853, AT-855 |
| FR-268 Scaffold Placeholder Boundary | AT-863 |
| FR-269 Contract Runner Prompt Presence | AT-862 |
| FR-270 Migration/RLS Release Evidence | AT-843, AT-855 |


| FR-271 OpenAPI Starter | AT-874–AT-876 |
| FR-272 Unique Operation IDs | AT-875, AT-876 |
| FR-273 Endpoint Authorization Matrix | AT-877, AT-878 |
| FR-274 URL ID Is Not Authorization | AT-879 |
| FR-275 API Idempotency Declaration | AT-880 |
| FR-276 API Revision Declaration | AT-881 |
| FR-277 Stable Error Catalog | AT-882–AT-884 |
| FR-278 Idempotency Key Mismatch | AT-883 |
| FR-279 Request Correlation ID | AT-884 |
| FR-280 OpenAPI Contract Validator | AT-885, AT-886 |
| FR-281 Migration Rollback Drill | AT-887 |
| FR-282 Rollback Preserves Existing Data | AT-890 |
| FR-283 Rollback Preserves Schema Version | AT-888 |
| FR-284 Seed Failure Isolation | AT-891 |
| FR-285 UI Design Tokens | AT-893–AT-895 |
| FR-286 Health Semantic Colors | AT-896 |
| FR-287 Component State Vocabulary | AT-897–AT-900 |
| FR-288 Missing Metric Rendering | AT-897 |
| FR-289 Result Class Visibility | AT-898 |
| FR-290 Chart Semantic Contract | AT-899 |
| FR-291 Conflict Resolver Transparency | AT-900 |
| FR-292 UI Contract Validator | AT-901 |
| FR-293 Delivery Checklist Automation | AT-902 |
| FR-294 Production Ready Truth Table | AT-902 |
| FR-295 Site Build Prompt Continuity | AT-886, AT-901 |


| FR-296 Health Platform Adapter Boundary | AT-903 |
| FR-297 Platform Provenance Preservation | AT-904, AT-905, AT-907, AT-908 |
| FR-298 Provider Stable-ID Deduplication | AT-911 |
| FR-299 Distinct-device Preservation | AT-912 |
| FR-300 Write-back Echo Prevention | AT-913 |
| FR-301 Health Connect Fine-grained Permissions | AT-903, AT-915 |
| FR-302 Health Connect Historical/Background Permission Separation | AT-903, AT-916 |
| FR-303 Health Connect Recording Method Provenance | AT-906 |
| FR-304 HealthKit Fine-grained Type Permissions | AT-903, AT-915 |
| FR-305 HealthKit Empty-query Privacy Safety | AT-909, AT-910 |
| FR-306 HealthKit Limited-history Coverage | AT-909 |
| FR-307 Manual Fallback | AT-915 |
| FR-308 Platform-import Offline Persistence | AT-915 |
| FR-309 Platform SDK Runtime Evidence Boundary | AT-916 |
| FR-310 Nutrition Mass Scaling | AT-917 |
| FR-311 Recipe Nutrient Summation | AT-918 |
| FR-312 Recipe Portion Math | AT-919, AT-920, AT-924, AT-925 |
| FR-313 Missing Nutrient Propagation | AT-921 |
| FR-314 Volume-to-mass Safety | AT-922, AT-923 |
| FR-315 Recipe Snapshot Immutability | AT-921 |
| FR-316 Recipe Versioning | AT-921 |
| FR-317 Calculation-vs-display Precision | AT-926 |
| FR-318 Nutrition Golden Vectors | AT-917–AT-927 |
| FR-319 Health Adapter Fixtures | AT-904–AT-914 |
| FR-320 Domain API Coverage Matrix | AT-928 |
| FR-321 Expanded OpenAPI Labs | AT-929 |
| FR-322 Expanded OpenAPI Nutrition | AT-930 |
| FR-323 Expanded OpenAPI Core Health Domains | AT-931–AT-934 |
| FR-324 Wearable Import API Receipt | AT-935, AT-936 |
| FR-325 Provider Overlap Safety | AT-911, AT-912 |


| FR-326 Attachment Source Entity | AT-938, AT-946 |
| FR-327 Secure Attachment Storage | AT-941, AT-971 |
| FR-328 Upload Quarantine | AT-942, AT-943 |
| FR-329 MIME and Signature Validation | AT-944 |
| FR-330 Configurable File Limits | AT-974 |
| FR-331 Parser Least Privilege | AT-942 |
| FR-332 Content Hash Integrity | AT-939, AT-945 |
| FR-333 Per-user Duplicate Detection | AT-939, AT-940 |
| FR-334 Attachment Version Immutability | AT-946 |
| FR-335 EXIF Privacy | AT-947, AT-948 |
| FR-336 Document Type Catalog | AT-963 |
| FR-337 Extraction Candidate Staging | AT-949, AT-954, AT-955 |
| FR-338 Candidate Review Gate | AT-955, AT-956 |
| FR-339 Extraction Commit Receipt | AT-956, AT-957 |
| FR-340 Lab Extraction Fields | AT-950, AT-959, AT-960 |
| FR-341 Unmapped Candidate Safety | AT-952 |
| FR-342 Missing Unit Safety | AT-953 |
| FR-343 Source Reference Interval Preservation | AT-959 |
| FR-344 Partial Candidate Commit | AT-958 |
| FR-345 Attachment Delete/Facts Separation | AT-964, AT-965 |
| FR-346 Local-only Attachments | AT-966 |
| FR-347 Attachment API Coverage | AT-967–AT-971 |
| FR-348 Upload Idempotency | AT-968, AT-972 |
| FR-349 Attachment Download Authorization | AT-971 |
| FR-350 Photo Metadata Boundary | AT-948, AT-963 |
| FR-351 Timeline Document Linking | AT-960, AT-963 |
| FR-352 Deterministic Offline Extraction Baseline | AT-949, AT-977 |
| FR-353 Parser Confidence Boundary | AT-961 |
| FR-354 Document Ingestion Fixtures | AT-939, AT-942, AT-943, AT-949, AT-962 |
| FR-355 Site Synthetic Document Demo | AT-977 |


| FR-356 Medication Product/Ingredient Separation | AT-978 |
| FR-357 Medication Plan vs Intake | AT-979, AT-1004 |
| FR-358 Intake Event Snapshot | AT-988, AT-1011 |
| FR-359 Supplement Multi-ingredient Composition | AT-980 |
| FR-360 Ingredient Normalization States | AT-981, AT-1010 |
| FR-361 Active-moiety/Elemental Basis Safety | AT-987 |
| FR-362 Route-aware Exposure | AT-983, AT-1003 |
| FR-363 Planned vs Observed Exposure | AT-979 |
| FR-364 RxNorm Identity Adapter | AT-989, AT-991 |
| FR-365 DailyMed Versioned Label Adapter | AT-989, AT-992 |
| FR-366 openFDA Evidence Boundary | AT-989, AT-993 |
| FR-367 DSLD Supplement Label Adapter | AT-990, AT-994 |
| FR-368 ODS Supplement Evidence Adapter | AT-990, AT-995 |
| FR-369 Safety Knowledge Rule Lifecycle | AT-997 |
| FR-370 Safety Rule Provenance | AT-996, AT-1007 |
| FR-371 Interaction Type Taxonomy | AT-1002 |
| FR-372 Action Category Boundary | AT-996 |
| FR-373 Applicability Context | AT-983, AT-998, AT-1003 |
| FR-374 Insufficient Context State | AT-998, AT-1006 |
| FR-375 Duplicate Ingredient Detection | AT-984 |
| FR-376 Duplicate Ingredient Is Not Toxicity Claim | AT-985 |
| FR-377 Unit-compatible Ingredient Aggregation | AT-986, AT-987 |
| FR-378 Unknown Proprietary Blend Amount | AT-982 |
| FR-379 Medication Safety Fixture Pack | AT-1001, AT-1008 |
| FR-380 No-match Wording Safety | AT-999 |
| FR-381 Safety Pack Freshness | AT-1000 |
| FR-382 Medication Knowledge API | AT-1013–AT-1015 |
| FR-383 Safety Review API | AT-1016 |
| FR-384 Site Medication Safety Lab | AT-1017 |
| FR-385 Medication Claim Boundary | AT-999 |

| FR-386 Preventive v0.23 requirement | AT-1018 |
| FR-387 Preventive v0.23 requirement | AT-1019, AT-1020 |
| FR-388 Preventive v0.23 requirement | AT-1020 |
| FR-389 Preventive v0.23 requirement | AT-1021, AT-1045, AT-1047 |
| FR-390 Preventive v0.23 requirement | AT-1022, AT-1055 |
| FR-391 Preventive v0.23 requirement | AT-1023, AT-1028 |
| FR-392 Preventive v0.23 requirement | AT-1031, AT-1032, AT-1033 |
| FR-393 Preventive v0.23 requirement | AT-1023, AT-1024, AT-1025, AT-1026, AT-1027, AT-1037, AT-1038, AT-1039 |
| FR-394 Preventive v0.23 requirement | AT-1027 |
| FR-395 Preventive v0.23 requirement | AT-1023, AT-1024, AT-1025, AT-1026 |
| FR-396 Preventive v0.23 requirement | AT-1031, AT-1063 |
| FR-397 Preventive v0.23 requirement | AT-1032 |
| FR-398 Preventive v0.23 requirement | AT-1033, AT-1034 |
| FR-399 Preventive v0.23 requirement | AT-1037, AT-1038, AT-1039 |
| FR-400 Preventive v0.23 requirement | AT-1040 |
| FR-401 Preventive v0.23 requirement | AT-1047 |
| FR-402 Preventive v0.23 requirement | AT-1048 |
| FR-403 Preventive v0.23 requirement | AT-1048 |
| FR-404 Preventive v0.23 requirement | AT-1047 |
| FR-405 Preventive v0.23 requirement | AT-1018, AT-1047 |
| FR-406 Preventive v0.23 requirement | AT-1035, AT-1036 |
| FR-407 Preventive v0.23 requirement | AT-1047 |
| FR-408 Preventive v0.23 requirement | AT-1056 |
| FR-409 Preventive v0.23 requirement | AT-1053 |
| FR-410 Preventive v0.23 requirement | AT-1041, AT-1042, AT-1046 |
| FR-411 Preventive v0.23 requirement | AT-1043 |
| FR-412 Preventive v0.23 requirement | AT-1044 |
| FR-413 Preventive v0.23 requirement | AT-1045 |
| FR-414 Preventive v0.23 requirement | AT-1021, AT-1046 |
| FR-415 Preventive v0.23 requirement | AT-1051, AT-1055 |
| FR-416 Preventive v0.23 requirement | AT-1052, AT-1056 |
| FR-417 Preventive v0.23 requirement | AT-1041, AT-1042, AT-1053 |
| FR-418 Preventive v0.23 requirement | AT-1054 |
| FR-419 Preventive v0.23 requirement | AT-1058, AT-1059, AT-1060, AT-1061, AT-1062 |
| FR-420 Preventive v0.23 requirement | AT-1063 |

## v0.24 lab governance + identifier integrity

| Requirement | Canonical acceptance evidence |
|---|---|
| FR-421 | AT-1064, AT-1065, AT-1066, AT-1088 |
| FR-422 | AT-1090 |
| FR-423 | AT-1089, AT-1090 |
| FR-424 | AT-1067, AT-1068, AT-1069 |
| FR-425 | AT-1070, AT-1096 |
| FR-426 | AT-1071 |
| FR-427 | AT-1074 |
| FR-428 | AT-1075 |
| FR-429 | AT-1074 |
| FR-430 | AT-1076, AT-1077, AT-1079 |
| FR-431 | AT-1076, AT-1077 |
| FR-432 | AT-1078 |
| FR-433 | AT-1079 |
| FR-434 | AT-1080 |
| FR-435 | AT-1081 |
| FR-436 | AT-1082, AT-1083, AT-1084 |
| FR-437 | AT-1082 |
| FR-438 | AT-1085 |
| FR-439 | AT-1086 |
| FR-440 | AT-1087 |
| FR-441 | AT-1091 |
| FR-442 | AT-1092 |
| FR-443 | AT-1093 |
| FR-444 | AT-1088 |
| FR-445 | AT-1073 |
| FR-446 | AT-1064, AT-1068, AT-1077, AT-1083, AT-1101 |
| FR-447 | AT-1094 |
| FR-448 | AT-1095, AT-1096 |
| FR-449 | AT-1097 |
| FR-450 | AT-1098, AT-1099, AT-1100, AT-1101 |
| FR-451 | AT-1102 |
| FR-452 | AT-1103, AT-1104, AT-1105, AT-1106 |
| FR-453 | AT-1107 |
| FR-454 | AT-1108 |
| FR-455 | AT-1103, AT-1104, AT-1105, AT-1106, AT-1108 |


---

<!-- SOURCE: 26_RELEASE_GATES_AND_DEFINITION_OF_DONE.md -->

# RELEASE GATES AND DEFINITION OF DONE

A feature is not complete merely because its UI exists.

## Gate G0 — Specification

PASS requires:
- requirement identified,
- source-of-truth file identified,
- acceptance criterion defined,
- unresolved product ambiguity documented.

## Gate G1 — Code

PASS requires:
- implementation committed/generated,
- build graph resolves in a valid toolchain,
- no placeholder path masquerades as implementation.

## Gate G2 — Static checks

PASS requires, where applicable:
- formatter,
- linter/analyzer,
- type checking,
- schema validation,
- migration syntax validation.

## Gate G3 — Automated tests

PASS requires:
- relevant unit tests,
- database tests,
- API tests,
- widget/component tests where appropriate,
- no known blocking failing tests hidden from report.

## Gate G4 — Integration

PASS requires:
- client ↔ backend path works,
- persistence round trip works,
- authorization is enforced,
- timeline/source linking works where relevant.

## Gate G5 — Platform build

### Android
- release APK build succeeds,
- AAB build succeeds.

### iOS
- build succeeds in supported Xcode/macOS environment when available.

### Web
- production web build succeeds.

Each platform is reported independently.

## Gate G6 — Runtime smoke

Examples:
- launch,
- login,
- create/edit/read representative records,
- restart and verify persistence,
- sync if applicable.

A simulator/emulator run is labeled as such.
A real-device run is separately labeled.

## Gate G7 — Data integrity

PASS requires:
- migration tests,
- correction semantics,
- missing-value semantics,
- unit semantics,
- idempotent retry tests,
- cross-user isolation tests.

## Gate G8 — Security/privacy review

PASS requires at least:
- ownership/authorization tests,
- secret scan,
- environment config review,
- transport/deployment config review,
- log review for sensitive-data leakage,
- deletion/export checks.

This is not automatically equivalent to regulatory compliance.

## Gate G9 — Release package

PASS requires:
- repository,
- lockfiles,
- environment template,
- migrations,
- API docs,
- test report,
- build artifacts that actually exist,
- build/deploy instructions,
- known limitations,
- checksums where packages are delivered.

## Final Definition of Done

A release may be called production-ready only when all release-required gates are PASS for the intended deployment.

If iOS signing credentials are unavailable, the report may say:
“iOS source/build configuration complete; TestFlight upload BLOCKED by credentials.”

It may not say:
“iOS deployed.”

## Evidence labels

Use exactly or equivalently clear states:

- NOT_STARTED
- SPECIFIED
- CODED
- STATICALLY_CHECKED
- TESTED
- BUILT
- INSTALLED
- BEHAVIORALLY_VALIDATED
- DEPLOYED
- BLOCKED

A higher label implies real evidence for lower required stages, not a guess.


---

<!-- SOURCE: 27_IMPLEMENTATION_CHECKLIST.md -->

# IMPLEMENTATION CHECKLIST

This is a high-level runbook for the future implementing agent.

## Repository
- [ ] Read every handoff file.
- [ ] Record actual toolchain versions.
- [ ] Create repository structure.
- [ ] Add formatter/linter/type checks.
- [ ] Add CI or reproducible local check command.
- [ ] Add `.env.example`.
- [ ] Ensure secrets are ignored.

## Backend
- [ ] Authentication.
- [ ] User ownership authorization.
- [ ] Relational schema.
- [ ] Migrations.
- [ ] Timeline.
- [ ] Labs.
- [ ] Conditions.
- [ ] Symptoms.
- [ ] Mind.
- [ ] Food.
- [ ] Medication/intake.
- [ ] Vitals.
- [ ] Sleep.
- [ ] Activity.
- [ ] Export.
- [ ] Sync change feed.
- [ ] OpenAPI.
- [ ] Backend tests.

## Mobile
- [ ] Android host.
- [ ] iOS host.
- [ ] local database.
- [ ] outbox.
- [ ] authentication/session.
- [ ] Today.
- [ ] Timeline.
- [ ] Labs.
- [ ] Mind.
- [ ] Conditions.
- [ ] Symptoms.
- [ ] Nutrition.
- [ ] Medication/intake.
- [ ] Vitals.
- [ ] Sleep/activity.
- [ ] Settings/export.
- [ ] offline tests.
- [ ] sync tests.

## Web
- [ ] authentication.
- [ ] responsive shell.
- [ ] Today/dashboard.
- [ ] Timeline.
- [ ] Labs/trends.
- [ ] Nutrition.
- [ ] health modules.
- [ ] settings/export.
- [ ] accessibility keyboard pass.
- [ ] production build.

## Food
- [ ] provider interface.
- [ ] current provider docs verified.
- [ ] provider attribution/licensing obligations recorded.
- [ ] search.
- [ ] barcode.
- [ ] normalization.
- [ ] immutable snapshot.
- [ ] missing != zero tests.
- [ ] quantity/unit tests.
- [ ] provider error behavior.

## Data integrity
- [ ] stable UUID strategy.
- [ ] correction relationships.
- [ ] revision/conflict model.
- [ ] deletion tombstones.
- [ ] migration tests.
- [ ] backup/restore test.
- [ ] timezone tests.
- [ ] unit compatibility tests.

## Security
- [ ] cross-user authorization tests.
- [ ] token/session storage review.
- [ ] secret scan.
- [ ] sensitive log review.
- [ ] attachment access review if attachments implemented.
- [ ] rate-limit/abuse controls.
- [ ] deletion/export authorization.

## Release
- [ ] Android APK.
- [ ] Android AAB.
- [ ] Android smoke test.
- [ ] iOS build or exact blocker.
- [ ] TestFlight setup or exact blocker.
- [ ] web production build.
- [ ] deployment docs.
- [ ] test report.
- [ ] checksum/package manifest.
- [ ] final known-limitations list.


## Universal health / advanced
- [ ] Universal HealthFact
- [ ] Vaccination events
- [ ] Procedures and treatment courses
- [ ] Oncology treatment events
- [ ] HealthProduct / ProductUseEvent
- [ ] Health Modules settings
- [ ] Model Registry / ScoreResult
- [ ] Population life-table / HALE adapters
- [ ] Validated model eligibility checks
- [ ] App composite coverage/confidence
- [ ] Results/Longevity dashboard
- [ ] Historical score reproducibility
- [ ] Lifespan fake-precision guard


## Comparison / deterministic offline core
- [ ] ComparisonProfile.
- [ ] Scenario clone.
- [ ] N-profile comparison UI.
- [ ] Baseline/delta calculations.
- [ ] Safe settings reset.
- [ ] Per-module reset.
- [ ] Daily Missions engine.
- [ ] Training progression rule pack.
- [ ] Mission safety gate.
- [ ] Offline education packs.
- [ ] Offline quizzes/review scheduling.
- [ ] Contextual education triggers.
- [ ] Android Health Connect adapter.
- [ ] Apple HealthKit adapter.
- [ ] Wearable provenance.
- [ ] Wearable deduplication.
- [ ] Network-offline acceptance pass.
- [ ] Confirm no required LLM endpoint.

## Longevity ↔ Shortevity / Human OS
- [ ] Protection Score.
- [ ] Burden Score.
- [ ] Function/Capacity channel.
- [ ] Balance visualization with safety label.
- [ ] Trajectory engine.
- [ ] Cumulative exposure engine.
- [ ] Causal/evidence graph.
- [ ] Treatment-burden tracking.
- [ ] Early-warning rule engine.
- [ ] State/event/decision continuity.
- [ ] Correction propagation.
- [ ] Effective-date policies.
- [ ] Dependency invalidation/recalculation.
- [ ] Decision Memory.
- [ ] Failure Memory.
- [ ] Human OS donor transfer map.
- [ ] Recovery-aware mission orchestration.
- [ ] Verify no donor private state leakage.


## Life course / health OS maturity
- [ ] Whole-life timeline.
- [ ] EpisodeOfCare.
- [ ] Biological-age Model Registry support.
- [ ] Multiple-clock comparison.
- [ ] Function/capacity records.
- [ ] Quality-of-life instruments.
- [ ] Pain tracking.
- [ ] Rehab plan vs session.
- [ ] Multimorbidity view.
- [ ] Medication/supplement interaction graph.
- [ ] Environmental exposure records.
- [ ] Optional social-context records.
- [ ] Clinical code/CodedConcept support.
- [ ] Interoperability adapter layer.
- [ ] Source-preserving unit normalization.
- [ ] Deterministic TwinSnapshot.
- [ ] ScenarioPatch.
- [ ] Scenario evidence labels.
- [ ] PersonalBaseline.
- [ ] Anomaly rules.
- [ ] ForecastResult.
- [ ] Full-state export.
- [ ] Restore/merge/deduplication tests.


## Data trust / governance
- [ ] DataQualityProfile.
- [ ] Missingness taxonomy.
- [ ] Provenance drilldown.
- [ ] Source precision preservation.
- [ ] Canonical UCUM-compatible unit codes.
- [ ] Safe conversion registry.
- [ ] MeasurementDevice and MeasurementSession.
- [ ] Model Registry and eligibility gates.
- [ ] Golden model fixtures.
- [ ] Model retirement handling.
- [ ] RulePack precedence and conflict behavior.
- [ ] ReferenceDataset/applicability.
- [ ] ConsentRecord and AuditEvent.
- [ ] Local-only profile.
- [ ] PersonalExperiment.
- [ ] Import staging, receipts and rollback.
- [ ] Pack manifests/checksums/rollback.
- [ ] Dense time-series aggregates.
- [ ] Standards source re-verification.


## Production shell
- [ ] Android Keystore-backed key strategy.
- [ ] Apple Keychain-backed secret strategy.
- [ ] Local database encryption strategy.
- [ ] App lock.
- [ ] Session/device registry.
- [ ] Revoke sessions/devices.
- [ ] Local-only→cloud migration.
- [ ] Reminder scheduler.
- [ ] Reminder/completion separation.
- [ ] Timezone semantics.
- [ ] Notification permission states.
- [ ] WCAG 2.2 AA web checklist.
- [ ] Screen-reader mobile smoke.
- [ ] Text scaling.
- [ ] Reduced motion.
- [ ] Aging-friendly display preset.
- [ ] Turkish localization.
- [ ] English localization.
- [ ] Clinician report generator.
- [ ] Controlled sharing.
- [ ] Privacy-minimized crash telemetry.
- [ ] Transactional crash recovery.
- [ ] Startup integrity recovery.
- [ ] Sanitized support bundle.
- [ ] Safe mode.
- [ ] Environment separation.
- [ ] ReleaseRecord.
- [ ] MASVS mapping.
- [ ] Secret scan.
- [ ] Claim Registry.


## Implementation blueprint
- [ ] Reference architecture frozen/documented.
- [ ] Normative vs reference boundary documented.
- [ ] Screen-state machines implemented.
- [ ] Stable timeline tie-break ordering.
- [ ] Migration fixture harness.
- [ ] Correction migration fixture.
- [ ] Food snapshot migration fixture.
- [ ] Tombstone migration fixture.
- [ ] Canonical API error codes.
- [ ] Cursor pagination.
- [ ] Idempotency handling.
- [ ] Revision conflict handling.
- [ ] Synthetic data generator.
- [ ] Seeded golden dataset.
- [ ] Failure injection.
- [ ] Performance benchmark harness.
- [ ] 10k timeline fixture.
- [ ] 1M dense-series fixture.
- [ ] 20-profile compare fixture.
- [ ] E2E reference scenarios.
- [ ] CI test pyramid.
- [ ] Flaky test registry.
- [ ] Machine-readable test evidence.
- [ ] No-mock-completion audit.


## Component/module contracts
- [ ] UI component contract registry.
- [ ] Typed ResultCard hierarchy.
- [ ] Provenance drilldown.
- [ ] ConflictResolver.
- [ ] Canonical entity ownership map.
- [ ] Dependency invalidation graph.

## Bootstrap/contracts
- [ ] Workspace bootstrap script/commands.
- [ ] Client/API/database runnable shells.
- [ ] First MindCheckin vertical slice.
- [ ] Generated OpenAPI reproducibility check.
- [ ] Breaking-contract diff.
- [ ] Resource validation schemas.

## Fixtures / recovery / chaos
- [ ] Named fixture catalog.
- [ ] Golden fixture reproducibility.
- [ ] Fuzz seed capture.
- [ ] DR-01..DR-10 drill harness.
- [ ] Restore relationship verification.
- [ ] Sync chaos simulator.
- [ ] Stable error catalog.
- [ ] Release artifact layout verifier.


## Domain completion / release dossier
- [ ] Domain API catalog implemented.
- [ ] CRUD ownership matrix enforced.
- [ ] Stable date-range/cursor/sort behavior.
- [ ] Search projection correction/deletion propagation.
- [ ] JSON/CSV export semantics.
- [ ] Compact layout.
- [ ] Medium layout.
- [ ] Expanded layout.
- [ ] Aging-friendly density.
- [ ] Retention/deletion matrix.
- [ ] Account deletion state machine.
- [ ] Tombstone stale-resurrection protection.
- [ ] Domain event envelope/catalog.
- [ ] Idempotent event consumers.
- [ ] Derived projection rebuild.
- [ ] Capability degradation matrix.
- [ ] Production acceptance dossier.
- [ ] Release evidence schema.
- [ ] Platform-scoped signoff states.


## Interactive Site Lab
- [ ] Read Site Build Prompt.
- [ ] Use synthetic default data.
- [ ] Build functional profile controls.
- [ ] Build deterministic live result updates.
- [ ] Build Compare Lab with 3+ profiles.
- [ ] Preserve scenario/source isolation.
- [ ] Build Reset Demo to Defaults.
- [ ] Build How calculated? transparency.
- [ ] Verify no LLM requirement.
- [ ] Verify mobile + desktop layout.
- [ ] Verify keyboard accessibility.
- [ ] Produce source + lockfile + run/build instructions.
- [ ] Publish only when real publishing evidence exists.


## Starter packs / executable schemas
- [ ] MP-CORE-DERIVED-1 implemented.
- [ ] MP-CORE-DERIVED-1 golden fixtures.
- [ ] RP-CORE-INVARIANTS-1 implemented.
- [ ] Rule ID/version explanation.
- [ ] REF-SYNTHETIC-DEMO-1 bundled.
- [ ] WHO reference attribution path.
- [ ] USDA FDC provider secret server-side.
- [ ] Open Food Facts license/attribution surface.
- [ ] UCUM license notice scope reviewed.
- [ ] FHIR third-party terminology firewall.
- [ ] AHA PREVENT license gate.
- [ ] EDU-HEALTH-LITERACY-FOUNDATION-1.
- [ ] Data Sources & Licenses screen.
- [ ] starter_schemas validation.
- [ ] pack activation fixture runner.
- [ ] Site starter-pack integration.


## Golden vectors / database kernel / help
- [ ] CORE_DERIVED production runner passes v0.17 golden vectors.
- [ ] Invalid-vector error codes pass.
- [ ] SQLite schema migration executes with FK enforcement.
- [ ] PostgreSQL schema migration executes in real PostgreSQL test environment.
- [ ] Lab PRESENT/missing constraints.
- [ ] Outbox mutation unique constraint.
- [ ] Pack ID/version unique constraint.
- [ ] Idempotent synthetic seed.
- [ ] No real-user health defaults seeded.
- [ ] Canonical data dictionary used in generated types/docs.
- [ ] Zero-knowledge onboarding.
- [ ] Results-literacy help.
- [ ] NOT_ELIGIBLE help.
- [ ] Clinician/export examples mirrored by tests.
- [ ] Attribution manifest renderer.
- [ ] Transactional invalidation/stale-result flow.


## Migration / authorization / interoperability / repo
- [ ] Migration framework maps 0001–0004 semantics.
- [ ] Fresh SQLite migration test.
- [ ] SQLite upgrade-preservation test.
- [ ] PostgreSQL migration test environment.
- [ ] Distinct PostgreSQL runtime vs migration roles.
- [ ] Trusted authenticated user context.
- [ ] Application authorization owner checks.
- [ ] PostgreSQL RLS policies.
- [ ] Connection-pool RLS context-isolation tests.
- [ ] Cross-user guessed-ID tests.
- [ ] Repository scaffold converted to real workspace.
- [ ] Contract verification runner in CI.
- [ ] FHIR adapter.
- [ ] FHIR validator in CI/integration.
- [ ] Terminology/license review.
- [ ] Missing-value FHIR mapping tests.


## OpenAPI / rollback / UI / delivery
- [ ] OpenAPI generated/validated in CI.
- [ ] OperationId → authorization-policy mapping complete.
- [ ] Idempotency middleware/storage.
- [ ] Revision/ETag conflict path.
- [ ] Stable API error catalog.
- [ ] Request/correlation ID.
- [ ] SQLite rollback drill.
- [ ] PostgreSQL rollback drill.
- [ ] UI token package.
- [ ] Component state matrix.
- [ ] Missing-not-zero UI tests.
- [ ] Result-class UI tests.
- [ ] Chart missing-gap tests.
- [ ] Conflict resolver transparency.
- [ ] Delivery-readiness checker.


## Health platform / nutrition / API coverage
- [ ] Health Connect availability/permission adapter.
- [ ] Health Connect background/history capability checks.
- [ ] Health Connect recording-method provenance.
- [ ] HealthKit availability/capability.
- [ ] HealthKit fine-grained permission requests.
- [ ] HealthKit limited/unknown read scope handling.
- [ ] Provider stable-ID import idempotency.
- [ ] Write-back echo prevention.
- [ ] Steps/sleep overlap policy.
- [ ] Nutrition mass-scaling engine.
- [ ] Recipe totals/serving/final-mass math.
- [ ] Missing nutrient coverage.
- [ ] Density-gated volume conversion.
- [ ] Recipe version immutability.
- [ ] Nutrition golden-vector CI.
- [ ] Health-adapter fixture CI.
- [ ] Expanded domain OpenAPI coverage.


## Documents / attachments / extraction
- [ ] Attachment + AttachmentVersion repository.
- [ ] Private cloud object storage.
- [ ] Upload session + idempotent completion.
- [ ] Content hash/size verification.
- [ ] MIME/content detection.
- [ ] Quarantine/security scan path.
- [ ] Local-only document path.
- [ ] Thumbnail derivative privacy.
- [ ] EXIF/share metadata policy.
- [ ] LabExtractionCandidate staging.
- [ ] Mapping state UNMAPPED/AMBIGUOUS support.
- [ ] Review/commit receipt.
- [ ] Partial candidate commit.
- [ ] Attachment links to canonical entities.
- [ ] Delete source vs delete facts UX.
- [ ] Document API authorization tests.
- [ ] Parser fixture validator.
- [ ] Synthetic Site document demo.


## Medication / supplement / safety knowledge
- [ ] ProductConcept / IngredientConcept normalization.
- [ ] MedicationPlan vs IntakeEvent separation.
- [ ] Supplement multi-ingredient composition.
- [ ] Historical ingredient snapshots.
- [ ] Planned vs observed exposure.
- [ ] Duplicate ingredient detector.
- [ ] Unit/amount-basis compatibility.
- [ ] RxNorm adapter + attribution/version.
- [ ] DailyMed versioned SPL adapter.
- [ ] openFDA label evidence adapter.
- [ ] DSLD supplement label adapter.
- [ ] ODS fact-sheet evidence references.
- [ ] Interaction rule lifecycle.
- [ ] InteractionAssessment provenance.
- [ ] Safety pack freshness handling.
- [ ] No-match wording safety.
- [ ] Medication safety fixture CI.
- [ ] Medication Safety Site Lab.


## Preventive care
- [ ] Explicit guideline jurisdiction selection.
- [ ] No silent U.S. fallback.
- [ ] Preventive service vs rule separation.
- [ ] Eligibility/recommendation/due dimensions.
- [ ] Unknown-history state.
- [ ] Interval due engine.
- [ ] Vaccine dose validity/minimum intervals.
- [ ] Catch-up and series completion rules.
- [ ] Evidence-of-immunity source logic.
- [ ] Screening method variants.
- [ ] Relevant-anatomy inputs.
- [ ] Prior-abnormal follow-up pathway.
- [ ] Shared-decision UI.
- [ ] Evidence-insufficient UI.
- [ ] Guideline source snapshots/current status.
- [ ] Refresh/diff/conflict workflow.
- [ ] Preventive API.
- [ ] Preventive missions/reminders.
- [ ] Preventive fixture CI.
- [ ] Synthetic Site Preventive Care Lab.


---

<!-- SOURCE: 28_UNIVERSAL_HEALTH_INPUT_ENGINE.md -->

# UNIVERSAL HEALTH INPUT ENGINE

## Root interaction model

The root behavior of Longevity App is:

**ENTER / SELECT / WRITE → STRUCTURE → TIME-STAMP → STORE → CALCULATE → SHOW RESULT**

A user may enter a narrow fact such as a vaccine date, chemotherapy cycle, height, weight, skin type, cancer diagnosis, resting heart rate, cream use, medicine or supplement. The app maps each narrow fact into a broader health domain while preserving its original meaning.

The product must not require every future fact to have been predicted as a dedicated screen.

## Universal HealthFact / HealthEvent

Use an extensible envelope for health facts that do not yet need a dedicated entity. Fields can include:

- id, user_id
- domain, category, subtype, title, status
- value_type plus numeric/text/boolean/coded/structured value
- unit when applicable
- effective_at or start_at, optional end_at
- recorded_at
- source_type/source_name/source_record_id
- tags, notes, attachments
- corrects_id, deleted_at, created_at, updated_at

Use specialized entities when the domain needs specialized validation or mathematics. HealthFact is an extensibility layer, not an excuse to flatten everything.

## Input types

Support number, text, note, yes/no, single choice, multi-choice, date, date/time, date range, duration, quantity+unit, percentage, rating scale, structured fields and attachments.

## Provenance

Important facts can identify their source: manual entry, clinician/report, laboratory, pharmacy, wearable/device, imported document, external API or derived calculation. Derived data must never masquerade as measured data.

## Universal add flow

1. `+ Add`
2. search or choose broad health domain
3. choose record type
4. fill relevant fields
5. set date/time
6. optionally attach source/document
7. save
8. show which timeline, score or risk module uses the record

Examples:
- `+ Add → Preventive Care → Vaccination → Vaccine → Date → Save`
- `+ Add → Oncology → Treatment → Chemotherapy → Cycle/Date → Save`
- `+ Add → Dermatology → Skin Profile → Skin Type/Sensitivity → Save`

## Editing/removal

Users can correct, end/deactivate, archive and delete according to data policy. Historical facts should not be silently rewritten when correction provenance matters.


---

<!-- SOURCE: 29_HEALTH_DOMAIN_TAXONOMY.md -->

# HEALTH DOMAIN TAXONOMY

The user's narrow examples are members of broader domains. This taxonomy is for navigation, extensibility, advanced-module activation and scoring. It is not itself a diagnostic coding system.

## Core / General

- Identity & demographic context
- Anthropometrics & body composition
- Vitals
- Laboratory / biomarkers
- Diagnoses / conditions
- Symptoms
- Medications
- Supplements
- Vaccination / immunization
- Procedures / interventions
- Preventive care / screening
- Allergies / intolerances / reactions

## Lifestyle / Healthspan

- Nutrition and hydration
- Exercise / fitness / physical function
- Sleep
- Substance exposure
- Psychological / mental wellbeing
- Social / functional health
- Environmental / occupational exposure

## Advanced clinical domains

### Cardiovascular / vascular
Coronary disease, stroke/TIA, heart failure, arrhythmia, valvular disease, peripheral arterial disease, blood pressure, lipids, ECG/echo/imaging metadata, coronary calcium, procedures and validated cardiovascular risk models.

### Oncology
Cancer type, pathology, stage, grade, biomarkers, diagnosis date, remission/recurrence state, surgery, chemotherapy, immunotherapy, targeted therapy, hormone therapy, radiation, cycles, adverse effects and cancer-specific models when validated.

### Endocrine / metabolic
Diabetes, glucose/HbA1c, thyroid, adrenal/pituitary, metabolic syndrome and metabolic parameters.

### Renal / urinary
Kidney function, eGFR, creatinine, albuminuria/UACR, CKD, dialysis and urinary conditions.

### Gastrointestinal / hepatic
Liver, fibrosis/cirrhosis, stomach/intestine, gallbladder, inflammatory bowel conditions, malabsorption-related records and procedures.

### Respiratory
Asthma, COPD, lung function, sleep-related breathing disorders, respiratory symptoms and oxygen therapy.

### Neurology / cognition
Neurological diagnoses, headaches, seizures, cognition, memory testing, neuroimaging metadata and neurodegenerative conditions.

### Dermatology / skin
Skin type, sensitivity, acne, rosacea, eczema/dermatitis, psoriasis, lesions, topical products, creams, medications, UV exposure, procedures, photos and validated melanoma/skin-cancer tools where applicable.

### Musculoskeletal / orthopedic
Pain, injuries, fractures, bone density, arthritis, mobility, strength, surgery and rehabilitation.

### Rheumatology / autoimmune
Autoimmune diagnoses, inflammatory markers, flares and immunomodulatory treatment.

### Immunology / infectious disease
Infections, immune deficiencies, serology, vaccines, antimicrobial treatment and exposure events.

### Oral / dental
Periodontal status, caries, tooth loss, procedures, hygiene and dental visits.

### Ophthalmology
Visual acuity, refraction, retinal conditions, glaucoma and procedures.

### ENT / hearing
Hearing, tinnitus, vestibular, sinus/nasal/throat conditions.

### Reproductive / sexual health
Reproductive history, fertility, contraception, pregnancy history where applicable, screening and procedures.

### Genetics / family history
Family history by relative/condition and validated genetic/genomic findings with provenance/privacy.

### Geriatric / frailty / function
Frailty instruments, falls, gait speed, grip strength, activities of daily living, cognition/function and care dependency.

## Special data classes

- Treatment timelines: chemotherapy, radiotherapy, infusion, surgery, rehab and procedures
- Device/wearable: watches, BP devices, glucose monitors, scales, sleep sensors
- Documents/imaging: lab PDFs, pathology, imaging, prescriptions, vaccine records, discharge summaries, photos

## Design rule

The database can support the full taxonomy while the default UI remains simple. Users only see advanced depth they enable.


---

<!-- SOURCE: 30_ADVANCED_HEALTH_MODULES_AND_SETTINGS.md -->

# ADVANCED HEALTH MODULES AND SETTINGS

## Product metaphor

Advanced modules work like graphics settings in a sophisticated game: a simple default mode, optional advanced modules and an Expert/Research view.

## Health Complexity Mode

### BASIC
Default visible areas: Today, Timeline, Mind, Nutrition, Labs, basic conditions/symptoms, medication/supplements, vaccination, vitals, sleep, activity and basic longevity results.

### ADVANCED
Users can individually enable specialist modules:
- Cardiovascular / Vascular
- Oncology
- Endocrine / Metabolic
- Renal
- Gastrointestinal / Hepatic
- Respiratory
- Neurology / Cognition
- Dermatology / Skin
- Musculoskeletal
- Rheumatology / Autoimmune
- Immunology / Infectious Disease
- Oral / Dental
- Ophthalmology
- ENT / Hearing
- Reproductive / Sexual Health
- Genetics / Family History
- Geriatric / Frailty / Function
- Environmental / Occupational Exposure

### EXPERT / RESEARCH VIEW
May expose raw model inputs, eligibility, formula/version, confidence/coverage, provenance, curves, scenario assumptions and raw trends. Expert mode does not remove safety labels.

## Module behavior

Enabling a module adds deeper forms, domain dashboards, applicable calculators, timeline filters and reports.

Disabling a module hides specialist UI but does NOT delete records, erase timeline history or silently remove relevant data from explicitly requested validated calculations.

## Cardiovascular Advanced
May collect blood pressure, lipids, smoking, diabetes, BMI, eGFR, UACR, HbA1c, known CVD, coronary calcium, ECG/echo and vascular procedures. The app only runs a risk model when its eligibility rules are met.

## Oncology Advanced
May collect cancer type, diagnosis date, stage/grade, pathology, biomarkers, regimen, chemotherapy cycles, surgery, radiation, immunotherapy, recurrence/remission and adverse effects. There is no universal validated “cancer score”.

## Dermatology Advanced
May collect skin type, sensitivity, diagnoses, symptoms, topical products, creams, medications, procedures, UV exposure and photo timeline. Skin-domain results must not automatically change lifespan.

## Settings screen

`Settings → Health Modules`

Each module card can show: Off / Basic / Advanced, explanation, calculators available, stored-data indicator and privacy note.


---

<!-- SOURCE: 31_SCORING_LONGEVITY_AND_MATH_ENGINE.md -->

# SCORING, LONGEVITY AND MATHEMATICAL ENGINE

## Goal

Turn entered data into useful mathematics without fake precision. The app supports multiple result classes instead of collapsing all health into one unexplained number.

## Result classes

### R1 Population baseline
Population remaining life expectancy and population healthy life expectancy (HALE). These are not personalized guarantees.

### R2 Validated clinical risk model
A documented cardiovascular, cancer-specific, frailty or other validated model. Preserve its native output such as probability, horizon or score.

### R3 App Composite Domain Score
Transparent 0–100 app-defined summary, e.g. Sleep, Fitness, Skin, Preventive Care, Cardiometabolic Healthspan. Not automatically a diagnosis or probability.

### R4 Data Coverage / Confidence
How complete, recent and applicable the inputs are.

### R5 Adherence / behavior
Examples: medication adherence, preventive-care completion, training adherence.

### R6 Derived measurement
BMI, rolling average, change from baseline, slope, etc.

### R7 Experimental/research model
Any non-validated personalized lifespan/healthspan model. Must be clearly labeled and non-authoritative by default.

## Global Longevity Results

Show separately:
- chronological age when provided,
- population baseline remaining life expectancy,
- population HALE where available,
- applicable validated disease-specific risks,
- App Healthspan Composite,
- data coverage/confidence,
- personalized lifespan only when an applicable validated/calibrated survival model exists, otherwise no invented age-at-death.

### Population baseline
Conceptually:
`Baseline expected age = current age + e_x`
where `e_x` is remaining life expectancy from the selected life table.

Store source, geography, sex dimension if used, table year, age and version/retrieval date.

## Domain score is not lifespan

A skin cream may improve skin symptoms or skin-domain outcomes but does not justify `+ years`.
A vaccine may improve prevention status but does not justify arbitrary lifespan years.
Chemotherapy is an oncology treatment event and only feeds a prognosis model if the model actually accepts the relevant disease/treatment inputs.

**Domain score change ≠ lifespan change.**

## App Composite Domain Score

For component `i`:
- normalized score `s_i` in [0,100]
- importance weight `w_i`
- data-quality factor `q_i` in [0,1]

Possible default:
`DomainScore = Σ(w_i × q_i × s_i) / Σ(w_i × q_i)`

Coverage:
`Coverage = Σ(w_i for available eligible components) / Σ(w_i for all eligible components)`

Quality:
`Quality = Σ(w_i × q_i) / Σ(w_i for available components)`

Always display coverage and confidence beside an app composite.

## Normalization functions

Each component declares one method:
- higher-is-better,
- lower-is-better,
- target band,
- categorical mapping,
- binary/graded completion,
- published validated instrument.

Targets/cutoffs are sourced and versioned. Validated instruments use their published scoring rather than being silently remapped.

## Confidence

Possible labels: INSUFFICIENT_DATA, LOW, MODERATE, HIGH.
Consider coverage, recency, source quality, model validation and population applicability.

## Cardiovascular Advanced mathematics

Use validated cardiovascular models when eligible rather than inventing a risk probability. A model adapter declares source, version/license, eligibility, required variables, exclusions, horizons and outputs.

AHA PREVENT is an example adapter candidate. It remains separate from any App Cardiovascular Domain Score.

## Oncology Advanced mathematics

There is no universal cancer-risk equation. Maintain a model registry keyed by cancer type, population, purpose and eligibility. Keep incidence risk, recurrence risk, treatment response, cancer-specific survival and overall survival distinct.

## Life expectancy mathematics

For a survival function `S(t)`:
`E[T_remaining] = ∫ S(t) dt`

Official life tables already provide standard remaining-life quantities and should be used directly where appropriate.

If a validated personalized all-cause survival model yields `S_personal(t)`:
`Expected remaining years = ∫ S_personal(t) dt`
`Expected age = current age + expected remaining years`

Include calibration/uncertainty limits.

### Experimental hazard model
A research mode could use:
`h_personal(t) = h_0(t) × exp(β1x1 + ... + βkxk)`
`S_personal(t) = exp(-∫h_personal(u)du)`

Do NOT build authoritative lifespan by combining unrelated literature relative risks. Before production use require coherent derivation, calibration, validation, uncertainty and competing-risk handling where needed.

## Healthspan

Healthspan is not lifespan.

Show:
- population HALE baseline,
- App Healthspan Composite,
- disease-free/disability-free projections only when a model is designed for that endpoint.

Possible composite domains: cardiovascular/metabolic, physical function, sleep, mental wellbeing, cognition, mobility/musculoskeletal, disease burden, prevention and lifestyle.

## Intervention scenarios

“What-if” scenarios may recompute validated models according to their intended use. Treatment benefit must not be estimated merely by changing a biomarker unless the evidence/model supports that interpretation.

## Versioning

Every result stores:
- model_id, model_version, model_type
- calculated_at
- eligible
- input_record_ids
- source_reference
- population_scope
- output
- uncertainty
- coverage
- limitations

A score without a model version is not reproducible.

# 13. SHORTEVITY / BURDEN CHANNEL

The app may calculate app-defined burden and protection scores as described in `41_RISK_BURDEN_RESILIENCE_MATH.md`.

These remain distinct from validated mortality risk, survival probability, life expectancy and HALE.

Never convert `BurdenScore → years lost` without an explicit applicable validated survival model.

# 14. BALANCE INDEX

Optional visualization: `BalanceIndex = ProtectionScore - BurdenScore`, range -100..+100.

The UI must always display the source Protection and Burden channels so the net value cannot hide simultaneous high protection and high burden.


---

<!-- SOURCE: 32_RESULTS_AND_LONGEVITY_DASHBOARD.md -->

# RESULTS AND LONGEVITY DASHBOARD

## Purpose

One place where entered health information becomes understandable output while keeping facts, validated risks, app-defined scores and population baselines distinct.

## Top-level layout

### Header
Current age if provided, data coverage, last update and active health modules.

### Longevity baseline
- population life-expectancy baseline
- population HALE where available
- source/geography/year badge

### Personalized validated risk cards
Only eligible validated calculators, e.g. cardiovascular risk or cancer-specific risk.

### Healthspan domain cards
0–100 app composites where defined, such as Cardiometabolic, Fitness/Function, Sleep, Nutrition, Mental Wellbeing, Preventive Care, Skin when enabled and other enabled domains.

Every card shows score, coverage, confidence, trend and `How calculated?`.

### Lifespan projection state
- POPULATION_BASELINE_ONLY
- VALIDATED_PERSONAL_MODEL_AVAILABLE
- EXPERIMENTAL_MODEL_ENABLED
- INSUFFICIENT_DATA

Do not manufacture a personalized age when only a population baseline exists.

### Timeline impact
Show recent records that changed results: labs, vaccines, treatment events, weight, smoking status, chemotherapy cycle, diagnosis or medication change.

## Domain drilldown

### Cardiology
Validated risk outputs, BP/lipid trends, relevant labs, events/procedures, app domain composite, eligibility and missing inputs.

### Oncology
Cancer type/status, treatment timeline, applicable risk/prognosis tools and screening. No universal validated cancer score.

### Dermatology
Skin profile, conditions, products, symptom trend and optional photo timeline. Domain results remain separate from mortality prediction.

## Score drilldown

Tapping any result opens:
1. definition
2. formula/model
3. input records
4. missing inputs
5. calculation date/version
6. sources
7. limitations

## Historical reproducibility

Store model version and source-record IDs so an old result can be interpreted later. Do not silently recompute every old result under a new model without preserving history.

## Longevity ↔ Shortevity dual view

Add an optional bidirectional view:
- Protective / Resilience
- Risk / Burden
- Function / Capacity
- Trajectory
- Coverage / Confidence

Validated clinical risk remains a separate result class and must not be visually replaced by the app balance score.


---

<!-- SOURCE: 33_TREATMENTS_VACCINES_PROCEDURES_AND_PRODUCTS.md -->

# TREATMENTS, VACCINES, PROCEDURES AND HEALTH PRODUCTS

This generalizes supplements, medicines, creams, vaccines, procedures and chemotherapy.

## HealthProduct
Catalog entity for prescription/OTC medicine, supplement, topical cream/ointment/gel, skincare product, medical nutrition product or other health product. Catalog presence is not proof of use.

Possible fields: name, class, active ingredients, strength/concentration, form, route, manufacturer, barcode/identifier and source.

## ProductUsePlan
Intended use: product, dose/amount, unit, route, frequency, start/end and purpose.

## ProductUseEvent
Actual use: product, date/time, amount, route, optional body site, note and reaction.

## VaccinationEvent
Vaccine/target, administration date, dose number, manufacturer/lot when known, provider/site, route/site, source/document and optional user-recorded reaction.

Vaccination contributes to prevention history. It must not be translated directly into arbitrary lifespan years.

## ProcedureEvent
Type, date/time, institution/provider, indication, outcome/status, notes and documents. Examples include surgery, endoscopy, catheterization, biopsy, dental or dermatologic procedure.

## OncologyTreatmentEvent
When Oncology is enabled: chemotherapy, radiotherapy, immunotherapy, targeted therapy, hormonal therapy, surgery, transplant and other oncology treatments. Record regimen, cycle/fraction, agents, dose, date, adverse effects and response references when known.

Do not infer prognosis solely from “chemotherapy received”.

## TreatmentCourse
Multiple events can belong to a treatment course: diagnosis → regimen → cycle 1 → cycle 2 → imaging → response → cycle 3.

## Dermatology / skincare use
Topical use can record product, active ingredients, body area, amount/frequency, start/end, symptom response, irritation and optional photos. Skin/cosmetic outcomes remain separate from lifespan.

## Intervention outcome tracking
Optionally connect a baseline metric, intervention start and follow-up values. Display temporal association without automatically claiming causality.

Stopping a medicine/supplement/product is an event/status transition, not deletion of history.


---

<!-- SOURCE: 34_COMPARISON_LAB_AND_BODY_PROFILES.md -->

# COMPARISON LAB AND BODY PROFILES

## Purpose

Longevity App must include a dedicated **Comparison** mode/tab.

The user can create as many comparison profiles as the device/database reasonably supports and compare their calculated health/longevity outputs side by side.

A comparison profile can represent:

1. the signed-in user's current body,
2. another explicitly created real-person profile,
3. a hypothetical/synthetic body,
4. a scenario clone of an existing profile with modified inputs.

The default use case should strongly support synthetic/hypothetical comparison without requiring real third-party personal data.

## Privacy rule for real-person profiles

If a profile represents another real person:
- the app must clearly label that it contains another person's health data,
- the user is responsible for having an appropriate lawful/consensual basis,
- sharing/export must be explicit,
- data must not be uploaded by default merely because it exists locally.

## Entity: ComparisonProfile

Fields:
- id
- owner_user_id
- profile_type: SELF | REAL_OTHER | SYNTHETIC | SCENARIO
- name
- description optional
- date_of_birth or age model input optional
- sex-related model input optional
- geography/model locale optional
- active_module_settings
- source_profile_id optional
- created_at
- updated_at

## Body settings

A comparison profile can have its own:
- age/date of birth
- height
- weight
- waist
- body composition
- blood pressure
- heart rate
- labs
- conditions
- medications
- supplements
- skin profile
- sleep
- exercise
- diet/nutrition
- smoking/alcohol/substance exposure
- vaccinations
- treatment history
- specialist Advanced modules
- any other supported HealthFact.

## Scenario clone

The user can duplicate a profile:

`Current Body → Clone → Scenario B`

Then change inputs without mutating the source profile.

Example:
- Body A: 120 kg
- Body B: 90 kg
- Body C: same body but non-smoker
- Body D: same body with different sleep/activity assumptions

The app recalculates eligible deterministic outputs independently.

## Compare canvas

The comparison screen can display N profiles as columns/cards.

Example:

| Metric | Body A | Body B | Body C |
|---|---:|---:|---:|
| Weight | 120 kg | 90 kg | 90 kg |
| Resting HR | 78 | 68 | 68 |
| Sleep score | 61 | 78 | 78 |
| CVD risk | model output | model output | model output |
| Healthspan composite | 58 | 74 | 79 |
| Data coverage | 88% | 72% | 72% |

The app must allow horizontal scrolling, profile pinning and metric filtering when many profiles are compared.

## Difference view

For a selected baseline profile:

`Δ = comparison value - baseline value`

For percentage-compatible metrics:

`%Δ = (comparison - baseline) / baseline × 100`

Do not calculate percentage change when the baseline is zero or the metric semantics do not support percentages.

## Model eligibility

Each profile is evaluated independently.

If Body A is eligible for a validated model and Body B is not:
- Body A gets its valid output,
- Body B shows `NOT_ELIGIBLE`,
- the app does not force a fake comparison.

## Comparison of lifespan

Population baseline and validated survival models may be compared only when:
- same endpoint definition,
- compatible model version,
- compatible population assumptions,
- sufficient data.

App composite scores can be compared separately.

Do not compare unlike outputs as though they are the same quantity.

## Unlimited profiles

Do not hard-code a small maximum such as 2 or 4 profiles.

UI can render a practical subset at once, but storage should support an arbitrary list subject to system resource limits.

## Export

Comparison configurations and results can be exported without modifying the original profile data.

## Acceptance principle

Comparison must be reproducible:
same inputs + same model/rule version = same result.


---

<!-- SOURCE: 35_DAILY_MISSIONS_AND_RULE_ENGINE.md -->

# DAILY MISSIONS AND DETERMINISTIC RULE ENGINE

## Purpose

Longevity App should combine observation with daily action.

A **Daily Missions** system gives Duolingo-like tasks, streaks and completion feedback, but tasks are generated by explicit deterministic rules rather than AI.

## Root rule

`Current state + user goals + constraints + history + rule version → today's missions`

Same inputs and same rule version must produce the same mission set.

## Examples

Possible missions:
- record today's mood check-in,
- record body weight,
- take a scheduled medication/supplement,
- complete a walk target,
- complete a workout prescription,
- log meals,
- complete a vaccination/screening reminder,
- read a short educational card,
- answer a short quiz,
- complete a mobility/recovery task.

## Strength-training example

A deterministic training plan can produce:

`Bench Press — 3 × 10 @ 30 kg`

only when the workout engine has enough information such as:
- exercise selection,
- previous completed sessions,
- prescribed progression rule,
- current program phase,
- available equipment,
- pain/injury/medical flags,
- user-defined maximum progression constraints.

The app must distinguish:
- planned workout task,
- actually completed sets,
- actual repetitions/load.

A planned `3×10 @ 30 kg` is not a completed session.

## Training progression engine

Example configurable progression rule:

If:
- previous target completed with all prescribed reps,
- no pain/injury stop flag,
- perceived exertion or reserve is within configured progression criteria,
- minimum recovery interval satisfied,

Then:
- add configured load increment or rep increment.

Otherwise:
- repeat,
- reduce,
- deload,
- or request user review according to explicit program rule.

Do not hard-code universal weight increases.

## Medical safety gate

Daily Missions must check active contraindication/safety flags before producing physical tasks.

Examples:
- acute injury,
- post-operative restriction,
- active chemotherapy treatment context,
- clinician-entered exercise restriction,
- symptomatic cardiovascular flag.

The app should suppress or downgrade tasks according to explicit safety rules.

It must not invent individualized medical clearance.

## Mission structure

Mission:
- id
- profile_id
- mission_type
- title
- rationale
- target
- unit
- generated_for_date
- source_rule_id
- source_rule_version
- prerequisite_record_ids
- status: PLANNED | STARTED | COMPLETED | SKIPPED | BLOCKED
- completion_record_ids
- points/xp optional
- created_at

## Mission categories

- Observe
- Train
- Recover
- Nutrition
- Sleep
- Prevention
- Medication/Adherence
- Learn
- Review

## Streaks

A streak is a behavioral/gamification metric only.

It must not:
- rewrite health scores,
- imply medical improvement by itself,
- punish medically appropriate skipped tasks.

A BLOCKED mission does not have to break a streak if the rule set says it was medically/instrumentally unavailable.

## Points / XP

XP can reflect:
- task completion,
- lesson completion,
- logging consistency.

XP is not a health outcome.

## Offline requirement

Mission generation must run locally with:
- local records,
- local rule packs,
- local goal settings,
- local education content.

No network or generative AI is required.

## Rule pack

Every mission rule stores:
- rule_id
- version
- inputs
- conditions
- output template
- safety conditions
- rationale
- source/reference if evidence-based.

Rule packs can be updated when online, but the currently installed version remains usable offline.


## v0.23 Preventive missions

A preventive assessment can generate a mission only when the rule/action policy allows it.

Examples:
- review missing vaccine history,
- schedule routine screening,
- discuss a shared-decision service,
- upload/import a preventive record.

Mission completion does not mark the preventive medical service completed.
Only a valid PreventiveEvent (or reviewed imported equivalent) does.


---

<!-- SOURCE: 36_WEARABLE_AND_HEALTH_PLATFORM_INTEGRATION.md -->

# WEARABLE AND HEALTH PLATFORM INTEGRATION

## Goal

Longevity App should import user-authorized sensor/health data from platform health stores instead of requiring manual duplication.

## Android

Preferred integration boundary:
**Android Health Connect**

Potential records include:
- sleep sessions and stages,
- heart rate,
- resting heart rate,
- steps,
- exercise sessions,
- distance,
- calories,
- blood pressure when available,
- weight,
- oxygen saturation where available,
- respiratory rate,
- skin temperature where available,
- other supported records.

The implementation must verify current Health Connect SDK/data-type/permission requirements at build time.

## Apple

Preferred integration boundary:
**Apple HealthKit**

HealthKit can serve as the central iPhone/Apple Watch health repository when the user explicitly grants access.

Potential reads include:
- heart rate,
- workouts,
- steps/activity,
- sleep,
- weight,
- other authorized HealthKit data types.

The implementation must request only necessary fine-grained permissions.

## Source provenance

Every imported record stores:
- platform: HEALTH_CONNECT | HEALTHKIT | OTHER
- original/source application/device when available
- source record identifier when available
- imported_at
- measurement time
- device metadata where permitted
- raw/normalized unit metadata.

## Deduplication

Do not duplicate the same wearable measurement on every import.

Use:
- source IDs,
- platform metadata,
- time/value/device fingerprints only when IDs are unavailable,
- import cursor/change APIs when supported.

## Imported vs manual

Manual and wearable data may coexist.

Do not silently overwrite:
- manual weight,
- imported scale weight,
- clinician measurement.

Keep source visible.

## Sleep

Sleep import should preserve:
- session start/end,
- stages when available,
- source,
- associated heart-rate/SpO2/respiratory measurements where available.

## Heart rate

Support:
- raw time-series samples when practical,
- daily aggregates,
- resting heart rate,
- sleep-associated heart rate,
- workout heart rate.

The UI must show whether a value is:
- raw sample,
- aggregate,
- resting HR,
- user-entered.

## Permissions

Permissions are opt-in and revocable.

If permission is denied:
- app remains functional,
- manual entry remains available,
- no fake wearable values are generated.

## Offline

Once imported to the local database, data remains available for local calculations offline.

Import itself depends on what the OS health store makes available locally.

## Privacy

Health platform data remains sensitive and follows the same ownership/export/deletion rules as manually entered health records.


---

<!-- SOURCE: 37_DEFAULTS_RESET_AND_PROFILE_TEMPLATES.md -->

# DEFAULTS, RESET AND PROFILE TEMPLATES

## Requirement

The app must provide a one-action way to return configurable settings to defaults.

This must be safe.

## Separate actions

### Reset Settings to Defaults
Resets:
- UI preferences,
- enabled/hidden modules,
- comparison display preferences,
- scoring display preferences,
- notification preferences,
- daily mission presentation settings,
- non-personal calculation configuration that is safe to reset.

It does NOT delete:
- health history,
- labs,
- treatments,
- meals,
- wearable data,
- conditions,
- comparison profiles,
- account data.

### Reset One Module
Example:
`Cardiology Advanced → Reset module settings`

Resets module settings only.

### Reset Comparison Scenario
A synthetic/scenario profile can be reset to:
- system default template,
- source profile baseline,
depending on how it was created.

### Delete Health Data
This is a separate destructive workflow with explicit confirmation.

### Delete Account
Separate again.

Never combine these actions under one ambiguous “Reset Everything” button.

## Default profile

The default app profile contains:
- no invented diseases,
- no invented medications,
- no invented measurements,
- no invented diet,
- no invented exercise history.

Defaults are settings defaults, not fake health data.

## Templates

Optional synthetic templates can be supplied for educational/comparison use:
- Blank Adult
- Synthetic Athlete
- Synthetic Sedentary
- Synthetic Example with Cardiovascular Inputs

They must be visibly labeled `SYNTHETIC EXAMPLE`.

They must never appear as the real user's health history.

## Reset confirmation UX

Settings reset may use:
`Reset settings to defaults?`

Destructive health-data deletion must use a stronger flow and clearly state what will be deleted.

## Reproducibility

Default settings must carry a defaults version:

`DEFAULTS_vX`

Resetting later may use:
- current defaults,
- or a stored historical defaults version when reproducing an old scenario.


---

<!-- SOURCE: 38_OFFLINE_EDUCATION_AND_LEARNING_MODE.md -->

# OFFLINE EDUCATION AND LEARNING MODE

## Product role

Longevity App is both:
1. an observation/tracking system,
2. an education system.

Education must be useful without internet and without AI.

## Education content types

- glossary,
- short concept cards,
- anatomy/physiology basics,
- lab-marker explainers,
- sleep explainers,
- exercise fundamentals,
- nutrition fundamentals,
- medication/supplement terminology,
- vaccination/prevention explainers,
- cardiovascular concepts,
- oncology concepts,
- dermatology concepts,
- risk/statistics literacy,
- “what this metric means” cards.

## Contextual education

When a user enters data, the app may surface relevant education.

Examples:
- user logs LDL → “What is LDL?” card,
- user imports resting heart rate → “Resting heart rate” card,
- user logs vaccine → “How vaccination records work” card,
- user enables Cardiology Advanced → cardiovascular-risk literacy lesson.

Context trigger is deterministic, not generative.

## Duolingo-like learning loop

A lesson can contain:
1. brief explanation,
2. example,
3. 1–3 questions,
4. immediate answer feedback,
5. XP/completion,
6. optional later review task.

## Quiz types

- multiple choice,
- true/false,
- match term to definition,
- order steps,
- interpret a simple chart,
- identify which statement is supported.

Answer keys are authored/versioned.

## Learning state

Track:
- lesson exposure,
- completed quiz,
- correct/incorrect,
- review due date,
- streak/XP.

Learning progress must not modify health risk unless the health model explicitly uses a real behavior/measurement.

## Content packs

Offline content is packaged as versioned content packs.

Fields:
- pack_id
- version
- locale
- domain
- lessons
- source/reference metadata
- published/updated date.

## Evidence labels

Educational claims can display:
- guideline/source,
- evidence class,
- last reviewed date.

## No medical diagnosis through education

Educational cards explain concepts.
They do not diagnose the user from their entered data.

## Offline

All installed content packs, quizzes and review scheduling work without network.
New content packs can be downloaded when online.


---

<!-- SOURCE: 39_OFFLINE_DETERMINISTIC_CORE_CONTRACT.md -->

# OFFLINE DETERMINISTIC CORE CONTRACT

## Highest-level product rule

Core Longevity App must not depend on generative AI or continuous internet access.

## Must work offline after installation/content availability

- viewing existing health records,
- manual health data entry,
- timeline,
- labs and trends,
- food logging with cached/custom foods,
- comparison profiles/scenarios,
- deterministic scores,
- Daily Missions,
- training rule engine,
- installed educational content,
- quizzes/reviews,
- imported local health-store data already available to the app,
- settings reset,
- export to a local file where platform allows.

## May require internet

- account sign-in on a fresh device,
- cloud synchronization,
- downloading updated food/provider data,
- downloading new education/rule/model packs,
- public website,
- remote backup,
- provider/API lookup not cached locally.

## Calculation architecture

All calculations must be executable from local:
- records,
- model definitions,
- rule packs,
- content packs.

A model/rule definition must contain enough metadata to reproduce the result.

## No server-only hidden formula

If a core score is shown offline, the rule/formula/version must be available locally.

Server may verify/recompute, but it must not be the only place where the formula exists.

## Determinism

For deterministic engine version V:

`f(inputs, V) = same output`

No randomness may alter a health result unless randomness is explicitly part of an educational simulation and clearly labeled.

## Clock/time

Date-sensitive missions use local timezone and a defined rule-day boundary.

## Updates

Online updates may deliver:
- new rule packs,
- new evidence/model packs,
- new content packs,
- database migrations.

Installed old versions remain identifiable for historical reproducibility.

## No-AI invariant

No feature in the required product scope may fail merely because an LLM/API is unavailable.

Future AI may only be added by a new explicit product decision.


---

<!-- SOURCE: 40_LONGEVITY_SHORTEVITY_BIDIRECTIONAL_ENGINE.md -->

# LONGEVITY ↔ SHORTEVITY BIDIRECTIONAL ENGINE

## Definition

**Longevity** is the product umbrella for factors, states and trajectories associated with preserving or improving lifespan, healthspan, function, resilience and quality of life.

**Shortevity** is a product-specific umbrella term for the opposite direction: factors, states and trajectories associated with increased disease burden, risk, functional decline, harmful exposure, treatment burden, frailty, preventable loss of function or reduced survival.

`Shortevity` is not treated as a standard clinical endpoint. It must never be presented as a scientifically validated universal measure unless a specific validated model defines that endpoint.

## Core model

Every relevant domain can contain:
- protective/resilience signals,
- adverse/risk/burden signals,
- function/capacity signals,
- context,
- uncertainty/missingness.

The app should not assume that health is a one-direction score.

Conceptually:

`Health State = Protection + Burden + Function + Context + Uncertainty`

The exact mathematical relationship is model-specific.

## Four result channels

For each enabled domain support up to four distinct outputs:

1. `PROTECTION / RESILIENCE`
2. `RISK / BURDEN`
3. `FUNCTION / CAPACITY`
4. `DATA CONFIDENCE / COVERAGE`

Do not collapse all four into one number when doing so destroys meaning.

## Examples

### Cardiovascular
Longevity side can include controlled risk factors, physical activity, prevention and favorable function.
Shortevity side can include hypertension burden, smoking exposure, diabetes, prior disease and worsening functional capacity.

### Oncology
Longevity side can include screening completion, remission, documented treatment response, rehabilitation and preserved function.
Shortevity side can include active malignancy burden, progression/recurrence, treatment toxicity, cachexia/frailty and functional decline.

### Dermatology
Longevity side can include symptom control, appropriate treatment adherence and UV protection behavior.
Shortevity side can include uncontrolled disease burden, harmful UV exposure and treatment adverse effects.

A skin-domain burden score must not be converted into mortality years unless a validated survival model actually supports it.

## Acute vs chronic

Shortevity-side burden should distinguish:
- ACUTE_EVENT
- CHRONIC_BURDEN
- CUMULATIVE_EXPOSURE
- TRANSIENT_TREATMENT_BURDEN
- PERSISTENT_FUNCTIONAL_LOSS
- UNKNOWN

## Trajectory

Each domain can classify trajectory:
- IMPROVING
- STABLE
- WORSENING
- MIXED
- INSUFFICIENT_DATA

Trajectory comes from explicit deterministic rules or model outputs.

## Mathematical safety

Do not compute:

`Personal lifespan = baseline + longevity points - shortevity points`

unless a validated calibrated survival model explicitly defines that transformation.

Longevity/Shortevity scores are explanatory domain summaries unless otherwise specified.

## User-facing language

Detailed screens should prefer medically interpretable labels such as:
- Protective factors
- Risk/Burden
- Function
- Trajectory
- Validated risk
- Population baseline

`Shortevity` may remain the conceptual umbrella for the negative direction.


---

<!-- SOURCE: 41_RISK_BURDEN_RESILIENCE_MATH.md -->

# RISK, BURDEN, RESILIENCE AND TRAJECTORY MATHEMATICS

## Purpose

Provide deterministic mathematics for bidirectional health tracking without falsely converting every signal into lifespan years.

## Result families

### A. Validated risk
Keep the published/native output semantics.

### B. App Protection Score
0–100 app-defined summary for protective/resilience factors.

### C. App Burden Score
0–100 app-defined summary for adverse/risk/burden factors.

### D. Function Score
0–100 or instrument-native function/capacity output.

### E. Coverage / Confidence
Separate result.

## Protection Score

For normalized protective components `p_i`:

`ProtectionScore = Σ(w_i × q_i × p_i) / Σ(w_i × q_i)`

where `w_i` is importance weight, `q_i` is data-quality factor and `p_i` is a normalized protective component in [0,100].

## Burden Score

For normalized adverse components `b_i`:

`BurdenScore = Σ(v_i × q_i × b_i) / Σ(v_i × q_i)`

Higher BurdenScore means more tracked adverse burden in that app-defined domain.
It is not automatically probability of death.

## Balance Index

Optional visualization:

`BalanceIndex = ProtectionScore - BurdenScore`

Range: -100 to +100.

This is an app visualization only, not a clinical risk or life-expectancy model. The UI must always show Protection and Burden separately beside it.

## Trajectory

For repeated numeric measurements:

`trend = deterministic_slope(value over time)`

The implementation may use ordinary least squares for simple series or a robust estimator such as Theil-Sen when configured. Directionality must be declared for each metric.

## Cumulative exposure

For exposure rate `x(t)`:

`CumulativeExposure = ∫ x(t) dt`

Discrete implementation:

`Σ(exposure_level × duration)`

Do not combine unlike physical units into one quantity.

Examples may include established domain formulas such as pack-years, treatment dose accumulation or sedentary-time accumulation.

## Recovery / resilience

A recovery component may measure return toward a pre-event baseline:

`RecoveryFraction = (current - worst) / (baseline - worst)`

only when all values are comparable and directionality is defined.

## Confidence

Confidence is derived from coverage, recency, provenance, repeatability and model applicability. It remains separate from Burden or Protection.

## No arbitrary years-lost conversion

A BurdenScore of 70 does not mean 70% mortality, seven years lost or a “shortevity age.” Years lost require an applicable validated model.


---

<!-- SOURCE: 42_CAUSAL_EVIDENCE_AND_INTERVENTION_GRAPH.md -->

# CAUSAL, EVIDENCE AND INTERVENTION GRAPH

## Goal

Link observations, exposures, interventions, outcomes and evidence without pretending every association is causal.

## Node types

- OBSERVATION
- EXPOSURE
- BEHAVIOR
- CONDITION
- SYMPTOM
- BIOMARKER
- TREATMENT
- PROCEDURE
- VACCINATION
- PRODUCT_USE
- FUNCTION
- OUTCOME
- VALIDATED_RISK_OUTPUT
- APP_SCORE
- EDUCATION_ITEM
- RULE
- MODEL

## Edge types

- OBSERVED_WITH
- PRECEDES
- PART_OF
- CORRECTS
- DERIVED_FROM
- CALCULATED_BY
- ELIGIBLE_FOR
- CONTRAINDICATES
- SUPPORTS
- CONFLICTS_WITH
- POSSIBLE_ASSOCIATION
- EVIDENCE_SUPPORTED_EFFECT
- UNKNOWN_RELATION

Only use `EVIDENCE_SUPPORTED_EFFECT` when the installed evidence pack explicitly supports the relation for the relevant population, exposure/intervention and outcome.

## Intervention tracking

An intervention record can define baseline period, start date, intervention details, target outcome, follow-up window and observed outcome.

The app may display:

`Before → Intervention → After`

but should label this a within-person temporal observation unless stronger inference is justified.

## Evidence claim

Each evidence-backed relation can store:
- claim_id
- population
- exposure/intervention
- comparator
- outcome
- time horizon
- evidence class
- effect estimate when appropriate
- uncertainty
- source/reference
- review date
- version

## Scenario mode

Comparison profiles must distinguish:
- OBSERVED current body,
- HYPOTHETICAL scenario,
- EVIDENCE-SUPPORTED intervention estimate,
- purely mathematical recalculation.

## Safety

The graph is not a diagnosis engine. It supports traceability, education and deterministic calculations.


---

<!-- SOURCE: 43_HUMAN_OS_FULL_DONOR_TRANSFER.md -->

# HUMAN OS FULL DONOR TRANSFER INTO LONGEVITY ↔ SHORTEVITY

## Scope and honesty

The user authorized Human OS as a comprehensive Forge Donor.

This package integrates all reusable Human OS methodology accessible in the current project sources and prior verified handoff continuity.

It does NOT claim that an unseen standalone original Human OS repository was inspected byte-for-byte. Any additional canonical Human OS source supplied later must be compared deliberately; unseen capabilities remain UNKNOWN until inspected.

## Donor / Receiver

- Donor: Human OS methodology
- Receiver: Longevity App, now modeled as a Longevity ↔ Shortevity Health OS

## Transfer rule

Transfer methodology, not donor identity.

Do not import donor-private user history, personal dates, diet/routine defaults, academic/YKS records, persona or unrelated projects.

## Accessible transfer inventory

- HOS-T01 State continuity → TRANSFER → canonical current health state
- HOS-T02 Architecture continuity → TRANSFER → module/requirements registry
- HOS-T03 Decision continuity → TRANSFER → ADR and Decision Memory
- HOS-T04 Dated event orientation → ADAPT → HealthFact, TimelineEvent, specialized health events
- HOS-T05 Plan != completion → TRANSFER → missions, medication/intake, training plan/completion
- HOS-T06 UNKNOWN remains UNKNOWN → TRANSFER → all health data and calculations
- HOS-T07 Correction propagation → TRANSFER → revisions and derived-result invalidation
- HOS-T08 Effective-date policies → ADAPT → rule/model/default/content versions
- HOS-T09 Dependency propagation → TRANSFER → recalculation graph
- HOS-T10 Decision Memory → TRANSFER
- HOS-T11 Failure Mode Ledger → TRANSFER
- HOS-T12 Rollback/migration → TRANSFER → database/model/rule/content migration
- HOS-T13 Release evidence separation → TRANSFER → SPECIFIED/CODED/TESTED/BUILT/INSTALLED/VALIDATED/DEPLOYED
- HOS-T14 Provenance → TRANSFER → manual/lab/device/provider/document/calculated data
- HOS-T15 Evidence hierarchy → TRANSFER → evidence engine
- HOS-T16 Association != causation → TRANSFER → causal/evidence graph
- HOS-T17 Multi-timescale review → ADAPT → day/week/month/year/all-time health trends
- HOS-T18 Baseline → delta → current → TRANSFER → comparison and trajectory
- HOS-T19 Capacity-aware orchestration → ADAPT → Daily Missions
- HOS-T20 Recovery context → ADAPT → training, illness, post-procedure, oncology treatment
- HOS-T21 Safety gates → TRANSFER → mission generation and model eligibility
- HOS-T22 Source freshness → ADAPT → model/evidence/provider/content metadata
- HOS-T23 Source-bound mode → ADAPT → report/document import
- HOS-T24 Handoff/resume capsule → TRANSFER → portable app/project state
- HOS-T25 Single authority → TRANSFER → canonical records, projections remain projections
- HOS-T26 Kernel/hard constraints → TRANSFER
- HOS-T27 Soft targets → TRANSFER
- HOS-T28 Module contracts → TRANSFER
- HOS-T29 Change lifecycle IDEA→PROPOSED→ACCEPTED→SPECIFIED→AUDITED→CURRENT → TRANSFER
- HOS-T30 Backlog READY/BLOCKED/DEFERRED/DONE etc. → TRANSFER
- HOS-T31 Interruption recovery → TRANSFER
- HOS-T32 Deduplication → TRANSFER → events, wearable imports, sync
- HOS-T33 Profile firewall → TRANSFER → one profile's data never becomes another's default
- HOS-T34 Education evidence separation → ADAPT → viewed != learned, quiz != health outcome
- HOS-T35 Retrieval/review learning loop → ADAPT → offline education
- HOS-T36 Error repair → ADAPT → education/correction workflows
- HOS-T37 Historical model-version preservation → TRANSFER
- HOS-T38 Stable research signal identity → ADAPT → evidence/model registry
- HOS-T39 Daily orchestration → ADAPT → missions prioritize safety, due actions, recovery, goals and actual history
- HOS-T40 No punitive backlog stacking → ADAPT
- HOS-T41 Source-specific evidence meaning → TRANSFER
- HOS-T42 Audit stop rule → TRANSFER

## Receiver kernel produced by the transfer

Hard constraints:
- no required generative AI,
- offline deterministic core,
- missing != zero,
- plan != completion,
- self-report != diagnosis,
- app score != clinical probability,
- Shortevity score != years lost,
- domain score != lifespan,
- correction history,
- source provenance,
- profile/privacy isolation,
- versioned rules/models/results.

## Excluded donor content

- Academic/YKS-specific state → EXCLUDE
- Performing-arts state → EXCLUDE
- Personal donor diet/health/routine defaults → EXCLUDE
- Persona/voice behavior → EXCLUDE

## Unknown

`HOS-U01`: unseen standalone Human OS repository contents → UNKNOWN / ACCESS GAP.

## Integration stage

Accessible reusable methodology:
`DISCOVERED → CLASSIFIED → MAPPED → ADAPTED → STAGED → STATICALLY_VERIFIED`

Actual production application behavior remains NOT_RUN until a future implementing agent builds and executes the product.


---

<!-- SOURCE: 44_HUMAN_OS_STATE_EVENT_DECISION_MEMORY.md -->

# HUMAN OS STATE, EVENT AND DECISION MEMORY

## Three continuities

Longevity ↔ Shortevity preserves three distinct continuities.

### State continuity
What is true now?
Examples: current diagnosis status, latest weight, active medication plan, active treatment course, active modules.

### Event continuity
What actually happened?
Examples: vaccination, chemotherapy cycle, workout, symptom episode, lab measurement, medicine intake.

### Decision continuity
Why did a configuration or design choice exist?
Examples: why a model was enabled, why a mission rule changed, why a module is hidden, why a scoring weight changed.

## Projection rule

Current state is a projection from prior state + events + corrections + active policies + model versions.
Changing current state does not erase event history.

## Correction event

A correction stores:
- correction_id
- original_record_id
- corrected_record_id or fields
- reported_at
- effective_at
- reason
- actor/source

Affected derived calculations are invalidated/recomputed.

## Policy / rule versions

Rule packs, score normalizations, defaults, education packs and model versions store effective dates. New versions do not silently rewrite historical results.

## Decision Memory

Each important decision preserves:
- decision_id
- question/problem
- current_choice
- alternatives
- reason
- assumptions
- known downsides
- dependencies
- switch_condition
- effective version/date
- status

## Failure Memory

Observed failures preserve:
- failure_id
- module
- observed behavior
- expected behavior
- environment/data
- severity
- suspected/confirmed cause
- repair
- regression test
- verification status

Hypothetical failure modes are not mislabeled as observed failures.

## Portable handoff

Portable state should include schema version, model/rule/content versions, active modules, current state, event history, correction links, decision/config versions, pending sync/outbox state, known failures and export date.


---

<!-- SOURCE: 45_HUMAN_OS_DAILY_ORCHESTRATION_AND_RECOVERY.md -->

# HUMAN OS DAILY ORCHESTRATION AND RECOVERY

## Goal

Daily Missions behave like a health orchestration engine, not a generic checklist.

## Inputs

- actual recent health events
- active conditions
- treatment context
- goals
- training program
- sleep/recovery data
- medication/supplement plans
- preventive due items
- education review due items
- known time/capacity constraints
- device availability
- rule-pack version

## Suggested priority

1. invalid/conflicting data needing resolution
2. safety-critical or configured time-sensitive actions
3. clinician-entered restrictions
4. medication/adherence items
5. preventive care
6. recovery constraints
7. training/health behavior
8. observation/data entry
9. education/review
10. optional optimization

Priority is versioned/configurable.

## Capacity

Capacity is contextual, not a permanent trait.
Possible inputs include available time, sleep/recovery, recent training load, illness/symptoms, active treatment, user-entered readiness and mobility/injury restrictions.

## No punitive backlog stacking

- missed optional task does not automatically double tomorrow
- blocked task can be deferred
- treatment/recovery can reduce mission load
- one high-priority safety action can displace optional optimization

## Recovery states

- NORMAL
- FATIGUED
- ACUTE_ILLNESS
- POST_PROCEDURE
- INJURY_LIMITED
- ACTIVE_TREATMENT
- CLINICIAN_RESTRICTED
- UNKNOWN

Recovery state affects mission eligibility, not factual health history.

## Training

Progression uses actual completed-session evidence. Unknown load/reps/recovery stays unknown. Generated prescriptions remain PLAN until completion events exist.

## Completion evidence

Mission completion requires explicit user completion, a compatible device/import event, or another defined completion source. Time passing alone never completes a mission.


---

<!-- SOURCE: 46_SHORTEVITY_TRAJECTORY_AND_EARLY_WARNING.md -->

# SHORTEVITY TRAJECTORY AND EARLY-WARNING ENGINE

## Purpose

Detect deterministic patterns that deserve attention without diagnosing.

## Signal levels

- INFORMATION
- WATCH
- REVIEW
- URGENT_CONFIGURED_RULE

`URGENT_CONFIGURED_RULE` is only for explicit safety rules configured from reliable sources or clinician-entered instructions. The app must not invent emergency thresholds.

## Pattern types

- persistent deterioration
- sudden change from configured/personal baseline
- recurrent symptom
- treatment burden accumulation
- functional decline
- missing configured follow-up
- material data conflict

## Personal baseline

When enough history exists, use a declared deterministic method such as median, rolling median, mean + dispersion or model-specific baseline.

## Deviation

When assumptions are appropriate:

`z = (current - baseline_mean) / baseline_sd`

For small/noisy samples prefer a robust deviation such as a median/MAD-based method.

## Alert rule metadata

- rule_id
- version
- metric/domain
- eligibility
- baseline method
- threshold
- persistence requirement
- action text
- source
- limitations

## No diagnosis

An alert means: “this configured pattern was detected.” It does not mean “you have disease X.”

## Dashboard

The Shortevity view may summarize active burden domains, worsening trajectories, cumulative exposures, unresolved review flags and data confidence. It should also show improving/recovered items to avoid one-sided alarmism.


---

<!-- SOURCE: 47_LIFE_COURSE_AND_EPISODES_OF_CARE.md -->

# LIFE COURSE AND EPISODES OF CARE

## Purpose

Longevity ↔ Shortevity should model a person as a longitudinal life course, not as unrelated screens.

## LifeCourse

A profile may contain a continuous chronology from the earliest known history to the present.

Possible life-course phases:
- prenatal/perinatal when voluntarily recorded,
- childhood,
- adolescence,
- adulthood,
- older age.

The app must not invent missing childhood or family history.

## Episode of Care

An **EpisodeOfCare** groups related events around one health problem, treatment or recovery period.

Examples:
- influenza infection episode,
- orthopedic injury → surgery → rehabilitation,
- cancer diagnosis → staging → treatment cycles → surveillance,
- cardiovascular event → hospitalization → medications → cardiac rehabilitation,
- pregnancy episode,
- psychiatric treatment episode.

Fields:
- id
- profile_id
- domain
- title
- start_at
- end_at optional
- status
- primary_condition_id optional
- related_record_ids
- care_team/provider metadata optional
- outcome/state
- notes
- created_at/updated_at

## Episode state

Suggested:
- PLANNED
- ACTIVE
- STABILIZED
- RECOVERING
- SURVEILLANCE
- RESOLVED
- CHRONIC
- UNKNOWN

Do not infer a clinical state merely because time passed.

## Event graph

An episode can connect:
Diagnosis
→ procedure
→ medication
→ treatment course
→ symptoms/adverse effects
→ labs
→ functional change
→ follow-up.

## Life-course transitions

Important transitions may be marked:
- disease onset,
- remission,
- recurrence,
- major surgery,
- disability onset,
- smoking cessation,
- major weight change,
- menopause when applicable and voluntarily recorded,
- retirement or occupational exposure change,
- major training/activity transition.

Transition does not imply causality.

## Timeline zoom

The UI should support:
- day,
- week,
- month,
- year,
- multi-year,
- whole-life overview.

## Baseline periods

A user/scenario can mark a period as a reference baseline.

Example:
`Baseline: 2026-01-01 → 2026-03-31`

Future changes can compare against this period using explicit rules.

## Life-course output

The system can answer deterministically:
- what happened,
- when,
- which episode it belonged to,
- what state followed,
- which calculated outputs changed,
- what remains unknown.

## Privacy

Sensitive life-course data can be hidden from summary surfaces without deleting canonical history.


---

<!-- SOURCE: 48_BIOLOGICAL_AGE_AND_AGING_CLOCKS.md -->

# BIOLOGICAL AGE AND AGING CLOCKS

## Purpose

Support biological-aging metrics without pretending there is one universally true “biological age”.

## Distinction

Chronological age:
calendar time since birth.

Biological-age estimate:
a model-derived estimate using specified biomarkers or phenotypic inputs.

Functional age:
a domain-specific comparison based on function/performance.

No model-derived age should replace chronological age.

## Model Registry

Each aging clock must be a versioned ModelRegistryEntry.

Required metadata:
- model_id
- version
- purpose
- required inputs
- transformation/formula
- training/validation population
- units
- missing-data policy
- eligible age/population
- output semantics
- uncertainty if available
- source/reference
- license/implementation constraints
- status: VALIDATED_EXTERNAL | APP_EXPERIMENTAL | RESEARCH_ONLY

## Possible model families

The architecture may support:
- clinical chemistry/phenotypic clocks,
- mortality-risk-derived age measures,
- epigenetic clocks when compatible data exist,
- proteomic/metabolomic clocks,
- functional-age measures,
- organ-specific age models.

No specific clock is mandatory merely because the architecture supports it.

## Age acceleration

When the model defines an expected biological age:
`AgeAcceleration = EstimatedBiologicalAge - ChronologicalAge`

If the published model instead defines a residual or other acceleration metric, preserve its native definition.

Do not force all models into this formula.

## Multi-clock view

A user may have multiple clocks:

| Model | Estimate | Delta | Coverage | Version |
|---|---:|---:|---:|---|
| Clock A | 42.1 y | +1.1 y | 100% | 1.0 |
| Clock B | 38.7 y | -2.3 y | 92% | 2.1 |

The app must not average unlike clocks into a single “true biological age” by default.

## Missing data

If required biomarkers are missing:
- show missing inputs,
- return NOT_CALCULABLE or documented partial mode,
- never impute silently unless the model explicitly includes an imputation method.

## Longitudinal tracking

Store every computed clock result with:
- source record IDs,
- model version,
- calculation time.

This permits:
- trend over time,
- model-version comparison,
- scenario comparison.

## Lifespan relationship

A biological-age estimate is not automatically:
- life expectancy,
- years lost,
- guaranteed healthspan.

If a clock is linked to mortality or morbidity risk in its validation literature, present that relationship accurately and separately.

## Offline

Once model coefficients/formulas are legally available in a local model pack, calculation should run offline.


---

<!-- SOURCE: 49_FUNCTION_QUALITY_OF_LIFE_PAIN_AND_REHABILITATION.md -->

# FUNCTION, QUALITY OF LIFE, PAIN AND REHABILITATION

## Purpose

Healthspan must include what a person can actually do and how they function, not only disease codes and biomarkers.

## Functional domains

- mobility
- strength
- endurance
- balance
- dexterity
- activities of daily living
- instrumental activities of daily living
- work/occupational function
- exercise capacity
- cognitive function
- sensory function
- social function

## FunctionalMeasurement

Fields:
- id
- profile_id
- instrument_or_metric
- domain
- value
- unit/scale
- measured_at
- source
- assistance level
- notes
- model/instrument version.

Validated instruments preserve native scoring.

## Quality of life

Support structured quality-of-life instruments as optional modules.

Do not invent a universal QoL score.

A generic app-defined QoL composite may exist only if clearly labeled and transparent.

Possible dimensions:
- physical wellbeing
- emotional wellbeing
- social functioning
- pain/interference
- fatigue
- independence
- sleep
- perceived health.

## Pain

Pain should be a dedicated longitudinal construct.

Possible fields:
- location,
- quality/type,
- intensity,
- interference,
- onset/duration,
- triggers,
- relieving factors,
- associated symptoms,
- treatment/use events,
- function impact.

A 0–10 pain score is subjective self-report.

## Rehabilitation

### RehabPlan
- goals
- prescribed activities
- frequency
- restrictions
- start/end
- source/provider.

### RehabSession
- actual date
- exercises/interventions
- duration
- pain before/after
- function result
- notes.

Plan != completed session.

## Recovery trajectory

The app may compare:
- pre-event baseline,
- worst/acute phase,
- current,
- target.

But targets must be explicit and not fabricated.

## Frailty

Frailty instruments can be added through Model Registry.

Keep:
- instrument-native score,
- app function domain,
- validated outcome associations

separate.

## Healthspan relevance

Function and quality of life can be major healthspan outputs even if life expectancy is unchanged.


---

<!-- SOURCE: 50_MULTIMORBIDITY_POLYPHARMACY_AND_INTERACTION_GRAPH.md -->

# MULTIMORBIDITY, POLYPHARMACY AND INTERACTION GRAPH

## Purpose

People can have multiple conditions and multiple treatments simultaneously. The system must model interactions rather than treating each module as isolated.

## Multimorbidity

A profile can contain many active conditions.

Do not reduce all disease burden to condition count.

Track:
- condition severity/status,
- duration,
- functional impact,
- treatment burden,
- relevant validated burden instruments.

## Interaction Graph

Nodes can include:
- condition,
- medication,
- supplement,
- treatment,
- symptom,
- lab abnormality,
- procedure,
- mission,
- contraindication rule.

Edges:
- TREATS
- MAY_WORSEN
- CONTRAINDICATES
- INTERACTS_WITH
- REQUIRES_MONITORING
- DUPLICATES_EFFECT
- ASSOCIATED_WITH
- CAUSED_BY only when supported by explicit evidence/source
- UNKNOWN_RELATION.

## Medication burden

Track:
- number of active medicines,
- dosing frequency,
- administration complexity,
- adherence,
- adverse effects,
- monitoring requirements.

A simple medication count is descriptive, not a universal polypharmacy diagnosis.

## Supplement interaction

Supplements are included in the same interaction architecture.

The app must not assume “natural” means risk-free.

## Rule packs

Interaction rules may be installed as versioned evidence/rule packs.

A rule must include:
- entities/classes involved,
- directionality,
- severity,
- evidence/source,
- date/version,
- recommended app action,
- whether the rule is educational or safety-critical.

## Safety behavior

For detected interactions:
- show rule/source,
- avoid prescribing medication changes,
- distinguish “review with clinician/pharmacist” from emergency rules,
- allow false-positive dismissal only with a recorded reason when appropriate.

## Mission integration

Mission engine can:
- suppress incompatible training task,
- request monitoring,
- avoid duplicate reminders,
- schedule education.

It must not alter medication dose unless an explicit clinician-entered plan already defines that change.

## Shortevity

Medication/treatment burden can contribute to an app burden view, but must remain distinct from mortality risk.


---

<!-- SOURCE: 51_EXPOSOME_ENVIRONMENT_AND_SOCIAL_CONTEXT.md -->

# EXPOSOME, ENVIRONMENT AND SOCIAL CONTEXT

## Purpose

Health is influenced by cumulative environmental and social context. The app should support these data without moralizing or pretending perfect causal attribution.

## Exposome categories

- air pollution
- tobacco smoke / secondhand smoke
- occupational exposures
- UV radiation
- noise
- heat/cold
- sleep environment
- infectious exposure context
- chemical exposures when known
- travel/geographic exposure
- sedentary exposure
- physical workload.

## EnvironmentalExposure

Fields:
- exposure_type
- start/end
- intensity
- unit
- location precision policy
- source: manual/sensor/public dataset/import
- confidence
- notes.

## Social context

Optional user-controlled data:
- social connection/isolation
- living situation
- caregiving burden
- work schedule
- shift work
- financial/access barrier markers
- healthcare access
- food access
- transportation constraints.

These are context variables, not character judgments.

## Privacy

Precise location is sensitive.

Use:
- explicit permission,
- minimization,
- coarse location where sufficient,
- local processing when possible.

## Cumulative exposure

Where a domain has a meaningful formula:
`ExposureBurden = Σ(intensity × duration)`

Do not combine unrelated exposure units into one physical quantity.

## Scenario use

Comparison mode can model:
- lower air pollution scenario,
- different shift schedule,
- smoking cessation,
- reduced UV exposure.

Label scenarios as hypothetical.

## Education

Contextual education can explain:
- what an exposure means,
- evidence strength,
- how it is measured,
- uncertainty.

## Longevity/Shortevity

Environmental/social data can inform:
- evidence-backed risk models,
- app-defined burden/protection domains,
- mission feasibility.

They should not directly produce arbitrary years lost.


---

<!-- SOURCE: 52_INTEROPERABILITY_CLINICAL_CODES_AND_SEMANTICS.md -->

# INTEROPERABILITY, CLINICAL CODES AND SEMANTICS

## Purpose

Longevity App should be able to exchange health information without making its internal model depend on one external standard.

## Principle

Internal canonical model
↔ semantic adapters
↔ external standards/providers.

## Supported adapter targets

The implementation should be designed for future adapters such as:
- HL7 FHIR resources,
- platform health stores,
- laboratory exports,
- clinical document formats,
- research/common-data models.

Current versions and licensing must be verified at implementation time.

## Clinical terminology support

Where lawful/available, records may carry codes from suitable terminologies.

Examples of semantic roles:
- condition/diagnosis code,
- laboratory observation code,
- medication ingredient/product code,
- procedure code,
- unit code.

A code is metadata describing meaning; the human-readable label must remain available.

## Internal terminology concept

### CodedConcept
- system
- code
- display
- version optional
- user_label optional.

Never discard the user's original wording merely because a standardized code is added.

## Unit semantics

Use canonical unit representation where possible.

Store:
- source numeric value,
- source unit text,
- normalized value/unit when converted,
- conversion formula/version.

Never overwrite source values during normalization.

## FHIR mapping examples

Conceptual mappings:
- Condition → Condition-like resource
- LabResult/Vital → Observation-like resource
- MedicationPlan → MedicationRequest-like resource
- IntakeEvent → MedicationAdministration/Statement-like representation depending on semantics
- ProcedureEvent → Procedure-like resource
- VaccinationEvent → Immunization-like resource
- EpisodeOfCare → EpisodeOfCare-like resource
- Document/attachment → DocumentReference-like resource.

The implementing agent must verify exact current FHIR structures rather than relying solely on these conceptual names.

## Import policy

Imported clinical data:
1. preserve source payload/reference where allowed,
2. normalize into canonical entities,
3. retain external identifiers,
4. deduplicate,
5. mark source/provider,
6. do not treat import success as clinical verification.

## Export policy

Offer:
- internal JSON/CSV,
- future FHIR export bundle/profile where supported.

Export must state schema/version.

## Semantic conflict

If two systems label the same concept differently:
- preserve both source labels,
- map to canonical concept only when mapping confidence is adequate,
- keep UNKNOWN/UNMAPPED when not.

## Offline

Imported standardized data remains locally usable after normalization.


---

<!-- SOURCE: 53_DETERMINISTIC_DIGITAL_TWIN_AND_SCENARIO_ENGINE.md -->

# DETERMINISTIC DIGITAL TWIN AND SCENARIO ENGINE

## Definition

A **Digital Twin** in this product is a deterministic computational profile representing a person's recorded health state and applicable models.

It is not a claim to perfectly simulate biology.

## Twin layers

1. Canonical observed data
2. Current-state projection
3. Derived metrics
4. Validated model outputs
5. App-defined domain scores
6. Scenario overrides

## TwinState

Fields:
- profile_id
- as_of_time
- source_event_cursor
- active conditions
- active plans/treatments
- latest measurements
- rolling metrics
- model versions
- rule-pack versions
- unresolved conflicts
- coverage.

## ScenarioPatch

A scenario modifies selected inputs without changing canonical observations.

Fields:
- scenario_id
- base_profile/twin
- base_as_of
- patch operations
- rationale
- created_at
- model/rule versions.

Examples:
- weight 120 → 90 kg
- smoker → non-smoker
- sleep 5.5 → 7.5 h
- medication adherence 50% → 95%
- activity level change.

## Calculation

`ScenarioResult = Engine(BaseTwin + ScenarioPatch, ModelVersionSet)`

Same base + patch + versions must reproduce same result.

## Scenario classes

- PARAMETER_ONLY
- BEHAVIOR_CHANGE
- INTERVENTION_HYPOTHESIS
- TREATMENT_PLAN
- ENVIRONMENT_CHANGE
- COMBINED.

## Evidence labels

Every changed output should identify why it changed:

- DIRECT_FORMULA_RECALCULATION
- VALIDATED_MODEL_RECALCULATION
- APP_COMPOSITE_RECALCULATION
- EVIDENCE_SUPPORTED_INTERVENTION_ESTIMATE
- HYPOTHETICAL_ONLY.

## Counterfactual safety

Changing a biomarker in a scenario is not automatically equivalent to achieving that biomarker through treatment.

Example:
lowering modeled LDL input can show model sensitivity,
but is not automatically a treatment-effect estimate.

## Comparison

Compare:
- observed current twin,
- historical twin at prior date,
- synthetic twin,
- scenario twin.

## Snapshot

Twin snapshots are reproducible views, not separate canonical health history.

## Offline

Twin/scenario calculations must run offline when all required local model packs are installed.


---

<!-- SOURCE: 54_PERSONAL_BASELINE_ANOMALY_AND_FORECAST_ENGINE.md -->

# PERSONAL BASELINE, ANOMALY AND FORECAST ENGINE

## Purpose

Distinguish a person's own normal range/trajectory from population reference data.

## Personal baseline

A baseline has:
- metric,
- profile,
- time window,
- inclusion/exclusion rules,
- source types,
- estimator,
- version.

Possible estimators:
- median,
- mean,
- trimmed mean,
- rolling median,
- model-specific expected value.

## Personal reference band

Possible deterministic band:
- percentile band,
- median ± robust dispersion,
- model-derived interval.

Do not call a personal reference band a clinical reference range.

## Anomaly

An anomaly is:
`unexpected relative to the configured personal baseline/model`.

It is not automatically clinically abnormal.

## Robust deviation

For robust data:
`RobustZ = (x - median) / (1.4826 × MAD)`

when MAD > 0 and assumptions are acceptable.

## Population vs personal

Display separately:
- laboratory/provider reference interval,
- population guideline/target when applicable,
- personal baseline band.

Do not merge them.

## Forecast

Forecasts may be used for:
- trend continuation,
- expected mission load,
- training progression,
- weight trend,
- selected physiological series.

Forecasts must be deterministic and versioned.

Possible models:
- linear trend,
- exponential smoothing,
- domain-specific validated model.

## Forecast uncertainty

Every forecast should expose:
- horizon,
- method,
- training window,
- uncertainty/limitations.

## No diagnosis

An anomaly or forecast does not diagnose disease.

## Missingness

Do not forecast when sample count/quality fails the rule-defined minimum.


---

<!-- SOURCE: 55_PORTABLE_EXPORT_BACKUP_AND_RESTORE_FORMAT.md -->

# PORTABLE EXPORT, BACKUP AND RESTORE FORMAT

## Goal

A user's complete health system should survive:
- device change,
- app reinstall,
- ChatGPT memory reset,
- backend migration.

## Full portable bundle

A full export can contain:

- manifest,
- profile metadata,
- canonical health events/facts,
- specialized entities,
- timeline references,
- corrections/revisions,
- decision records,
- model/rule/content versions,
- score results,
- comparison profiles/scenarios,
- Daily Missions history,
- education progress,
- wearable provenance,
- attachments or attachment manifest,
- sync metadata necessary for restore where safe,
- schema version.

## Bundle rules

- deterministic schema version,
- file hashes,
- no hidden dependence on conversation memory,
- sensitive data warning,
- optional encryption,
- clear created_at/exported_at.

## Restore

Restore should:
1. validate manifest/checksums,
2. inspect schema version,
3. migrate if supported,
4. detect identity collision,
5. preserve event IDs,
6. preserve corrections,
7. preserve model/result versions,
8. preserve provenance,
9. verify counts and key relationships,
10. report skipped/unmapped fields.

## Merge vs replace

Restore UI must distinguish:
- merge into current account/profile,
- create separate imported profile,
- destructive replace when explicitly supported.

Do not silently merge duplicates.

## Selective export

Allow:
- Labs only,
- Nutrition only,
- selected date range,
- comparison profile,
- full health history.

## Privacy

Export is highly sensitive.
Warn users and avoid automatic public/share destinations.

## Developer handoff connection

The same philosophy applies to project development:
critical project state belongs in files/repository, not ChatGPT memory.


---

<!-- SOURCE: 56_CONTINUOUS_FORGE_DEVELOPMENT_LOOP.md -->

# CONTINUOUS FORGE DEVELOPMENT LOOP

## Purpose

The user wants Longevity App / Human Health OS to be continuously enriched.

This does NOT mean background autonomous work.

It means every explicit future `Forge` continuation resumes from the latest verified handoff and performs the next useful bounded improvement.

## Loop

1. RESOLVE CURRENT
   - read latest handoff state,
   - verify package/manifest when available,
   - preserve previous verified release.

2. AUDIT PURPOSE
   - ask: what prevents the system from better modeling, teaching, comparing or orchestrating human health?

3. DISCOVER GAPS
   Inspect:
   - data coverage,
   - domain coverage,
   - mathematics,
   - evidence,
   - UI,
   - interoperability,
   - privacy,
   - offline behavior,
   - testing,
   - implementation handoff.

4. RANK
   Rank candidate improvements by:
   - user value,
   - foundational leverage,
   - safety,
   - dependency readiness,
   - avoidance of duplication.

5. SELECT ONE COHERENT INCREMENT
   Do not generate version churn for cosmetic wording only.

6. SPECIFY
   Update:
   - product requirement,
   - data model,
   - user flow,
   - math/rule model,
   - API/architecture if affected,
   - failure mode,
   - acceptance tests,
   - build prompt.

7. HUMAN OS DONOR CHECK
   Ask whether an accessible donor method can improve the increment.
   Preserve receiver identity/private-state firewall.

8. STATIC AUDIT
   - JSON parse,
   - requirement→test traceability,
   - contradiction scan,
   - package integrity,
   - previous hard-constraint retention.

9. PACKAGE
   Create:
   - versioned handoff ZIP,
   - master handoff,
   - build prompt,
   - SHA-256.

10. STOP RULE
   Stop the current Forge turn when:
   - selected increment is coherent,
   - static gates pass,
   - no critical contradiction remains.

Then wait for the next explicit Forge call.

## No fake continuous work

Do not claim:
- background execution,
- automatic future versions,
- silent web research,
- scheduled development,
unless an actual supported automation is explicitly created.

## Next-increment selection

If the user supplies a specific new idea, that idea outranks generic backlog discovery.

If the user only says `Forge`, choose the highest-value READY gap in the latest handoff.

## No version bump rule

If audit finds no material useful delta, report NO_OP rather than incrementing a version.


## v0.10 audit heuristic
After data-trust/governance is specified, future Forge increments should prefer unresolved structural gaps over simply adding more health-category names. Candidate areas include accessibility/inclusive design, notifications/calendar, clinician/export views, implementation reference tests, deployment/observability and market/regulatory boundaries when they materially improve the handoff.


## v0.11 next-gap heuristic

After the production shell, prefer:
- concrete end-to-end reference implementation contract,
- screen-by-screen visual state specifications,
- database/API migration fixtures,
- test-data generators,
- benchmark/performance budgets,
- packaging for future coding agent,
over adding more category names unless the user supplies a new product idea.


## v0.12 next-gap heuristic

After implementation ambiguity is reduced, the next generic Forge should prefer:
- concrete module contracts/API schemas that remain under-specified,
- visual component/token/state handoff,
- clinically relevant evidence/model pack catalog design,
- developer bootstrap scripts/repository scaffold specification,
- disaster recovery and data-integrity drills,
rather than broadening category taxonomy without a user-requested need.


## v0.13 next-gap heuristic

After component/module/bootstrap/recovery contracts, future Forge should prioritize either:
- complete domain-by-domain API/schema catalogs,
- visual design tokens and responsive layout blueprints,
- package/model/rule fixture implementations,
- formal data-retention/deletion matrix,
- production acceptance dossier,
whichever most reduces implementation ambiguity.


## v0.14 next-gap heuristic

After domain/API/retention/release-evidence closure, the next default Forge should prioritize:
- executable schema/contract examples,
- concrete algorithm/model pack starter catalog,
- onboarding/demo/reference datasets,
- complete end-user documentation/help system,
- licensing/third-party attribution matrix,
- source-code generation handoff ergonomics,
if those produce a material implementation delta.


## v0.15 direct-output rule

Each future handoff release should preserve the dedicated interactive Site Lab build prompt unless explicitly retired.

When Site behavior changes materially, update both:
- Site contract
- Site build prompt

Do not let the Site drift into contradicting production-app health semantics.


## v0.16 next-gap heuristic

After starter packs and executable schemas exist, the next default Forge should prefer:
- complete end-user onboarding/help/reference manual,
- exact pack fixture/golden vectors and reference implementation snippets,
- clinician-facing structured export examples,
- complete database DDL/index/constraint blueprint,
- or release/legal attribution page generation,
whichever most reduces implementation ambiguity.


## v0.17 next-gap heuristic

After golden vectors + database kernel + onboarding exist, default next Forge should prefer:
- complete migration sequence/examples and server row-level authorization design,
- structured clinician/FHIR export mapping examples,
- exact rule/model pack golden fixtures for more domains,
- UX visual tokens/component snapshots,
- or an executable repository bootstrap scaffold,
whichever most reduces coding-agent ambiguity without pretending production implementation exists.


## v0.18 next-gap heuristic

After migration/auth/repository/FHIR contracts exist, the next default Forge should prefer:
- exact API endpoint authorization matrices and OpenAPI starter document,
- complete local/server migration receipts + rollback drills,
- UI design tokens/component-state snapshots,
- domain-specific calculation/reference packs with legitimate sources,
- or build-agent delivery checklist automation.


## v0.19 next-gap heuristic

After OpenAPI/rollback/UI/delivery automation, prefer:
- concrete full API resource coverage and OpenAPI-generated fixture tests,
- platform-specific HealthKit/Health Connect adapter contracts,
- deterministic nutrition/recipe computation fixtures,
- clinical/domain source packs that can be lawfully and reproducibly integrated,
- or a first real implementation bootstrap if execution environment supports Flutter/backend builds.


## v0.20 next-gap heuristic

After health-platform adapters + nutrition math + expanded API coverage, prefer:
- documents/attachments ingestion and lab-report parsing contract,
- medication/supplement interaction source architecture,
- preventive screening/vaccination rule packs with lawful evidence sources,
- exact API schemas for treatments/function/exposome/documents,
- or a real compiled implementation bootstrap when Flutter/backend toolchains are available.


## v0.21 next-gap heuristic

After secure document ingestion, prefer:
- medication/supplement interaction source architecture and deterministic interaction graph,
- preventive vaccination/screening rule packs with jurisdiction/evidence versioning,
- exact treatment/function/exposome API schemas,
- document parser corpus/evaluation harness,
- or a real compiled implementation bootstrap when target toolchains are available.


## v0.22 next-gap heuristic

After medication/supplement identity and safety architecture, prefer:
- preventive screening/vaccination rule-pack architecture,
- laboratory reference-range and critical-value source governance,
- condition-specific care-plan/episode templates,
- medication knowledge refresh/diff tooling and curator workflow,
- or real compiled implementation bootstrap if target build toolchains are available.


## v0.23 next-gap heuristic

After preventive-care engine and guideline governance, prefer:
- laboratory reference-range / critical-value governance,
- preventive source-ingestion curator tooling and rule-diff UI,
- condition-specific care-plan/episode templates,
- medication/preventive knowledge refresh automation,
- or real compiled implementation bootstrap when target toolchains are available.

## v0.24 next-gap heuristic

After lab interpretation governance and identifier repair, prefer:
- real lawful lab terminology/analyte mapping and reference-source adapters,
- condition-specific care-plan/episode templates,
- medication/preventive knowledge refresh/diff curator workflow,
- device measurement-quality/calibration provenance,
- or first compiled app/backend bootstrap when target toolchains are available.


---

<!-- SOURCE: 57_DATA_QUALITY_PROVENANCE_AND_UNCERTAINTY_ENGINE.md -->

# DATA QUALITY, PROVENANCE AND UNCERTAINTY ENGINE

## Purpose

A health number is not trustworthy merely because it exists.

Every important datum should be interpreted together with source, acquisition method, unit, timestamp, recency, precision, completeness, plausibility, conflict status and model applicability.

## DataQualityProfile

Track: source_quality, measurement_quality, recency, completeness, consistency, identity_match, unit_validity, plausibility, conflict_state, overall_quality_class and quality_notes.

Suggested classes: HIGH, MODERATE, LOW, UNKNOWN, INVALID.

These are data-quality labels, not medical-risk labels.

## Provenance

Every canonical health record should support origin type/system/provider, device where applicable, external record ID, recorded/imported time, effective/measurement time, transformation and conversion history, corrections, source-document reference and verification state.

Suggested verification states: USER_ENTERED, DEVICE_MEASURED, PROVIDER_IMPORTED, DOCUMENT_EXTRACTED_UNVERIFIED, DOCUMENT_EXTRACTED_CONFIRMED, CLINICIAN_SOURCE_REPORTED, DERIVED, SYNTHETIC, UNKNOWN.

## Conflict states

NONE, DUPLICATE_CANDIDATE, VALUE_CONFLICT, UNIT_CONFLICT, IDENTITY_CONFLICT, TIME_CONFLICT, SOURCE_CONFLICT, UNRESOLVED.

Conflicts remain visible until deterministically resolved or explicitly corrected.

## Plausibility

Rules may detect impossible values, dates, units, ordering, or improbable-but-possible values. Output: ACCEPT, REVIEW or REJECT_INVALID. Medically unusual does not automatically mean invalid.

## Precision

Preserve source precision. Do not turn 5.2 into 5.200000 and imply extra measurement precision.

## Missingness taxonomy

Distinguish NOT_MEASURED, NOT_REPORTED, UNKNOWN, NOT_APPLICABLE, WITHHELD, IMPORT_FAILED, UNMAPPED, PENDING and INVALID.

## Derived-result quality

Derived results inherit limitations from their critical inputs. A quality formula, if used, must be versioned and explainable.

## User-facing questions

Every important result should be able to answer: where did the data come from, when was it measured, what units were used, was it converted, what is missing, are there conflicts, and how confident is the calculation?


---

<!-- SOURCE: 58_MEASUREMENT_DEVICE_CALIBRATION_AND_UNIT_ENGINE.md -->

# MEASUREMENT, DEVICE, CALIBRATION AND UNIT ENGINE

## Purpose

Prevent unit collisions, device ambiguity and false precision.

## Quantity model

A numeric measurement supports numeric value, original unit text, canonical unit code, optional normalized value/unit, conversion rule/version, measurement time, source/device, precision/resolution, reported uncertainty and measurement context.

## Canonical units

Use a machine-readable canonical unit strategy compatible with UCUM principles. Store both original source unit text and canonical unit code. Never discard the source representation.

## Commensurability

Before conversion verify compatible quantities.

Examples: mass↔mass may be convertible; concentration↔concentration may be convertible when bases align; mass concentration↔molar concentration requires analyte identity/molar mass; mL↔g requires density/context; mg/dL↔mmol/L may require analyte-specific conversion.

Do not guess conversions.

## Conversion record

Record conversion_id, source value/unit, target value/unit, formula, constants, analyte/context, rule version and calculated_at.

## MeasurementDevice

Fields: id, manufacturer, model, device type, serial/hash optional, firmware optional, source platform, calibration state, calibration date and notes.

## Calibration

Calibration metadata may include date, method, reference device, next due date and status. Never invent calibration status.

## Repeated measurements

Support measurement sessions preserving every reading. Mean/median/selected protocol result may be calculated only under an explicit rule/protocol.

## Outliers

Never silently delete an outlier. States: INCLUDED, FLAGGED, EXCLUDED_BY_RULE, EXCLUDED_BY_USER_WITH_REASON.

## UI

Display preferred units only when safe conversion exists. Source and canonical history remain preserved.


---

<!-- SOURCE: 59_MODEL_REGISTRY_VALIDATION_AND_GOVERNANCE.md -->

# MODEL REGISTRY, VALIDATION AND GOVERNANCE

## Purpose

A formula must not enter production merely because it exists.

## Model Registry entry

Required metadata: model_id, name, version, domain, model_type, endpoint, time_horizon, input definitions, output semantics, eligibility, exclusions, training population, validation population, calibration information, performance information when available, uncertainty semantics, missing-data policy, intended use, prohibited uses, source/publication, implementation reference, license, effective_from, retired_at, status and local pack checksum when applicable.

## Statuses

CANDIDATE, REVIEWED, APPROVED_APP_COMPOSITE, APPROVED_VALIDATED_EXTERNAL, RESEARCH_ONLY, DEPRECATED, RETIRED, BLOCKED.

APPROVED_VALIDATED_EXTERNAL means implementation/intended-use metadata was reviewed. It does not mean the app performed its own clinical validation.

## Eligibility gate

Before calculation check required inputs, age/population constraints, disease/exclusion status, units, missing-data rule and model status.

Outputs: ELIGIBLE, NOT_ELIGIBLE, MISSING_INPUTS, MODEL_RETIRED, BLOCKED, UNKNOWN.

## Golden fixtures

Each deterministic mathematical model should have reference fixtures containing input, expected output/tolerance, model version and source/reference. Fixtures test arithmetic implementation, not clinical validity.

## Calibration and transport

Retain calibration information where available and flag population mismatch/recalibration concerns. Never assume perfect transportability across populations.

## Retirement

Retired models remain interpretable for historical results but are blocked for new production calculations unless explicitly allowed for research/reproduction.

## Reproducibility

Same inputs, preprocessing, model version and pack checksum must produce the same deterministic output.


---

<!-- SOURCE: 60_RULE_PACK_GOVERNANCE_AND_SAFETY.md -->

# RULE PACK GOVERNANCE AND SAFETY

## Purpose

Daily Missions, alerts, education triggers, interaction warnings and progression rules are deterministic but still require governance.

## RulePack metadata

rule_pack_id, version, domain, locale, rules, evidence/source references, intended/prohibited use, severity classes, effective_from, retired_at, checksum and status.

Statuses: DRAFT, REVIEWED, ACTIVE, DEPRECATED, RETIRED, BLOCKED.

## Rule structure

Each rule defines rule_id, version, prerequisites, inputs, condition, output/action, rationale, safety constraints, source/evidence and failure behavior.

## Default-deny safety

If a safety-critical rule requires missing/conflicting/invalid data, return INSUFFICIENT_DATA, REVIEW_REQUIRED or BLOCKED instead of fabricating eligibility.

## Precedence

Define explicit precedence. Example: safety block > clinician-entered restriction > recovery/treatment restriction > monitoring > plan/progression > optional optimization.

If active rules conflict and no precedence resolves it, block affected action and expose the conflict.

## Effective dates

New rule versions apply prospectively by default. Historical missions/results retain the rule version actually used.

## Tests

Each rule pack should include positive, negative, boundary, missing-data and conflict fixtures.

## Explainability

Example: “Mission generated because RULE-X v1.4 matched inputs A/B/C.”


---

<!-- SOURCE: 61_REFERENCE_POPULATIONS_AND_BENCHMARKING.md -->

# REFERENCE POPULATIONS AND BENCHMARKING

## Purpose

Compare to appropriate reference populations without turning population statistics into personal destiny.

## ReferenceDataset

Fields: dataset_id, version, population, geography, period, age definition, sex-related dimension when scientifically required, inclusion/exclusion, measurement protocol, metric definitions, percentiles/distribution, source, license and last_verified.

## Benchmark types

Population percentile, age-stratified reference, scientifically relevant sex-stratified reference, disease-specific cohort, athletic/functional cohort, laboratory metadata, national life table and healthy-life-expectancy dataset.

## Rule

Never display “better than 80% of people” without naming people where, age group, metric, dataset and version.

Percentile is descriptive, not automatically optimal, healthy, causal or desirable.

If a profile is outside dataset scope, return NOT_APPLICABLE or LOW_APPLICABILITY instead of silent extrapolation.

Historical benchmark snapshots keep their original dataset version.


---

<!-- SOURCE: 62_CONSENT_PRIVACY_ACCESS_AND_AUDIT_LEDGER.md -->

# CONSENT, PRIVACY, ACCESS AND AUDIT LEDGER

## Purpose

Know who can access what, why and when.

## Access model

Default health data access is private to the profile owner. Future sharing roles must use least privilege.

## ConsentRecord

Fields: consent_id, profile_id, purpose, data_categories, recipient/integration, granted_at, expires_at optional, revoked_at optional, policy/version and source/user action.

## Fine-grained permissions

Examples: Health Connect sleep read, HealthKit heart-rate read, document upload, export sharing, cloud sync. Do not request broad access without product need.

## AuditEvent

Fields: audit_id, actor, action, resource type/id, timestamp, device/session, result and purpose when relevant. Avoid duplicating full sensitive payloads into audit logs.

## Local-only mode

Support a local-only profile where practical. It has no cloud sync but retains deterministic offline core and may later opt into migration/sync explicitly.

## Third-party profile

Another real person's comparison profile must be clearly labeled, private/local by default, and not auto-synced/shared.

## Delete semantics

Separate hide/archive, delete record, delete module data, delete profile and delete cloud account.


---

<!-- SOURCE: 63_PERSONAL_EXPERIMENTS_AND_N_OF_1_OBSERVATION.md -->

# PERSONAL EXPERIMENTS AND N-OF-1 OBSERVATION

## Purpose

Allow observation of changes around a personal intervention without overclaiming causality.

This is not a medication-prescribing engine.

## PersonalExperiment

Fields: experiment_id, profile_id, question, hypothesis, intervention/exposure, baseline window, intervention window, follow-up window, target outcomes, confounders, stopping/safety conditions, status and created_at.

## Appropriate examples

Bedtime routine, training volume, caffeine reduction, skincare routine comparison, meal timing and other low-risk user-selected behaviors.

## High-risk boundary

Do not generate instructions to start/stop/change prescription drugs, chemotherapy, anticoagulation or other high-risk medical treatment as an app experiment. Such changes can be observed after they occur through real care decisions.

## Designs

Baseline→intervention→follow-up, A/B periods, repeated A/B when appropriate and simple interrupted time-series.

## Causality

The app may say an outcome changed during an intervention period. It must not automatically say the intervention caused the change.

## Statistical summaries

Use mean/median difference, variability, trend and appropriate effect estimates when sample size/design supports them. Do not manufacture p-values from tiny autocorrelated series.


---

<!-- SOURCE: 64_IMPORT_VALIDATION_RECONCILIATION_AND_DEDUPLICATION.md -->

# IMPORT VALIDATION, RECONCILIATION AND DEDUPLICATION

## Pipeline

RECEIVE → IDENTIFY SOURCE → PARSE → VALIDATE SCHEMA → NORMALIZE WITHOUT DESTROYING SOURCE → MAP SEMANTICS → CHECK IDENTITY → CHECK DUPLICATES → CHECK CONFLICTS → STAGE → COMMIT → RECEIPT.

## Staging

Stage rather than commit when mapping, identity, unit or duplicate/conflict status is uncertain.

## Deduplication priority

1. authoritative external ID,
2. explicit source record link,
3. exact event identity from same provider,
4. cautious fingerprint heuristic.

Similarity is evidence, not proof.

## Conflict reconciliation

Same source + same external ID may be a provider update/version. Different devices may represent legitimate separate measurements. Incompatible units remain conflict until mapped. Different timestamps are usually distinct events.

## Document extraction

Retain source document and extraction metadata where possible. Mark extracted values unverified when confirmation is required. Never invent unreadable fields.

## Import receipt

Store batch ID, source, received time, parsed count, committed count, duplicates skipped, conflicts staged, failures and schema version.

## Rollback

A bad import batch should be reversible without deleting unrelated prior history.
\n\n## v0.21 document import\nFile import adds content hash, attachment version, security state and extraction candidate staging. Exact duplicate source file is a duplicate candidate, not an instruction to duplicate structured health records.\n


---

<!-- SOURCE: 65_MODEL_RULE_CONTENT_PACK_UPDATE_CHAIN.md -->

# MODEL, RULE AND CONTENT PACK UPDATE CHAIN

## Pack types

MODEL_PACK, RULE_PACK, REFERENCE_DATA_PACK, EDUCATION_CONTENT_PACK, TERMINOLOGY_PACK, UNIT_PACK.

## Manifest

pack_id, type, version, created_at, effective_from, compatibility range, checksum, source/reference metadata, license, dependencies, supersedes and changelog.

## States

DISCOVERED, DOWNLOADED, VERIFIED, STAGED, ACTIVE, ROLLED_BACK, RETIRED, BLOCKED.

## Activation checks

Checksum, signature when supported, schema compatibility, dependency compatibility and deterministic fixture tests.

## Historical reproducibility

Old pack versions remain identifiable for historical results. Garbage collection may remove unused bytes only when interpretation/reconstruction remains possible through retained metadata/formula snapshots.

## Rollback

Deactivate failing new pack, restore prior active pack, preserve already-calculated historical outputs with their original version metadata, and never relabel them silently.

## Offline

The last verified active packs continue working offline.


---

<!-- SOURCE: 66_PERFORMANCE_TIME_SERIES_AND_STORAGE_POLICY.md -->

# PERFORMANCE, TIME-SERIES AND STORAGE POLICY

## Purpose

Wearables can generate very large data streams. The system must scale without blindly discarding meaningful detail.

## Data tiers

Tier 1: sparse canonical events/facts.
Tier 2: dense time series such as heart rate, steps, sensor streams and sleep stages.
Tier 3: derived aggregates such as daily resting HR and trend features.

## Raw retention

Retention is data-type/policy specific. Do not delete source samples solely because an aggregate exists unless policy explicitly permits it and the ownership/export contract remains satisfied.

## Downsampling

Use raw data for short windows and deterministic aggregates for long windows. Visualization downsampling must not rewrite canonical raw records.

## Aggregate provenance

Store source series/range, aggregation formula, window, timezone and version.

## Indexing

Index by profile/user, domain/type, observed/effective time, source/external ID and sync revision.

## Attachments

Large documents/photos use blob/object storage abstraction with database metadata, access control, hash, size/type and retention policy.

## Resource constraints

Comparison supports arbitrary stored profiles but may virtualize/paginate large views.

## Battery

Wearable import/sync should use platform-appropriate background scheduling and avoid unnecessary polling.


---

<!-- SOURCE: 67_TECHNICAL_STANDARDS_SOURCE_REGISTER.md -->

# TECHNICAL STANDARDS SOURCE REGISTER

Implementation time must re-verify current versions.

## SRC-UNIT-001 — UCUM

Name: Unified Code for Units of Measure
Official: https://ucum.org/
Checked: 2026-10-05
Observed specification during check: UCUM 2.2, dated 2024-06-17.
Receiver use: canonical unit-code strategy and unit commensurability/conversion discipline.
Important: re-check exact current release and license at implementation time.

## SRC-FHIR-001 — HL7 FHIR

Name: Fast Healthcare Interoperability Resources
Official release directory: https://hl7.org/fhir/directory.html
Checked: 2026-10-05
Observed: FHIR R5 5.0.0 is listed as the published current release; R6 entries are in a work-in-progress/development sequence.
Receiver use: interoperability adapter architecture only.
The internal canonical schema must not be made identical to one FHIR release.

## Freshness rule

Technical standards metadata must include source URL, checked date, standard/version, implementation impact and license notes where relevant. Handoff-time version is not permanent truth.


## SRC-A11Y-001 — WCAG 2.2

Official:
https://www.w3.org/WAI/standards-guidelines/wcag/

Checked:
2026-10-05

Observed:
WCAG 2.2 is a W3C Recommendation. W3C encourages use of the latest WCAG 2 version.

Receiver use:
web accessibility target and cross-platform accessibility design reference.

## SRC-MOBILESEC-001 — OWASP MASVS

Official:
https://mas.owasp.org/MASVS/

Checked:
2026-10-05

Observed control groups:
storage, cryptography, authentication, network, platform, code, resilience, privacy.

Receiver use:
mobile security verification baseline.

## SRC-ANDROIDSEC-001 — Android Keystore

Official:
https://developer.android.com/privacy-and-security/keystore

Checked:
2026-10-05

Receiver use:
secure key-material strategy for Android.

## SRC-APPLESEC-001 — Apple Keychain Services

Official:
https://developer.apple.com/documentation/security/keychain-services

Checked:
2026-10-05

Receiver use:
secure storage of small app/user secrets on Apple platforms.

## SRC-IOSNOTIFY-001 — Apple UserNotifications

Official:
https://developer.apple.com/documentation/usernotifications/unusernotificationcenter

Checked:
2026-10-05

Receiver use:
iOS local notification permission/scheduling adapter.

## SRC-ANDROIDALARM-001 — Android exact alarms

Official:
https://developer.android.com/about/versions/14/changes/schedule-exact-alarms

Checked:
2026-10-05

Receiver use:
avoid assuming exact alarm permission is universally available/pregranted; use precise alarms only where justified.


## SRC-FDC-LICENSE-002 — USDA FoodData Central

Official:
https://fdc.nal.usda.gov/api-guide/

Checked:
2026-10-06

Observed:
FoodData Central states its data are public domain / CC0 1.0 and requests source citation.
API use requires a data.gov API key; keys exposed publicly may be deactivated.

Receiver:
food provider adapter + attribution + secret-management requirement.

## SRC-OFF-LICENSE-002 — Open Food Facts

Official:
https://openfoodfacts.github.io/documentation/docs/Product-Opener/api/tutorials/license-be-on-the-legal-side/

Checked:
2026-10-06

Observed:
database ODbL; individual contents Database Contents License; product images CC BY-SA with possible other embedded rights.

Receiver:
provider adapter + attribution/licensing review; do not bundle giant snapshot by default.

## SRC-WHO-DATA-LICENSE-002 — WHO data.who.int datasets

Official:
https://data.who.int/about/data/terms-and-conditions

Checked:
2026-10-06

Observed:
unless specifically indicated otherwise, datasets are under CC BY 4.0 plus WHO dataset terms; attribution is required and WHO endorsement must not be implied.

Receiver:
life-expectancy/HALE reference pack license and attribution gate.

## SRC-AHA-PREVENT-LICENSE-002 — AHA PREVENT code access

Official:
https://professional.heart.org/en/guidelines-and-statements/about-prevent-calculator

Checked:
2026-10-06

Observed:
AHA provides access to PREVENT source code at no cost through a license agreement; applicants must accept terms before code access.

Receiver:
PREVENT remains LICENSE_ACCEPTANCE_REQUIRED_NOT_BUNDLED until implementation clears the gate.


## SRC-HEALTHCONNECT-020 — Android Health Connect permissions/data types

Official:
https://developer.android.com/health-and-fitness/health-connect/data-types
https://developer.android.com/health-and-fitness/health-connect/ui/permissions
https://developer.android.com/health-and-fitness/health-connect/metadata

Checked:
2026-10-06

Observed:
- Health Connect exposes data-type-specific permissions.
- background read and extended historical read are separate access capabilities/permissions.
- user-facing app settings should expose sync/access controls.
- record metadata includes recording-method semantics such as manual/automatic/active/unknown.

Receiver:
Android health-platform adapter and provenance/permission state.

Implementation rule:
re-check current SDK record classes/permissions/Play declaration requirements before release.

## SRC-HEALTHKIT-020 — Apple HealthKit authorization

Official:
https://developer.apple.com/documentation/healthkit/authorizing-access-to-health-data
https://developer.apple.com/documentation/healthkit/hkhealthstore

Checked:
2026-10-06

Observed:
- HealthKit requires fine-grained read/write authorization per requested type.
- HealthKit capability and purpose strings are required for intended access.
- privacy behavior means the app cannot simply infer read-authorization success from an empty query.
- current documentation describes full, limited-history, or no read access and exposes earliest authorized sample date APIs.

Receiver:
Apple health-platform adapter, coverage and permission-uncertainty semantics.

Implementation rule:
re-check target iOS/HealthKit APIs, entitlements and App Review requirements at build/release time.


## SRC-RXNORM-022 — NLM RxNorm / RxNav

Official:
https://www.lhncbc.nlm.nih.gov/RxNav/APIs/RxNormAPIs.html
https://www.nlm.nih.gov/research/umls/rxnorm/docs/rxnormfiles.html

Checked:
2026-10-06

Observed:
- RxNorm API exposes normalized RxNorm concepts and current/historical scopes.
- current API/version endpoint reports the active RxNorm dataset/API version.
- most RxNorm API access does not require a license under NLM terms; release-file licensing differs by distribution.
- current prescribable content is separately published.
- NLM requests attribution/no-endorsement language for applications using NLM data.

Receiver:
drug identity normalization, source/version metadata, attribution.

Boundary:
not treated as a complete interaction database.

## SRC-DAILYMED-022 — DailyMed SPL web services

Official:
https://dailymed.nlm.nih.gov/dailymed/app-support-web-services.cfm

Checked:
2026-10-06

Observed:
- DailyMed v2 REST services expose current Structured Product Labeling information.
- version/history and label download mechanisms exist.
- labels can support ingredient, warnings, contraindications, interactions and dosage evidence.

Receiver:
versioned drug-label evidence adapter.

## SRC-OPENFDA-LABEL-022 — openFDA drug labeling

Official:
https://open.fda.gov/apis/drug/label/searchable-fields/
https://open.fda.gov/about/status/

Checked:
2026-10-06

Observed:
- searchable drug-label fields include active ingredient, contraindications, drug interactions and dosage-related sections.
- drug-label endpoint status was current on 2026-10-05 in the checked service status.
- openFDA states its data should not be relied on alone for medical-care decisions.

Receiver:
label search/indexing and evidence discovery; not sole automatic safety-rule authority.

## SRC-DSLD-022 — NIH ODS Dietary Supplement Label Database

Official:
https://ods.od.nih.gov/Research/Dietary_Supplement_Label_Database.aspx

Checked:
2026-10-06

Observed:
DSLD catalogs supplement label images, ingredient names/forms, ingredient amounts and label statements and is regularly updated.

Receiver:
supplement product/ingredient/serving composition and label provenance.

Boundary:
not treated as a complete interaction or efficacy database.

## SRC-ODS-FACTSHEETS-022 — NIH ODS Dietary Supplement Fact Sheets

Official:
https://ods.od.nih.gov/factsheets/list-all/

Checked:
2026-10-06

Observed:
ODS fact sheets provide evidence-based information on supplement ingredients, including safety and interactions with medicines for many topics.

Receiver:
curated supplement safety/interaction evidence and education.


## SRC-CDC-PREVENTIVE-023 — CDC immunization schedules

Official:
https://www.cdc.gov/vaccines/hcp/imz-schedules/
https://www.cdc.gov/vaccines/hcp/imz-schedules/adult-age-compliant.html
https://www.cdc.gov/vaccines/hcp/imz-schedules/adult-medical-condition-compliant.html

Checked:
2026-10-06

Observed:
- CDC provides adult immunization views by age and medical condition/other indication.
- the checked official pages identify the July 2, 2025 schedule as the current/compliant adult schedule.
- the pages describe a March 16, 2026 court order affecting later ACIP votes/changes.

Receiver:
U.S. vaccination GuidelinePack source snapshots.

Architecture consequence:
current calendar year must not be substituted for source version/current-status evidence.

## SRC-USPSTF-023 — USPSTF preventive recommendations and grades

Official:
https://www.uspreventiveservicestaskforce.org/uspstf/recommendation-topics
https://www.uspreventiveservicestaskforce.org/uspstf/about-uspstf/methods-and-processes/grade-definitions

Checked:
2026-10-06

Observed:
- USPSTF publishes preventive service recommendations for defined primary-care populations.
- native recommendation classes include A, B, C, D and I statement.
- Grade C is selective/shared-decision oriented.
- I means evidence is insufficient to assess benefit/harm balance.

Receiver:
U.S. screening/preventive-service rule source and native-grade metadata.

## SRC-WHO-PREVENTIVE-023 — WHO immunization and screening references

Official:
https://www.who.int/teams/immunization-vaccines-and-biologicals/policies/who-recommendations-for-routine-immunization---summary-tables
https://www.who.int/publications/i/item/9789289054782

Checked:
2026-10-06

Observed:
- WHO routine immunization summary tables support programme managers across age groups.
- WHO screening guidance emphasizes evidence, potential harms and quality assurance.

Receiver:
global reference/education and programme-design metadata.

Boundary:
not an automatic national personal schedule.

## SRC-TR-MOH-PREVENTIVE-023 — Türkiye Ministry of Health vaccination sources

Official:
https://asi.saglik.gov.tr/kimlere-asi-yapilir/eriskin-asilama.html
https://asi.saglik.gov.tr/

Checked:
2026-10-06

Observed:
- Ministry sources publish adult vaccination information.
- Ministry-affiliated 2026 pages report active childhood-schedule updates.

Receiver:
candidate Türkiye jurisdiction pack.

Boundary:
no Türkiye clinical rule pack is activated until exact central current source/version reconciliation and fixture review are completed.

## SRC-CLSI-EP28-024 — Reference intervals
Official: https://clsi.org/shop/standards/ep28/
Checked: 2026-10-06
Observed: CLSI EP28 Third Edition defines/establishes/verifies quantitative clinical laboratory reference intervals; CLSI states the document was reaffirmed as suitable in 2020. EP28IG (2022) gives a practical verification guide.
Receiver: ReferenceIntervalSnapshot governance. No numerical range table bundled.

## SRC-CLSI-GP47-024 — Critical/significant-risk results
Official: https://clsi.org/shop/standards/gp47/
Checked: 2026-10-06
Observed: GP47 addresses identification, reporting and management of laboratory results needing urgent clinical review and emphasizes local policies/processes.
Receiver: CriticalRule governance and notification-receipt boundary. No universal threshold table bundled.

## SRC-CLSI-EP09-024 — Method comparison / bias
Official: https://clsi.org/shop/standards/ep09/
Checked: 2026-10-06
Observed: current listed EP09 Third Edition covers measurement-procedure comparison and bias estimation using patient samples. CLSI also reports revision work underway; implementation must recheck current edition.
Receiver: MethodComparabilityRecord architecture.

## SRC-CLSI-EP33-024 — Delta checks
Official: https://clsi.org/shop/standards/ep33/
Checked: 2026-10-06
Observed: EP33 Second Edition (2023) provides guidance for selecting/establishing delta-check limits and evaluating changes between consecutive results.
Receiver: delta-check metadata and evidence boundary.

## SRC-IFCC-CRIDL-024 — Reference intervals and decision limits
Official: https://ifcc.org/ifcc-scientific-division/sd-committees/c-ridl/
Checked: 2026-10-06
Observed: IFCC C-RIDL focuses on reference intervals and decision limits and global sources of variation.
Receiver: separation of population reference intervals from clinical decision limits and source discovery.


---

<!-- SOURCE: 68_SECURE_LOCAL_STORAGE_KEY_MANAGEMENT_AND_APP_LOCK.md -->

# SECURE LOCAL STORAGE, KEY MANAGEMENT AND APP LOCK

## Purpose

Longevity App stores sensitive health information. Local-first must not mean insecure-by-default.

## Key-management principle

Use platform-native secure key facilities for cryptographic key material:

- Android: Android Keystore
- Apple platforms: Keychain / platform security APIs
- Web: browser/platform security primitives appropriate to the selected architecture

Do not hard-code encryption keys into the application package.

## Android

Use Android Keystore-backed keys for app-controlled cryptographic operations.

Important:
- keys may be non-exportable,
- usage constraints can be configured,
- hardware-backed protection may be available depending on device.

Do not depend on deprecated convenience wrappers when current platform guidance recommends lower-level/current mechanisms.

## Apple

Use Keychain for small secrets such as:
- authentication tokens,
- encryption key references/material where appropriate,
- device/session secrets.

Do not store large health databases directly in Keychain.

## Local database protection

The implementing agent must choose a maintained, platform-compatible strategy for protecting local health data at rest.

Requirements:
- no plaintext secret in source,
- key separated from protected data,
- key rotation/migration strategy,
- restore behavior documented,
- device-lock behavior documented,
- failure/recovery behavior documented.

## App lock

Optional:
- biometric unlock,
- device credential/passcode-backed unlock,
- configurable privacy timeout.

App lock protects casual/local access. It is not a substitute for server authentication or OS security.

## Sensitive screen protection

Where platforms support it, consider:
- hiding sensitive previews in app switcher,
- preventing unintended screenshots only when justified,
- hiding selected sensitive modules from dashboard.

Do not claim screenshot prevention is universally enforceable.

## Tokens

Authentication tokens:
- stored using secure platform facilities,
- scoped minimally,
- rotated/revoked when appropriate,
- never written to normal logs.

## Key loss

The system must define what happens if device keys are lost.

Possible outcomes:
- re-authenticate and re-download cloud-backed data,
- restore an encrypted backup,
- local-only data may be unrecoverable if no export/backup exists.

The app must not falsely promise recoverability.

## Backup interaction

Encryption keys and encrypted databases must have compatible backup/restore policies.

A backup that restores ciphertext without its required key is not a valid restore strategy.

## Acceptance

Security implementation must be tested against:
- locked/unlocked device states,
- reinstall,
- device migration,
- token revocation,
- failed biometric,
- key loss,
- backup restore.


---

<!-- SOURCE: 69_AUTHENTICATION_SESSION_DEVICE_AND_ACCOUNT_RECOVERY.md -->

# AUTHENTICATION, SESSION, DEVICE AND ACCOUNT RECOVERY

## Purpose

Provide secure account access without making cloud identity mandatory for local-only users.

## Account modes

### LOCAL_ONLY
- no cloud identity required,
- local deterministic core works,
- optional later migration to cloud account.

### CLOUD_ACCOUNT
- authenticated server identity,
- sync across devices,
- remote backup where enabled.

## Authentication

Use a maintained production authentication architecture.

Possible supported methods:
- passkey,
- password,
- federated sign-in,
- platform-supported credentials.

The exact mechanism is an implementation decision and must be threat-modeled.

## Session model

Session metadata:
- session_id
- user_id
- device_id
- created_at
- last_seen_at
- expires_at
- auth_strength
- revoked_at
- client/app version
- risk flags.

## Device registry

A cloud account can show recognized devices:
- device label,
- platform,
- first/last seen,
- current/revoked status.

Users can revoke old devices.

## Reauthentication

Sensitive actions may require reauthentication:
- full export,
- account deletion,
- security settings change,
- adding a new recovery method,
- sharing third-party data.

## Account recovery

Recovery design must avoid:
- storing plaintext passwords,
- weak security questions,
- silently bypassing user authentication.

Recovery choices depend on auth provider and must be documented.

## Local-only migration

When a LOCAL_ONLY user creates a cloud account:
1. authenticate,
2. create server profile,
3. stage local records,
4. deduplicate/validate,
5. upload with provenance,
6. verify counts/receipts,
7. preserve local data until sync confirmation.

## Session invalidation

Support:
- sign out current device,
- revoke another device,
- revoke all sessions,
- password/passkey/security-reset invalidation as appropriate.

## Offline

Cached authenticated mobile sessions may allow local use while offline according to the security policy.

Offline mode must not fabricate server authorization for actions requiring server access.


---

<!-- SOURCE: 70_NOTIFICATIONS_REMINDERS_SCHEDULER_AND_CALENDAR.md -->

# NOTIFICATIONS, REMINDERS, SCHEDULER AND CALENDAR

## Core rule

A reminder is not proof of completion.

Notification delivery, notification open, mission completion and health event completion are separate states.

## Reminder entity

### Reminder
- id
- profile_id
- type
- title
- schedule
- timezone
- source_plan_id optional
- enabled
- priority
- quiet_hours_policy
- platform_schedule_id optional
- created_at
- updated_at.

## Types

- medication/supplement reminder
- measurement reminder
- Daily Mission
- workout
- sleep routine
- hydration/food logging
- preventive care
- vaccination
- screening/follow-up
- rehabilitation
- education review
- appointment reminder
- custom.

## Scheduling

Support:
- one-time,
- daily,
- selected weekdays,
- interval,
- calendar-date based,
- due-date based,
- event-relative when deterministically supported.

## Time zone

Every schedule declares timezone semantics.

When timezone changes:
- fixed-local-time reminders may follow local clock,
- fixed-instant reminders may remain tied to an instant,
depending on reminder type.

This behavior must be explicit.

## Platform behavior

Android:
- notification permission/state must be checked,
- exact alarm APIs/permissions should be used only when the product truly requires precise timing.

iOS:
- use UserNotifications APIs and explicit user authorization.

Web:
- notifications depend on browser permission/platform support and are not assumed always available.

## Offline

Local reminders should continue offline when platform scheduling allows.

Cloud push is supplementary, not required for local Daily Missions.

## Rescheduling

If a plan changes:
- cancel/update obsolete scheduled notification,
- retain plan/history,
- do not create duplicate reminders.

## Completion

Possible states:
- SCHEDULED
- DELIVERED
- OPENED
- SNOOZED
- DISMISSED
- COMPLETED_BY_EVENT
- CANCELED.

Only `COMPLETED_BY_EVENT` can represent actual task completion.

## Snooze

Snooze changes reminder delivery, not the underlying due date/history.

## Quiet hours

User-configurable quiet hours can suppress/delay noncritical reminders.

Safety-critical user-configured medical reminders require explicit behavior rather than being silently delayed.

## Calendar

Optional calendar-style view may display:
- planned reminders,
- appointments,
- treatment sessions,
- preventive due dates,
- missions.

Calendar is a projection over plans/events, not a second source of truth.


## v0.23 Preventive reminders

Preventive reminders derive from due-state projections and source/rule versions.

Rules:
- reminder/opened/dismissed != medical completion,
- UNKNOWN_HISTORY may prompt records review rather than "overdue" alerts,
- SHARED_DECISION should not use mandatory/red overdue styling,
- guideline pack change can cancel/reschedule obsolete reminders,
- no punitive backlog stacking.


---

<!-- SOURCE: 71_ACCESSIBILITY_INCLUSIVE_DESIGN_AND_AGING_UI.md -->

# ACCESSIBILITY, INCLUSIVE DESIGN AND AGING UI

## Purpose

A health/longevity app must work for users with changing vision, hearing, dexterity, cognition and fatigue.

## Web target

Target WCAG 2.2 AA for the authenticated web app and public website unless a stricter product/legal target is selected.

## Cross-platform principles

### Perceivable
- text scaling
- sufficient contrast
- meaningful labels
- alternatives for non-text information
- do not encode health meaning by color alone.

### Operable
- keyboard support on web
- logical focus order
- sufficiently large touch targets
- avoid gesture-only critical actions
- support platform assistive technologies.

### Understandable
- plain-language explanations
- consistent navigation
- explain abbreviations
- reversible actions
- confirm destructive actions.

### Robust
- semantic controls
- accessible names/roles
- screen-reader compatible component structure.

## Aging-friendly mode

Optional display preset:
- larger default text,
- higher contrast,
- reduced information density,
- simplified Today dashboard,
- larger controls.

This is a display preference, not an assumption about chronological age.

## Cognitive load

Advanced modules can be hidden.

Use progressive disclosure:
Basic → Advanced → Expert.

Do not force users to understand all medical terminology to enter a simple measurement.

## Motion

Respect reduced-motion preferences.

Avoid using animation as the only way to communicate state.

## Charts

Charts must have:
- text summary,
- units,
- accessible data/table alternative where practical,
- focusable/inspectable points on web where feasible.

## 1–10 controls

Do not rely only on drag gestures.
Provide keyboard/tap alternatives.

## Error messages

Errors should state:
- what failed,
- what the user can do,
- whether data were saved,
- whether retry is safe.

## Accessibility testing

Release gates should include:
- screen reader smoke tests,
- keyboard-only web flow,
- text scaling,
- contrast,
- reduced motion,
- touch target review,
- chart alternative review.


---

<!-- SOURCE: 72_LOCALIZATION_UNITS_TIMEZONES_AND_CULTURAL_FORMATTING.md -->

# LOCALIZATION, UNITS, TIMEZONES AND CULTURAL FORMATTING

## Purpose

General-public software must not hard-code one language, date format or unit convention into domain logic.

## Locale

UserProfile stores:
- locale,
- language preference,
- region,
- timezone,
- preferred display unit system.

## Translation architecture

User-visible strings:
- externalized,
- keyed,
- parameterized,
- plural-aware,
- not constructed through fragile string concatenation.

## Initial language packs

Recommended initial product languages:
- Turkish
- English

The architecture must support additional locales without schema redesign.

## Clinical/source wording

Do not translate or overwrite a source label destructively.

Keep:
- original source label,
- canonical internal concept,
- localized display label.

## Units

Preferred display unit is a view concern when safe conversion exists.

Source/canonical units remain preserved.

## Dates

Store unambiguous timestamps and preserve timezone context.

Display according to locale.

Do not parse ambiguous dates such as `03/04/2027` without locale/source context.

## Numbers

Handle:
- decimal separator,
- thousands separator,
- percent format,
- unit spacing,
- localized numerals where platform supports.

Canonical numeric storage remains locale-neutral.

## Right-to-left

Architecture should not assume left-to-right only.

Even if initial release is Turkish/English, component layout should avoid unnecessary hard-coded directional assumptions.

## Education content

Content packs are locale/version specific.

Scientific claim/source identity remains independent of translation.

## Search aliases

Food, condition, analyte and exercise search can use:
- localized names,
- canonical names,
- synonyms/aliases.

Do not merge two distinct clinical concepts merely because a translation is similar.


---

<!-- SOURCE: 73_CLINICIAN_VIEW_REPORTS_AND_CONTROLLED_SHARING.md -->

# CLINICIAN VIEW, REPORTS AND CONTROLLED SHARING

## Purpose

Users may want to show structured health history to a clinician or another trusted person without giving unrestricted account access.

## Clinician view

A read-only report/view can include selected:
- profile basics,
- active conditions,
- medication/supplements,
- allergies,
- recent labs,
- vital trends,
- treatment timeline,
- symptoms,
- wearable summaries,
- functional status,
- documents.

## User control

Before generation:
- choose sections,
- choose date range,
- choose whether app-defined scores are included,
- choose whether personal experiments are included,
- choose whether notes are included.

## Report classes

- Emergency Summary
- Medication & Allergy Summary
- Lab Trend Report
- Treatment Episode Report
- Cardiovascular Summary
- Oncology Summary
- General Health Timeline
- Custom Report.

## App-defined scores

Reports must clearly label:
- validated clinical model outputs,
- app-defined composite scores,
- population baselines,
- hypothetical scenarios.

Do not make an app score look like a clinician-issued diagnosis.

## Share artifact

Possible:
- PDF
- structured JSON
- future FHIR-compatible export
- temporary secure link when cloud infrastructure supports it.

## Temporary sharing

If secure links are implemented:
- expiration,
- revocation,
- access audit,
- minimal scope,
- no indexability.

## Real-other profiles

Do not expose another person's comparison profile in a clinician report unless explicitly selected and appropriate.

## Emergency summary

Offline emergency summary may be optionally enabled.

It should not bypass app lock/privacy by default without an explicit user-selected design.

## Provenance

Every report includes:
- generated_at,
- date range,
- profile identity label,
- source/app version,
- disclaimer about user-entered/derived data.

## No medical authorship fabrication

Do not label user-entered or app-derived data as clinician-certified unless it actually came from an identified clinician/provider source.


---

<!-- SOURCE: 74_OBSERVABILITY_CRASH_RECOVERY_AND_SUPPORT.md -->

# OBSERVABILITY, CRASH RECOVERY AND SUPPORT

## Purpose

Production software must detect failures without leaking sensitive health data.

## Observability classes

- application health
- API health
- sync health
- database/migration health
- import health
- pack update health
- job/scheduler health
- performance
- crash/error events.

## Privacy-first telemetry

Default telemetry should avoid:
- raw lab values,
- diagnoses,
- free-text notes,
- exact health timelines,
- exported documents.

Prefer:
- event type,
- error code,
- module,
- app version,
- platform/version,
- coarse performance metadata,
- request ID.

## Crash report

Crash reports can include:
- stack trace,
- app version,
- device/platform,
- feature/module,
- sanitized breadcrumbs.

Sensitive content must be redacted/minimized.

## Sync diagnostics

Track:
- pending outbox count,
- oldest pending mutation age,
- last successful sync,
- last error class,
- conflict count.

Do not log raw payload by default.

## Support bundle

User may explicitly generate a support bundle containing:
- app version,
- schema version,
- active pack versions,
- device/platform metadata,
- sanitized logs,
- failed operation IDs.

Health data should be excluded by default unless the user explicitly chooses otherwise.

## Crash-safe writes

Critical writes use transactions.

On crash:
- committed transactions remain,
- partial uncommitted writes roll back,
- outbox state recovers deterministically.

## Startup recovery

Startup can verify:
- schema version,
- migration state,
- local database health,
- active pack checksums,
- interrupted import/update state.

## Safe mode

Optional safe mode may:
- disable optional packs/modules,
- open read-only,
- permit export/support bundle,
when startup detects a critical plugin/pack failure.

## Status page

Cloud backend can expose service health without exposing user information.

## Support identity

Every reported error can carry a request/error ID so support can correlate system logs without asking the user to send screenshots of sensitive data.


---

<!-- SOURCE: 75_PRODUCTION_ENVIRONMENTS_DEPLOYMENT_AND_RELEASE_OPERATIONS.md -->

# PRODUCTION ENVIRONMENTS, DEPLOYMENT AND RELEASE OPERATIONS

## Environments

At minimum:
- LOCAL/DEV
- TEST
- STAGING
- PRODUCTION

Data and credentials must not be casually shared across environments.

## Configuration

Environment-specific configuration includes:
- API base URLs,
- auth configuration,
- database endpoints,
- food-provider backend credentials,
- telemetry configuration,
- feature flags,
- pack repositories.

Secrets are never committed to source.

## Database deployment

Production migration procedure:
1. backup/restore point,
2. migration compatibility check,
3. deploy migration,
4. verify invariants,
5. deploy compatible services/clients,
6. monitor,
7. rollback/recovery plan.

## Feature flags

Use only when they improve safe rollout.

Flags must not create invisible permanent divergence of health semantics.

A model/rule version is not merely a feature flag.

## Mobile release

Android:
- release build,
- signing workflow,
- APK/AAB artifacts,
- staged rollout strategy where distribution platform supports it.

iOS:
- Xcode archive/build,
- signing/provisioning,
- TestFlight/App Store release path when credentials are available.

## Web release

- immutable/versioned asset build,
- HTTPS,
- secure headers appropriate to architecture,
- cache strategy,
- rollback to previous verified build.

## Backend release

- versioned image/artifact,
- migration compatibility,
- health checks,
- logs/metrics,
- rollback.

## Artifact provenance

A release record should include:
- git/source commit
- app version/build
- backend version
- schema version
- model/rule/content pack versions
- build date
- checksums
- test report.

## Progressive release

If supported:
- internal
- test/beta
- partial rollout
- general availability.

Do not silently migrate all users to a new clinical model merely because an app binary updated.

## Incident readiness

Production operations should define:
- severity levels,
- rollback authority,
- user communication path,
- data-integrity incident handling,
- security incident handling,
- post-incident review.

## Release honesty

A staged artifact is not deployed production.
A successful build is not a successful rollout.
A rollout is not behavioral validation.


---

<!-- SOURCE: 76_THREAT_MODEL_AND_MOBILE_SECURITY_BASELINE.md -->

# THREAT MODEL AND MOBILE SECURITY BASELINE

## Purpose

Make security testable rather than decorative.

## Threat categories

At minimum consider:
- lost/stolen device
- malicious local app
- rooted/jailbroken environment
- token theft
- account takeover
- insecure API authorization
- cross-user object access
- network interception/misconfiguration
- malicious import/file
- dependency compromise
- backup leakage
- log/telemetry leakage
- web XSS/CSRF/session issues as architecture requires
- reverse engineering/tampering
- compromised update/pack channel.

## Mobile security baseline

Use OWASP MASVS as a verification reference for relevant areas such as:
- storage
- crypto
- authentication
- network
- platform interaction
- code quality/update posture
- resilience
- privacy.

The implementation must re-check the current MASVS/MASTG at build/release time.

## Authorization

Server-side resource ownership is mandatory.

Never depend on hidden UI routes for access control.

## File import

Treat external files as untrusted.

Validate:
- MIME/type,
- size,
- parser behavior,
- storage location,
- malicious content risk.

## Web

If a web client exists, include an architecture-appropriate web threat model covering:
- session/token storage,
- XSS,
- CSRF when applicable,
- CSP/security headers,
- clickjacking,
- CORS,
- upload handling.

## Supply chain

Pin/lock dependencies.
Review:
- stale/deprecated libraries,
- known vulnerabilities,
- transitive dependencies,
- build scripts.

## Secret scanning

CI/release should fail or block when production secrets are committed.

## Security test evidence

Record:
- test/control ID,
- environment,
- result,
- finding severity,
- remediation,
- retest status.

## High-risk finding rule

A known unresolved high-risk cross-user data exposure or secret-leak defect blocks production release.


---

<!-- SOURCE: 77_REGULATORY_PRODUCT_BOUNDARY_AND_CLAIM_CONTROL.md -->

# REGULATORY PRODUCT BOUNDARY AND CLAIM CONTROL

## Purpose

Longevity App handles health information and mathematical outputs. Product claims must remain aligned with what the software actually does.

This file is not legal advice and does not claim compliance with any jurisdiction.

## Current intended product role

Primary:
- personal health tracking,
- education,
- deterministic calculation,
- visualization,
- comparison/scenario analysis,
- reminders/planning.

The app is not automatically a medical device merely because it handles health data, but some future functions/claims may trigger additional regulatory obligations depending on jurisdiction.

## Claim classes

### Tracking claim
“Record and visualize your blood pressure.”

### Educational claim
“Learn what systolic and diastolic pressure mean.”

### Calculation claim
“Calculate a published risk model when eligibility is met.”

### Decision-support claim
“Highlight configured patterns for review.”

### Diagnostic/treatment claim
“You have disease X.”
“You should take medication Y.”

Diagnostic/treatment claims require separate product/legal/clinical governance and are outside default scope.

## Claim registry

Maintain:
- claim_id
- user-facing wording
- feature
- evidence/model
- intended market
- status
- legal/clinical review status where required.

## Store listing consistency

App Store/Play/web marketing claims must match actual supported behavior.

Do not advertise:
- lifespan extension,
- disease prevention,
- diagnostic accuracy,
- treatment optimization

without adequate substantiation and appropriate product/regulatory review.

## Market launch review

Before public launch in a region, verify:
- privacy/data laws,
- consumer health rules,
- medical-device implications,
- accessibility requirements,
- app-store health policies,
- terms/privacy disclosures.

## Dynamic boundary

If future Forge adds:
- diagnostic AI,
- treatment recommendation,
- medication dosing,
- emergency triage,
- clinician decision support,

it must trigger a regulatory-boundary review before becoming production scope.


---

<!-- SOURCE: 78_REFERENCE_IMPLEMENTATION_BLUEPRINT.md -->

# REFERENCE IMPLEMENTATION BLUEPRINT

## Purpose

Convert the product specification into a concrete implementation starting point without making one technology choice more authoritative than the health/data semantics.

## Normative vs reference

### Normative
These must remain true regardless of framework:
- canonical health semantics,
- offline deterministic core,
- no generative-AI dependency,
- plan != completion,
- missing != zero,
- self-report != diagnosis,
- correction/provenance history,
- model/rule versioning,
- owner authorization,
- safe unit handling,
- comparison/scenario isolation,
- release-evidence honesty.

### Reference implementation
Preferred starting architecture:

```text
Flutter/Dart clients
  ├─ Android
  ├─ iOS
  └─ authenticated Web dashboard

Local client data layer
  ├─ SQLite-compatible mobile store
  ├─ browser-appropriate local store/cache
  └─ durable sync outbox

Backend API
  ├─ typed HTTP/REST API
  ├─ OpenAPI contract
  ├─ authentication/authorization
  ├─ food/provider adapters
  ├─ sync/change feed
  └─ export/report services

Server data
  ├─ PostgreSQL-class relational database
  └─ object/blob storage abstraction for documents
```

A future implementing agent may substitute equivalent technologies only if all acceptance criteria and offline/sync/security semantics remain satisfied.

## Client architecture

Recommended layers:
1. Presentation
2. Application/use cases
3. Domain
4. Repository interfaces
5. Local persistence
6. Remote API adapter
7. Sync engine
8. Platform adapters
9. Pack/model/rule runtime

No UI widget should directly implement clinical/scoring formulas.

## Domain package

Keep core value objects framework-neutral where practical:
- IDs
- timestamps/timezones
- Quantity/Unit
- Provenance
- DataQuality
- HealthFact
- LabResult
- ScoreResult
- ModelEligibility
- Mission
- ComparisonProfile
- ScenarioPatch
- SyncRevision

## Repository boundaries

Examples:
- HealthRecordRepository
- LabRepository
- FoodRepository
- TimelineRepository
- ModelRegistryRepository
- RulePackRepository
- ComparisonRepository
- MissionRepository
- EducationRepository
- WearableRepository
- ExportRepository

Repositories expose domain operations, not raw UI-oriented database queries.

## Backend service boundaries

Suggested modules:
- auth
- profiles
- timeline
- labs
- conditions/symptoms
- nutrition
- medications/treatments
- wearables
- models/scores
- sync
- imports
- exports/reports
- packs
- audit

## Storage separation

Sparse canonical records and dense time-series records may use different physical strategies while retaining one semantic ownership model.

## Reference implementation precedence

If reference code and specification conflict:
1. current Master Product Specification,
2. canonical data/model contracts,
3. acceptance tests,
4. this reference blueprint,
5. historical prototype code.

Reference implementation is replaceable. Product semantics are not.


---

<!-- SOURCE: 79_SCREEN_STATE_MACHINE_SPEC.md -->

# SCREEN STATE MACHINE SPECIFICATION

## Purpose

Every major screen must explicitly define loading, empty, ready, stale/offline, conflict and error states rather than leaving them to ad-hoc UI decisions.

## Shared screen states

- INITIAL
- LOADING
- READY
- EMPTY
- OFFLINE_READY
- STALE
- VALIDATION_ERROR
- SYNC_CONFLICT
- PERMISSION_BLOCKED
- FATAL_ERROR

A screen may omit impossible states but must document the subset it supports.

## Shared rules

### INITIAL
No network/database assumptions have been made.

### LOADING
Do not show fake zero/normal values as placeholders.

### EMPTY
Explain what data are missing and how to add them.
Absence of records is not a health judgment.

### OFFLINE_READY
Show locally available data and whether remote freshness is unknown.

### STALE
Data exist but a known newer remote/provider state may not yet be synchronized.

### VALIDATION_ERROR
Preserve unsaved user input when safe.
Show field-specific repair guidance.

### SYNC_CONFLICT
Show that two legitimate versions exist.
Do not silently discard either version.

### PERMISSION_BLOCKED
Explain which optional OS permission is unavailable and keep manual fallback where supported.

### FATAL_ERROR
Provide retry/recovery/support path and state whether data were saved.

# TODAY

Inputs:
- current local date/timezone,
- current profile,
- today's events,
- current missions,
- latest measurements,
- sync state.

READY sections:
- quick add,
- Daily Missions,
- health summary,
- recent changes,
- contextual education.

Invariant:
planned mission never renders as completed without completion evidence.

# TIMELINE

READY:
- chronologically ordered projections,
- filter chips by domain,
- source/provenance indicator where useful.

EMPTY:
`No recorded events in this period.`

Pagination/infinite-scroll must not reorder identical timestamps nondeterministically; use stable tie-breaker IDs.

# LABS

LIST state:
- sessions grouped by date.

DETAIL state:
- session metadata,
- result rows,
- source/ref interval metadata,
- correction history.

ANALYTE state:
- unit-compatible series,
- raw points/table,
- chart,
- model/reference overlays only when explicitly labeled.

# NUTRITION

SEARCH states:
- local cached result,
- remote provider result,
- offline cache only,
- provider unavailable,
- no result.

ENTRY preview must show:
- selected identity,
- quantity,
- basis,
- known nutrient coverage,
- missing nutrient indicators.

# COMPARE

States:
- no comparison profiles,
- 1 profile selected,
- 2+ comparable profiles,
- mixed eligibility,
- incompatible output/model,
- stale scenario.

When output semantics are incompatible, render `NOT_COMPARABLE` instead of an invented delta.

# RESULTS

Sections must be typed:
- Population Baseline
- Validated Risk
- Protection/Resilience
- Burden/Shortevity
- Function/Capacity
- Biological Aging
- Coverage/Confidence
- Experimental/Scenario

Every card has a drilldown:
- meaning,
- model/rule version,
- input record IDs,
- eligibility,
- source,
- limitations.

# DAILY MISSIONS

States per mission:
- PLANNED
- STARTED
- COMPLETED
- SKIPPED
- BLOCKED
- DEFERRED

Notification state is separate.

# LEARN

Lesson states:
- NOT_STARTED
- IN_PROGRESS
- COMPLETED
- REVIEW_DUE

Quiz feedback is deterministic and authored/versioned.

# SETTINGS / RESET

Reset actions must display target scope before confirmation:
- settings only,
- one module settings,
- scenario,
- data deletion,
- account deletion.

No ambiguous `Reset Everything` destructive control.


---

<!-- SOURCE: 80_DATABASE_MIGRATION_AND_INVARIANT_FIXTURES.md -->

# DATABASE MIGRATION AND INVARIANT FIXTURES

## Purpose

Make schema evolution testable before real user data exist.

## Migration policy

Every persisted schema change requires:
- `from_version`,
- `to_version`,
- migration function/SQL,
- rollback/recovery note,
- representative pre-migration fixture,
- expected post-migration fixture,
- invariant assertions.

## Schema version sequence

The implementing repository may start with a clean production schema version such as `1`; handoff versions are NOT database schema versions.

Do not use `v0.12` as a database migration number merely because this handoff is v0.12.

## Required invariant fixture classes

### MIG-F01 Correction preservation
Before:
- original MindCheckin A
- correction MindCheckin B → corrects A

After migration:
- both IDs preserved,
- correction relationship preserved,
- current projection resolves B.

### MIG-F02 Food snapshot immutability
Before:
- FoodEntry → FoodSnapshot S

After:
- entry still references same historical snapshot identity,
- migration does not requery external provider.

### MIG-F03 Plan/completion separation
Before:
- MedicationPlan exists,
- no IntakeEvent.

After:
- no fabricated IntakeEvent.

### MIG-F04 Missing nutrient
Before:
- fiber amount absent with status MISSING.

After:
- remains MISSING, not 0.

### MIG-F05 Source units
Before:
- original value/unit preserved plus normalized value.

After:
- source value/unit unchanged.

### MIG-F06 Comparison scenario isolation
Before:
- Source profile A
- Scenario B patch changes weight.

After:
- A unchanged,
- B patch preserved.

### MIG-F07 Historical model result
Before:
- ScoreResult model X v1.

After:
- remains linked to X v1 even if X v2 is active.

### MIG-F08 Tombstone
Before:
- synchronized deleted record tombstone.

After:
- stale offline copy cannot resurrect it.

### MIG-F09 Wearable external identity
Before:
- imported record external ID E.

After:
- E preserved so re-import still deduplicates.

### MIG-F10 Audit/privacy
Migration must not copy full sensitive payloads into audit/log tables accidentally.

## Fixture representation

Use machine-readable fixtures such as JSON plus migration tests.

Each fixture contains:
- fixture_id,
- schema_from,
- schema_to,
- pre_state,
- expected_post_state,
- invariants.

## Failure behavior

A migration failure must:
- roll back transaction when supported,
- leave schema version unchanged,
- emit a technical error ID,
- avoid partially marking success.

## Backup gate

For production server migrations affecting health data:
- compatible restore point/backup exists,
- restore procedure is known,
- migration dry-run or staging fixture pass exists.


---

<!-- SOURCE: 81_CANONICAL_API_ENVELOPES_PAGINATION_AND_IDEMPOTENCY.md -->

# CANONICAL API ENVELOPES, PAGINATION AND IDEMPOTENCY

## Purpose

Prevent every backend module from inventing incompatible response/error/sync conventions.

## Success envelope

Single resource example:

```json
{
  "data": {"id": "..."},
  "meta": {
    "request_id": "...",
    "server_time": "...",
    "api_version": "v1"
  }
}
```

Collection example:

```json
{
  "data": [],
  "meta": {
    "request_id": "...",
    "next_cursor": null,
    "has_more": false
  }
}
```

The implementing agent may omit the outer envelope only if the entire API remains consistent and machine-documented.

## Error envelope

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "...",
    "fields": {},
    "retryable": false,
    "request_id": "..."
  }
}
```

Do not place stack traces or secrets in production client errors.

## Error codes

At minimum distinguish:
- VALIDATION_ERROR
- UNAUTHENTICATED
- FORBIDDEN
- NOT_FOUND
- REVISION_CONFLICT
- IDEMPOTENCY_CONFLICT
- RATE_LIMITED
- PROVIDER_UNAVAILABLE
- UNSUPPORTED_UNIT
- NOT_ELIGIBLE
- MISSING_INPUTS
- IMPORT_CONFLICT
- INTERNAL_ERROR.

## Pagination

Use cursor pagination for large timelines/time-series lists.

Requirements:
- stable deterministic order,
- opaque cursor,
- no duplicate/skip under ordinary forward pagination,
- tie-break by stable ID when timestamps match.

## Idempotency

Mutation classes prone to retry duplication must accept an idempotency identity.

Examples:
- offline event create,
- import commit,
- export job creation,
- sync mutation.

Server behavior:
- same key + same semantic request → return original accepted result,
- same key + materially different request → IDEMPOTENCY_CONFLICT.

## Concurrency

Mutable resources use revision/version semantics.

Update request may include:
- base_revision,
- if-match/equivalent token.

Stale update returns REVISION_CONFLICT rather than silent overwrite.

## Delete

Synchronized deletions return/record tombstone semantics where needed.

## Time

API timestamps are unambiguous ISO-8601/RFC3339-like values with offset/UTC semantics.
Date-only fields remain date-only.

## Units

API health quantities return:
- original value/unit when source-based,
- canonical/normalized value separately when available,
- conversion metadata when transformed.

## Data quality

Response can include compact quality/provenance summary plus endpoint/drilldown for full metadata.


---

<!-- SOURCE: 82_SYNTHETIC_DATA_GENERATOR_AND_SCENARIO_FIXTURES.md -->

# SYNTHETIC DATA GENERATOR AND SCENARIO FIXTURES

## Purpose

Provide reproducible test data without using a real person's health history.

## Core rule

All generated fixtures are visibly synthetic.
They must never be imported into a real profile without an explicit synthetic/test namespace.

## Generator seed

A deterministic generator accepts:
- seed,
- profile template,
- date range,
- enabled modules,
- anomaly/event options.

Same seed + generator version produces the same synthetic dataset.

## Required templates

### SYN-001 Healthy-ish baseline
Moderate activity, normal synthetic labs, stable sleep.

### SYN-002 Cardiometabolic burden
Synthetic obesity/hypertension/lipid/glucose burden with explicit `SYNTHETIC` provenance.

### SYN-003 Oncology episode
Synthetic diagnosis → treatment course → lab monitoring → recovery events.
No prognosis value is fabricated unless a dedicated synthetic model fixture defines it.

### SYN-004 Multimorbidity
Multiple synthetic conditions + medication plans + interactions.

### SYN-005 Wearable dense series
Heart-rate/steps/sleep samples across at least 30 days.

### SYN-006 Offline/sync conflict
Two clients edit a mutable setting and independently append events.

### SYN-007 Missingness stress
Missing units, missing nutrient, unknown calibration, incomplete model inputs.

### SYN-008 Extreme-but-valid values
Boundary values that are unusual but intentionally marked valid for parser/format testing.

### SYN-009 Invalid import
Impossible date/unit/schema values expected to stage/reject.

### SYN-010 Compare lab
At least 12 synthetic profiles/scenarios with mixed model eligibility.

## Property generators

Generate valid randomized instances for:
- UUIDs,
- timestamps across DST/timezone boundaries,
- quantities/units,
- lab series,
- timeline events,
- food entries,
- missions,
- score results,
- sync mutations.

Randomized tests must be seedable.

## Privacy test

CI fixtures must not contain known real-user identifiers.

## Golden datasets

Keep a small checked-in golden dataset for deterministic E2E tests.
Large datasets can be generated on demand.

## Failure injection

Generator can simulate:
- network timeout after server commit,
- duplicate provider record,
- stale revision,
- pack corruption,
- import interruption,
- migration interruption,
- permission denial,
- clock/timezone change.


---

<!-- SOURCE: 83_PERFORMANCE_BUDGETS_AND_SCALE_TARGETS.md -->

# PERFORMANCE BUDGETS AND SCALE TARGETS

## Purpose

Give the implementing agent measurable nonfunctional targets while recognizing that final budgets must be verified on real representative hardware.

These are initial engineering budgets, not medical requirements.

## Reference device classes

Test at least:
- mid-range supported Android device/emulator profile,
- supported iPhone simulator/device profile,
- mainstream desktop browser,
- constrained network profile,
- offline mode.

Document actual hardware used for release evidence.

## Startup

Warm launch target:
- main shell interactive quickly enough to avoid blocking daily logging.

Cold launch target:
- show usable local shell before nonessential network sync completes.

Recommended engineering target:
- first meaningful local screen <= 2.5 s on reference mid-range device.

This is a target, not a guaranteed SLA until measured.

## Local writes

Simple canonical record create target:
- local transaction acknowledgement <= 150 ms p95 under normal database size.

UI can update optimistically only after durable local commit when losing the record would be misleading.

## Timeline

For 10,000 sparse events:
- initial page query <= 300 ms p95 locally on reference device,
- pagination stable and incremental.

## Dense wearable series

Reference scale fixture:
- >= 1,000,000 time-series samples.

Long-range chart must query aggregates rather than materializing all raw samples.

## Compare mode

For 20 synthetic profiles and 25 displayed metrics:
- comparison calculation should complete locally without UI freeze,
- expensive independent calculations may be cached by input/model hash.

## Daily Missions

Mission generation target:
- <= 250 ms p95 for ordinary installed rule pack and one profile.

## Model calculations

Typical scalar risk/composite model:
- <= 100 ms locally excluding large external dataset load.

## Search

Local cached food/term search:
- first useful result <= 200 ms target for representative catalog size.

Remote provider latency is separately measured and must not block manual food entry.

## Memory

Dense-series visualization must use bounded-memory streaming/windowing.

Do not load an entire multi-year raw sensor history into UI memory.

## Battery/network

Background sync/import should:
- batch work,
- avoid tight polling,
- obey platform scheduling,
- expose data-saver/battery constraints when relevant.

## Bundle size

Track:
- Android APK/AAB size,
- iOS archive size,
- web initial transfer size,
- offline content/model packs separately.

Do not reject useful offline packs solely to chase one arbitrary binary-size number; make pack size visible and optional where appropriate.

## Benchmark report

Release benchmark records:
- build/version,
- device/browser,
- dataset fixture,
- measurement method,
- p50/p95/p99 where meaningful,
- pass/fail against current budget.


---

<!-- SOURCE: 84_END_TO_END_REFERENCE_SCENARIOS.md -->

# END-TO-END REFERENCE SCENARIOS

## Purpose

Prove that modules form one coherent product instead of isolated demos.

# E2E-01 Local-only daily health use

1. Create LOCAL_ONLY profile.
2. Enter weight and mind check-in offline.
3. Generate Daily Missions offline.
4. Complete one mission.
5. Open Timeline.
6. Open Results.
7. Restart app.
8. Verify records and completion persist.
9. Reset UI settings to defaults.
10. Verify health records remain.

# E2E-02 Lab longitudinal trend

1. Create two LabSessions on different dates.
2. Add same analyte with compatible units.
3. View raw values and trend.
4. Correct older result.
5. Verify correction provenance.
6. Verify dependent trend recalculates.
7. Verify historical source record remains available.

# E2E-03 Nutrition provider snapshot

1. Search provider food online.
2. Log quantity.
3. Save FoodSnapshot.
4. Simulate upstream provider changing nutrient value.
5. Reopen historical meal.
6. Historical totals remain based on saved snapshot.
7. Add custom food offline.

# E2E-04 Wearable import

1. Grant supported health-store permission.
2. Import sleep + heart-rate sample.
3. Re-run import.
4. No duplicate canonical records.
5. Revoke permission.
6. Existing imported history remains according to policy.
7. Manual entry still works.

# E2E-05 Compare / scenario twin

1. Create observed profile.
2. Clone to 3 scenarios.
3. Modify weight/sleep/smoking-like synthetic inputs.
4. Recalculate eligible models.
5. Mixed eligibility displays correctly.
6. Baseline profile remains unchanged.
7. Export comparison report.

# E2E-06 Treatment episode

1. Create synthetic oncology condition.
2. Create EpisodeOfCare.
3. Add treatment course and cycle events.
4. Add symptoms/labs/function records.
5. Show treatment burden and recovery separately.
6. Do not produce universal cancer score.

# E2E-07 Offline-to-cloud migration

1. Use local-only profile offline.
2. Create representative records.
3. Create cloud account.
4. Stage/upload local data.
5. Verify counts and IDs.
6. Sign in second device/web.
7. Confirm synchronized history.
8. Retry interrupted mutation and verify no duplicate.

# E2E-08 Notification semantics

1. Create medication plan + reminder.
2. Deliver notification.
3. Open notification.
4. Verify no IntakeEvent exists.
5. User explicitly records intake.
6. Only then mark related mission/event complete.

# E2E-09 Migration/restore

1. Load prior-schema golden fixture.
2. Apply migrations.
3. Verify invariants.
4. Export full portable bundle.
5. Restore into clean environment.
6. Verify IDs, correction links, model versions and counts.

# E2E-10 Security isolation

1. Create User A and User B.
2. Create private record for B.
3. Attempt access using A with guessed ID.
4. Server returns forbidden/not found according to policy.
5. Audit technical event without leaking B health payload.

# E2E-11 Accessibility/localization

1. Switch Turkish/English.
2. Enable large text/reduced motion.
3. Complete Today → Add → Save with screen reader/keyboard where applicable.
4. Canonical stored numeric values remain unchanged.

# E2E-12 Pack update/rollback

1. Install model/rule pack v1.
2. Calculate/save result.
3. Install verified v2.
4. New result uses v2.
5. Old result remains v1.
6. Simulate v2 failure.
7. Roll back active pack to v1 without relabeling historical v2 result.


---

<!-- SOURCE: 85_TEST_PYRAMID_CI_AND_RELEASE_MATRIX.md -->

# TEST PYRAMID, CI AND RELEASE MATRIX

## Test layers

### L0 Static
- formatting
- lint/analyzer
- type checks
- JSON/schema validation
- secret scan
- dependency manifest checks.

### L1 Unit
- formulas
- unit conversion
- eligibility
- rule evaluation
- data-quality classification
- parsers
- serializers.

### L2 Repository/database
- CRUD
- transactions
- migrations
- correction links
- tombstones
- indexing/query behavior.

### L3 API
- auth
- authorization
- validation
- pagination
- idempotency
- revision conflicts
- export/import.

### L4 Component/widget
- form validation
- state rendering
- accessibility semantics
- localization.

### L5 Integration
- client↔local DB
- client↔API
- sync
- provider adapters
- pack loader.

### L6 End-to-end
Use `84_END_TO_END_REFERENCE_SCENARIOS.md`.

### L7 Platform runtime
- Android emulator/device
- iOS simulator/device
- supported browsers.

### L8 Security/performance
- authorization attack cases
- secret leakage
- performance budgets
- large datasets.

## CI required on every pull request

Minimum:
- L0
- fast L1
- selected L2/L3
- deterministic fixture validation.

## Main/release candidate

Run:
- full L1-L5
- E2E subset
- migration suite
- security isolation suite
- build all available platforms.

## Release branch/tag

Run:
- full acceptance matrix applicable to release scope,
- Android release build,
- iOS release build if environment available,
- web production build,
- backend/container build,
- performance benchmark subset,
- threat-model gates,
- artifact checksum generation.

## Flaky test rule

Do not silently rerun until green and call it PASS.

Track flaky tests explicitly:
- test ID
- observed frequency
- owner
- root cause status
- quarantine status.

A quarantined test cannot satisfy a release-critical acceptance gate.

## Evidence artifact

CI should produce machine-readable test report:
- build ID
- commit
- environment
- test IDs
- result
- duration
- retry count
- artifact links/checksums.

## Coverage

Code coverage is diagnostic, not a quality proof.

Prioritize critical semantic paths:
- authorization
- corrections
- sync/idempotency
- units
- model eligibility
- missingness
- migration
- export/restore.


---

<!-- SOURCE: 86_IMPLEMENTATION_AGENT_EXECUTION_PROTOCOL.md -->

# IMPLEMENTATION AGENT EXECUTION PROTOCOL

## Purpose

Tell a future coding agent exactly how to execute without asking the user to make low-level engineering choices already governed by this package.

## Phase 1 — Ingest

1. Read all authoritative handoff files.
2. Parse machine-readable JSON contracts.
3. Build a requirements index.
4. Report true contradictions only.
5. Do not ask the user to repeat product requirements already present.

## Phase 2 — Resolve environment

Identify:
- OS/toolchains,
- Flutter/Dart availability,
- Android SDK,
- Xcode/macOS availability,
- backend/runtime/database availability,
- signing credentials,
- network/provider credentials.

Classify each platform:
- READY
- PARTIALLY_READY
- BLOCKED.

Continue independent work for READY platforms.

## Phase 3 — Architecture freeze

Create:
- repository tree,
- ADRs for deviations,
- schema plan,
- API/OpenAPI plan,
- local storage/sync plan,
- pack/model/rule runtime plan.

No major framework rewrite after implementation begins without a concrete blocker or measured benefit.

## Phase 4 — Foundation first

Implement P0 foundation before polishing feature UI.

Required early vertical slice:
`profile → local DB → API/auth → sync → timeline`

This proves the product spine.

## Phase 5 — Incremental vertical slices

Preferred order:
1. Mind + Timeline
2. Labs + trends/corrections
3. Food + snapshots
4. Conditions/symptoms/vitals
5. Medication/intake
6. Missions/reminders
7. Results/model runtime
8. Compare/scenarios
9. Wearables
10. Education
11. advanced domains
12. reports/exports.

Each slice includes:
- data model,
- local persistence,
- backend/API if needed,
- UI states,
- tests,
- acceptance evidence.

## Phase 6 — No mock completion

Mocks/stubs may be used temporarily, but a feature is not complete while its production path remains a stub.

Examples:
- a fake food provider response is not provider integration,
- a hard-coded risk score is not model implementation,
- an in-memory repository is not persistence,
- screenshot mockup is not UI behavior.

## Phase 7 — Fix before expand

When tests expose a real failure in the current slice:
- repair it,
- add regression coverage,
- rerun affected gates,
then continue.

Do not accumulate known critical failures while adding new features.

## Phase 8 — Build evidence

Capture actual commands/results for:
- dependency install,
- analyze/lint,
- tests,
- migrations,
- backend start/health,
- Android build/install,
- iOS build,
- web build,
- E2E runs.

Do not fabricate command success.

## Phase 9 — Packaging

Final deliverable includes:
- source repository,
- lockfiles,
- migrations,
- environment template,
- OpenAPI,
- test report,
- APK/AAB,
- iOS project/build evidence,
- web production output,
- backend artifact/deployment docs,
- checksums,
- known blockers.

## Decision policy

For noncritical low-level choices:
- choose a maintained professional default,
- document it,
- proceed.

Ask the user only for genuinely product-defining choices or required private credentials/actions.

## Stop condition

The implementation agent stops only when:
- release scope is complete,
- or a concrete external blocker prevents further progress.

If blocked, continue every independent executable path before reporting the blocker.


---

<!-- SOURCE: 87_COMPONENT_LIBRARY_AND_INTERACTION_CONTRACTS.md -->

# COMPONENT LIBRARY AND INTERACTION CONTRACTS

## Purpose

Turn visual design into reusable behavioral contracts. A component is not complete because it looks correct; it must define states, semantics, actions, validation, accessibility and offline behavior.

## Shared component contract

Every reusable component should declare:
- purpose,
- required props/data,
- optional props/data,
- visible states,
- user actions,
- validation behavior,
- loading/empty/error behavior,
- accessibility semantics,
- localization behavior,
- offline behavior,
- analytics/telemetry restrictions,
- test IDs/acceptance references.

## Core components

### AppShell
Owns navigation chrome only. It must not own canonical health state.

States:
- authenticated local-only,
- authenticated cloud,
- offline,
- sync pending,
- safe mode.

### MetricCard
Displays one observed or derived metric.

Required:
- label,
- value/status,
- unit when applicable,
- timestamp/period,
- source/result class.

Optional:
- trend,
- reference band,
- confidence,
- quality badge.

Rules:
- missing renders missing, never zero;
- unit cannot be omitted for unitful numeric values;
- derived value exposes calculation/source drilldown.

### ResultCard
Typed result surface for:
- POPULATION_BASELINE,
- VALIDATED_RISK,
- APP_COMPOSITE,
- PROTECTION,
- BURDEN,
- FUNCTION,
- BIOLOGICAL_AGE,
- EXPERIMENTAL.

The visual style must not make an app composite look more authoritative than a validated risk result.

### TimelineCard
Shows:
- event type,
- occurred/effective time,
- title/value,
- source/status,
- correction indicator.

Opening it deep-links to the canonical source record.

### DataQualityBadge
Values:
- HIGH,
- MODERATE,
- LOW,
- UNKNOWN,
- INVALID.

This badge describes data quality, not health quality.

### ProvenanceDrawer
Shows:
- origin,
- device/provider,
- source timestamp,
- import time,
- original unit/value,
- normalized unit/value,
- corrections,
- external IDs where safe.

### QuantityInput
Combines numeric input + unit selection.

Rules:
- locale-aware display,
- locale-neutral canonical parse,
- incompatible unit options hidden/blocked,
- source precision preserved when editing imported data.

### DateTimeInput
Must distinguish:
- date only,
- local datetime,
- instant with timezone,
- uncertain/approximate date where the domain supports it.

### ScaleInput1To10
Must support:
- tap,
- keyboard on web,
- screen reader,
- direct numeric alternative where useful.

### MissingDataIndicator
Never uses `0` to mean missing.

Supports semantic reasons:
- NOT_MEASURED,
- NOT_REPORTED,
- UNKNOWN,
- NOT_APPLICABLE,
- IMPORT_FAILED,
- INVALID.

### AddRecordSheet / AddRecordPage
Flow:
1. choose/search domain,
2. choose record type,
3. render typed form,
4. validate,
5. preview important consequences,
6. save,
7. show canonical record and affected projections.

Must not imply an unsaved form already changed Results.

### ConflictResolver
Shows both local and server/alternate representations plus:
- revisions,
- changed fields,
- provenance,
- resolution options.

Must not offer `Use latest` when “latest” is not semantically safe.

### PermissionGate
Shows:
- capability,
- why it is requested,
- current permission state,
- manual fallback,
- link to system settings where supported.

Denial never creates fake data.

### MissionCard
Separates:
- mission status,
- notification status,
- completion evidence.

`DELIVERED` notification is never rendered as `COMPLETED` mission.

### ReminderCard
Shows schedule semantics and timezone.

### ChartFrame
Must include:
- title,
- metric,
- units,
- time window,
- series legend,
- accessible text/table alternative,
- no interpolation across known missing gaps unless explicitly configured.

### CompareGrid
Supports:
- N profiles,
- sticky metric column,
- horizontal virtualization,
- baseline pinning,
- NOT_ELIGIBLE,
- NOT_COMPARABLE,
- coverage/confidence.

### ErrorBanner
Contains:
- human-readable error,
- whether data were saved,
- safe retry action,
- support/error ID when available.

Never prints stack traces or secrets.

### DestructiveActionDialog
For delete/reset/share revocation.
Must name exact scope.

## Component ownership rule

Reusable UI components do not directly call external providers or mutate canonical storage. They invoke application/use-case interfaces.

## Test rule

Every reusable component with health semantics must have:
- at least one normal-state test,
- one missing/error state test,
- one accessibility/semantic test where applicable.


---

<!-- SOURCE: 88_MODULE_CONTRACTS_AND_DEPENDENCY_GRAPH.md -->

# MODULE CONTRACTS AND DEPENDENCY GRAPH

## Purpose

Define who owns which data and which module is allowed to mutate it.

## Module contract fields

Each module declares:
- `module_id`,
- purpose,
- owned canonical entities,
- read dependencies,
- write operations,
- emitted domain events,
- derived outputs,
- offline capability,
- cloud dependency,
- model/rule dependencies,
- security boundary,
- failure isolation,
- acceptance-test range.

## Ownership rule

Every canonical entity has one authoritative owning module.
Other modules may reference/read it through contracts but do not create shadow copies.

## Core modules

### PROFILE
Owns:
- UserProfile,
- profile preferences,
- module visibility settings.

Does not own health history.

### TIMELINE
Owns:
- timeline projection/index only.

Reads canonical domain events.
Must not become the canonical source for labs, meals or treatments.

### LABS
Owns:
- LabSession,
- LabResult,
- lab corrections.

Emits:
- LAB_SESSION_CREATED,
- LAB_RESULT_CORRECTED.

### MIND
Owns MindCheckin.

### CONDITIONS_SYMPTOMS
Owns Condition and SymptomEvent.

### NUTRITION
Owns:
- Meal,
- FoodEntry,
- FoodSnapshot,
- CustomFood,
- Recipe.

### MEDICATION_TREATMENT
Owns:
- MedicationPlan,
- IntakeEvent,
- TreatmentCourse,
- TreatmentEvent,
- HealthProduct/ProductUseEvent.

### VITALS_FUNCTION
Owns:
- VitalMeasurement,
- BloodPressureMeasurement,
- FunctionalMeasurement,
- PainEvent,
- RehabSession.

### SLEEP_ACTIVITY
Owns SleepEpisode and ActivityEvent.

### WEARABLE_IMPORT
Owns import/link/provenance adapters, not the final semantic meaning of all records.
It maps into the owning domain module.

### MODEL_RUNTIME
Owns:
- ModelRegistryEntry,
- model execution,
- ScoreResult.

Cannot mutate raw source observations.

### RULE_RUNTIME
Owns rule packs/execution decisions.
Can generate Mission/Alert proposals through contracts.

### MISSIONS_REMINDERS
Owns:
- Mission,
- Reminder.

Cannot fabricate completion.

### COMPARE_TWIN
Owns:
- ComparisonProfile,
- TwinSnapshot,
- ScenarioPatch.

Cannot mutate source profile canonical records.

### EDUCATION
Owns:
- EducationContentPack,
- LessonProgress.

Education completion does not mutate clinical risk.

### SYNC
Owns:
- outbox,
- sync cursor,
- mutation receipts,
- conflict transport state.

It does not decide domain-specific clinical conflict resolution.

### IMPORT_EXPORT
Owns:
- ImportBatch,
- export bundle creation,
- staging.

Canonical commit routes through owning modules.

### SECURITY_AUDIT
Owns:
- SessionRecord,
- DeviceRegistration,
- ConsentRecord,
- AuditEvent.

### PACKS
Owns PackManifest lifecycle and verified activation.

## Dependency direction

Preferred:
UI → application/use cases → domain/repositories → adapters.

Prohibited examples:
- Labs UI importing directly from HealthKit,
- CompareGrid writing directly to LabResult,
- Timeline deleting source entities,
- sync transport calculating health risk.

## Derived dependency graph

Corrections should invalidate derived outputs through declared dependencies.

Example:
`LabResult LDL` → `Cardiovascular model input` → `ScoreResult` → `Results projection`.

A correction to LDL invalidates dependent ScoreResult but not unrelated sleep history.

## Cycle rule

Canonical module dependencies must not create uncontrolled write cycles.
If two modules need mutual awareness, use domain events/read projections rather than recursive writes.


---

<!-- SOURCE: 89_REPOSITORY_BOOTSTRAP_AND_WORKSPACE_LAYOUT.md -->

# REPOSITORY BOOTSTRAP AND WORKSPACE LAYOUT

## Purpose

Provide a concrete first-commit layout for the future coding agent.

## Reference workspace

```text
human-health-os/
  README.md
  LICENSE-or-private-notice
  .gitignore
  .editorconfig
  .env.example
  docs/
    architecture/
    product/
    adr/
    api/
    security/
    release/
  apps/
    client/
      lib/
      test/
      integration_test/
      android/
      ios/
      web/
  services/
    api/
      src/
      tests/
      migrations/
  packages/
    domain/
    calculations/
    rule_engine/
    unit_engine/
    sync_contracts/
    test_fixtures/
  packs/
    models/
    rules/
    education/
    references/
    terminology/
    units/
  tools/
    fixture_generator/
    migration_verifier/
    pack_validator/
    release_audit/
  contracts/
    openapi/
    schemas/
    fixtures/
  infra/
    local/
    staging/
    production/
  reports/
    tests/
    benchmarks/
    security/
```

Exact names may vary, but responsibilities should remain separated.

## First commit goals

The first repository commit should already include:
- workspace structure,
- README with product invariants,
- toolchain version files where supported,
- dependency lockfiles after bootstrap,
- formatter/linter configuration,
- empty but runnable client shell,
- empty but runnable backend health endpoint,
- local database bootstrap/migration 1,
- test command,
- environment template,
- CI skeleton,
- no production secrets.

## Bootstrap proof

A successful bootstrap proves only:
- source tree exists,
- toolchain resolves,
- shells run,
- migrations initialize,
- tests execute.

It does NOT prove product features are complete.

## Dependency policy

Prefer maintained dependencies with:
- active releases/security posture,
- stable licensing,
- platform compatibility,
- minimal overlap.

Before locking a dependency, record why it is needed.

## Workspace commands

The implementation should expose simple developer commands equivalent to:
- bootstrap/install,
- format,
- lint/analyze,
- test-fast,
- test-all,
- migrate,
- run-api,
- run-client,
- generate-openapi,
- generate-fixtures,
- benchmark,
- release-audit.

Exact command names depend on build tooling.

## Generated-code rule

Generated OpenAPI/client/schema files must be reproducible and clearly marked.
Do not manually edit generated code without changing its generator/source.

## Environment rule

`.env.example` contains names and safe placeholders only.
No real keys/tokens.

## Reference-code precedence

If future reference implementation code conflicts with product contracts, contracts win until an explicit ADR/spec patch changes them.


---

<!-- SOURCE: 90_OPENAPI_RESOURCE_SCHEMAS_AND_VALIDATION_RULES.md -->

# OPENAPI RESOURCE SCHEMAS AND VALIDATION RULES

## Purpose

Define the minimum semantic schema rules that concrete OpenAPI/JSON Schema must encode.

## Common synchronized resource fields

Where applicable:
- `id`: stable globally unique ID,
- `user_id/profile_id`: server-derived/authorized ownership, not trusted from arbitrary client input,
- `created_at`,
- `updated_at`,
- `server_revision`,
- `deleted_at`/tombstone when synchronized deletion applies.

## Validation principles

- reject unknown enum values unless explicit forward-compatible container exists,
- preserve unknown external concepts in staging rather than guessing,
- numeric fields reject NaN/Infinity,
- date/time fields use unambiguous formats,
- 1–10 fields enforce inclusive bounds,
- IDs cannot switch owner,
- immutable snapshot fields cannot be mutated after canonical logging except through explicit version/correction semantics.

## MindCheckin

Required:
- id,
- observed_at,
- at least one rating or note according to product policy.

Ratings: integer 1..10.

## LabSession

Required:
- id,
- collected_at or explicit date-only variant.

Optional:
- reported_at,
- laboratory,
- fasting status,
- notes.

## LabResult

Must support either:
- numeric value,
- textual value,
- coded result,
according to result type.

Numeric result requires unit unless the analyte is explicitly unitless.

## Condition

Status enum includes:
- CONFIRMED_DIAGNOSIS,
- SELF_REPORTED_HISTORY,
- SUSPECTED_OR_EVALUATION_PENDING,
- RESOLVED,
- UNKNOWN.

## FoodSnapshot

After a FoodEntry references it as historical source snapshot, provider identity, basis and nutrient set are immutable for that snapshot identity.

## NutrientValue

`amount = null` with semantic data status is valid.
`MISSING` must not be serialized as `amount: 0`.

## ScoreResult

Required:
- result_class,
- model_id,
- model_version,
- calculated_at,
- input_record_ids,
- output,
- eligibility/applicability metadata.

## Reminder

Reminder state does not include domain completion as an implicit side effect.

## Mission

Status transitions should reject impossible jumps when evidence is required.

## ComparisonProfile

Scenario profile must reference source/base without modifying it.

## Error codes

At minimum:
- VALIDATION_ERROR
- AUTH_REQUIRED
- FORBIDDEN
- NOT_FOUND
- REVISION_CONFLICT
- IDEMPOTENCY_CONFLICT
- NOT_ELIGIBLE
- MISSING_INPUTS
- NOT_COMPARABLE
- PERMISSION_REQUIRED
- IMPORT_STAGED
- PACK_INVALID
- RATE_LIMITED
- INTERNAL_ERROR

## OpenAPI release gate

Generated OpenAPI must:
- parse,
- match implementation routes,
- include security declarations,
- include error schemas,
- be diffed between releases for breaking changes.


---

<!-- SOURCE: 91_FIXTURE_CATALOG_AND_TEST_PROFILE_LIBRARY.md -->

# FIXTURE CATALOG AND TEST PROFILE LIBRARY

## Purpose

Provide named deterministic synthetic profiles that exercise realistic combinations of modules without using real-user data.

All fixtures are SYNTHETIC.

## FIX-P01 — Blank New User
- no health history,
- default settings,
- used for empty states/onboarding.

## FIX-P02 — Basic Longitudinal Adult
- weight series,
- mind check-ins,
- sleep/activity,
- two lab sessions,
- food diary.

## FIX-P03 — Mixed Units Lab
- same analyte across compatible units,
- one incompatible/unknown unit record,
- correction history.

## FIX-P04 — Multimorbidity
- multiple active conditions,
- medications,
- supplement,
- interaction warning,
- functional measurement.

## FIX-P05 — Oncology Episode
- synthetic malignancy condition,
- treatment course,
- chemotherapy cycles,
- labs,
- symptoms,
- function/recovery.

No real regimen or medical recommendation is implied.

## FIX-P06 — Cardio Model Eligible
Synthetic values satisfying one configured model fixture's eligibility.

## FIX-P07 — Cardio Model Ineligible
Fails one or more documented eligibility conditions.

## FIX-P08 — Wearable Dense Series
- sleep,
- resting HR,
- raw HR series,
- external IDs,
- duplicates.

## FIX-P09 — Conflict Profile
- stale mutable revision,
- local/server conflicting settings,
- duplicate-candidate imports.

## FIX-P10 — Offline Outbox
- pending create,
- pending update,
- timeout-after-server-commit case.

## FIX-P11 — Comparison Lab
At least 20 profiles with mixed eligibility and 25 metrics.

## FIX-P12 — Accessibility Stress
- long translated labels,
- large text,
- missing values,
- error states.

## FIX-P13 — Restore Legacy
Represents prior supported DB schema with correction/tombstone/snapshot relationships.

## FIX-P14 — Pack Rollback
- active v1,
- staged v2,
- v2 corruption/failure,
- historical v2 result.

## FIX-P15 — Third-party Private Profile
Synthetic REAL_OTHER profile to verify privacy defaults.

## Generator requirements

Every fixture has:
- fixture_id,
- generator_version,
- seed,
- expected entity counts,
- expected invariants,
- forbidden identifiers,
- expected acceptance tests.

## Golden vs fuzz

Golden fixtures are stable and versioned.
Property/fuzz generators may vary but must emit reproducible failing seeds.

## PHI/PII rule

No fixture may copy a real person's health history, email, phone number, identifier or document.
Synthetic names should be obviously non-real test labels where names are required.


---

<!-- SOURCE: 92_DATA_INTEGRITY_AND_DISASTER_RECOVERY_DRILLS.md -->

# DATA INTEGRITY AND DISASTER RECOVERY DRILLS

## Purpose

Prove that backup, restore, migration and recovery actually preserve the health-history invariants the product promises.

## Drill classes

### DR-01 Local database corruption
Simulate unreadable/corrupted local store.
Expected:
- detect failure,
- avoid overwriting recoverable copy,
- offer recovery/safe mode/export where possible,
- report whether cloud restore is available.

### DR-02 Interrupted migration
Terminate during migration.
Expected:
- prior valid schema remains recognizable,
- migration not marked complete,
- retry/recovery is deterministic.

### DR-03 Cloud database restore
Restore backup to clean compatible environment.
Verify:
- user/profile counts,
- event IDs,
- correction links,
- tombstones,
- external IDs,
- ScoreResult model versions,
- pack versions.

### DR-04 Object storage mismatch
Database points to missing attachment/blob.
Expected:
- canonical record remains,
- attachment state is MISSING/UNAVAILABLE,
- no record deletion cascade.

### DR-05 Accidental batch import
Rollback one import batch.
Verify unrelated pre-existing records remain.

### DR-06 Bad pack activation
Activate pack with logical/runtime failure after integrity verification.
Expected:
- detect failure,
- roll back active pack,
- preserve historical results produced before rollback.

### DR-07 Sync resurrection attack
Offline stale device uploads record previously deleted/tombstoned.
Expected:
- tombstone wins according to policy,
- deleted record not silently resurrected.

### DR-08 Account/session compromise
Revoke all sessions.
Expected:
- server operations stop for revoked tokens,
- local offline data remain locally readable according to app-lock policy.

### DR-09 Key loss
Simulate loss of local encryption key.
Expected:
- recovery behavior matches documented architecture,
- no false promise that unrecoverable local-only ciphertext can be restored.

### DR-10 Export/restore checksum failure
Tamper with portable bundle.
Expected:
- checksum validation fails,
- restore blocked or explicitly staged for forensic/user review.

## Recovery Point / Recovery Time

For cloud deployments, product operations should define target:
- RPO: acceptable data-loss window,
- RTO: acceptable service-recovery window.

Exact production values are deployment/business decisions and must be measured rather than invented in the handoff.

## Drill evidence

Each drill records:
- environment,
- versions,
- starting fixture,
- fault injected,
- steps,
- observed result,
- invariant checks,
- recovery duration,
- PASS/FAIL,
- follow-up issue IDs.

## Release rule

A documented backup without a successful restore drill is not sufficient evidence of recoverability.


---

<!-- SOURCE: 93_SYNC_CONFLICT_SIMULATOR_AND_CHAOS_TESTS.md -->

# SYNC CONFLICT SIMULATOR AND CHAOS TESTS

## Purpose

Offline-first correctness fails in edge timing, not happy-path demos. Provide deterministic chaos scenarios.

## Simulator controls

Inject:
- latency,
- packet loss,
- timeout before commit,
- timeout after commit,
- duplicate request,
- reordered response,
- server 5xx,
- 429/rate limit,
- expired auth,
- stale revision,
- clock skew,
- duplicate external import,
- tombstone conflict,
- interrupted app process.

## CHAOS-S01 Timeout after create commit
Server commits record, response is lost.
Retry with same idempotency identity must return/resolve same canonical record.

## CHAOS-S02 Two-device profile edit
A and B edit same mutable profile setting from same base revision.
Second stale write receives REVISION_CONFLICT.

## CHAOS-S03 Independent append events
Two devices create different symptom events offline.
Both should merge.

## CHAOS-S04 Delete vs stale update
A deletes resource, B later pushes stale update.
Deletion/tombstone policy prevents silent resurrection.

## CHAOS-S05 Correction chain conflict
Two devices independently correct same historical record.
System surfaces a semantic conflict rather than selecting by timestamp only.

## CHAOS-S06 Pack/model mismatch
Device A calculates with model v1 while B has v2.
Historical results retain versions; sync does not relabel outputs.

## CHAOS-S07 Clock skew
Device clock differs materially.
Server ordering relies on revision/cursor semantics rather than client clock alone.

## CHAOS-S08 Import while offline
Wearable/import data stage locally and reconcile external IDs after connectivity returns.

## Determinism

Chaos scenario seed/config must be reproducible.

## Invariants

- no duplicate canonical event from retry,
- no cross-user data leakage,
- no stale write silently overwrites newer mutable state,
- no tombstone resurrection,
- no history/model-version relabeling,
- sync cursor advances only after durable local apply.


---

<!-- SOURCE: 94_ERROR_CATALOG_AND_USER_RECOVERY_COPY.md -->

# ERROR CATALOG AND USER RECOVERY COPY

## Purpose

Errors need stable machine codes and user-safe recovery language.

## Error record fields

- error_code
- severity
- retryability
- data_saved_state
- user_message_key
- technical_detail_policy
- support_id
- recovery_actions.

## Core catalog examples

### OFFLINE_REMOTE_UNAVAILABLE
Meaning:
Remote feature unavailable; local data still usable.

### VALIDATION_ERROR
Meaning:
Input needs correction.
Preserve form values where safe.

### REVISION_CONFLICT
Meaning:
Another version exists.
Offer conflict resolution, not blind overwrite.

### PERMISSION_REQUIRED
Meaning:
Optional OS permission missing.
Offer manual fallback.

### IMPORT_STAGED
Meaning:
Data received but needs mapping/review before canonical commit.

### PACK_INVALID
Meaning:
Downloaded model/rule/content pack failed verification.
Continue using prior verified pack when possible.

### DATABASE_RECOVERY_REQUIRED
Meaning:
Local storage failed integrity/startup checks.
Enter safe recovery path.

### AUTH_EXPIRED
Meaning:
Cloud session expired.
Local data remain usable where policy permits.

### NOT_ELIGIBLE
Meaning:
The selected validated model does not apply to this profile.
Do not phrase as a health failure.

### INSUFFICIENT_DATA
Meaning:
Not enough valid data for this result.
List missing inputs when appropriate.

## Copy principles

User message answers:
1. What happened?
2. Was my data saved?
3. What can I do now?

Avoid:
- blame,
- unexplained developer jargon,
- false medical reassurance,
- stack traces,
- internal URLs/secrets.

## Health-specific error rule

If a calculation fails, do not substitute a stale/zero/normal-looking value without a visible stale label and documented policy.


---

<!-- SOURCE: 95_RELEASE_ARTIFACT_LAYOUT_AND_HANDOFF_INDEX.md -->

# RELEASE ARTIFACT LAYOUT AND HANDOFF INDEX

## Purpose

Define exactly what the future implementation agent should return so the user does not receive an unstructured folder dump.

## Final release bundle layout

```text
HUMAN_HEALTH_OS_RELEASE_<version>/
  START_HERE.md
  RELEASE_STATE.json
  RELEASE_NOTES.md
  KNOWN_LIMITATIONS.md
  CHECKSUMS.sha256
  source/
  builds/
    android/
      app-release.apk
      app-release.aab
    ios/
      project-or-archive-evidence/
    web/
      production-build/
    backend/
      deployable-artifact-or-container-reference/
  contracts/
    openapi/
    schemas/
  migrations/
  tests/
    test-report.json
    acceptance-report.json
    e2e-report.json
    security-report.json
    benchmark-report.json
  docs/
    BUILD.md
    RUN.md
    DEPLOY.md
    SECURITY.md
    DATA_MODEL.md
    API.md
    BACKUP_RESTORE.md
  packs/
    manifests/
```

## START_HERE

Must answer:
- what this release is,
- what is actually built,
- which platforms were tested,
- how to run/install,
- known blockers.

## RELEASE_STATE.json

Machine-readable states for:
- source,
- static checks,
- tests,
- backend,
- Android build/install,
- iOS build/install,
- web build/deploy,
- security,
- performance.

## Artifact existence rule

Never list a build artifact path that does not exist.

## Checksum rule

Generate checksums only after final artifact bytes are fixed.

## Handoff precedence

For shipped implementation:
1. release-state/evidence of what actually exists,
2. source/contracts,
3. current product handoff,
4. reference implementation notes.

Implementation code does not silently redefine product semantics.


---

<!-- SOURCE: 96_BOOTSTRAP_ACCEPTANCE_AND_FIRST_COMMIT_CHECKLIST.md -->

# BOOTSTRAP ACCEPTANCE AND FIRST-COMMIT CHECKLIST

## Purpose

Create a hard first milestone before feature development expands.

## BOOTSTRAP-01 Workspace
- repository initialized,
- directory boundaries created,
- README states core invariants,
- no production secrets.

## BOOTSTRAP-02 Client shell
- app launches,
- basic navigation shell,
- localization bootstrap,
- theme/accessibility hooks,
- local database initializes.

## BOOTSTRAP-03 Backend shell
- service starts,
- health endpoint works,
- database migration runs,
- OpenAPI generates.

## BOOTSTRAP-04 Auth/profile vertical slice
- create/login or configured dev auth,
- owner-scoped profile,
- local profile representation,
- logout/revoke path defined.

## BOOTSTRAP-05 Sync spine
- client-generated stable ID,
- outbox mutation,
- server accept/idempotency,
- pull cursor,
- local apply.

## BOOTSTRAP-06 First canonical health slice
Recommended:
MindCheckin.

Must include:
- form,
- local persistence,
- timeline projection,
- sync path,
- correction path,
- tests.

## BOOTSTRAP-07 Test/CI
- format/lint,
- unit test,
- migration test,
- API test,
- one component test,
- one integration smoke,
- secret scan.

## BOOTSTRAP-08 Evidence
Produce:
- commands run,
- test report,
- repo tree,
- exact blocked tooling.

## First-commit exit criteria

Do not start broad feature development until:
- bootstrap tests pass,
- vertical slice persists across restart,
- sync retry is idempotent in test,
- owner authorization test exists,
- no mock completion is claimed.


---

<!-- SOURCE: 97_DOMAIN_API_AND_SCHEMA_CATALOG.md -->

# DOMAIN-BY-DOMAIN API AND SCHEMA CATALOG

## Purpose

Turn the conceptual product model into an implementation catalog so the future coding agent knows which domain owns which resources, operations, queries and invariants.

This catalog is normative for semantic boundaries. Exact route spelling may change if the same contract is preserved.

## Common conventions

All user/profile-scoped canonical resources use:
- stable globally unique `id`,
- server-authorized owner/profile identity,
- `created_at`,
- `updated_at` when mutable,
- `server_revision` when synchronized mutation can conflict,
- tombstone/deletion metadata where synchronized deletion applies,
- provenance/source metadata where medically/data-semantically important.

List endpoints use stable cursor pagination when result sets can grow materially.

## PROFILE

Resources:
- UserProfile
- profile preferences
- enabled Health Modules

Operations:
- GET current profile
- PATCH mutable preferences with revision semantics
- export profile settings

Hard invariants:
- profile preferences cannot mutate canonical health history,
- locale/unit display settings do not rewrite source values.

## TIMELINE

Resource:
- TimelineEvent projection

Operations:
- GET paginated timeline
- GET filtered timeline by domain/date/type

Hard invariants:
- projection only,
- delete/edit routes operate on source entity, not timeline shadow copy,
- stable sort = occurred/effective time + deterministic tie-breaker ID.

## LABS

Resources:
- LabSession
- LabResult

Operations:
- create/read session
- add result
- create correction
- retrieve analyte series
- retrieve raw source/provenance

Queries:
- date range
- analyte key
- provider/laboratory

Hard invariants:
- numeric values preserve source unit,
- correction history persists,
- incompatible units cannot silently merge into one series.

## CONDITIONS / SYMPTOMS

Resources:
- Condition
- SymptomEvent

Operations:
- CRUD/status transition
- symptom episode create/end

Hard invariants:
- suspected != confirmed,
- resolved does not erase history.

## MIND

Resource:
- MindCheckin

Operations:
- create
- correct
- list by date range

Hard invariants:
- 1..10 range validation,
- self-report != diagnosis.

## NUTRITION

Resources:
- Meal
- FoodEntry
- FoodSnapshot
- NutrientValue
- CustomFood
- Recipe

Operations:
- meal CRUD
- provider/local food search
- barcode lookup
- create immutable logged FoodSnapshot
- custom food/recipe CRUD
- day totals query

Hard invariants:
- missing nutrient != zero,
- historical FoodSnapshot is not silently rewritten by upstream provider change,
- unknown unit conversion is rejected.

## MEDICATION / SUPPLEMENT / HEALTH PRODUCT

Resources:
- HealthProduct
- MedicationPlan/ProductUsePlan
- IntakeEvent/ProductUseEvent

Operations:
- catalog/custom product create
- plan CRUD
- actual intake/use event append/correct

Hard invariants:
- plan != actual use,
- reminder != intake,
- catalog existence != user exposure.

## TREATMENT / PROCEDURE / VACCINATION

Resources:
- TreatmentCourse
- TreatmentEvent
- ProcedureEvent
- VaccinationEvent
- EpisodeOfCare

Operations:
- create course/episode
- append treatment/procedure/vaccination event
- link related records
- close/change state explicitly

Hard invariants:
- elapsed time alone does not resolve episode,
- treatment event does not imply success/failure/prognosis.

## VITALS / FUNCTION / PAIN / REHAB

Resources:
- VitalMeasurement
- BloodPressureMeasurement
- FunctionalMeasurement
- PainEvent
- RehabPlan
- RehabSession
- MeasurementSession

Operations:
- append measurement
- create correction
- group repeated measurement session
- plan/session rehab operations

Hard invariants:
- source context/device preserved,
- repeated-reading aggregate only by explicit protocol,
- rehab plan != performed session.

## SLEEP / ACTIVITY

Resources:
- SleepEpisode
- ActivityEvent
- dense time-series references/aggregates

Operations:
- append/import
- query range
- aggregate query

Hard invariants:
- raw vs aggregate provenance preserved,
- derived aggregate cannot masquerade as raw sample.

## WEARABLE IMPORT

Resources:
- ExternalHealthRecordLink
- ImportBatch
- staged import records

Operations:
- permission/capability state
- incremental import
- reconcile/deduplicate
- batch receipt

Hard invariants:
- adapter does not own final semantic health entities,
- ambiguous records stage instead of guessed canonicalization.

## MODELS / RESULTS

Resources:
- ModelRegistryEntry
- ScoreResult
- DomainStateSnapshot
- ReferenceDataset

Operations:
- list installed/eligible models
- calculate deterministic result
- retrieve historical result snapshot
- explain inputs/model/source/limitations

Hard invariants:
- model eligibility checked before calculation,
- model version pinned into result,
- failed calculation != zero/normal result,
- app composite != validated probability.

## RULES / MISSIONS / REMINDERS

Resources:
- RulePack
- Mission
- Reminder

Operations:
- generate missions
- transition mission status
- schedule/update/cancel reminders
- explain source rule

Hard invariants:
- notification state separate from completion,
- safety precedence explicit,
- missed optional mission does not automatically duplicate workload.

## COMPARE / DIGITAL TWIN

Resources:
- ComparisonProfile
- TwinSnapshot
- ScenarioPatch

Operations:
- create/clone profile
- apply non-destructive scenario patch
- calculate comparison set
- export comparison

Hard invariants:
- scenario cannot mutate canonical source profile,
- unlike endpoints/models render NOT_COMPARABLE.

## EDUCATION

Resources:
- EducationContentPack
- LessonProgress

Operations:
- read installed lesson
- submit deterministic quiz response
- schedule review

Hard invariants:
- learning completion != health improvement,
- content source/version retained.

## SECURITY / ACCOUNT / CONSENT

Resources:
- SessionRecord
- DeviceRegistration
- ConsentRecord
- AuditEvent

Operations:
- list/revoke sessions
- grant/revoke scoped consent
- query own audit history where product exposes it

Hard invariants:
- owner authorization server-side,
- audit logging does not duplicate full health payload by default.

## IMPORT / EXPORT / BACKUP

Resources:
- ImportBatch
- portable export manifest
- restore receipt

Operations:
- stage/commit/rollback import
- generate export
- verify/restore bundle

Hard invariants:
- restore verifies hashes before canonical commit,
- merge does not silently duplicate known IDs,
- export schema/version declared.

## PACKS

Resource:
- PackManifest

Operations:
- discover/download/verify/stage/activate/rollback/retire

Hard invariants:
- invalid checksum never activates,
- historical result retains actual pack/model/rule version.

## Domain API completeness rule

A production module is not complete until it has:
1. owned-resource schema,
2. create/read/update/correct/delete semantics where applicable,
3. authorization rule,
4. validation rule,
5. pagination/query semantics where applicable,
6. offline/sync behavior,
7. error codes,
8. acceptance evidence.


## v0.23 Preventive Care

OpenAPI operations:
- `listPreventiveEvents`
- `createPreventiveEvent`
- `listPreventiveAssessments`
- `runPreventiveAssessment`
- `listPreventiveDueItems`
- `listPreventiveServices`
- `listPreventiveGuidelinePacks`
- `getPreventiveGuidelinePack`

Schemas:
- PreventiveServiceDefinition
- PreventiveRule
- PreventiveEvent
- PreventiveAssessment
- GuidelinePack.


---

<!-- SOURCE: 98_RESPONSIVE_LAYOUT_BLUEPRINT.md -->

# RESPONSIVE LAYOUT, DENSITY AND VISUAL BLUEPRINT

## Purpose

Specify how one information architecture adapts from phone to tablet to desktop without turning web into a stretched phone screen.

## Responsive classes

The implementation may use framework-native breakpoints, but behavior should correspond to:

### COMPACT
Typical phone portrait / narrow window.
- single primary content column,
- bottom navigation or compact navigation,
- charts scroll/zoom or switch to concise summaries,
- compare tables horizontally scroll,
- quick-add remains thumb reachable.

### MEDIUM
Large phone landscape / small tablet / narrow desktop.
- optional navigation rail,
- 1–2 content columns,
- master/detail allowed where it improves flow,
- larger charts.

### EXPANDED
Tablet landscape / desktop.
- persistent side navigation,
- multi-column dashboard,
- master/detail panels,
- wider comparison grid,
- visible filters where space permits.

## Density modes

- COMFORTABLE default
- COMPACT_DATA optional
- AGING_FRIENDLY optional

Density affects layout only, never data semantics.

## Global shell

### Compact
Top app bar:
- profile/context,
- date or screen title,
- sync/offline indicator,
- quick add.

Bottom destinations should prioritize:
- Today
- Timeline
- Add
- Compare/Results
- More

Exact visible items may vary after usability testing.

### Expanded
Left navigation:
- Today
- Timeline
- Results
- Compare
- Labs
- Nutrition
- Mind
- Conditions/Symptoms
- Medications/Treatments
- Activity/Sleep
- Learn
- Settings

Main area supports responsive cards/panels.

## Today blueprint

Compact order:
1. date/context
2. important blocked/review state
3. Daily Missions
4. quick add
5. current health summary
6. recent changes
7. contextual education

Expanded:
- left/main: missions + recent health
- right: results summary + trends + education

Do not place a large lifespan number above all clinically meaningful context.

## Results blueprint

Sections retain typed visual hierarchy:
1. Population Baseline
2. Validated Risk
3. Protection/Burden/Function
4. Biological Aging
5. Coverage/Confidence
6. Scenario/Experimental

Each card must expose model/type label before or adjacent to the number.

## Compare blueprint

Compact:
- pinned metric labels,
- horizontally scrollable profile columns,
- sticky baseline profile where technically feasible.

Expanded:
- matrix/grid,
- profile pinning,
- metric/domain filters,
- delta view.

Never shrink values until unreadable merely to fit all profiles.

## Labs blueprint

Compact:
- sessions list → session detail → analyte detail navigation.

Expanded:
- session list panel,
- result table/detail panel,
- analyte trend panel where selected.

## Timeline blueprint

Compact:
- one vertical chronological list.

Expanded:
- filters/period selector in side/top rail,
- timeline list + selected event inspector.

## Forms

Compact:
- one logical section at a time for long medical forms,
- sticky Save only if it does not obstruct content.

Expanded:
- grouped 2-column form only for semantically related fields,
- never arrange fields solely to fill space.

## Charts

For every breakpoint:
- unit visible,
- period visible,
- raw/table alternative accessible,
- tooltip/point inspection accessible,
- missing intervals visually distinct from zero.

## Error/offline banners

Banners must not permanently consume excessive compact screen height.
Critical state remains accessible after dismissal where dismissal is allowed.

## Visual wireframe semantics

Every production screen spec must identify:
- primary task,
- primary action,
- destructive action,
- empty state,
- offline state,
- error state,
- accessibility label strategy,
- compact/medium/expanded layout.


---

<!-- SOURCE: 99_DATA_RETENTION_DELETION_AND_TOMBSTONE_MATRIX.md -->

# DATA RETENTION, DELETION AND TOMBSTONE MATRIX

## Purpose

Make deletion behavior deterministic without pretending one retention duration is legally correct for every market.

This specification defines product semantics. Market-specific legal retention requirements must be reviewed before launch.

## Deletion concepts

### HIDE
UI-only visibility change. Canonical data remains.

### ARCHIVE
Record remains canonical but is no longer active/default.

### SOFT_DELETE / TOMBSTONE
Record is logically deleted and deletion synchronizes across devices.

### HARD_DELETE
Underlying canonical data are physically removed when policy permits.

### ACCOUNT_DELETE
Account-level workflow covering cloud data, sessions, integrations and documented retention exceptions.

## Global rules

- settings reset is not data deletion,
- disabling a module is not data deletion,
- correction is not deletion,
- source history needed to explain a correction is not silently removed by editing,
- synchronized deletion must prevent stale-device resurrection,
- backups/derived caches follow documented expiry/purge policy,
- deletion receipt should state scope/status where feasible.

## Matrix

| Data class | Default user delete? | Sync tombstone? | Derived invalidation? | Exportable before delete? | Notes |
|---|---|---|---|---|---|
| Profile settings | yes/reset | usually | no/limited | yes | reset and delete are distinct |
| LabSession/LabResult | yes | yes if synced | yes | yes | correction history semantics documented |
| Condition/Symptom | yes | yes | yes | yes | deleting source invalidates derived views |
| MindCheckin | yes | yes | yes | yes | self-report history |
| Meal/FoodEntry | yes | yes | yes | yes | FoodSnapshot retained only as needed by surviving entries/policy |
| MedicationPlan | yes | yes | mission/reminder | yes | intake history separate |
| IntakeEvent | yes | yes | adherence/derived | yes | plan deletion must not silently delete intake unless explicitly chosen |
| Treatment/Procedure/Vaccine | yes | yes | yes | yes | episode links repaired/updated |
| Vital/Function/Pain | yes | yes | yes | yes | raw/aggregate dependencies handled |
| Wearable raw sample | configurable | provider/local strategy | aggregates | yes according to policy | high-volume retention may differ |
| Derived aggregate | rebuildable | normally derived | n/a | optional | can purge/rebuild if source survives |
| ScoreResult | historical snapshot policy | maybe | n/a | yes | old result may be retained to explain historical decision even if source deletion policy requires purge/recompute; final behavior must be explicit |
| Comparison/Synthetic profile | yes | yes if synced | scenario results | yes | never deletes source profile |
| Mission | yes/archive | yes | streak/XP | yes | reminder history separate |
| Education progress | yes/reset | yes | review schedule | yes | no health-risk effect |
| Reminder | yes | platform schedule canceled | no clinical completion | optional | deleting reminder does not delete source plan |
| Consent | revoke, history policy | server | access | yes | revocation timestamp may need audit retention |
| AuditEvent | not ordinary editable record | policy-specific | no | scoped | tamper-resistant semantics; legal/privacy review required |
| ImportBatch | rollback + receipt | policy-specific | yes | receipt yes | rollback targets only batch effects |
| Attachment | yes | yes | source link state | yes | canonical record may remain with missing attachment marker |
| Backup/export file | user-controlled | n/a | no | n/a | app should not assume it can revoke a file already exported externally |

## Derived dependency deletion

When source data are deleted:
1. mark deletion/tombstone,
2. identify dependent projections/results,
3. invalidate/recalculate/remove according to model contract,
4. preserve deletion receipt/audit metadata as policy permits,
5. synchronize tombstone,
6. prevent stale resurrection.

## Account deletion states

Suggested:
- REQUESTED
- REAUTH_REQUIRED
- QUEUED
- IN_PROGRESS
- COMPLETED
- PARTIAL_WITH_DOCUMENTED_RETENTION
- FAILED_RETRYABLE
- FAILED_REVIEW_REQUIRED

Do not display COMPLETED while accessible user health data remain outside explicitly documented retention exceptions.

## Backups

Backup deletion lag must be documented.
A user-facing deletion flow should distinguish immediate logical unavailability from later backup purge when architecture/legal obligations require it.

## Local-only

For local-only profiles, hard deletion may be device-local, but exported copies/backups outside app control cannot be recalled.

## Third-party providers

Deleting local imported data does not necessarily delete the source data held by Apple Health, Health Connect, a laboratory or another provider.
The UI must say what scope the deletion actually controls.
\n\n## v0.21 attachment retention\nOriginal bytes, thumbnails, parser/OCR scratch text, extraction candidates, review receipts and canonical facts have separate retention/deletion semantics. Source deletion must not silently cascade into canonical health-history deletion.\n
