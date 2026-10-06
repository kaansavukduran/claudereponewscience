# CLAUDE.md: Human OS (Human Health OS / Longevity App)

You are the technical lead of this repository. Read `project_state/CURRENT_STATE.json` first (canonical cursor: `development_state`, `active_forge`, `suspended_forges`, `verified_gates`), then `docs/ROADMAP.md` and `docs/ARCHITECTURE.md`. The product summary is in `docs/HUMAN_OS_OVERVIEW.md`.

**Source authority:** verified repository code > a hash-verified CURRENT handoff (none present; v0.26 baseline missing) > the v0.31 master `docs/handoff/v0.31/HUMAN_OS_CLAUDE_CODE_MASTER_FORGE_v0.31_CLAUDE_CODE_WEB_ONE_SHOT.md` (process and plan, D-011) > candidate addenda > history. Product semantics: `docs/handoff/v0.24/`. Conflicts are listed in `project_state/SOURCES.md`; never resolve them silently.

## What lives where

| Path | Role |
|---|---|
| `human_health_os/` | **The product.** One Flutter app for Android, iOS, Web/PWA, Windows (portable and installer), macOS and **Linux** (Fedora/Nobara and Ubuntu/Debian families; D-008). Pure-Dart domain code goes in `lib/src/domain/`, with no Flutter, IO or HTML imports. |
| `contracts/golden_vectors/` | Language-neutral contract. Every engine in every language must pass these vectors. |
| `packages/domain` (TS) | Reference oracle for the engines (73 vectors). The Build Lab and the reference API use it too. |
| `apps/site` | **Human OS Build Lab.** Synthetic-only teaching and simulation lab (React). It is not a product surface. |
| `services/api` | Reference sync/API candidate (Node + SQLite). Dev auth only. |
| `apps/client` | React/Capacitor prototype client. Superseded by `human_health_os/` once parity exists. Do not extend it. |
| `docs/handoff/` | Specs as received (`v0.24` product semantics; `v0.27`/`v0.28` candidates; `v0.31` master) plus repo-local material. See `project_state/SOURCES.md`. |
| `project_state/` | Canonical development state: current state, FORGE log, decisions, risks, gaps, sources. |
| `evidence/` | Machine-written JSON receipts (`tests/`, `builds/`, `runtime/`) from `tools/evidence/run_gate.py`. No PASS without a receipt. |
| `reports/` | Earlier evidence (screenshots, logs, artifact records) kept for history. |
| `packaging/linux/`, `tools/linux/` | Linux packaging inputs and scripts (F015-L1). |

## Commands

```bash
export PATH=/opt/toolchains/flutter/bin:$PATH               # Flutter 3.47.6 / Dart 3.13.5 (install: see docs/DEVELOPMENT_PLAN.md)
export CHROME_EXECUTABLE=/opt/pw-browsers/chromium-1194/chrome-linux/chrome
cd human_health_os && flutter pub get && dart format --output=none --set-exit-if-changed . && flutter analyze && flutter test
flutter build web --release --no-web-resources-cdn --dart-define=APP_ENV=development --dart-define=SOURCE_REVISION=$(git rev-parse HEAD)
# Flutter/Dart versions reach the app through FlutterVersion; FLUTTER_VERSION is reserved, never pass it.
xvfb-run -a flutter test integration_test -d linux             # real file IO, relaunch, folder move (needs libgtk-3-dev)
cd .. && EXPECT_FLUTTER_VERSION=3.47.6 node tools/flutter_web_smoke.mjs   # Playwright smoke: Today → Timeline → Labs, identity
python3 tools/validate_project_state.py && python3 -m unittest tools/evidence/test_run_gate.py   # state/evidence self-audit
pnpm install && pnpm typecheck && pnpm test && python3 tools/verify_contracts.py   # TS reference + Build Lab
```

## Invariants (never break)

planned ≠ completed · prescribed ≠ taken · reminder ≠ completion · missing ≠ zero · unknown ≠ false · source text ≠ normalized interpretation · association ≠ causation · risk estimate ≠ diagnosis · screening ≠ diagnosis · scenario ≠ observation · model output ≠ observed fact · reference interval ≠ optimal target · reference interval ≠ clinical decision limit · outside reference ≠ critical · self-report ≠ diagnosis · no interaction found ≠ safe · unknown history ≠ zero history · same display name ≠ same measurand (v0.31 §2). Corrections create new records. History is never rewritten silently. Every computed result carries its model or rule ID and version, inputs, missing inputs and limitations. Build Lab synthetic data never mixes with real profiles. The core never requires an LLM or the network.

## FORGE workflow (v0.31 §22, §31–§34)

`FORGE` runs **one** bounded increment of the v0.31 ladder (F001–F017, `docs/ROADMAP.md`): orient → select gap → specify → implement → test → fix the first failure → retest → regression → audit → package → update state → stop. `FORGE xN` = up to N sequential Forges, each closed on its own.

On start or resume: read the state file, compare it with `git status`, resume from the first unverified action, never mark an interrupted Forge complete because code exists. Repository reality beats the state file; record the discrepancy.

Run gates through `python3 tools/evidence/run_gate.py --id <EV-…> --kind TEST|BUILD|RUNTIME --forge <F…> -- <command>`. Evidence goes stale when source, lockfile, profile or config change. Done = v0.31 §34. Report format = v0.31 §24, appended to `project_state/FORGE_LOG.md`. Recommend exactly one next Forge.

## Honesty and safety

- Use the evidence ladder from the digest and never collapse its levels: IMPLEMENTED < STATICALLY_TESTED < UNIT_TESTED < INTEGRATION_TESTED < COMPILED < RUNTIME_TESTED < PACKAGED < SIGNED < NOTARIZED < DEPLOYED, plus NOT_RUN, BLOCKED_ENVIRONMENT, BLOCKED_BY_HOST_OS and UNKNOWN. Never hand-craft binaries.
- The invariant list above is a working subset. Where it and the digest differ, the digest wins.
- Storage: development builds save an **unencrypted** log under XDG/Application Support/LOCALAPPDATA. Production and portable modes stay memory-only until the encrypted vault (FORGE 004). Never write plaintext health data next to an executable.
- Never commit secrets or real health data. Never put server secrets in Dart, `--dart-define`, or a web bundle.
- Add dependencies only after a recorded review (license, maintenance, platforms). Commit `pubspec.lock` and `pnpm-lock.yaml`.
- Git: no `reset --hard`, `clean -fd` or force-push. Work on the designated branch.
