# MASTER HANDOFF v0.25 — ADDENDUM (Forge increment: connected implementation)

Base: `docs/handoff/v0.24/LONGEVITY_APP_MASTER_HANDOFF_v0.24.md` (unchanged, authoritative for product semantics).
This addendum is the v0.25 delta. The v0.24 Developer Handoff ZIP (`LONGEVITY_APP_DEVELOPER_HANDOFF_v0.24.zip`, SHA-256 `d0eb812b…e699`) was **not available** in this session; only its checksum file was. Machine assets it contained (original golden-vector JSON, reference_code, OpenAPI starter, DDL files) were therefore **reconstructed from the Master Handoff text** where needed and are labelled as such.

## Selected increment

The v0.24 next-gap heuristic lists "first compiled app/backend bootstrap when target toolchains are available". The user asked for the parallel projects (production app and Site Lab) to be developed **connected to each other**. v0.25 does both: one compiled monorepo where the Site Lab, the production client and the API run the same deterministic core.

## New requirements (FR-456 … FR-463)

| ID | Requirement |
|---|---|
| FR-456 Shared Core Package | All calculations, rules and engines live in one framework-neutral package consumed by every target. |
| FR-457 Cross-target Golden Contract | Golden vectors under `contracts/` are executed by the core and by an independent port; both must pass. |
| FR-458 Server/Device Result Parity | For the same profile, server-computed results deep-equal on-device results. |
| FR-459 Shared Semantic UI | Result-class labelling, missing-state rendering, "How calculated?", tokens and EN/TR strings come from one shared UI package. |
| FR-460 Repository Abstraction | Client data access goes through one repository interface with local-only and cloud implementations satisfying the same contract tests. |
| FR-461 Write Delivery Uncertainty | A network failure after send is reported as `saved: UNKNOWN`; retries are safe via idempotency keys. |
| FR-462 Native Shell Reuse | Android/iOS shells wrap the same client build; native-only storage/keys replace web storage before release. |
| FR-463 Evidence-linked Status | `docs/RELEASE_STATUS.md` lists PASS (with command), BLOCKED (exact blocker) or NOT_RUN for every gate. |

## New acceptance tests (AT-1109 … AT-1118)

| ID | Test | Where |
|---|---|---|
| AT-1109 | Domain package passes all 73 golden vectors (core, lab, nutrition, preventive, med-safety). | `packages/domain/test/golden.test.ts` |
| AT-1110 | Independent Python port passes core, lab, and nutrition-scale vectors. | `tools/verify_contracts.py` |
| AT-1111 | API `/scores/compute` output deep-equals `computeProfileResults` for the same scenario profile. | `services/api/test/api.test.ts` |
| AT-1112 | Client cloud repository output equals on-device results (parity). | `apps/client/test/repository.test.ts` |
| AT-1113 | LocalRepository and ApiRepository pass the same contract test. | `apps/client/test/repository.test.ts` |
| AT-1114 | Site Lab passes the 10 required Site tests on desktop and mobile. | `apps/site/e2e/site.spec.ts` |
| AT-1115 | Site has no horizontal page scroll on any tab on mobile. | Site e2e test 8 |
| AT-1116 | Client web build: local-only onboarding, labs NOT_REPORTED, cloud onboarding against API, missions plan ≠ completion. | `apps/client/e2e/client.spec.ts` |
| AT-1117 | Released migrations are checksum-guarded (tampering is detected). | API test |
| AT-1118 | Dev-session auth route is absent in production configuration. | API test |

## Identifier note

Golden-vector IDs are new (`GV-CORE-*`, `GV-LAB-*`, `GV-NUT-*`, `GV-PREV-*`, `GV-MED-*`) and uniqueness-checked by `tools/verify_contracts.py`. New FR/AT IDs continue after the highest v0.24 canonical IDs found by scanning the Master Handoff (FR-455, AT-1108); an earlier draft of this addendum used FR-244/AT-1100 and collided — caught and renumbered before release.
