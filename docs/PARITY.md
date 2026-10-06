# How the parallel projects connect

Human Health OS ships as three targets: the **production client** (Android, iOS and Web), the **API** and the **Interactive Site Lab**. They used to be described in two separate build prompts. In this repository they share one core instead of each having its own copy.

```
                 contracts/golden_vectors/*.json   ◄── tools/verify_contracts.py (independent Python port)
                                │
                     packages/domain  (@hhos/domain) ── formulas, Longevity↔Shortevity channels, compare,
                                │                         lab interpretation v0.24, nutrition, preventive,
                                │                         med safety, missions, scenarios
            ┌───────────────────┼────────────────────┐
     packages/packs        packages/ui               │
  (synthetic data, EDU,   (tokens, ResultCard,       │
   rule packs, licenses)   MetricValue, NumField,    │
            │              HowCalculated, i18n)      │
   ┌────────┴──────┬──────────┴────────┐             │
apps/site      apps/client ───────HTTP /v1──► services/api
(Site Lab,     (Local: IndexedDB          (SQLite kernel, ownership,
 synthetic)     Cloud: ApiRepository)      idempotency, If-Match)
```

## What is shared and how we check it stays shared

| Contract | Single source | Site Lab | Client | API | Evidence |
|---|---|---|---|---|---|
| CORE_DERIVED formulas (BMI, WHtR, pack-years, Δ, %Δ, volume, rolling, OLS, MAD-z) | `packages/domain/src/coreDerived.ts` | ✓ | ✓ | ✓ | 19 vectors in TS + the same 19 in Python |
| Protection / Burden / Function / Coverage / Balance | `packages/domain/src/composites.ts` | ✓ | ✓ | ✓ (`/scores/compute`) | `services/api/test` + `apps/client/test`: the server's results deep-equal the on-device results |
| External models are never faked (PREVENT, oncology, clocks, WHO baseline) | `packages/domain/src/results.ts` | ✓ | ✓ | ✓ | Site e2e test 6, packs invariants |
| Compare: N profiles, %Δ only where meaningful | `packages/domain/src/compare.ts` | ✓ | ✓ | ✓ (`/v1/compare`) | Site e2e test 7, client e2e cloud test |
| Scenario clone never mutates its source | `packages/domain/src/profile.ts` | ✓ | ✓ | ✓ (`/scenarios`) | Site e2e test 3, API and client tests |
| Lab interpretation v0.24 (reference, critical, method, RCV, baseline) | `packages/domain/src/labInterpretation.ts` | ✓ (playground) | ✓ (Labs screen) | ✓ (`/interpretation`) | 19 vectors in TS + Python, plus e2e |
| Missions: plan ≠ completion, safety gate, no stacking | `packages/domain/src/missions.ts` | ✓ | ✓ | ✓ | packs invariants, API test, both e2e suites |
| Missing ≠ zero in UI | `packages/ui` (`MetricValue`, `NumField`, `TrendChart`) | ✓ | ✓ | n/a | Site e2e test 5, client e2e labs test |
| Result class always visible + "How calculated?" | `packages/ui/src/components.tsx` | ✓ | ✓ | payload carries `modelId`/`version` | e2e |
| Data Sources & Licenses | `packages/packs/src/catalog.ts` (`ATTRIBUTION_MANIFEST`) | ✓ | ✓ | ✓ (`/v1/attribution`) | Site e2e |
| Design tokens (light, dark, high-clarity) | `packages/ui/src/tokens.css` | ✓ | ✓ | n/a | screenshots |

## Rules for future changes (also in the v0.25 build prompts)

1. A new calculation goes in `packages/domain` together with golden vectors. All three targets then get it in the same commit.
2. UI code never contains clinical or scoring math.
3. A change counts as merged only when the TypeScript tests, `python3 tools/verify_contracts.py`, both Playwright suites and the parity tests are all green.
