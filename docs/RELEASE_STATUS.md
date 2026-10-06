# Release status — v0.25 (evidence-linked)

Checked on 2026-10-06 in a Linux cloud container: Node 22.22.0, pnpm 10.28.0, Python 3.13, Chromium (Playwright 1.56.1).
Each row is labelled **PASS** (the command was run and its output is cited), **BLOCKED** (the exact blocker is named) or **NOT_RUN**.
Overall status: **NOT PRODUCTION_READY**. The native build, real authentication, PostgreSQL and the security gates are still open.

| Gate | Status | Evidence / blocker |
|---|---|---|
| Typecheck (all 6 packages) | PASS | `pnpm typecheck` |
| Domain golden vectors (73: core 19, lab 19, nutrition 5, preventive 20, med-safety 10) | PASS | `pnpm --filter @hhos/domain test` → 73/73 |
| Shared-pack invariants (synthetic pack, compare, scenario, missions, education) | PASS | `pnpm --filter @hhos/packs test` → 14/14 |
| Independent Python port of the vectors + SQLite kernel probes + ID integrity | PASS | `python3 tools/verify_contracts.py` (writes `reports/tests/verify_contracts.json`) |
| API integration (auth, ownership/404, idempotency, If-Match, labs, interpretation, scores parity, missions, compare, seed, migrations checksum, prod route lock) | PASS | `pnpm --filter @hhos/api test` → 13/13 |
| Client repository contract (local + cloud against the real API) + server/device parity | PASS | `pnpm --filter @hhos/client test` → 5/5 |
| Site Lab unit tests (state/reset/clone) | PASS | `pnpm --filter @hhos/site test` → 4/4 |
| Site Lab e2e: the 10 required tests + lab/missions/preventive (desktop 1440×900 + Pixel 7) | PASS | `pnpm --filter @hhos/site e2e` → 25 passed, 1 skipped (keyboard test runs on desktop only) |
| Client web e2e: local-only + cloud (against the API) + labs + missions (desktop + Pixel 7) | PASS | `pnpm --filter @hhos/client e2e` → 8 passed |
| Production web builds (Site + client) | PASS | `pnpm build` → `apps/site/dist`, `apps/client/dist` |
| Android APK/AAB | **BLOCKED** | `npx cap add android` succeeded. `./gradlew assembleDebug` failed: the environment network policy returns **403 for `dl.google.com`** (Google Maven: AGP 8.13.0, google-services 4.4.4), and no Android SDK is installed (`ANDROID_HOME` is unset). Fix: allow `dl.google.com` and install an SDK, or build on a machine that has the Android toolchain. |
| iOS / Xcode / TestFlight | **BLOCKED** | Needs macOS with Xcode; this container runs Linux. |
| Native secure storage (SQLite store, Keystore/Keychain) | NOT_RUN | The interface is ready (`DocumentStore`); there is no native implementation yet. |
| HealthKit / Health Connect adapters | NOT_RUN | The Site shows only synthetic wearable data and makes no device claims. |
| Real authentication / identity provider | NOT_RUN | `/v1/auth/dev-session` is development-only and is disabled when `HHOS_ENV=production`. |
| PostgreSQL DDL + RLS runtime | NOT_RUN | PostgreSQL 16 binaries are present but no cluster was started (AT-821). |
| Account-deletion workflow (cloud) | NOT_RUN | The client reports `NOT_IMPLEMENTED` instead of pretending to delete. Local delete-all is implemented and tested. |
| FHIR export validation | NOT_RUN | — |
| Threat model / OWASP MASVS review | NOT_RUN | — |
| Performance budgets | NOT_RUN | — |
| CI workflow | NOT_RUN (defined) | `.github/workflows/ci.yml` has not run on GitHub yet. |

## Known limitations

- The v0.24 Developer Handoff ZIP was not available (only its SHA-256). The golden vectors, migration and catalogs in this repository were **reconstructed from the Master Handoff text** and are labelled as such.
- Body inputs are stored as JSON on the profile row. Correction history for body facts (FR-22/26) is not modelled yet. Labs have real columns and keep their reference-interval snapshots.
- Composite normalisation anchors are synthetic demo anchors (`APP-COMPOSITES-DEMO-1`). They are not clinical targets.
- No real clinical threshold, interaction or preventive pack is active. All rule packs are synthetic.
