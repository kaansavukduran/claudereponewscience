# Test strategy

Every claim moves up the ladder only with evidence: **IMPLEMENTED → STATICALLY_TESTED → UNIT_TESTED → INTEGRATION_TESTED → COMPILED → RUNTIME_TESTED → PACKAGED → SIGNED → NOTARIZED → DEPLOYED**. A test that was written but not run is NOT_RUN. An analysis pass on Linux never counts as a PASS for a Windows or macOS build.

## Layers

| Layer | Flutter app (`human_health_os/`) | TypeScript reference + Build Lab (`packages/*`, `apps/site`, `services/api`) |
|---|---|---|
| Static | `dart format --output=none --set-exit-if-changed .`, `flutter analyze` | `pnpm typecheck` |
| Unit (pure domain) | `flutter test test/domain` (no Flutter bindings needed) | `pnpm test` (vitest) |
| Cross-language contract | `flutter test test/contracts`: the Dart engines run `contracts/golden_vectors/*.json` | The same vectors in TS (`packages/domain/test`) and in Python (`tools/verify_contracts.py`) |
| Widget | `flutter test test/widget`: shell, navigation, empty/error/missing states | — |
| Integration | `xvfb-run flutter test integration_test -d linux` (real file IO, relaunch, moved folder) | API + client repository tests |
| Build | `flutter build web --release --no-web-resources-cdn` (offline-capable; the plain CDN build fetches CanvasKit/fonts at start), plus `flutter build linux` when GTK is present (CI smoke), `apk`, `appbundle`, `ios`, `macos` and `windows` on their own hosts | `pnpm build` |
| Runtime smoke | `node tools/flutter_web_smoke.mjs`: serve `build/web`, drive it with Playwright/Chromium (semantics enabled): starts, Today, Today → Timeline → Labs, banner, build identity, 0 external requests, 0 page errors, 0 console errors, 0 failed requests | Playwright suites for the Site and the client |
| Linux runtime/packaging | `tools/linux/launch_smoke.sh`, `tools/linux/check_symbols.sh <bundle> <rootfs>`, install/remove per format and distro (F015-L1) | — |
| Packaging | Portable ZIP and installer smoke on a clean Windows VM. DMG mount/launch on macOS. | Artifact publish check |
| State self-audit | `python3 tools/validate_project_state.py` (state paths exist, PASS gates backed by receipts, hosts never over-claimed) | — |

## Golden vectors are the bridge

`contracts/golden_vectors/` is language-neutral and holds 73 vectors (core 19, lab 19, nutrition 5, preventive 20, med-safety 10). Every engine that exists in more than one language must pass the **same** files:

- TypeScript `@hhos/domain`: `pnpm --filter @hhos/domain test`
- Python independent port: `python3 tools/verify_contracts.py`
- Dart `human_health_os/lib/src/domain`: `flutter test test/contracts` (from v0.31 F011)

A formula change is one PR that touches the vectors and every implementation together. Widening a tolerance without a recorded model/version decision is forbidden.

## Required negative and edge cases (each domain)

Missing input → explicit missing state, never 0. Invalid input → error code, no number. Unknown history ≠ never done. Plan or notification → never completion. Scenario edits never mutate the source. Unit mismatch → blocked, never converted silently. Every external/licensed model stays UNAVAILABLE with no fabricated output.

## Flutter specifics

- Domain code under `lib/src/domain` imports only `dart:core`, `dart:math` and `dart:convert`, so it can be unit-tested without Flutter. An architecture test greps for forbidden imports (`package:flutter`, `dart:io`, `dart:html`).
- Widget tests use `tester.view.physicalSize` to cover a 390×844 phone, an 820×1180 tablet and a 1440×900 desktop.
- Web runtime smoke builds with `--no-web-resources-cdn` (sandboxed hosts can block the CanvasKit CDN) and enables semantics, so Playwright can find text.

## Evidence (v0.31 §33)

Every gate runs through `python3 tools/evidence/run_gate.py`, which executes the command and writes a JSON receipt to `evidence/tests/`, `evidence/builds/` or `evidence/runtime/`: evidence id, kind, Forge, source revision, dirty flag, exact command, cwd, start/finish time, exit code, PASS/FAIL derived from the exit code, Flutter/Dart versions, log SHA-256 and a short log tail. Build receipts add artifact paths, sizes and SHA-256 plus the lockfile digest. Raw logs stay out of git.

A PASS is valid only for the source revision in its receipt; a change to source, lockfile, build profile or config makes it stale (§33.5). `project_state/CURRENT_STATE.json → verified_gates` lists only receipts, and `tools/validate_project_state.py` rejects anything else. Older prose evidence stays in `reports/`. Toolchain reports go to `reports/toolchain/`.
