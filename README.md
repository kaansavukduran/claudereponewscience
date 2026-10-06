# Human OS / Human Health OS / Longevity App

Start with `CLAUDE.md` and `project_state/CURRENT_STATE.json`.

**Product:** `human_health_os/` is one Flutter app for Android, iOS, Web/PWA, Windows (portable and installer), macOS and Linux (Fedora/Nobara and Ubuntu/Debian families). See ADR-IMPL-002 in `project_state/DECISIONS.md` and `docs/ARCHITECTURE.md`. Development runs in bounded FORGE cycles, logged in `project_state/FORGE_LOG.md`.

The TypeScript workspace below came before the Flutter app. It is now the **reference oracle** (`packages/domain` + golden vectors) and the **Build Lab** (`apps/site`, synthetic only). `apps/client` is a frozen prototype.

TypeScript workspace targets:

| Target | Path | What it is |
|---|---|---|
| Interactive Site Lab | `apps/site` | Synthetic-first web laboratory: profile builder, Longevity ↔ Shortevity channels, Compare Lab, lab-interpretation and method-comparison lab, Preventive Care Lab, Safety Lab, nutrition math, Daily Missions, timeline and wearables, Learn (EN/TR), Data Sources & Licenses |
| Prototype client (frozen) | `apps/client` | Earlier React prototype (web; Capacitor shells were never built here, so Android/iOS stay BLOCKED). Superseded by `human_health_os/`; do not extend |
| API | `services/api` | `/v1` HTTP API on SQLite: owner authorization, Idempotency-Key, If-Match revisions, stable error envelope, append-only migrations |
| Shared core | `packages/domain` | Every formula, rule and engine. Nothing is re-implemented in a UI or the server |
| Shared packs | `packages/packs` | REF-SYNTHETIC-DEMO-1, EDU-HEALTH-LITERACY-FOUNDATION-1, synthetic rule packs, attribution manifest |
| Shared UI | `packages/ui` | Design tokens (light, dark, high clarity), ResultCard, MetricValue (missing ≠ 0), HowCalculated, NumField, TrendChart, EN/TR strings |
| Contracts | `contracts/golden_vectors` | 73 golden vectors executed by TypeScript **and** by an independent Python port |

`docs/PARITY.md` shows how the targets stay connected. `docs/RELEASE_STATUS.md` lists what is proven and what is blocked.

## Commands

```bash
pnpm install
pnpm typecheck
pnpm test                          # domain + packs + api + client + site unit and integration tests
python3 tools/verify_contracts.py  # independent Python port + SQLite kernel + ID integrity
pnpm build                         # apps/site/dist and apps/client/dist
pnpm --filter @hhos/site e2e       # Playwright, desktop + mobile
pnpm --filter @hhos/client e2e     # Playwright, starts the API on :8788
pnpm dev:site                      # http://localhost:5173
pnpm dev:api                       # http://localhost:8787/v1/health
pnpm dev:client                    # http://localhost:5174
```

Requires Node ≥ 22.18 (TypeScript runs through native type stripping, so there is no build step for the packages) and Python ≥ 3.10.

## Invariants (enforced by tests)

missing ≠ zero · plan ≠ completion · self-report ≠ diagnosis · app score ≠ validated clinical risk · domain score ≠ lifespan · Shortevity score ≠ years lost · scenario ≠ observed fact · reference interval ≠ optimal target ≠ decision limit · outside reference ≠ critical · no rule found ≠ guaranteed safe · reset ≠ delete · deterministic/offline core, no generative AI.

## Handoff

- Source authority and lineage: `project_state/SOURCES.md`. Current process master: `docs/handoff/v0.32/` (candidate, D-013); product semantics: `docs/handoff/v0.24/`.
- `docs/handoff/v0.25/`: **repo-local** prompts written by an earlier Claude session, not the user's v0.25 (which was never supplied).
- `docs/adr/`: early implementation decisions; ADR-IMPL-001's client choice is superseded by ADR-IMPL-002 (`project_state/DECISIONS.md`).
- `project_state/CURRENT_STATE.json` and `project_state/FORGE_LOG.md`: the current Forge checkpoint, evidence and the next increment.
