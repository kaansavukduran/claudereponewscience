# Roadmap (dependency-ordered FORGE increments)

Each line is one bounded FORGE. A stage starts only after the stage it depends on reaches the stated evidence level. The status of each increment is tracked in `project_state/CURRENT_STATE.json`.

## FOUNDATION
- **F001 – Flutter bootstrap + responsive shell.** `flutter create --empty` for 6 platforms. Ten destinations with rail/bar navigation. Visible build-profile badge. Widget tests. Web build and Playwright runtime smoke. Linux, Android, iOS, macOS and Windows are reported independently (v0.27 gate V1–V3).
- **F002 – Local heartbeat.** Profile plus one canonical record (body weight) through the `HealthRepository` port. In-memory and file-backed vault adapters. Save, restart, and get the same record back. Missing ≠ 0 in the UI. *(The user's §32 first vertical slice.)*
- **F003 – Dart core-derived engines** (`lib/src/domain/scoring`). Must pass `contracts/golden_vectors/core_derived_vectors.json` exactly like TS and Python. Adds an architecture test that blocks Flutter imports in the domain.
- **F004 – Encrypted vault v1.** Versioned header, passphrase KDF, wrapped data key, wrong-passphrase and corrupt-header handling, and a portable-path-move test (same profile UUID). Web uses WebCrypto plus an export warning.
- F005 – Schema migrations and backup/restore of the vault (checkpoint before migrate).

## CORE HUMAN
- F006 – Timeline (an index over canonical records), corrections with `supersedes` lineage, and tombstones.
- F007 – Measurements and vitals (weight, height, waist, blood pressure, resting heart rate) with units and provenance, plus BMI/WHtR results.
- F008 – Labs: sessions and results (PRESENT, NOT_REPORTED, UNREADABLE), reference-interval snapshots, and trend with method discontinuity.
- F009 – Lab interpretation engine (Dart port, lab vectors).

## DAILY HUMAN
- F010 – Mind check-in (1–10) and symptoms. F011 – Sleep and activity (manual first). F012 – Nutrition: foods, snapshots, recipes (nutrition vectors).

## MEDICAL
- F013 – Products, ingredients, plan versus intake, and safety engine (med-safety vectors). F014 – Conditions (provenance states) and treatments. F015 – Documents and attachments with staged lab extraction candidates. F016 – Preventive engine (preventive vectors, jurisdiction packs).

## INTELLIGENCE
- F017 – Protection/Burden/Function/Coverage composites. Numeric vectors are added first, then the port. F018 – Compare and scenarios. F019 – Personal baselines and early-warning patterns. F020 – Daily missions with plan ≠ completion. F021 – Learn (EDU pack moved to JSON/ARB so the Build Lab and the app share it). F022 – Longevity/Shortevity dashboard (MODELLED labels, no date-of-death).

## INTEROPERABILITY
- F023 – Capability registry, Health Connect adapter (Android host). F024 – HealthKit adapter (macOS host). F025 – Portable export and import bundle. F026 – Terminology adapters (LOINC, UCUM) after licence review.

## SYNC
- F027 – Accounts with a real identity provider. F028 – Encrypted sync with idempotency, revisions and conflicts (semantics from `services/api`). F029 – Backup and recovery.

## DESKTOP
- F030 – Windows build plus portable ZIP (`portable_mode.json`, `UserData/` vault). F031 – Windows installer (data survives uninstall). F032 – macOS app plus DMG (Application Support storage). F033 – Signed update metadata.

## WEB
- F034 – PWA manifest, service worker and install. Browser-limit disclosures. F035 – Retire `apps/client` once parity exists. F036 – The Build Lab reads shared JSON packs, so the same content feeds the app and the Lab.

## RELEASE
- F037 – Accessibility pass (semantics, text scale, contrast). F038 – Performance budgets. F039 – Security review against SECURITY_MODEL. F040 – SBOM, licenses and provenance. F041 – Signing, notarization and store submission, each on its own host.
