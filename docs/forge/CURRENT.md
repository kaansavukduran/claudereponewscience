# Forge CURRENT: Human Health OS v0.25

- **Last verified checkpoint:** v0.25, the connected implementation bootstrap (2026-10-06). See `docs/RELEASE_STATUS.md`.
- **Previous:** v0.24, lab interpretation governance and identifier repair (spec only).
- **Increment delivered:** the first compiled code. The Site Lab, the production client and the API all import one `@hhos/domain` core. Cross-target golden vectors, server/device parity tests and the v0.25 build prompts keep them linked.

## Active modules (code)

Core derived formulas · Protection/Burden/Function/Coverage/Balance (app-defined demo) · external-model "never fake" cards · Compare/Scenario · Lab interpretation v0.24 · Nutrition/recipe math · Preventive engine (synthetic pack) · Med/supplement safety (synthetic pack) · Missions and progression · EDU foundation pack (EN/TR) · Attribution manifest · SQLite kernel and API · client repositories (local and cloud).

## Open work, ranked for the next Forge

1. **Native release path.** Android build (needs `dl.google.com` allowed and an Android SDK), a SQLite-backed `DocumentStore`, Keystore/Keychain secrets, then iOS on macOS.
2. **Real authentication.** An identity provider, session/device registry, and an account-deletion state machine.
3. **Canonical body facts with corrections.** Move profile `inputs_json` into `health_facts` with supersedes chains (FR-22/26) and recalculation invalidation (FR-242/243).
4. **PostgreSQL + RLS runtime.** Port migration 0001, run the RLS policies, and add pooled-connection isolation tests (AT-820/821).
5. **Lawful real reference sources.** Lab analyte mapping / reference adapters (the v0.24 heuristic), then curated preventive and medication packs.
6. **HealthKit / Health Connect adapters** behind the existing provenance model.

## Known issues

See "Known limitations" in `docs/RELEASE_STATUS.md`. No background or automatic Forge runs. The next increment starts only on an explicit `Forge` request.
