# Test strategy

Every claim moves up the ladder only with evidence: **IMPLEMENTED → STATICALLY_TESTED → UNIT_TESTED → INTEGRATION_TESTED → COMPILED → RUNTIME_TESTED → PACKAGED → SIGNED → NOTARIZED → DEPLOYED**. A test that was written but not run is NOT_RUN. An analysis pass on Linux never counts as a PASS for a Windows or macOS build.

## Layers

| Layer | Flutter app (`app/`) | TypeScript reference + Build Lab (`packages/*`, `apps/site`, `services/api`) |
|---|---|---|
| Static | `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze` | `pnpm typecheck` |
| Unit (pure domain) | `flutter test test/domain` (no Flutter bindings needed) | `pnpm test` (vitest) |
| Cross-language contract | `flutter test test/contracts`: the Dart engines run `contracts/golden_vectors/*.json` | The same vectors in TS (`packages/domain/test`) and in Python (`tools/verify_contracts.py`) |
| Widget | `flutter test test/widget`: shell, navigation, empty/error/missing states | — |
| Integration | `integration_test/` (device or desktop), later | API + client repository tests |
| Build | `flutter build web --release`, plus `flutter build linux` when GTK is present (CI smoke), `apk`, `appbundle`, `ios`, `macos` and `windows` on their own hosts | `pnpm build` |
| Runtime smoke | Serve `build/web` and drive it with Playwright/Chromium (semantics enabled): the app starts, shows Today, and navigates to Labs | Playwright suites for the Site and the client |
| Packaging | Portable ZIP and installer smoke on a clean Windows VM. DMG mount/launch on macOS. | Artifact publish check |

## Golden vectors are the bridge

`contracts/golden_vectors/` is language-neutral and holds 73 vectors (core 19, lab 19, nutrition 5, preventive 20, med-safety 10). Every engine that exists in more than one language must pass the **same** files:

- TypeScript `@hhos/domain`: `pnpm --filter @hhos/domain test`
- Python independent port: `python3 tools/verify_contracts.py`
- Dart `app/lib/src/domain`: `flutter test test/contracts` (from FORGE 003)

A formula change is one PR that touches the vectors and every implementation together. Widening a tolerance without a recorded model/version decision is forbidden.

## Required negative and edge cases (each domain)

Missing input → explicit missing state, never 0. Invalid input → error code, no number. Unknown history ≠ never done. Plan or notification → never completion. Scenario edits never mutate the source. Unit mismatch → blocked, never converted silently. Every external/licensed model stays UNAVAILABLE with no fabricated output.

## Flutter specifics

- Domain code under `lib/src/domain` imports only `dart:core`, `dart:math` and `dart:convert`, so it can be unit-tested without Flutter. An architecture test greps for forbidden imports (`package:flutter`, `dart:io`, `dart:html`).
- Widget tests use `tester.view.physicalSize` to cover a 390×844 phone, an 820×1180 tablet and a 1440×900 desktop.
- Web runtime smoke builds with `--no-web-resources-cdn` (sandboxed hosts can block the CanvasKit CDN) and enables semantics, so Playwright can find text.

## Evidence

Each FORGE writes the exact commands and their PASS/FAIL into `project_state/FORGE_LOG.md`. Machine-readable outputs go to `reports/tests/`. Toolchain reports go to `reports/toolchain/`.
