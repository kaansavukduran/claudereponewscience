# Data model (canonical, platform-independent)

Normative source: `docs/handoff/v0.24/LONGEVITY_APP_MASTER_HANDOFF_v0.24.md`, sections "CANONICAL DATA MODEL", "CANONICAL DATA DICTIONARY" and "DATABASE DDL, CONSTRAINT AND INDEX BLUEPRINT". This file is the implementation-facing summary. Where they disagree, the handoff wins until a recorded decision changes it.

## The envelope every canonical record shares

| Field | Meaning |
|---|---|
| `id` | Stable UUID. Never derived from a file path or display name. |
| `profile_id` | Owning profile (UUID). A portable vault keeps it across machines. |
| `kind` | Record kind, e.g. `body.weight`, `lab.result`, `mind.checkin`, `medication.intake` |
| `state` | `OBSERVED` · `REPORTED` · `PLANNED` · `COMPLETED` · `DERIVED` · `MODELLED` · `ASSUMED` · `UNKNOWN` |
| `value` | Typed value: quantity (number + unit), text, code, or structured payload. May be absent. |
| `value_status` | `PRESENT` · `NOT_REPORTED` · `NOT_MEASURED` · `NOT_APPLICABLE` · `UNKNOWN`. Missing is a status, never 0. |
| `original` | Original source representation (text, unit, precision) kept verbatim |
| `provenance` | `MANUAL` · `DEVICE` · `PROVIDER` · `DOCUMENT` · `API` · `DERIVED` · `MODELLED` · `IMPORTED` · `UNKNOWN`, plus `source_id`, `source_version` and `device_id` when known |
| `observed_at` / `effective_at` | When it happened or applies, with timezone semantics recorded |
| `recorded_at` / `created_at` | When it was entered or stored |
| `supersedes_id` | Correction lineage. A correction is a **new** record. The old one stays auditable. |
| `deleted_at` | Tombstone. A deleted record never comes back through sync. |
| `schema_version` | Record schema version, for migrations |

Derived and modelled results are separate records (`ScoreResult`). Each carries `model_id`, `model_version`, `result_class`, `status`, input record IDs, missing inputs, coverage, limitations and `calculated_at`. A model or rule change creates new results. History is never rewritten silently.

## Entity families, in Forge order

1. **Profile** (FORGE 002). `Profile{id, display_name, profile_type: SELF|REAL_OTHER|SYNTHETIC|SCENARIO, source_profile_id, timezone, locale, preferred_units, created_at}`. SYNTHETIC and SCENARIO profiles are labelled and kept apart from SELF data.
2. **Generic observation** (FORGE 002). Body measurements (weight, height, waist), vitals (blood pressure, resting heart rate) and the mind check-in, all through the envelope.
3. **Labs** (FORGE 004). `LabSession` + `LabResult{analyte_code?, display_name, numeric_value?, text_value?, unit, specimen, method, laboratory, reference_interval_snapshot, source_flag, result_state: PRESENT|NOT_REPORTED|UNREADABLE}`. Interpretation (reference / critical / method / RCV / baseline) is a separate `LabInterpretationAssessment`.
4. **Timeline** (FORGE 003/004). `TimelineEvent` is an **index** over canonical records, not a second source of truth.
5. Medications and supplements: `ProductConcept`, `IngredientConcept`, `MedicationPlan`, `IntakeEvent` (requires `taken_at`), `InteractionAssessment`.
6. Nutrition: `Food`, `FoodSnapshot` (immutable once logged), `Meal`, `FoodEntry`, `RecipeVersion`.
7. Activity, sleep and wearables: dense series with source/device provenance and an overlap policy. Sources are never blindly summed.
8. Conditions and symptoms: condition status `SUSPECTED|SELF_REPORTED|PROVIDER_REPORTED|PROVIDER_CONFIRMED|RESOLVED|ENTERED_IN_ERROR|UNKNOWN`.
9. Preventive care: `PreventiveServiceDefinition`, `PreventiveRule`, `PreventiveEvent` (requires `completed_at`), `PreventiveAssessment` (eligibility, recommendation mode and due state kept separate).
10. Missions and pathways: `Mission{status: PLANNED|STARTED|COMPLETED|SKIPPED|BLOCKED, completion_record_ids}`. COMPLETED requires at least one completion record.
11. Comparison: `ComparisonProfile`, `ScenarioPatch` (non-mutating).

## Storage mapping

- **Flutter app:** a `HealthRepository` port with adapters. FORGE 002 ships an in-memory adapter plus a file-backed JSON-lines vault adapter for desktop and tests. An encrypted SQLite (or equivalent) adapter follows in the encryption FORGE. Domain code never imports a storage package.
- **TypeScript reference API** (`services/api`): SQLite kernel `migrations/0001_kernel.sql`, with the same invariants as CHECK constraints (PRESENT ⇒ value, COMPLETED ⇒ completion record, OK ⇒ numeric output).
- **Exports:** a portable bundle that keeps IDs, provenance, corrections and model/rule versions. A FHIR adapter is a later, separately validated layer.
