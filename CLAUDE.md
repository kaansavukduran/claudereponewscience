# CLAUDE.md: Human OS (Human Health OS / Longevity App)

You are the technical lead of this repository. Read `project_state/CURRENT_STATE.json` first, then `docs/ARCHITECTURE.md` and `docs/ROADMAP.md`. The product summary is in `docs/HUMAN_OS_OVERVIEW.md`, and the user's normative rules are in `docs/handoff/claude-code-init/MASTER_INIT_PROMPT_DIGEST.md`.

## What lives where

| Path | Role |
|---|---|
| `human_health_os/` | **The product.** One Flutter app for Android, iOS, Web/PWA, Windows (portable and installer), macOS and **Linux** (Fedora/Nobara and Ubuntu/Debian families; D-008). Pure-Dart domain code goes in `lib/src/domain/`, with no Flutter, IO or HTML imports. |
| `contracts/golden_vectors/` | Language-neutral contract. Every engine in every language must pass these vectors. |
| `packages/domain` (TS) | Reference oracle for the engines (73 vectors). The Build Lab and the reference API use it too. |
| `apps/site` | **Human OS Build Lab.** Synthetic-only teaching and simulation lab (React). It is not a product surface. |
| `services/api` | Reference sync/API candidate (Node + SQLite). Dev auth only. |
| `apps/client` | React/Capacitor prototype client. Superseded by `human_health_os/` once parity exists. Do not extend it. |
| `docs/handoff/` | Specs as received (`v0.24` is authoritative; `v0.27-candidate` is a candidate) plus repo-local material. See `project_state/SOURCES.md`. |
| `project_state/` | Canonical development state: current state, FORGE log, decisions, risks, gaps. |

## Commands

```bash
export PATH=/opt/toolchains/flutter/bin:$PATH               # Flutter 3.47.6 / Dart 3.13.5 (install: see docs/DEVELOPMENT_PLAN.md)
export CHROME_EXECUTABLE=/opt/pw-browsers/chromium-1194/chrome-linux/chrome
cd human_health_os && flutter pub get && dart format --output=none --set-exit-if-changed lib test && flutter analyze && flutter test
flutter build web --release --no-web-resources-cdn --dart-define=APP_ENV=development --dart-define=SOURCE_REVISION=$(git rev-parse HEAD)
xvfb-run -a flutter test integration_test -d linux             # real file IO, relaunch, folder move (needs libgtk-3-dev)
cd .. && node tools/flutter_web_smoke.mjs                       # Playwright runtime smoke of human_health_os/build/web
pnpm install && pnpm typecheck && pnpm test && python3 tools/verify_contracts.py   # TS reference + Build Lab
```

## Invariants (never break)

planned ≠ completed · missing ≠ zero · unknown ≠ false · model/scenario ≠ observation · reference interval ≠ optimal target ≠ decision limit · out-of-range ≠ critical · self-report ≠ diagnosis · prescription/reminder ≠ intake · no interaction found ≠ safe · unknown history ≠ zero history · same name ≠ same measurand. Corrections create new records. History is never rewritten silently. Every computed result carries its model or rule ID and version, inputs, missing inputs and limitations. Build Lab synthetic data never mixes with real profiles. The core never requires an LLM or the network.

## FORGE workflow

`FORGE` runs **one** bounded increment: orient → select gap → specify → implement → test → fix the first failure → retest → regression → audit → package → stop. `FORGE: <scope>` uses that scope if it is coherent.

Write the report in the format in the digest (§36). Append it to `project_state/FORGE_LOG.md` and update `CURRENT_STATE.json`. Recommend exactly one next FORGE.

## Honesty and safety

- Use the evidence ladder from the digest and never collapse its levels: IMPLEMENTED < STATICALLY_TESTED < UNIT_TESTED < INTEGRATION_TESTED < COMPILED < RUNTIME_TESTED < PACKAGED < SIGNED < NOTARIZED < DEPLOYED, plus NOT_RUN, BLOCKED_ENVIRONMENT, BLOCKED_BY_HOST_OS and UNKNOWN. Never hand-craft binaries.
- The invariant list above is a working subset. Where it and the digest differ, the digest wins.
- Storage: development builds save an **unencrypted** log under XDG/Application Support/LOCALAPPDATA. Production and portable modes stay memory-only until the encrypted vault (FORGE 004). Never write plaintext health data next to an executable.
- Never commit secrets or real health data. Never put server secrets in Dart, `--dart-define`, or a web bundle.
- Add dependencies only after a recorded review (license, maintenance, platforms). Commit `pubspec.lock` and `pnpm-lock.yaml`.
- Git: no `reset --hard`, `clean -fd` or force-push. Work on the designated branch.
