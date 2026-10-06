# FORGE log

## FORGE 000 (retroactive, pre-initialization): TypeScript shared-core prototype (repo milestone R1)

Commits `368af38`, `247f971`, written by an earlier Claude session before the master initialization prompt existed. They produced `packages/domain` (73 golden vectors), `apps/site` (synthetic Build Lab, published privately as a Claude artifact), `services/api`, `apps/client` and `tools/verify_contracts.py`. Evidence is in `docs/RELEASE_STATUS.md`. Since ADR-IMPL-002 this work serves as the reference oracle and the Build Lab.

## PHASE 0: Initialization (2026-10-06): INITIALIZATION_COMPLETE

Inventoried sources (`project_state/SOURCES.md`), git, toolchain (`reports/toolchain/flutter_doctor_2026-10-06.txt`) and code. Decided ADR-IMPL-002 and D-003..D-006 (`DECISIONS.md`). Created CLAUDE.md, docs (overview, architecture, data model, security, test, release, platform matrix, roadmap, development plan) and the project_state files. Flutter 3.47.6 / Dart 3.13.5 installed at `/opt/toolchains/flutter`, with the SHA-256 checked against the release manifest.

---

# FORGE 001: Flutter repository bootstrap + responsive shell

## Goal
Turn the specification into a real Flutter repository and prove the v0.27 first-compiled-slice gate: the app starts, the responsive shell renders, destinations change, the non-production profile is visible, no network is needed, a widget test sees Today, and a widget test navigates to Labs. Then build and runtime-smoke at least one real target.

## Baseline state
No Flutter code. Flutter was not installed when the FORGE started. Phase 0 documents were uncommitted.

## Implemented
- `flutter create --empty --platforms=android,ios,web,windows,macos,linux --org org.humanhealthos human_health_os`. The tool-generated runners and SDK constraint (`^3.13.5`) were kept.
- `lib/src/config/app_config.dart`: `APP_ENV`, `APP_VERSION` and `SOURCE_REVISION` via `--dart-define`. Unknown values fall back to development, never to production.
- `lib/src/core/capabilities.dart`: runtime capability registry. Nothing is claimed as available. Health Connect is offered only on Android and HealthKit only on iOS. Web says "not on this platform". Network is "not required".
- `lib/src/navigation/`: 10 destinations (v0.27 doc 209). A rail at ≥ 840 dp (extended at ≥ 1200 dp) with a scroll-safe wrapper. Below that, a bottom bar with 4 primary destinations plus a "More" sheet for the rest.
- `lib/src/features/today`: build info, capabilities and an honest "nothing is stored yet". Other destinations get an honest planned state that names their FORGE and one invariant. No fake data and no dead buttons.
- EN/TR strings with `flutter_localizations` (an SDK package; no third-party dependency added).
- Theme with health-role colour tokens that mirror the Build Lab tokens.
- `tools/flutter_web_smoke.mjs`: Playwright runtime smoke over a local static server, with external-request detection.
- CI: Flutter jobs for Linux/web, Android, Windows and macOS/iOS on their own runners.

## Files changed
`human_health_os/**` (new), `tools/flutter_web_smoke.mjs`, `.github/workflows/ci.yml`, `package.json` + `pnpm-lock.yaml` (root dev dependency `@playwright/test@1.56.1`, already used by the Site), `reports/{runtime,artifacts,toolchain}/*`, plus the Phase 0 docs and state files.

## Data / migration changes
None (no persistence in this FORGE).

## Security / privacy impact
No storage and no network. An architecture test blocks network clients in `lib/` and secret-looking literals. `--dart-define` carries non-secret values only.

## Tests actually executed
| Command | Result | Status |
|---|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | 0 changes after the formatter pass | PASS |
| `flutter analyze` | No issues found | PASS |
| `flutter test` | 23/23 (widget 16, unit 4, architecture 3) | PASS |
| Mutation check: set `semanticContainer: true` and run the heading test | test FAILS as expected, passes again after revert | PASS (the test is meaningful) |
| `node tools/flutter_web_smoke.mjs` | 18/18 checks: desktop-en, phone-en, phone-tr; Today, banner, Labs, no external requests, no page errors | PASS |
| Linux bundle under Xvfb (`LANG=C.UTF-8`) | process alive after 12 s, renders Today (`reports/runtime/flutter-linux-today.png`) | PASS (start only) |

## Builds actually executed
| Platform | Command | Status |
|---|---|---|
| Web | `flutter build web --release --no-web-resources-cdn --dart-define=APP_ENV=development` | **PASS** (sha256 in `reports/artifacts/forge-001.json`) |
| Linux x64 | `flutter build linux --release` (after `apt-get install libgtk-3-dev`) | **PASS** |
| Android APK/AAB | — | BLOCKED_ENVIRONMENT (no SDK; Google Maven 403) |
| iOS | — | BLOCKED_BY_HOST_OS |
| macOS | — | BLOCKED_BY_HOST_OS |
| Windows portable / installer | — | BLOCKED_BY_HOST_OS |

## Bugs found
1. Non-exhaustive `switch` after adding `CapabilityStatus.notRequired` (compile error).
2. **Flutter web crashes at startup** when the browser reports the locale `en-US@posix` (`RangeError: Incorrect locale information provided`). This was caused by the container's POSIX locale. It is a Flutter engine/locale-parsing issue (RISKS R-11).
3. **Accessibility:** `Card` merged a section heading with its body text into one semantics node, so screen readers read the whole card as a heading.
4. The development banner was clipped on narrow Turkish phones (fixed 32 px height).
5. First attempt at the banner fix (`height: double.infinity`) produced invalid constraints.
6. The smoke selectors assumed one ARIA role. Flutter exposes rail items as `button` and bar items as `tab`.

## Fixes applied
2 → the smoke uses explicit BCP-47 locales (en-US, tr-TR), and the risk is recorded. 3 → `semanticContainer: false` plus a heading test, mutation-verified. 4/5 → a fixed 44 px `SizedBox` with two lines and ellipsis, plus a 320×640 Turkish test. 6 → the selectors handle both roles.

## Regression check
After every fix: `flutter analyze` (clean), `flutter test` (23/23), web rebuild plus smoke (18/18). The TS side was untouched in this FORGE apart from the root dev dependency (see the next-FORGE audit).

## Artifacts produced
- `human_health_os/build/web/` and `human_health_os/build/linux/x64/release/bundle/` (local only, gitignored). The hashes of deterministic tarballs are in `reports/artifacts/forge-001.json`.
- Screenshots: `reports/runtime/flutter-web-*.png`, `reports/runtime/flutter-linux-today.png`. Smoke JSON: `reports/runtime/flutter_web_smoke.json`.

## Known limitations
Capability descriptions are English-only (labels are EN/TR). There is no URL routing and no deep links. Linux runtime navigation was not automated. Nothing is persisted. Android, iOS, macOS and Windows are not built here. CI has not run because there is no GitHub access.

## State update
The FOUNDATION stage has started: F001 is **COMPILED + RUNTIME_TESTED** on web and Linux. Gaps G-01 and G-11 (partly) are closed.

## Next recommended FORGE
**FORGE 002, the local heartbeat.** Add a `HealthRepository` port, an in-memory adapter and a file-backed vault adapter. Create one profile and one canonical weight observation with provenance and `value_status`. Save, restart and read back the same record, and show missing ≠ 0 in the UI.
