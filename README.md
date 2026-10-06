# Human Health OS / Longevity App

This monorepo turns the v0.24 handoff into working code. Three targets share one deterministic core:

| Target | Path | What it is |
|---|---|---|
| Interactive Site Lab | `apps/site` | Synthetic-first web laboratory: profile builder, Longevity ↔ Shortevity channels, Compare Lab, lab-interpretation and method-comparison lab, Preventive Care Lab, Safety Lab, nutrition math, Daily Missions, timeline and wearables, Learn (EN/TR), Data Sources & Licenses |
| Production client | `apps/client` | The real app (web now; Android and iOS via Capacitor shells): local-only (IndexedDB) or cloud account, Today, Body, Labs, Results, Compare, Settings (reset ≠ delete) |
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

- `docs/handoff/v0.24/`: the authoritative Master Handoff and build prompts as received.
- `docs/handoff/v0.25/`: build prompts extended with the connected-targets requirements, plus the v0.25 addendum (FR-456…463, AT-1109…1118).
- `docs/adr/`: implementation decisions, including the deviation from the Flutter preference.
- `docs/forge/CURRENT.md`: the current Forge checkpoint and the next increments.
