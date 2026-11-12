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

---

# FORGE 002: Local heartbeat (profile + one canonical record, save → restart → read back)

## Goal
First real health data path in the Flutter product: one self profile, one canonical body-weight observation with provenance and `value_status`, saved, re-read after restart, and shown with missing ≠ 0. Mid-FORGE the user supplied v0.28 (Linux distribution layer) and said to develop that way, so the v0.28 storage rules were applied here.

## Baseline state
F001 (6abf755): shell only, nothing persisted. Web and Linux RUNTIME_TESTED (launch). No domain layer.

## Implemented
- **Domain (pure Dart):** `HealthRecord` envelope (`RecordState`, `ValueStatus`, `Provenance`, `Quantity`, original text, UTC observed/recorded times, `supersedesId`, `deletedAt`, `schemaVersion`), `validate()` with stable codes (MISSING_ID, PRESENT_REQUIRES_QUANTITY, MISSING_HAS_NO_QUANTITY, NON_UTC_TIME, SELF_SUPERSEDE, UNIT_NOT_SUPPORTED, OUT_OF_PLAUSIBLE_RANGE), `currentRecords()` (supersede chains + tombstones), `Profile`, `HealthRepository` port, `StorageDescription`.
- **Vault log:** append-only JSON lines (header + operations). An interrupted last line is skipped **with a visible warning**; a bad middle line is skipped with a warning; identical duplicates replay idempotently; conflicting duplicates and newer formats are refused.
- **Adapters:** one `LogRepository` over three sinks: memory, file (`dart:io`, temp-file + rename on create, append + flush), browser `localStorage` (`dart:js_interop`, SDK only). Conditional export picks the platform.
- **Storage policy (v0.28 / D-009):** production → memory only. Portable mode (`portable_mode.json` beside the executable) → memory only, **nothing written beside the app** until the encrypted vault (F004). Development desktop → XDG data dir / Application Support / LOCALAPPDATA. Android/iOS → memory with a notice. Every mode is labelled in the UI ("not encrypted (development)", "Not saved: kept only until the app closes", browser "may be cleared").
- **Application + UI:** `HeartbeatService` (accepts "78,4"; blank, non-numeric, out-of-range and future times are errors, never 0), `WeightCard` (empty state, save, latest, history with "entered as" when the text differs), `bootstrap()` with a memory fallback if the vault cannot be opened.
- **Audit fixes (honesty lens on F001; the code and completeness lenses did not finish and were not rerun):** Today intro rewritten from present-tense claims to "is being built…"; health-platform text no longer claims file import; Today now names its planned FORGE (020) for check-ins and missions; "This build" shows the source revision; the staging banner carries "not for clinical decisions"; the domain purity guard now checks import/export/part in both quote styles, fails if `lib/src/domain` disappears and has negative fixtures; README, ARCHITECTURE, CLAUDE.md (smoke path, full evidence ladder, digest precedence), PLATFORM_MATRIX, KNOWN_GAPS (status column) and D-007 (real transitive package list) corrected; the `docs/forge/CURRENT.md` link restored as a redirect stub; the smoke JSON now records time, git HEAD, `main.dart.js` hash, browser and runs; the Linux run log records liveness and labels headless GTK noise.

## Files changed
`human_health_os/lib/src/{domain,data,application}/**` (new), `lib/src/app/{app_services,bootstrap}.dart` (new), `lib/src/core/ids.dart` (new), `lib/src/features/today/*`, `lib/src/l10n/strings.dart`, `lib/src/core/capabilities.dart`, `lib/src/config/app_config.dart`, `lib/src/navigation/destinations.dart`, `lib/main.dart`; tests in `test/{domain,data,widget,architecture}`, `integration_test/heartbeat_test.dart`; `pubspec.yaml` (+ `integration_test` SDK dev dependency); `tools/flutter_web_smoke.mjs`; docs and `project_state/*`; `docs/handoff/v0.28-candidate/*`.

## Data / migration changes
New on-disk format `hhos-vault-log` v1 (`vault.hhoslog.jsonl`, header `encryption: none-dev-only`). Record schema v1. Readers refuse newer versions. F004 replaces the payload with an encrypted envelope; a migration from v1 dev logs is optional (dev data only).

## Security / privacy impact
Development builds now write **unencrypted** health data to the user data directory (labelled in the UI). Production and portable builds cannot write health data at all. No network code (architecture test). No secrets in the repo (scan of staged files: none). Real health data: none committed; tests use synthetic values in temp directories.

## Tests actually executed
| Command | Result | Status |
|---|---|---|
| `dart format --output=none --set-exit-if-changed lib test integration_test` | 0 changed | PASS |
| `flutter analyze` | no issues | PASS |
| `flutter test` | 58/58 (domain, data contract on memory + file, storage policy, architecture, widget incl. TR 320×640, staging, revision) | PASS |
| Mutation: double-quoted Flutter `export` in `domain/profile/profile.dart` | architecture test FAILS, passes after revert | PASS (guard is meaningful) |
| `xvfb-run flutter test integration_test -d linux` on 3243163 | save "77,9" → relaunch → same record → data folder moved → same record | PASS |
| `node tools/flutter_web_smoke.mjs` on the 3243163 web build | 26/26 (desktop-en, phone-en, phone-tr; save → reload → persisted; honesty label; 0 external requests; 0 page errors) | PASS |
| Linux release bundle under Xvfb (X11), `LANG=C.UTF-8`, scratch `XDG_DATA_HOME` | alive after 12 s (`kill -0`), screenshot shows Today + revision `3243163d0808`; vault = header + self profile, 0 records | PASS (launch only) |
| TS reference / Build Lab (`pnpm test`, `verify_contracts.py`) | not rerun: no TS change in this FORGE | NOT_RUN |

## Builds actually executed
| Platform | Command | Status |
|---|---|---|
| Web | `flutter build web --release --no-web-resources-cdn --dart-define=APP_ENV=development --dart-define=SOURCE_REVISION=3243163…` | **PASS** (`reports/artifacts/forge-002.json`) |
| Linux x64 | `flutter build linux --release …SOURCE_REVISION=3243163…` | **PASS**; glibc floor GLIBC_2.34; 0 unresolved `ldd` entries on Ubuntu 24.04 |
| Linux packages (Flatpak, AppImage, tar.zst, deb, rpm) | — | NOT_RUN (next FORGE) |
| Android APK/AAB | — | BLOCKED_ENVIRONMENT |
| iOS / macOS | — | BLOCKED_BY_HOST_OS |
| Windows portable / installer | — | BLOCKED_BY_HOST_OS |

## Bugs found
1. **v0.28 rule violation:** portable mode would have written a plaintext vault into `UserData/` beside the executable.
2. Real file IO inside `testWidgets` (fake-async zone) never completed, so a widget test hung.
3. Lint failures: private type in a public API (browser sink), getter/setter pair, initializing formals.
4. Audit (honesty lens): present-tense capability claims on Today and in the capability registry; wrong smoke path in CLAUDE.md/ARCHITECTURE; vacuous domain purity test; stale README/PLATFORM_MATRIX/KNOWN_GAPS; broken CURRENT.md link; SBOM wording; staging banner without the clinical disclaimer.

## Fixes applied
1 → portable mode is memory-only with a notice until F004, with a test proving nothing is written beside the executable. 2 → widget tests use a shared `MemoryLogSink`; real IO is proven in `test/data` and the Linux `integration_test`. 3 → `_BrowserLogSink`, public field, public `clock`. 4 → see "Audit fixes" above.

## Regression check
After the last change: format, analyze, 58/58 tests, mutation check, clean web + Linux release rebuilds from the commit, web smoke 26/26, Linux integration test, Linux launch. The F001 checks are a subset of the current smoke and widget suites and all pass.

## Artifacts produced
- Deterministic tarballs of `build/web` and the Linux release bundle (session scratchpad; hashes, commands, glibc floor and lockfile digests in `reports/artifacts/forge-002.json`). Not committed; not packages.
- `reports/runtime/flutter-web-*-{today,labs,weight}.png`, `flutter_web_smoke.json`, `flutter-linux-today.png`, `flutter-linux-run.log`.

## Known limitations
Storage is unencrypted (development only); production/portable cannot persist yet. Only body weight in kg. No corrections UI (the domain supports supersede). Android/iOS have no storage path adapter. Capability details and storage notices are English-only. Linux tested only on Ubuntu 24.04 under Xvfb X11. CI never ran (no GitHub access). Two of three audit lenses (code, completeness) did not complete.

## State update
F002 **RUNTIME_TESTED** on web and Linux (Ubuntu 24.04, X11). G-02 PARTIAL (encryption pending), G-01 CLOSED, G-11 PARTIAL, new G-12…G-14.

## Next recommended FORGE
**FORGE F030L-1: Linux distribution, first real packages** (roadmap item F030L, pulled forward; FORGE numbers follow roadmap ids, so F003 stays the Dart engines) per `docs/handoff/v0.28-candidate/BUILD_LINUX_DESKTOP_DISTRIBUTION_v0.28.txt`, because the user asked to develop along v0.28 and the release bundle is now real. Scope: install only real tools (zstd, rpm, desktop-file-utils, appstream, lintian); produce `HumanHealthOS-Linux-x86_64-Portable.tar.zst`, `.deb` and `.rpm` with desktop entry, AppStream metainfo and icon; validate each with its own tool; install/launch smoke in real Fedora, Debian and Ubuntu containers only if container images can actually be pulled; record path, arch, SHA-256, format, source revision, toolchain, lock digest, SBOM and signing state per artifact. Flatpak and AppImage only if their builders can be installed; Nobara, Wayland and every distro not actually run stay NOT_RUN. Portable mode stays memory-only (F004). Then F004 (encrypted vault, which unblocks portable persistence) and F003 (Dart engines against the golden vectors).

---

# FORGE F030L-1 → F015-L1: Linux distribution, first real packages — INTERRUPTED (IN_PROGRESS_RECOVERABLE)

Interrupted by the user's v0.31 one-shot directive before its report was finished. Evidence and the exact resume point are in `reports/artifacts/forge-f030l-1.json` and `reports/linux/` (commits e4c64e3, 66572f9, 9ac285b, d1df671). Summary: tar.zst, deb, rpm and AppImage were built for real from a staging release bundle (UNSIGNED, hashed). On Ubuntu 24.04 the deb installs, launches and uninstalls cleanly (user data kept), the tarball and the AppImage (FUSE and extract-and-run) launch, and the app renders on Weston (Wayland). Two real defects surfaced on an Ubuntu 22.04 userland: (1) a GLib 2.80 symbol leaked into the runner → **fixed** (GLib API cap, symbol gate); (2) the engine `dlopen`s `libGLESv2.so.2`, which no package declares → **open**. Fedora 44: static rpm checks only. Debian, Nobara, GNOME/KDE Wayland, Flatpak: NOT_RUN (BLOCKED_ENVIRONMENT). Not a PASS for any distro other than Ubuntu 24.04.

---

# PHASE 0 (v0.31 reconciliation), 2026-10-06 — INITIALIZATION_COMPLETE

Router (v0.31 §42): canonical state existed → an unfinished Forge existed (F030L-1) → it was checkpointed as `IN_PROGRESS_RECOVERABLE`, not resumed, because the user's current command scopes this run to Phase 0 + F001.

- **Inventory:** branch `claude/code-capabilities-kz21fr`, clean tree at d1df671; real Flutter project `human_health_os/` with android, ios, web, windows, macos and linux folders; toolchain and egress report in `reports/toolchain/environment_v031_2026-10-06.txt` (Flutter 3.47.6 / Dart 3.13.5, Linux desktop and web available; Android SDK absent and `dl.google.com` denied; Apple and Windows hosts absent).
- **Sources:** v0.31 master stored in `docs/handoff/v0.31/` (SHA `7f999e0f…864c`) and classified CANDIDATE / process authority (D-011). v0.26 baseline still absent → release state CANDIDATE_UNMERGED. Seven conflicts with repository reality recorded in `SOURCES.md` (C-1…C-7), none resolved silently.
- **State machine:** `CURRENT_STATE.json` migrated to schema 2 (development_state, active_forge, suspended_forges, verified_gates, known_blockers, baseline with spec hash).
- **Roadmap:** v0.31 ladder F001–F017 is canonical; legacy ids mapped.
- **Control files:** CLAUDE.md (source authority, full v0.31 invariant list, resume rules, receipts), TEST_STRATEGY (receipts), PLATFORM_MATRIX (v0.31 parity matrix with implementation reality), RISKS R-14…R-17, KNOWN_GAPS G-15…G-17, DECISIONS D-010…D-012.
- **Self-audit:** new `tools/validate_project_state.py`. First run FAILED on a real inconsistency (state cited a not-yet-existing file in a non-planned field) → validator taught to skip planned-work fields → PASS. Negative fixture (fake PASS receipt, gate without receipt, iOS "COMPILED") → all three rejected.
- **F001 acceptance criteria** (objective, receipt-backed): AC-1…AC-9 in `CURRENT_STATE.json → active_forge.acceptance_criteria`.

Hard blocker for F001: none. Continuing into F001 in the same run, per the v0.31 one-shot contract.

---

# FORGE F001 (v0.31 ladder): Repository heartbeat — F001_COMPLETE

## Goal
Prove the v0.31 F001 exit gate on the real repository: responsive shell, Today → Timeline → Labs, a visible build-profile indicator and build identity, analyzer/test PASS, one host-supported build plus runtime receipt, no new persistence. Repository reality (v0.31 §31.3, §44): the Flutter repo, shell and a pre-v0.31 persistence heartbeat already existed, so F001 repaired and re-proved instead of recreating.

## Baseline State
d1df671 / Phase 0 at 0ce5262. 59 widget/unit tests, web and Linux runtime-tested under legacy ids; no receipt system; no Timeline navigation test; build identity without Flutter/Dart/schema; shell texts citing legacy Forge ids.

## Implemented
- `tools/evidence/run_gate.py`: runs a gate and writes an immutable JSON receipt (real timestamps, exit code → PASS/FAIL, revision, source-dirty flag, Flutter/Dart/node/python versions, lockfile SHA-256, log SHA-256 + tail, artifact digests; directory digests ignore timestamps; a declared but missing artifact fails the gate). 6 unit tests.
- `tools/evidence/check_f001_scope.py` (AC-1, AC-8) and `tools/validate_project_state.py` (Phase 0).
- App: "This build" shows Flutter, Dart (from the framework's `FlutterVersion`) and record schema; absent values read `unknown`.
- Shell empty states and capability texts cite v0.31 ladder ids (Timeline → F003, Labs → F004, vault → F006 …).
- Tests: Today → Timeline → Labs on phone (bottom bar) and desktop (rail); identity given vs not given (mutation-checked: removing the Flutter row fails both).
- Web smoke: Timeline step, identity row, `EXPECT_FLUTTER_VERSION`; CI computes the expected version.

## Files Changed
tools/evidence/{run_gate.py,test_run_gate.py,check_f001_scope.py}, tools/validate_project_state.py, tools/flutter_web_smoke.mjs, human_health_os/lib/src/{config/app_config.dart, features/today/today_screen.dart, l10n/strings.dart, navigation/destinations.dart, core/capabilities.dart, data/local/storage_io.dart + storage_web.dart (notice text only)}, human_health_os/test/widget/shell_test.dart, .github/workflows/ci.yml, CLAUDE.md, .gitignore, docs/ROADMAP.md, project_state/*, evidence/**.

## Data / Migration Changes
None. AC-8 receipt EV-TEST-F001-0015: domain, data tests, integration test and lockfile unchanged since d1df671; lib/src/data diff = 6 notice-text lines.

## Security / Privacy Impact
No new storage, network or dependency. Receipts contain commands, versions and log tails only; secret scan of all receipts clean; raw logs are gitignored (`evidence/logs/`). Build identity is non-secret by design.

## Tests Actually Executed
| Command | Receipt | Result |
|---|---|---|
| `flutter pub get --enforce-lockfile` | EV-TEST-F001-0006 | PASS |
| `dart format --output=none --set-exit-if-changed .` | EV-TEST-F001-0007 | PASS (33 files, 0 changed) |
| `flutter analyze` | EV-TEST-F001-0008 | PASS (no issues) |
| `flutter test` | EV-TEST-F001-0009 | PASS (63) |
| `python3 -m unittest tools/evidence/test_run_gate.py` | EV-TEST-F001-0010 | PASS (6) |
| `xvfb-run flutter test integration_test -d linux` (regression) | EV-TEST-F001-0011 | PASS |
| `python3 tools/verify_contracts.py` (regression) | EV-TEST-F001-0012 | PASS |
| `pnpm test` (regression: 73 + 14 + 4 + 13 + 5) | EV-TEST-F001-0014 | PASS |
| `python3 tools/evidence/check_f001_scope.py d1df671` | EV-TEST-F001-0015 | PASS |
| `python3 tools/validate_project_state.py` | EV-TEST-F001-0016 | PASS (on 6f1f619) |
| Earlier receipts 0001–0005 (dbe9b54) | — | PASS but stale after the repair; 0013 (`pnpm -s test`) exit 0 with an empty log, not counted |

## Builds Actually Executed
| Platform | Command | Result |
|---|---|---|
| Web | `flutter build web --release --no-web-resources-cdn --dart-define=APP_ENV=development --dart-define=APP_VERSION=0.1.0+1 --dart-define=SOURCE_REVISION=9e86ed0…` | **PASS** EV-BUILD-F001-0002: build/web tree sha256 `473f7258…7922` (39 files, 42 309 907 B), main.dart.js `e4db1bc0…2748` |
| Web (first attempt, dbe9b54) | same + `--dart-define=FLUTTER_VERSION=…` | **FAIL** EV-BUILD-F001-0001 (reserved define) |
| Linux x64 (regression) | `flutter build linux --release --dart-define=APP_ENV=development …` | **PASS** EV-BUILD-F001-0003: bundle tree `87ea1c11…3f44`, libapp.so `6be6bf48…ac05` |
| Android | — | BLOCKED_ENVIRONMENT (no SDK; dl.google.com denied) |
| iOS / macOS | — | BLOCKED_BY_HOST_OS |
| Windows | — | BLOCKED_BY_HOST_OS |

Runtime: web smoke **36/36 PASS** (EV-RUNTIME-F001-0001: desktop-en, phone-en, phone-tr; Today → Timeline → Labs; banner; "Flutter 3.47.6" shown; weight save → reload; 0 external requests; 0 page errors). Linux launch **PASS** (EV-RUNTIME-F001-0002: alive at 12 s under Xvfb X11; dev build wrote only the vault header + self profile; screenshot `reports/runtime/flutter-linux-f001-today.png`).

## Bugs Found
1. Web build failed: `FLUTTER_VERSION is used by the framework and cannot be set using --dart-define`.
2. `run_gate.py` crashed while printing when the evidence root was outside the repository (exit code then wrong) — caught by its own unit test.
3. Phase 0 validator flagged the state for citing a not-yet-existing file in a planned-work field.
4. Shell and capability texts showed legacy Forge ids that no longer match the canonical ladder.
5. `pnpm -s test` produced no output, so its PASS receipt was empty evidence.

## Fixes Applied
1 → read versions from `FlutterVersion` (framework-injected), drop the reserved defines in CI/CLAUDE.md. 2 → print relative path only when inside the repo. 3 → planned-work fields exempt from the path check. 4 → v0.31 ids. 5 → rerun without `-s`; the empty receipt is listed as uninformative.

## Regression Check
All F001 gates rerun on 9e86ed0 after the repair (0006–0012, 0014, builds 0002–0003, runtime 0001–0002). Persistence (Linux integration test), Linux build/launch and the TS/Python reference suites still pass.

## Artifacts Produced
Not committed (build outputs are gitignored); identified by their receipts: `human_health_os/build/web/` and `human_health_os/build/linux/x64/release/bundle/`. Committed: receipts in `evidence/`, screenshots `reports/runtime/flutter-web-*-{today,timeline,labs,weight}.png`, `reports/runtime/flutter-linux-f001-today.png`, smoke JSON `reports/runtime/flutter_web_smoke.json`. SBOM: NOT_GENERATED. Signing: n/a (web) / UNSIGNED (Linux bundle).

## Known Limitations
- Receipts store absolute artifact paths of this container.
- Web smoke runs headless Chromium only; PWA install NOT_TESTED. Linux launch is X11/Xvfb only for F001.
- Android, iOS, macOS, Windows not built here. CI never ran (GitHub push 403).
- Release state CANDIDATE_UNMERGED (v0.26 baseline missing). F015-L1 (Linux packages) stays suspended with an open libGLESv2 defect.
- The repository already contains a pre-v0.31 persistence slice; its v0.31 F002 exit gate is unverified.

## State Update
`development_state` READY; `active_forge` null; F001 DONE with 13 verified gates; F015-L1 suspended (IN_PROGRESS_RECOVERABLE); web RUNTIME_TESTED with receipts.

## Next Recommended Forge
**F002 — Local profile + persistence heartbeat (v0.31 exit-gate closure):** migration version and a migration receipt for vault log v1, the `human-health-os/` XDG subdirectory (conflict C-4) with a tested move of development data, persistence integration receipts on web and Linux, and a no-plaintext-secret review. No new record types. (Not started; requires an explicit `FORGE`.)

---

# PHASE 0 (v0.32 reconciliation), 2026-10-06 — INITIALIZATION_COMPLETE

Trigger: the user attached the v0.32 master (`9a8c50ef…c47d`) and ordered its one-shot run (Phase 0 → F001 → stop, no F002). Kernel bootstrap rule 1 applies: an existing Flutter repository is repaired and used in place.

- **Inventory:** branch `claude/code-capabilities-kz21fr`, clean at 254c534; `F001@v0.31` complete with 14 receipts; F015-L1 suspended. Toolchain: Flutter 3.47.6 / Dart 3.13.5; web (Chromium 141) and Linux desktop available; Android SDK absent; Windows/Apple hosts absent (`reports/toolchain/environment_v032_2026-10-06.txt`).
- **Spec reading:** v0.32 diffed against v0.31: new EXECUTION KERNEL (lines 1–381) plus five sentences in §42–§44; everything else byte-identical. Stored in `docs/handoff/v0.32/` with SHA256SUMS.
- **Reconciliation:** read-only multi-agent gap analysis (lenses: F001 contract, state/evidence, semantics/privacy, gates/commands; one adversarial skeptic per lens) → 40 confirmed (5 major, 35 minor, 0 blocker) and 6 refuted findings, kept in `reports/audit/v032_phase0_gap_analysis.json`. Majors: Timeline falsely says "No records yet" after a weight is saved; smoke ignores console errors; state cursor and authority pointers still on v0.31.
- **Control files:** SOURCES (v0.32 row, lineage, conflicts C-8 primary destinations and C-9 literal commands), D-013, CURRENT_STATE schema 3 (cursor F001@v0.32 with AC-1…AC-14, history keyed by contract, verified gates reset for v0.32 receipts), CLAUDE.md (authority, kernel, commands incl. `flutter doctor -v` and the exact v0.32 format gate, F006, report contract), ROADMAP, KNOWN_GAPS (canonical ids, G-18…G-21), RISKS, ARCHITECTURE, PLATFORM_MATRIX, DEVELOPMENT_PLAN, TEST_STRATEGY, README.
- **Self-audit:** `tools/validate_project_state.py` (see the commit's run); stale `F004` references removed from state and control files.

Hard blocker for F001: none. Continuing into F001@v0.32 in the same run.

---

# HUMAN OS FORGE F001@v0.32 — repository heartbeat (v0.32 contract), 2026-10-06 → 2026-10-07 — F001_COMPLETE

## Repository / Workspace State
Branch `claude/code-capabilities-kz21fr`; baseline 254c534 (clean). Implementation 3648371, audit repairs c803756; all closing gates ran on a clean tree at c803756. Pushed to origin (B-1 resolved).

## Toolchain Detected
Flutter 3.47.6 / Dart 3.13.5, Chromium 141 (Playwright), Node 22.22.0, pnpm 10.28.0, Python 3.13, Ubuntu 24.04 x86_64 with GTK3 + Xvfb. Android SDK absent (BLOCKED_ENVIRONMENT); Windows/Apple hosts absent (BLOCKED_BY_HOST_OS). `flutter doctor -v` is an informational gate (EV-TEST-F001-1001) and is not counted as a verified gate.

## Implemented
- Primary navigation exactly Today, Timeline, Labs; the seven placeholders form a secondary "Planned" group in the rail and in the More sheet (C-8), 48 dp targets, the open screen marked.
- Honest Timeline empty state (it pointed at a "No records yet" screen while records existed).
- Banner: disclaimer first, full profile line, never ellipsized; build identity from `FlutterVersion`; fail-closed `APP_ENV`; `APP_VERSION` default `unknown`.
- Storage capability "Saving off" (cause-neutral) for memory-only web/desktop; `SAVE_FAILED` message on unexpected storage errors; startup error screen; `<noscript>` notice; web title/manifest "Human OS".
- Evidence tooling: receipt schema 2 (covers, §33.2 build identity, both lockfiles, argv + shell-quoted command, covers checked before the run); validator: stale covers incl. untracked files, dirty receipts, build identity.
- Tests: `test/widget/f001_contract_test.dart` (v0.32 checks 1–8 incl. behavioral offline bootstrap, UX-2/4/5/6/7/8), network-guard self-test.

## Tests Actually Executed (receipts on c803756)
| Gate | Receipt | Result |
|---|---|---|
| `flutter pub get` | EV-TEST-F001-1011 | PASS |
| `dart format --set-exit-if-changed .` (0 changed) | EV-TEST-F001-1012 | PASS |
| `flutter analyze` | EV-TEST-F001-1013 | PASS (no issues) |
| `flutter test` (81) | EV-TEST-F001-1014 | PASS |
| evidence tooling unit tests (16) | EV-TEST-F001-1015 | PASS |
| `flutter test integration_test -d linux` (Xvfb) | EV-TEST-F001-1016 | PASS |
| `python3 tools/verify_contracts.py` | EV-TEST-F001-1017 | PASS |
| `pnpm test` | EV-TEST-F001-1018 | PASS |
| `check_f001_scope.py 254c534` | EV-TEST-F001-1019 | PASS |
| Earlier 1001–1010 (3648371) | — | PASS, now stale (audit repairs changed covered paths) |

## Build Commands Actually Executed
| Platform | Receipt | Result |
|---|---|---|
| Web, `flutter build web` exactly as the kernel writes it | EV-BUILD-F001-1001 (3648371) | COMPILED; references the gstatic CDN (C-9), not used for runtime |
| Web, offline `--no-web-resources-cdn`, development | EV-BUILD-F001-1011 | COMPILED: tree `93beb517…3c6a` (39 files), main.dart.js `f7f23052…de5b` |
| Linux x64 release, development | EV-BUILD-F001-1012 | COMPILED: bundle `6c8e184e…8edd`, libapp.so `724a0782…5cf2`, UNSIGNED |
| Android / iOS / macOS / Windows | — | BLOCKED_ENVIRONMENT / BLOCKED_BY_HOST_OS |

## Runtime Verification
- Web: EV-RUNTIME-F001-1011, 42/42 checks (desktop-en, phone-en, phone-tr; Today → Timeline → Labs; banner; identity; weight save → reload; 0 console errors, 0 failed requests, 0 external requests). RUNTIME_TESTED.
- Linux: EV-RUNTIME-F001-1012, alive at 12 s under Xvfb X11, screenshot `reports/runtime/linux-f001v032/f001v032-linux-x11.png`, log echoed into the receipt; the development build wrote only its XDG vault. RUNTIME_TESTED.

## Failures Found
1. Planned rail group overflowed by 112 px at 1024×700 (IntrinsicHeight wrapper).
2. Final audit: Linux launch receipt had an empty log (EH-1); banner ellipsized the profile name (UX-1); 55 px overflow in Today key/value rows at 320 dp and 2× text; unexpected save errors left no message; bootstrap failure had no screen; covers checked after the run; untracked files did not make evidence stale.

## Repairs Applied
1 → `NavigationRail(scrollable: true)`. 2 → each fixed in c803756 (see Implemented); every fix has a test.

## Regression Results
Mutations M1 (Medications primary), M2 (HttpClient in bootstrap), M3 (Timeline empty text removed), M4 (old banner order) each failed the intended test and were reverted. All 13 gates re-run after the repairs: PASS.

## Security / Privacy Audit
No secrets, keys or real health data in the diff. The network guard covers `package:http|dio|web|web_socket_channel`, `HttpClient`, `WebSocket`, `Socket.connect`, XHR, `EventSource`, JS `fetch`, `Image.network`. Fail-closed `APP_ENV` only removes configurations that persisted (D-013 note). Staging, production and portable stay memory-only.

## Evidence State
Shell RUNTIME_TESTED on web and Linux; persistence unchanged (development only, unencrypted). `verified_gates` = the 13 receipts above.

## Known Limitations
G-22…G-25 (domain comment, storage reason codes, web loading indicator, two-line planned labels); PWA install NOT_TESTED; Linux X11 only; CI never ran on GitHub; release state CANDIDATE_UNMERGED.

## Canonical State Update
`development_state` READY; `active_forge` null; `forge_history["F001@v0.32"]` DONE; `next_recommended_forge` F002@v0.32.

## Artifacts Produced
Receipts `evidence/*/EV-*-F001-1011…1019.json`; `reports/runtime/flutter_web_smoke_c8037566dd0b.json`; screenshots `reports/runtime/flutter-web-*.png`, `reports/runtime/linux-f001v032/`. Build outputs are gitignored and identified by receipt hashes.

## Next Recommended Forge
**F002@v0.32 — local profile + persistence heartbeat:** migration version and graph (G-15), replay validation and honest weight display (G-18), data-directory rules and the `human-health-os/` XDG move (G-19, C-4), storage reason codes (G-23, G-14 for storage text), domain comment (G-22), no-plaintext-secret test.

## Final Status
F001_COMPLETE.

---

# FORGE F002@v0.32 — local profile + persistence heartbeat (exit gate), 2026-10-07 — F002_COMPLETE

**Forge ID** F002@v0.32 · **Goal** close the master §39 F002 exit gate (persistence integration test, migration version initialized, no plaintext-secret shortcut) on the existing persistence slice, with gaps G-15, G-18, G-19, G-22, G-23 and conflict C-4. **Baseline** 2105a9e → implementation e16c73b (clean tree for all gates). Batch context: D-014 (MVP = F002–F006).

## Acceptance Criteria → evidence
| AC | What | Evidence |
|---|---|---|
| AC-1 | Format 1 written/read, no downgrade; newer vault/record/profile refused with a code; file untouched | `vault_compat_test` (EV-TEST-F002-0004) |
| AC-2 | Migration graph (+1, lossless, ordered ids); in-memory migration → read-only + §33.3 receipt; file unchanged | `vault_compat_test` |
| AC-3 | Synthetic v1 fixture = writer bytes; ids, provenance, correction link, notMeasured, UTC, order kept | `test/fixtures/vault/`, `vault_compat_test` |
| AC-4 | Replay validation: skipped entries named by line + rule; unreadable vs cut-off told apart | `vault_compat_test` |
| AC-5 | Weight card: Latest = newest real value; record's own state/source/unit; missing value named | `f002_persistence_test`; Linux screenshot |
| AC-6 | XDG_DATA_HOME empty/relative ignored; relative HHOS_DATA_DIR refused, nothing written | `repository_contract_test`, `storage_policy_test` |
| AC-7 | `HumanHealthOS/` → `human-health-os/` rename; both present → old untouched; failed move → old used; staging/production never touch | `storage_policy_test`, EV-TEST-F002-0006, **EV-RUNTIME-F002-0002** |
| AC-8 | StorageReason codes, one profile gate, capability from reason, EN/TR texts | `f002_persistence_test`, `f001_contract_test` |
| AC-9 | No secret-like vault field; `encryption: none-dev-only`; only APP_ENV/APP_VERSION/SOURCE_REVISION defines | `no_plaintext_secret_test` |
| AC-10 | Linux integration (real IO): save/relaunch; legacy move via the real adapter; header format 1 | EV-TEST-F002-0006 |
| AC-11 | F001 regression gates | EV-TEST-F002-0001…0003, 0005, 0007, 0008; EV-BUILD-F002-0001/0002; EV-RUNTIME-F002-0001 |
| AC-12 | Mutations M1–M6 caught | this entry (below) |

## Tests / Builds / Runtime
- `flutter test` 111 PASS (EV-TEST-F002-0004); integration 2 PASS (EV-TEST-F002-0006); tooling 16 PASS; contracts and `pnpm test` PASS.
- Web build COMPILED (EV-BUILD-F002-0001: tree `49fe1cdd…b51f`, main.dart.js `b1d4f22b…4298`); web smoke 42/42 RUNTIME_TESTED (EV-RUNTIME-F002-0001).
- Linux release COMPILED (EV-BUILD-F002-0002: bundle `98b613df…5645`, libapp.so `1ea5558e…ad26`, UNSIGNED). Launch RUNTIME_TESTED (EV-RUNTIME-F002-0002): a pre-F002 vault (the v1 fixture) placed in `~/.local/share/HumanHealthOS/` was moved by the real binary to `human-health-os/` with identical bytes; the screen shows the move note, Latest 74.8 kg (the correction), "Not measured" named, "Reported · Device" (`reports/runtime/linux-f002/f002-linux-x11.png`).

## Failures found and repairs
1. Expected breaks: F001 staging notice text and the record-schema error type changed → tests updated to the new contract.
2. First G-18 widget assertion looked for a descendant of the `weight-latest` Text itself (finder excluded the root) → assert on the widget's data.

## Mutations (each applied, intended test failed, reverted)
M1 replay without `validate()` · M2 old folder name `HumanHealthOS` · M3 Latest = first record · M4 missing version read as 1 · M5 migrated vault writable · M6 relative `HHOS_DATA_DIR` accepted → all CAUGHT.

## Security / privacy
No secrets, keys or real health data added. The development vault stays unencrypted and says so; staging, production and portable remain memory-only. The folder move is a same-parent rename in development builds only; nothing is deleted or merged.

## Known limitations
- No production migration exists yet; on-disk upgrade of an older vault waits for F005 checkpoints (D-014).
- Capability details remain EN-only (G-14 PARTIAL).
- macOS/Windows folder rules are unit-tested only (not compiled here).

## State update
`development_state` READY; `active_forge` null; `forge_history["F002@v0.32"]` DONE; verified gates = the 12 F002 receipts; G-15, G-18, G-19, G-22, G-23 CLOSED; G-14 PARTIAL; C-4 applied.

## Next recommended Forge
**F003@v0.32 — timeline + correction lineage** (MVP batch, D-014).

---

# FORGE F003@v0.32 — timeline + correction lineage, 2026-10-07 — F003_COMPLETE

**Goal** timeline projection; edits create lineage, never destructive rewrites; delete differs from correction and from entered-in-error (master §39). **Baseline** 0157f96 → implementation 8d64c5e (clean tree for all gates). MVP batch D-014, Forge 2 of 5.

## Semantics implemented
| Action | Record written | Effect |
|---|---|---|
| Correct | new version, `amend_reason: correction`, same observation time | newest version counts; older versions stay in history |
| Entered in error | marker (`notApplicable`, no value) | target voided; a mistaken correction lets the previous version count again; target stays in history as withdrawn |
| Delete | marker with `deleted_at` (tombstone) | every version leaves current views; history view keeps it; a later (stale) correction cannot resurrect it |
| Two live corrections of one version (sync/import) | — | conflict: both shown, Today shows "Versions disagree", never resolved by timestamp (v0.24 FR-166) |

Record schema 2 adds `amend_reason`; schema 1 records keep their exact JSON and a bare `supersedes_id` still means correction. An F002 build refuses a vault with schema 2 records (`RECORD_SCHEMA_NEWER`).

## Acceptance → evidence
AC-1 ordering, AC-2 correction history, AC-3 entered in error, AC-4 delete/no resurrection, AC-5 conflict, AC-6 schema rules: `test/domain/timeline_test.dart` (13), `test/data/lineage_store_test.dart` · AC-7 store integrity and AC-8 use cases: `lineage_store_test` · AC-9 UI: `test/widget/f003_timeline_test.dart` (6, EN/TR, 320 dp at 2×) · AC-10 fixture `v1_f003_schema2`: `vault_compat_test` · AC-11 EV-TEST-F003-0006 (Linux integration), EV-RUNTIME-F003-0001 (smoke: saved weight on the Timeline) · AC-12 regression receipts + mutations.

## Tests / Builds / Runtime (receipts on 8d64c5e)
- `flutter test` 138 PASS (EV-TEST-F003-0004); integration 3 PASS (EV-TEST-F003-0006); tooling 16, contracts, `pnpm test` PASS; format/analyze clean.
- Web COMPILED (EV-BUILD-F003-0001); smoke 46/46 RUNTIME_TESTED (EV-RUNTIME-F003-0001).
- Linux COMPILED (EV-BUILD-F003-0002, UNSIGNED); launch RUNTIME_TESTED on the schema-2 fixture vault (EV-RUNTIME-F003-0002): Today shows 80 kg (the 8 kg correction withdrawn), the deleted 79 kg is absent, the schema 1 record 81.5 kg is listed (`reports/runtime/linux-f003/f003-linux-x11.png`).

## Failures found and repairs
1. Expected contract breaks (record schema v2, Timeline no longer a placeholder) → F001/F002 tests updated to the new contract.
2. Determinism test compared records containing lists (identity equality) → compared string signatures.
3. A first "older build refuses" fixture test only restated constants → removed rather than kept as weak evidence; the real refusal is covered by `RECORD_SCHEMA_NEWER` tests.
4. Mutation T4 first produced a compile error (not a behavioural result) → redone as a behavioural mutation.

## Mutations (each caught)
T1 entered-in-error no longer voids the correction · T2 deletion ignored · T3 conflict picked by timestamp · T4 orphan amendment accepted · T5 older version can be amended · T6 schema 1 JSON gains `amend_reason`.

## Known limitations
No erasure (hard delete) workflow; observation time cannot be corrected; no derived outputs exist yet to invalidate; Timeline actions correct body weight only (labs arrive in F004).

## Next recommended Forge
**F004@v0.32 — labs vertical slice** (MVP batch, D-014).

---

# FORGE F004@v0.32 — labs vertical slice, 2026-10-07 — F004_COMPLETE

**Goal** manual LabResult entry with source label/value/unit/date/specimen; range metadata kept distinct from app interpretation; timeline integration. Exit: missing unit/range remains missing; source flag preserved; no diagnosis generated (master §39). **Baseline** e50873b → implementation e8ea064 (clean tree for all gates). MVP batch D-014, Forge 3 of 5.

## What a lab result is
A `lab.result` record (record schema 3) holding source text only: value as typed (`original_text`, e.g. "5,4"), printed unit (null when none), sample day (UTC midnight, shown without a time-zone shift) and `LabDetails` (printed name, specimen, laboratory, the lab's flag, the printed range; each null when not printed). State REPORTED, provenance manual. The app holds no thresholds and compares nothing; the screen says so. Interpretation (reference state, decision/critical rules, RCV, baseline) stays in the TS oracle until F011 (G-27).

## Acceptance → evidence
AC-1 schema rules, AC-2 missing stays missing, AC-3 flag/range verbatim, AC-4 no diagnosis (single stored record; JSON and EN/TR screen + row scans), AC-5 entry and errors, AC-6 timeline integration: `test/data/lab_result_test.dart`, `test/widget/f004_labs_test.dart` (EV-TEST-F004-0004) · AC-7 fixture `v1_f004_schema3` (`vault_compat_test`) + Linux launch on it (EV-RUNTIME-F004-0002) · AC-8 EV-TEST-F004-0006 · AC-9 EV-RUNTIME-F004-0001 (smoke 54/54) · AC-10 regression receipts + mutations.

## Tests / Builds / Runtime (receipts on e8ea064)
- `flutter test` 157 PASS; integration 4 PASS; tooling 16, contracts, `pnpm test` PASS; format/analyze clean.
- Web COMPILED (EV-BUILD-F004-0001: tree `7870db2b…fe84`, main.dart.js `5f41353d…7ca2`); smoke 54/54 RUNTIME_TESTED: in Chromium a result typed as printed is on screen with "Lab flag: H", survives a reload, no normal/abnormal wording.
- Linux COMPILED (EV-BUILD-F004-0002: bundle `76afbcf5…f6f0`, UNSIGNED); launch RUNTIME_TESTED on the schema-3 fixture vault (`reports/runtime/linux-f004/f004-linux-x11.png`).

## Failures found and repairs
1. **Product bug:** versions with equal entry times were ordered by id instead of lineage (a correction could appear older than what it corrects). Found by `lab_result_test`; fixed with a lineage-depth sort in `timeline.dart`; regression test in `timeline_test.dart`.
2. Expected contract breaks (record schema v3, Labs no longer a placeholder) → tests updated; NaN weight kept its `OUT_OF_PLAUSIBLE_RANGE` code (finite check made lab-specific).
3. Test drivers: widget tests needed lazy-list scrolling and focus release; the web smoke typed too fast and, on the phone layout, clicked fields that were off screen (Flutter hit-tests by position) so text landed in other fields — the app showed exactly what it received. Fixed in the smoke: wait after focus, scroll each field into view by wheel over the list padding, require on-screen bounding boxes.

## Mutations (each caught)
L1 missing unit stored as empty text · L2 lab flag dropped · L3 row compares value with range ("outside range") · L4 result stored as OBSERVED by the app · L5 schema 1/2 records gain a `lab` key · L6 Labs lists superseded versions.

## Known limitations
G-26 censored/qualitative values · G-27 interpretation (F011) · G-28 method, report time, structured ranges · no document import/OCR.

## Next recommended Forge
**F005@v0.32 — export + backup + staged restore** (MVP batch, D-014).

---

# FORGE F005@v0.32 — export + backup + staged restore, 2026-10-07 — F005_COMPLETE

**Goal** deterministic export of the canonical records; backup with manifest and checksums; staged restore. Exit: backup → delete test vault → restore → same records; checksums/manifest verified (master §39 F005, §36). **Baseline** b976d12 → implementation 5be93b6, review fixes e2b1439, 0622e9d, c878b1b (all closing gates on clean c878b1b). MVP batch D-014, Forge 4 of 5. Dependency review D-015 (`crypto`).

## What was built
- Backup bundle: manifest (§36.2) + the vault log byte for byte; deterministic.
- Restore gate (§36.3): format, encryption, digest, schema compatibility, identity, counts → staged copy beside the vault, read back and verified → old vault kept as `.before-restore-<time>` → switch. Refused when the live vault holds records (parsed or not), or was written by a newer app. After a restore the session refuses writes until a restart (state kept in AppServices).
- Deterministic export (records as stored + timeline projection).
- Adapters: desktop files (`backups/`, `exports/` beside the development vault), browser download (local Blob), memory. Staging/production/portable/invalid data folder: no file adapter.
- Today "Your data" card: create backup, export, check (local time), restore.

## Multi-agent adversarial review of the F002–F005 diff (ultracode)
Workflow `mvp-review-f002-f005`: 4 dimension finders + 1 skeptic per finding (25 agents; 6 verifications of the last dimension did not run: session limit). Findings were confirmed against the code at 5be93b6/0622e9d and fixed before verification finished, so the verifiers report them as "not reachable at HEAD" with the fixing commit. Each fix has a regression test that fails without it (mutations R1–R7):

| # | Finding (severity) | Fix |
|---|---|---|
| 1 | Torn last line merged the next confirmed write into it; lost on reload (major) | close the tail before the next write (e2b1439) |
| 2 | A write cut inside a multi-byte character made the whole vault unreadable and blocked restore (major) | line-by-line UTF-8 decoding, bad line skipped, never U+FFFD (e2b1439) |
| 3 | Restore replaced a vault written by a newer app (any parse error counted as "no records") (major, found twice) | `RESTORE_TARGET_NEWER`; raw record lines counted (e2b1439) |
| 4 | Restore replaced a readable vault whose records were all skipped on replay (major) | count raw record lines as well (c878b1b) |
| 5 | Lab values with a thousands separator stored 1000× too small (major) | `AMBIGUOUS_SEPARATOR` (e2b1439) |
| 6 | Labs/Timeline said "storage failed, try again" for a refused write (minor) | name `RESTART_REQUIRED`/`VAULT_READ_ONLY` (e2b1439) |
| 7 | Tomorrow accepted as a lab sample date in most zones (minor) | compare local calendar days (e2b1439) |
| 8 | Lab days sorted as UTC midnight against instants west of UTC (minor) | order by local day start; injectable, host-independent test (e2b1439, c878b1b) |
| 9 | Backup Check showed UTC time without a zone (minor) | local time (e2b1439) |
| 10 | Restored state lived in the card; returning to Today re-enabled backup/export (minor, found twice) | `AppServices.restartRequired` (e2b1439) |
| 11 | Cancelled lab correction left the old sample date and laboratory in the form (minor) | add-mode values restored (e2b1439) |
| 12 | Backups sorted by name (vault-id prefix), not newest first (minor) | sort by time in the name (0622e9d) |
| 13 | Restore message did not say where the old vault went (minor) | kept path shown (0622e9d) |
| 14 | Calendar-day ordering test passed without the fix on a UTC host (major, evidence) | injected zones (c878b1b) |
| 15 | Smoke "saved weight on the Timeline" could pass on Today (minor, evidence) | require the Timeline to be open (c878b1b) |
| 16 | No export test for withdrawals/deletions (minor, evidence) | test on the schema-2 fixture (c878b1b) |
| 17 | TR interpretation scan never matched "Tanı"/"Sağlıklı" (ASCII `\b`) (minor, evidence) | Unicode-aware boundaries + self-test (c878b1b) |
| 18 | No test that portable/production get no backup adapter (minor, evidence) | policy assertions (c878b1b) |

## Acceptance → evidence
AC-1 manifest/determinism, AC-2 restore gate refusals, AC-4 never replaces records, AC-5 write lock, AC-6 export, AC-7 policy: `test/data/backup_test.dart`, `test/application/export_test.dart`, `test/widget/f005_your_data_test.dart`, `test/data/storage_policy_test.dart`, `test/data/review_fixes_test.dart` (EV-TEST-F005-0013, and in New York time EV-TEST-F005-0018) · AC-3 restore drill on real files (unit) + Linux integration with a fresh start and a relaunch (EV-TEST-F005-0015) · AC-8 EV-RUNTIME-F005-0003 (smoke 60/60) · AC-9 architecture test + D-015 · AC-10 regression receipts + mutations.

## Tests / Builds / Runtime (receipts on c878b1b)
- `flutter test` 193 PASS in UTC (EV-TEST-F005-0013) and in `TZ=America/New_York` (EV-TEST-F005-0018); integration 5 PASS incl. the restore drill (EV-TEST-F005-0015); tooling 16, contracts, `pnpm test` PASS; format/analyze clean.
- Web COMPILED (EV-BUILD-F005-0003: tree `196fa8b2…211c`, main.dart.js `cce30634…950a`); smoke 60/60 RUNTIME_TESTED (EV-RUNTIME-F005-0003): in Chromium a backup downloads through a local Blob, its manifest SHA-256 matches the payload, it holds the saved weight and lab result and says it is unencrypted.
- Linux COMPILED (EV-BUILD-F005-0004: bundle `33786226…adfb`, libapp.so `7ed5e652…1082`, UNSIGNED); launch RUNTIME_TESTED on the schema-3 fixture vault (EV-RUNTIME-F005-0004, `reports/runtime/linux-f005/f005b-linux-x11.png`).
- The first gate run (EV-*-F005-0001…0009 on 0622e9d) passed but went stale with the second review round; kept as history, not verified gates.

## Failures found and repairs
1. **Product bugs:** the 18 review findings above (5 major data-integrity, 1 major evidence); each fixed with a regression test.
2. Expected contract break: `dart:io` confinement now allowlists the two native adapters (`storage_io.dart`, `data_files_io.dart`).
3. Test defects: the widget tamper test replaced text inside escaped JSON and so tampered nothing (now decodes, edits the payload, re-encodes); `removeLast` on a fixed-length list; an uppercase Turkish sample ("HASTALIK") that cannot match "hastalık" (dotless ı) replaced with a mixed-case one.

## Mutations (each caught; all 13 re-run at c878b1b)
B1 digest not checked · B2 restore replaces records · B3 old vault deleted, not kept · B4 payload not byte-identical · B5 export order unstable · B6 no write lock after restore · R1 torn tail not closed · R2 whole-file strict UTF-8 · R3 newer vault replaced · R4 lab day as a UTC instant (New York) · R5 thousands separator guessed · R6 skipped record lines not counted · R7 lab day as a UTC instant (UTC host, injected zones).

## Known limitations
G-29 browser restore · G-30 backups unencrypted (F006) · G-31 no import of external formats · cloud backup not built.

## Next recommended Forge
**F006@v0.32 — local security hardening** (last MVP Forge, D-014).
---

# FORGE F006@v0.32 — local security hardening, 2026-10-08 — F006_COMPLETE

**Goal** reviewed secret/key abstraction; installed and portable desktop vault protection; redacted logs. Exit: sensitive-data logging tests; key-loss/recovery states defined; no plaintext fallback (master §39 F006, §10, §11, §37; v0.24 key loss, DR-09). **Baseline** b1aeae6 → implementation 87c00ec, 5242d4d, c69dadf → review fixes ff37108, 82c9523, d81c5db, e2463a6, 98ac39e, tests 9b8217d (all closing gates on clean 9b8217d). MVP batch D-014, Forge 5 of 5: the MVP ladder F002–F006 is complete. Dependency review D-016 (`pointycastle` 4.0.0).

## What was built
- Crypto (D-016): Argon2id v1.3 (19 MiB, t=2, p=1, OWASP minimum) and ChaCha20-Poly1305 (RFC 8439) from pointycastle; known answers (RFC 8439 §2.8.2, RFC 9106 §5.3) and two vectors from the Argon2 reference C code (argon2-cffi) for the app's exact parameters and UTF-8 text. Key derivation in an isolate on native builds.
- Envelope `hhos-vault-enc` v1 around the unchanged format-1 log: a random data key wrapped under the passphrase and a 160-bit recovery key (shown once, confirmed); every log line sealed with the vault id and sequence number as associated data; changed, moved, copied-in and removed entries become visible warnings (`entryUnreadable`, `entryMissing`); a cut-off last line is an interrupted save and is closed before the next write; a failed append learns from storage whether its line landed before a number is used again.
- Key states and the vault gate (EN/TR): NO_VAULT (create, or memory only) · LOCKED · WRONG_PASSPHRASE (field cleared and refocused) · RECOVERY (recovery key + new passphrase; the vault is opened and checked first, then line 1 is replaced at byte level) · KEY_LOST (no false promise; "start a new vault" keeps the locked file under a new name) · UNREADABLE (newer, damaged, or not readable now: `VAULT_READ_FAILED`; untouched; a newer or unreadable-now vault is never set aside).
- Policy: staging, production and portable desktop builds persist only through the encrypted vault and write nothing before it exists; staging and production use different files; web builds other than development stay memory-only (Poly1305 fails under dart2js, Argon2id 7.4 s in V8: G-32); development keeps its labelled plaintext log. An append never re-creates a vault file that disappeared (`VAULT_MISSING`).
- Encrypted backups: the envelope byte for byte; restore reads the backup once, refuses the other kind (plaintext/encrypted) before any key prompt, asks for the backup's own passphrase or recovery key, checks the content, stops the session's writes before the switch, and puts the previous vault back if the switch fails (`RESTORE_SWITCH_FAILED`, or the kept path is named); export not offered for encrypted vaults (G-34).
- Redaction (§37): `core/redact.dart` is the only console writer (type + code; string fields only as lower-case code words); Flutter, platform (`PlatformDispatcher.instance.onError`) and startup errors routed through it; the gate logs redacted events (`vault_created`, `vault_unlocked warnings=N`, `vault_recovered`, `vault_set_aside`, `session_memory_only`, `*_failed error=Type(CODE)`).

## Multi-agent adversarial reviews (ultracode)
**Round 1** — workflow `wf_630e488a-5de` over b1aeae6..c69dadf: 4 lenses (crypto, storage, honesty, redaction/flow) find, 4 skeptics refute (8 agents). 15 confirmed reports = 11 distinct findings (2 major after verification); 6 refuted. Every fix has a regression test that fails without it (mutations S17–S30):

| # | Finding (severity after verification; reports) | Fix |
|---|---|---|
| 1 | Recovery rewrote the passphrase slot before the inner log was checked: a newer or damaged vault was left modified while the gate said it was not changed (major; CRYPTO-2, STORE-4, HONESTY-1, RED-01) | open and parse first, then replace the slot (ff37108) |
| 2 | A restore that failed after the live vault was moved left the session writable; its next save created a headerless vault (major; STORE-1) | writes stop before the switch; rollback or kept path named (`RESTORE_SWITCH_FAILED`); appends refuse a missing file (`VAULT_MISSING`) (ff37108) |
| 3 | A failed append whose bytes landed reused its sequence number, so the next saved entry was hidden as a copy (minor; CRYPTO-1, STORE-2) | resync the number from storage; SAVE_FAILED no longer says nothing changed (ff37108) |
| 4 | A new passphrase rewrote the file from decoded text and destroyed damaged sealed bytes (minor; CRYPTO-3) | byte-level `replaceFirstLine` (ff37108) |
| 5 | Development builds asked for an encrypted backup's key and ran Argon2id before refusing it by kind (minor; STORE-3) | kind check before the prompt (`holdsEncryptedVault`) (ff37108) |
| 6 | A backup that could not be read made a confirmed restore do nothing, without a message (minor; FLOW-2) | one read; failures reported (ff37108, 82c9523) |
| 7 | The entry-missing warning claimed the other entries were intact (minor; HONESTY-4) | text says other problems are listed (ff37108) |
| 8 | A vault that could not be read at startup ended on the startup-error screen without the gate (minor; FLOW-5) | `VAULT_READ_FAILED` unreadable state, kept in place (ff37108) |
| 9 | The gate said "Nothing was changed" after create had written the vault (minor; RED-04) | re-inspect; unlock mode with "created, but could not be opened" (ff37108) |
| 10 | F001/F005 staging tests ran `startApp()` against the host's real data folder (minor, evidence; RED-02) | temporary `HHOS_DATA_DIR`, asserted empty (ff37108) |
| 11 | No test that uncaught platform errors reach the redactor (minor, evidence; RED-03) | handler set on `PlatformDispatcher.instance` (the test binding drops `onError` assignments) and tested (ff37108) |

Refuted but acted on anyway: an unauthenticated key-slot list (CRYPTO-4: recovery now adds a missing passphrase slot; set authentication is G-39), the runtime smoke's regex search and missing file checks (RED-05: hardened), the permissive safe-word pattern (RED-07: tightened), the console-writer guard (RED-08: widened), the backup-key wording (HONESTY-3: reworded). RED-06 (docs ahead of receipts) is answered by this closing entry: the docs cite the receipts below.

**Own findings while testing the fixes** (82c9523): the restore read the backup twice (a second read could see another file); the restart texts promised restored data after a switch that failed. Fixed with tests.

**Round 2 (fix-round review)** — workflow `wf_d07eadb1-87a` over c69dadf..82c9523: 3 lenses (do the fixes hold, regressions, honesty) read the diff from git while mutations ran, then one skeptic per finding for the 6 most severe (9 agents). 10 reports = 6 distinct findings, all fixed in e2463a6 and 98ac39e with regression tests (mutations S32–S38). Skeptics confirmed FIXES-1 (major) and HONESTY-1 (real, rated minor); the other 4 verifications did not run (session limit), and those findings were checked against the code by hand before fixing.

| # | Finding (reports) | Fix |
|---|---|---|
| 12 | A failed append that stored nothing still used up its sequence number, leaving a permanent false "entry removed" warning (major as reported; REGRESSIONS-1, FIXES-2, HONESTY-1) | a write refused before anything is stored keeps its number (`VAULT_MISSING`, and `VAULT_WRITE_REFUSED` for a file that cannot be opened); after an unknown outcome the next append learns the number from storage; the missing-entry text no longer asserts removal |
| 13 | Two windows of the app on one vault reused sequence numbers, hiding confirmed entries as unreadable; a vault replaced by the other window was appended to (major as reported; FIXES-1) | before each append the stored size is compared and the next number learned from storage; a vault with another id is refused (`VAULT_CHANGED`); single-instance lock open as G-40 |
| 14 | A restore that moved no file said the previous file was "back where it was", also when there was none (REGRESSIONS-2, HONESTY-3) | `RESTORE_NOT_SWITCHED`: nothing changed on disk; saving stays paused as a precaution |
| 15 | The gate still said "Nothing was changed" after create when the new vault could not be read back, and recover had no such check (FIXES-3, HONESTY-2) | the gate decides from what the step wrote: created, or new passphrase stored |
| 16 | Redaction hid Flutter's default library name (REGRESSIONS-3) | lower-cased before filtering |
| 17 | The Turkish save-failure text named an action ("hatalı giriş") the Turkish screens do not have (HONESTY-4) | "yanlışlıkla girildi", the real label |

## Acceptance → evidence
AC-1 reviewed crypto: `test/data/vault_crypto_test.dart` (RFC 8439 §2.8.2, RFC 9106 §5.3, argon2-cffi vectors, production cost asserted), D-016, EV-TEST-F006-0019 · AC-2 envelope and byte scan, AC-3 integrity, AC-4 key states (data level): `test/data/encrypted_vault_test.dart`, fixture `enc_v1_f006` in `test/data/vault_compat_test.dart` · AC-4 key states (screens, EN/TR): `test/widget/f006_vault_gate_test.dart` · AC-5 no plaintext fallback: `test/data/storage_policy_test.dart`, the gate tests, EV-RUNTIME-F006-0008 (production first start on an empty home: the gate, nothing written) · AC-6 encrypted backups: `test/data/encrypted_backup_test.dart`, `test/widget/f005_your_data_test.dart`, the gate's Your data and restore-drill tests · AC-7 redaction: `test/security/no_sensitive_logs_test.dart`, EV-RUNTIME-F006-0009 (only redacted events, neither passphrase in the output) · AC-8 Linux: EV-TEST-F006-0024 (production vault on real files: create, save, relaunch, unlock; recovery; key lost), EV-BUILD-F006-0006, EV-RUNTIME-F006-0008, EV-RUNTIME-F006-0009 · AC-9 isolate key derivation (`storage_policy_test`, mutation S13), `test/architecture/imports_test.dart`, D-016 · AC-10 F001–F005 suites inside EV-TEST-F006-0022 (UTC) and EV-TEST-F006-0025 (New York), web smoke EV-RUNTIME-F006-0007, contracts EV-TEST-F006-0026, `pnpm test` EV-TEST-F006-0027, tooling EV-TEST-F006-0023, mutations 38/38.

## Tests / Builds / Runtime (receipts on 9b8217d)
- `flutter test` 282 PASS in UTC (EV-TEST-F006-0022) and in `TZ=America/New_York` (EV-TEST-F006-0025); Linux integration 7 PASS (EV-TEST-F006-0024); tooling (EV-TEST-F006-0023), contracts (EV-TEST-F006-0026), `pnpm test` (EV-TEST-F006-0027) PASS; `flutter pub get` (EV-TEST-F006-0019), format 0 changed (EV-TEST-F006-0020), analyze no issues (EV-TEST-F006-0021).
- Web (development) COMPILED (EV-BUILD-F006-0005: tree `8a9dc0e2…cf4b`, main.dart.js `08f82f96…d321`); smoke 60/60 RUNTIME_TESTED in Chromium 141 (EV-RUNTIME-F006-0007: EN desktop, EN and TR phone; no console errors, no external requests; a backup downloads with a matching checksum and says it is not encrypted).
- Linux (production profile) COMPILED (EV-BUILD-F006-0006: bundle `4dc97053…cd1f`, libapp.so `a0baee92…a469`, UNSIGNED). RUNTIME_TESTED on Ubuntu 24.04 under Xvfb X11: first start on an empty home shows the vault gate and writes nothing (EV-RUNTIME-F006-0008, `reports/runtime/linux-f006/f006c-prod-first-start.png`); on the encrypted fixture, driven by keyboard, the wrong passphrase is refused (`vault_unlock_failed error=CryptoFailure(NOT_AUTHENTIC)`), the right one opens it (`vault_unlocked warnings=0`; Today shows 78 kg · encrypted), the vault file is unchanged (sha256 `404df315…f501`), it is still an `hhos-vault-enc` v1 envelope and the only file in the data folder, and neither passphrase appears in the output (EV-RUNTIME-F006-0009, `f006c-prod-unlock-*.png`).
- Two earlier gate runs passed and went stale (kept as history, not verified gates): EV-*-F006-0001…0009 on 795212b (before the fix round) and EV-*-F006-0010…0018 on 98ac39e (before the two added tests).
- Not built here: Windows, macOS (BLOCKED_BY_HOST_OS), Android (BLOCKED_ENVIRONMENT), iOS (BLOCKED_BY_HOST_OS). Nothing is SIGNED or PACKAGED in this Forge.

## Failures found and repairs
1. **Product bugs:** the 11 review findings above (2 major) and the two own findings; each fixed with a regression test. Earlier in the Forge: the passphrase field lost its focus on Linux after a wrong try (found by the integration test; field cleared and refocused, `slowDerive` widget test); an envelope without entries was taken for a new vault (now a missing log header); a newer or damaged inner log showed a generic error (now the unreadable state).
2. Test defects: a two-digit "73" substring check failed in about half the runs (random ciphertext); duplicate "kg" text, a wrong record count, a button finder and a `debugPrint` restore-timing slip in new widget tests; a restart-banner expectation that the card replaces with its message.
3. Mutation S13 first failed to compile and was rewritten as a behavioural mutation.

## Mutations (each caught; 38 in all)
S1 sequence number not in the entry AAD · S2 vault id not in the key-wrap AAD · S3 portable development builds persist unencrypted · S4 recovery keeps the old passphrase · S5 set aside deletes · S6 restore ignores the backup kind · S7 unreadable live entries do not block a restore · S8 encrypted backup content not checked · S9 Argon2id cost lowered · S10 vault created before the recovery key is confirmed · S11 any unusable last line called an interrupted save · S12 removed entries not reported · S13 key derivation on the UI thread · S14 errors rendered with their message · S15 plaintext export for an encrypted vault · S16 a failed unlock may write · S17 recovery writes before the vault is checked · S18 a failed append reuses its number · S19 recovery drops a missing passphrase slot · S20 a read error not explained · S21 a vault unreadable now may be set aside · S22 an append re-creates a missing vault · S23 the new passphrase rewrites decoded text · S24 the switch does not stop the session · S25 a failed switch leaves the place empty · S26 the key is asked before the kind is checked · S27 the card keeps writing after a failed switch · S28 "nothing changed" after a created vault · S29 redaction lets ids and values through · S30 uncaught errors bypass redaction · S31 a failed backup read is retried and the restore goes on · S32 a failed append uses up its number · S33 lines from another window not noticed · S34 a replaced vault appended to · S35 a refused write leaves a fragment to close · S36 a restore that moved nothing says "put back" · S37 the gate decides from a re-read after a write · S38 the default Flutter library name redacted. All 38 ran on 98ac39e: 36 caught; S18 (a store that cannot tell its size) and S28 (a failure inside the create step after the write) were not, so two tests were added in 9b8217d and both are caught there (the code differs from 98ac39e only by a moved doc comment).

## Known limitations
G-13 OS key stores as convenience unlock · G-32 encrypted browser storage · G-33 passphrase change and data-key rotation · G-34 export for encrypted vaults · G-35 truncation at the end not detectable · G-36 app lock · G-37 secrets in memory, Unicode normalization · G-38 recovery key confirmed by checkbox · G-39 key slots not authenticated as a set · G-40 no single-instance lock (two windows on one vault: no saved entry is hidden, but each window shows only its own new entries until a restart). Windows and macOS compile the same pure-Dart vault but are not built here (BLOCKED_BY_HOST_OS); Android/iOS have no storage adapter.

## Next recommended Forge
**F007@v0.32 — daily domains, slice 1: measurements** (master §39 F007: one bounded slice per Forge). It builds on everything the MVP made (canonical record, timeline and correction lineage, labs, encrypted vault, backups). Not a Forge, but due first: the user's decision on making this closed MVP state the default branch (D-014).

---

# FORGE F007@v0.32 — daily domains, slice 1: measurements, 2026-11-07 — F007_COMPLETE

**Goal** measurements beyond body weight on the same canonical record, timeline, correction lineage, labs path, encrypted vault and backups: waist circumference, resting heart rate and blood pressure, typed by hand, kept as typed, never judged (master §39 F007, v0.24 FR-17). **Baseline** 48c3c94 (`main`, the closed MVP, D-017) → implementation 33d7aba, 94515ad, 7ef40d2, 8119785, 142648c, b0e963f → integration/smoke/old-code c9f7c7e, 019906b, e684c95 → review fixes 50479f0, the lock fix and the test-gap commit → closing gates on clean e1aaf17. Decisions D-018, conflicts C-10/C-11, gaps G-41…G-47. No new dependency.

## What was built
- Record schema 4 (RS-004, additive, no vault-format or envelope change): kinds `body.waist_circumference` (cm), `vital.resting_heart_rate` (bpm), `vital.blood_pressure` (mmHg); optional free-text `context` (as typed, at most 500 characters); a kind-tagged `details` slot (`blood_pressure`: systolic, diastolic, unit and the text typed for each). Each record is written with the oldest schema that holds it: weight and lab results stay at 3, so older apps are locked out only once a measurement is saved. Schema 1–3 records keep their exact JSON; the reader accepts 1–4 and refuses 5.
- Rules, structural only: schema gates before the marker early return; canonical unit only; finite numbers; waist, heart rate and systolic above 0; a stored diastolic may be 0; no upper bound and no clinical threshold (G-46). Systolic above diastolic is an entry rule only (`BP_ORDER`): domain rules only loosen (D-018).
- Entry: blank is `EMPTY`, 0 is `NOT_POSITIVE`, a possible thousands separator is refused, hundreds of digits are `NOT_A_NUMBER`; errors carry their field. Each save is one OBSERVED manual record with the time Save is pressed; two identical readings are two records. Corrections keep the observation time and (pre-filled) the note; `TARGET_WRONG_KIND` in every correct method, weight and lab included.
- Upgrade checkpoint: before the first record that older apps cannot read, in a non-empty vault, a backup of the vault as it is goes to `backups/` (plaintext, or the encrypted envelope) and is named on screen; if it cannot be written the save is refused (`CHECKPOINT_FAILED`) and nothing is stored. Browser builds keep none (G-47).
- UI (EN/TR): a Measurements card on Today (Latest per kind with time, source and a spoken summary; kind chooser; one or two fields and a note; the note that values are kept as typed and not judged; live-region Saved message; history); measurement rows and a kind-aware Correct, entered in error and delete on the Timeline, with Cancel. Numbers are shown with the decimals typed; blood pressure is `118/76 mmHg`; a missing value is named, never 0.
- Evidence tooling: `tools/compat/old_code_check.sh <revision>` (the older revision's code reads data this build wrote, in a scratch worktree); `tools/linux/measurements_smoke.sh`; fixtures `v1_f007_schema4` and `enc_v1_f007`; web smoke and Linux integration extended.

## Multi-agent adversarial review (ultracode)
The first attempt (workflow, 4 lenses) failed on a weekly usage limit and returned nothing; that is not a clean result and was not counted as one. It was run again with the Agent tool: four independent reviewers (domain, storage, UI, test adequacy), each in its own worktree, proving findings with scratch tests. No blocker. Confirmed and fixed with a regression test each (mutations T25–T31):

| # | Finding (reviewer) | Fix |
|---|---|---|
| 1 | A typed waist with more than 20 decimals made `toStringAsFixed` throw while building the Measurements card and the Timeline, on every launch (major; UI) | shown as typed; guard for 20+ decimals and 1e21+ |
| 2 | The upgrade checkpoint also fired for a weight or lab result in a store whose newest record was older than schema 3, and could refuse it with CHECKPOINT_FAILED (storage) | only a record older apps cannot read triggers it |
| 3 | Two first measurements started together both ran the checkpoint and one failed on a shared temp file (storage) | record writes serialized; backup temp files have their own name |
| 4 | The checkpoint notice was tied to a changed path, so a retry in the same second showed none (storage) | the notice belongs to the save that made it |
| 5 | A note was counted in UTF-16 units by the rule and in characters by the field (domain, UI) | counted in code points everywhere; "at most 500" |
| 6 | Hundreds of digits overflowed to infinity and showed "breaks a record rule (VALUE_NOT_FINITE)" (domain, UI) | `NOT_A_NUMBER` on the field |
| 7 | Switching kind kept the typed value under the other kind (57 bpm saved as 57 cm); no Cancel on the correction form; save errors not announced; the spoken time said "measured" (UI) | cleared; Cancel; live region; "saved"; Turkish "yorumlamaz" |
| 8 | `old_code_check.sh` printed a revision for inputs made from a dirty tree (storage) | refuses a dirty source tree (ignoring evidence outputs, like run_gate) |

Test-adequacy gaps (all closed with tests bound to mutations T32–T43): typed decimals on screen, the note through a correction, the console-leak list missing numbers and camelCase kind names, CHECKPOINT_FAILED on the card, no checkpoint for files that cannot restore (G-47), judging-word scan over error and empty-state texts, fields cleared after Save, the 500 boundary, the save-time observation, trimmed blood-pressure text, and the encrypted integration test now covering all three kinds and a correction. Not changed: web shows no note about the lock-out after a first measurement (G-47); correction fields are not pre-filled with the numbers; TR shows a dot as the decimal point (G-43); the stray-space merge of digits in `parseDecimal` is inherited from weight and lab (G-45).

## Acceptance → evidence
AC-1, AC-2, AC-3, AC-6, AC-7: `test/data/measurement_test.dart` · AC-4, AC-5, AC-8: `test/widget/f007_measurements_test.dart`, `test/widget/shell_test.dart` · AC-9: `test/security/no_sensitive_logs_test.dart`, `test/data/encrypted_vault_test.dart`, integration (no plaintext, encrypted checkpoint) · AC-10: EV-TEST-F007-0070 (main 48c3c94: 9 checks; run against HEAD the refusal checks fail) · AC-11: `measurement_test` checkpoint group, widget test, integration (checkpoint on disk) · AC-12: fixtures, `vault_compat_test`, `backup_test`, EV-RUNTIME-F007-0066 · AC-13: EV-TEST-F007-0064 (9 integration tests) · AC-14: EV-RUNTIME-F007-0063 (70 checks) · AC-15: EV-TEST-F007-0060 (UTC) and -0067 (New York), tooling, contracts, `pnpm test`, 43 mutations.

## Tests / Builds / Runtime (receipts on e1aaf17)
- `flutter test` 328 PASS in UTC (EV-TEST-F007-0060) and in `TZ=America/New_York` (EV-TEST-F007-0067); Linux integration 9 PASS (EV-TEST-F007-0064); tooling (-0061), contracts (-0068), `pnpm test` (-0069) PASS; `flutter pub get` (-0057), format 0 changed (-0058), analyze no issues (-0059).
- Web (development) COMPILED (EV-BUILD-F007-0062); smoke 70/70 RUNTIME_TESTED in Chromium (EV-RUNTIME-F007-0063): a blood pressure typed in the browser shows `118/76 mmHg` on Today and the Timeline, survives a reload and is in the backup download with the typed text and schema 4; no console errors, no external requests.
- Linux (development profile) COMPILED, UNSIGNED (EV-BUILD-F007-0065); RUNTIME_TESTED on Ubuntu 24.04 under Xvfb: the release binary opens the schema-4 fixture, shows 124/82 mmHg, 57 bpm and 84.25 cm (a newer "not measured" entry, a withdrawn and a deleted reading are skipped), the vault file keeps its sha256, stays the only file, no error events (EV-RUNTIME-F007-0066). Old-code check EV-TEST-F007-0070.
- Two earlier gate runs are kept as history, not verified gates: EV-*-F007-0029…0035 on 5979615 (the web smoke failed before any check: the rebuilt container had no Playwright browser build; the smoke now takes `CHROME_EXECUTABLE`) and EV-*-F007-0043…0056 on 38aab1b (13 PASS; the old-code check refused a tree whose only changes were evidence outputs, a defect of my guard).
- Not built here: Windows, macOS (BLOCKED_BY_HOST_OS), Android (BLOCKED_ENVIRONMENT), iOS (BLOCKED_BY_HOST_OS). Nothing is SIGNED or PACKAGED in this Forge.

## Failures found and repairs
1. Product: the review findings above; one regression of my own: the write lock first created a `Future` at construction, which lives in a test's fake-async zone, so a write in real async never ran and f002/f005 hung (found by the full suite, fixed before the gates, no lock future exists until a write is in flight).
2. Process: the container was rebuilt mid-Forge (Flutter, Linux packages and scratch scripts were gone; reinstalled from the pinned, checksum-verified release; the mutation script and close script were rewritten); `git add -A` once committed the review worktrees (removed in b555d4f, no history rewrite); a `git clean` in a command was refused by the permission layer and was not run (CLAUDE.md forbids it).
3. Mutation T20 (Latest shows a newer "not measured" entry) was not caught at first; a test was added.

## Mutations (each caught; 43 in all)
T1 blood pressure may carry a quantity · T2 blank becomes 0 · T3 inches accepted · T4 measurement kind at schema 3 · T5 context/details at schema 3 · T6 correction unlinked · T7 correction loses the observation time · T8 typed decimals not kept · T9 typed BP text dropped · T10 a judging word on the card · T11 schema 1–3 gain the context key · T12/T13 correct methods accept any kind · T14 no checkpoint · T15 a failed checkpoint does not stop the save · T16 checkpoint of an empty store · T17 BP order not checked at entry · T18 stored diastolic 0 refused · T19 Timeline shows the status label · T20 Latest shows a not-measured entry · T21 checkpoint not named on screen · T22 no Correct for measurements · T23 TR shows bpm · T24 empty note stored · T25 checkpoint for any newer record · T26 writes not serialized · T27 note counted in UTF-16 units · T28 infinity accepted · T29 many decimals not guarded · T30 kind switch keeps typed text · T31 no Cancel · T32 shortest form instead of typed decimals · T33 BP display ignores typed text · T34 note not pre-filled · T35 service drops the note · T36 checkpoint failure shown as a generic failure · T37 judging sentence in an error text · T38 fields not cleared · T39 limit off by one · T40 observation an hour later · T41 checkpoint wired for files that cannot restore · T42 BP text untrimmed · T43 a log line with a typed value.

## Known limitations
G-41 structured context, devices, sessions · G-42 other FR-17 metrics (temperature, SpO2, height, respiratory rate, body composition); BMI and waist-height ratio wait for F011 · G-43 one unit per kind, no UCUM code, no locale decimal display · G-44 the time of a measurement is the time Save is pressed; "not measured" entries cannot be made from the screen · G-45 weight entry rules (display rounding, ambiguous separator) · G-46 no upper bounds or REVIEW tier: a typo such as 1180 is saved, shown at once, one tap to correct · G-47 web development builds keep no checkpoint. The first measurement locks F002–F006 builds out of the vault (`RECORD_SCHEMA_NEWER`), by design; `main` therefore receives F007 only now that it is closed (D-017). Earlier gaps stay: G-13, G-32…G-40.

## Next recommended Forge
**F007@v0.32 — measurements, slice 2.** Finish the measurement domain before opening another one: the person cannot yet say when a measurement was taken (G-44), and height, temperature, SpO2 and respiratory rate are missing (G-42); height is also the input F011 needs for BMI and waist-height ratio. Slice 2 adds measurement time entry (with future-time and correction rules), those four metrics on the same record schema 4 path, and the weight entry rules (G-45). Nutrition, activity, sleep and subjective state follow as their own Forges.

---

# FORGE F007-S2@v0.32 — measurements, slice 2 (time, four more metrics, calm redesign), 2026-11-07 — F007_COMPLETE

**Goal** the person can say when a measurement was taken (G-44), four more FR-17 metrics (G-42: height, body temperature, SpO2, respiratory rate), the weight entry rules (G-45), and, on the owner's request, a calm, uncluttered interface (docs/DESIGN.md). **Baseline** 0617601 (`main`, F007 slice 1) → implementation cae4a66, e309ae3 → review fixes dcbd33a, e924d3f, 0ba1003 and the closing gates on clean d799709. Decisions D-019, D-020; conflict C-12; gaps G-48…G-51. No new dependency.

## What was built
- Record schema 5 (RS-005, additive, no new key): `body.height` (cm), `vital.body_temperature` (°C), `vital.oxygen_saturation` (%), `vital.respiratory_rate` (breaths/min). SpO2 above 100 refused at entry only; a stored 101 loads. A new height is a new record.
- Time of a measurement: "When" (`YYYY-MM-DD HH:MM`, `HH:MM` today, or a full time with an offset), parsed once at Save into a UTC instant; refusals `TIME_FORMAT`, `TIME_TOO_OLD`, `FUTURE_TIME` (the body-weight rule, shared), `TIME_DOES_NOT_EXIST`, `TIME_AMBIGUOUS`; an injectable `LocalZone` and a rule-based zone test New York and a 30-minute shift (Lord Howe). Entry rules only: nothing stored is re-judged. Corrections keep the observation time.
- Checkpoints also precede the first schema-5 record and never replace another backup (a same-second name moves on).
- Weight: ambiguous separators refused, typed decimals shown (Today and Timeline).
- Interface: a calm clinical theme (one teal accent, hairline borders, field edges at 3:1, a quiet development strip); Today leads with the date and the weight entry, then seven measurement tiles (value largest, measured time, a "saved" time when it differs by more than a minute), "Your data", the planned line, build facts last; adding is one sheet per kind with "More details" (time, note) closed by default, closed only by Save or Cancel, Next/Done on the keyboard; Timeline shows measured and saved times. `docs/DESIGN.md` (method and slop audit) and `docs/BRAINSTORM.md` (ideas under the invariants).
- Tooling: old-code check mode `f007s2`, fixtures `v1_f007s2_schema5` and `enc_v1_f007s2`, web smoke and integration for the tiles and sheet, and a local try-out package (`tools/package_web_local.sh`, `packaging/web-local/`, `downloads/Human-OS-web-<rev>.zip`: unzip, double-click `Human-OS-baslat.bat`; development build, data stays in the browser).

## Multi-agent adversarial reviews (ultracode)
The Workflow tool was off in this session; reviews ran with the Agent tool, each reviewer in its own worktree on e309ae3, proving findings by scratch tests and mutations. **Time/domain/storage:** no blocker or major; 2 misleading time texts (a US offset example, a bare-"HH:MM" offset hint), the 24-hour hint, a non-existent -14:00 offset: fixed. **UI/design/accessibility:** 3 medium (Save squeezed into a narrow strip at 2x text on 320 dp; a swipe or tap outside silently discarding typed numbers; the backup place shown once for 12 s) and lower ones (no keyboard submit, no safe-area padding, field edges at 1.3:1, weak navigation cue, weight card led with storage chips, a hint pointing to a field with another name, Turkish wording): all fixed, plus the audit's own findings. **Test adequacy:** about 55 mutations; gaps in weight typed decimals, the saved caption and its 60 s threshold, the Timeline saved/measured text, More details re-opening, Cancel, tile order, spoken labels, the dark theme: closed with tests bound to mutations V1–V10. Also U1–U7 for the UI fixes, all caught. Not changed (recorded as G-49): tiles two screens down at 2x text on a 320 dp phone, reduced motion, about ten text styles against the method's four.

## Acceptance → evidence
AC-1, AC-15: `test/data/measured_at_test.dart` (UTC and New York runs) · AC-2, AC-16: `test/unit/measurement_format_test.dart`, `test/widget/f007_measurements_test.dart` · AC-3, AC-4: `test/data/measurement_test.dart` · AC-5, AC-17, AC-18: widget tests, theme test · AC-6: judging-word scans over every new string and semantics label · AC-7, AC-19: weight tests · AC-8: checkpoint tests (4→5, 3→5, same second) and the integration test (two backups on disk) · AC-9: `test/security/no_sensitive_logs_test.dart`, encrypted integration · AC-10: EV-TEST-F007-0099 (9 checks; against HEAD 6 refusal checks fail) · AC-11: fixtures, `vault_compat_test`, EV-RUNTIME-F007-0095 · AC-12: EV-TEST-F007-0093 · AC-13: EV-RUNTIME-F007-0092 (78 checks) · AC-14: 372 tests in UTC (EV-TEST-F007-0089), 373 in New York (-0096), integration 9, contracts, pnpm.

## Tests / Builds / Runtime (receipts on d799709)
- `flutter test` 372 PASS (1 skipped) in UTC and 373 PASS in `TZ=America/New_York` (clock-change checks on the device zone); Linux integration 9 PASS; tooling, contracts, `pnpm test` PASS; pub get, format 0 changed, analyze no issues.
- Web (development) COMPILED; smoke 78/78 in Chromium (a blood pressure and a height with a typed time entered in the browser, spoken summaries, reload, Timeline, backup at schema 5, no console errors, no external requests). Linux (development profile) COMPILED, UNSIGNED; RUNTIME_TESTED on Ubuntu 24.04 under Xvfb on the schema-5 fixture: tiles with the stored values, vault file unchanged, no error events.
- Earlier gate runs kept as history, not verified gates: EV-*-F007-0072…0074 on 0ba1003 (analyze reported an info in my own test) .
- Not built here: Windows, macOS (BLOCKED_BY_HOST_OS), Android (BLOCKED_ENVIRONMENT), iOS (BLOCKED_BY_HOST_OS). The Windows launcher script of the local package was not run on Windows (G-51).

## Failures found and repairs
1. Product: the review findings above; a write lock built at construction hung widget tests in another zone (found by the full suite, fixed with no future until a write is in flight); a checkpoint filename could be replaced by a second checkpoint in the same second (found while writing the integration test, fixed and tested).
2. Process: my `git add -A` once staged the review worktrees (removed in an earlier Forge's commit, no history rewrite); a command containing `git clean` was refused by the permission layer and not run (CLAUDE.md forbids it); the analyze gate failed once on an info in a test, fixed and the gates rerun.

## Known limitations
G-41 structured context · G-42 body composition and other metrics · G-43 units, UCUM, locale decimals · G-46 no upper bounds (a typo such as 1180 is saved, shown at once, one tap to correct) · G-47 web has no checkpoint · G-48 time of an existing reading cannot be changed · G-49 design leftovers · G-50 the web package is a development build in a browser, a real Windows installer needs a Windows host · G-51 Windows launcher untested. The first schema-5 record locks F007-slice-1 builds out of the vault (`RECORD_SCHEMA_NEWER`), by design.

## Next recommended Forge
**U001 — the first-run experience and mouse-only entry** (D-020). A short first-run (what Human OS is, what stays on this device, add one number), steppers, quick-pick chips and time presets beside the typed fields, a plain-language "how to use" page, and the G-49 design leftovers; then U002 (a clickable body and specialties guide written from open standards) and U003 (glossary and measurement guide).

# FORGE G001@v0.32 — genetics: raw DNA file import, offline, 2026-11-07 — G001_COMPLETE

**Goal** a person loads a raw DNA file from 23andMe, AncestryDNA, MyHeritage or FamilyTreeDNA and sees, offline and on their device only, what the file contains (a searchable list of variants and genotypes), with a way to match against a local annotation pack that cites its source. User-directed track (D-020). **Baseline** 3e3c3b4 → implementation 83ac459, ad53636 → review fixes 0ea1b50, e70d592, 0b98e44, 51a56e6 (gates on 51a56e6).

## What was built
- Pure-Dart reader (`lib/src/domain/genetics/raw_genome.dart`): layouts detected from the header and first data lines; a no-call (`--`, `-`, `0`, empty) stays a no-call, a partial call is never turned into a base, indel markers kept as typed; unreadable lines counted with a code and line number (first 20 listed, never the line's text); duplicates counted (case-folded); build only from a closed set (36/37/38, GRCh and hg forms mapped, anything else is not a build statement); byte-level refusals (gzip, zip, bzip2, 7z, UTF-16, VCF, NUL, over 200 MB) and a file with more than one line in six unreadable is refused whole.
- Annotation packs (`annotation_pack.dart`): header with name, licence, build and plus strand or refused; statement shown as the source states it, with source, id and date; match kinds: the file lists the allele, lists no such allele (says nothing about other positions), no call, strand cannot be told apart, not comparable (insertion/deletion); text from a pack is made safe (control and direction characters removed, length capped). The bundled pack is invented and labelled so.
- Genetics screen, opened with the mouse from a Tools tile on Today: notice before any file (identifies you for life, relatives, the OS may keep copies, not a medical result), choose a file or an invented sample, summary, search by rsID or chromosome (chr prefix accepted), paging, two-line variant rows that hold at 320 dp and 2x text, spoken labels in the app language, Clear. The file is held only while the page is open and is never written, logged or sent; `file_picker` sits behind an interface and the chooser's cache is released in a `finally` (D-021, D-022).

## Multi-agent adversarial reviews (ultracode)
Three reviewers in their own worktrees (UI/design/wording, parser/packs/privacy, test adequacy); the Workflow tool was off, so they ran with the Agent tool. Findings and repairs are in `CURRENT_STATE.json` (`review`). The test-adequacy reviewer was cut short by an API limit: its parser probes (about 120) found survivors that now have tests; its pack-safety, UI and string probes did not run (G-60). The web smoke then failed because the Genetics tile was not exposed as a button to assistive technology and the browser; fixed with a semantic button and a mutation-bound test.

## Acceptance → evidence
AC-1..AC-3, AC-10: `test/data/raw_genome_test.dart` · AC-4: `test/security/no_sensitive_logs_test.dart`, `test/widget/g001_genetics_test.dart` · AC-5: widget tests (search, paging, refusals, 320 dp at 2x in EN and TR, judging-word scan) · AC-6, AC-11: `test/data/annotation_pack_test.dart` · AC-7: mutations bound to chr search, hidden-character removal, spoken label, row layout, tile semantics, and the reviewed parser gaps; 13 gates · AC-8, AC-13: D-021, web smoke EV-RUNTIME-F007-0133 (opens the screen and loads the sample in Chromium) · AC-9: this entry. AC-11 and AC-12 are met in a narrower form than written: see G-57 (homozygous calls on A/T and C/G alleles) and G-58 (the notice is shown while no file is loaded).

## Tests / Builds / Runtime (receipts on 51a56e6)
- `flutter test` 431 PASS (1 skipped) in UTC and 432 PASS in `TZ=America/New_York`; Linux integration 9 PASS; tooling, contracts, `pnpm test` PASS; pub get, format 0 changed, analyze no issues. Web (development) COMPILED, smoke PASS (EV-RUNTIME-F007-0133). Linux (development) COMPILED, UNSIGNED, RUNTIME_TESTED under Xvfb on the schema-5 fixture (EV-RUNTIME-F007-0136; the DNA screen itself is exercised by widget tests and the web smoke, not by the Linux binary).
- Earlier gate runs kept as history, not verified gates: EV-*-F007-0101…0103 (analyze info in my own test) and EV-*-F007-0114…0126 (web smoke failed on the Genetics tile as above). No old-code check was needed: no stored data or schema changed.
- Not built here: Windows, macOS (BLOCKED_BY_HOST_OS), Android (BLOCKED_ENVIRONMENT), iOS (BLOCKED_BY_HOST_OS); the native file dialog was not exercised on any platform in this environment (the picker is faked in tests; G-55).

## Failures found and repairs
1. Product: see reviews; the Genetics tile semantics bug was found by the web smoke, not by a unit test.
2. Process: the smoke appeared to hang for minutes when the tile could not be found (bounded loops with slow queries); fixed at the cause. The first reviewers hit API limits and were resumed.

## Known limitations
G-52 no saved genome · G-53 no real annotation data (licence review) · G-54 large-file parsing on the web main thread · G-55 file dialog needs a portal on Linux, no drag-and-drop · G-56 other layouts (Living DNA, VCF) · G-57 strand ambiguity of homozygous calls · G-58 notice only before the first file · G-59 search and paging at 700,000 rows · G-60 test-adequacy review incomplete. This feature lists what a file contains; it does not interpret it.

## Next recommended Forge
**U001 — the first-run experience and mouse-only entry** (D-020), then U002 (clickable body and specialties guide from open standards) and U003 (glossary).

# FORGE U001@v0.32 — mouse-only entry and a how-to page, 2026-11-07 — U001_COMPLETE

**Goal** a first-time user enters every measurement with the mouse only and finds a plain guide from Today (D-020). **Baseline** a932ada → 0ce7eca (number pad, time chips), how-to page, gates on the closing source revision.

## What was built
- Number pad in each measurement sheet: closed by default ("Show number pad"), types into the field chosen last (systolic, then diastolic), decimal comma in Turkish, a delete key; nothing is pre-filled, so no value suggests a norm.
- Quick-pick time chips under More details: Now (empties the field), 1 hour ago, this morning 08:00 (disabled until it is past), yesterday 20:00; the typed-time rules still check the value at Save.
- How to use Human OS: six steps naming the real buttons (a test checks every named label exists), EN/TR, reachable from Today's Tools.
- Windows download (U004 groundwork): `.github/workflows/windows-exe.yml` builds on a GitHub Windows runner, makes `Human-OS-Setup.exe` (Inno Setup, `packaging/windows/human_os.iss`) and a portable ZIP, starts the exe for 10 s, and publishes the pre-release `windows-dev`. Run 42400912303 on a5416ea passed: COMPILED, PACKAGED (unsigned), started on Windows. This is CI evidence, not a local receipt; SmartScreen will warn because the build is not signed.

## Tests / Builds / Runtime
`flutter test` 437 PASS (1 skipped) in UTC and 438 in New York; Linux integration 9 PASS; web smoke PASS; Linux release COMPILED and RUNTIME_TESTED under Xvfb; tooling, contracts, pnpm PASS. Mutations on focus tracking, decimal separator, delete key and the Now chip were each caught.

## Known limitations
G-61 the weight card has no number pad yet · no first-run wizard (BRAINSTORM D13) · the Windows build is a development build (unencrypted log under %LOCALAPPDATA%), unsigned, and was only started, not clicked through, on Windows.

## Next recommended Forge
**U002 — clickable body and specialties guide from open standards** (WHO ICD-11 chapters, UEMS specialties), with sources, never verbatim atlas text, never diagnosing.

# FORGE U005@v0.32 — settings: language, theme, colour, text size, 2026-11-07 — U005_COMPLETE

**Goal** the owner asked why the app was not in Turkish (it followed the device language with no switch) and for a changeable look. **Built** a Settings page opened from a top-bar icon on every screen and from Today: language Türkçe / English / device, light / dark / device, five accent colours (no red or amber; each tone tested at 4.5:1 on its surface), text size device / larger / largest; one click each, applied at once; saved in `appearance.json` by development desktop builds (D-023), kept for the session elsewhere (G-62). **Tests** 443 PASS in UTC, 444 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations on the language switch, dark mapping, text factor and the save call were each caught. **Downloads** Windows (`windows-dev`), Linux (`linux-dev`), Android (`android-dev`) and macOS (`macos-dev`) pre-releases are built by GitHub Actions on each platform's own host (CI evidence; not signed; iOS needs an Apple signing identity). **Next** U006 customisable Today.

# FORGE U006@v0.32 — customisable Today, 2026-11-07 — U006_COMPLETE

**Goal** the owner asked for an editable, changeable, user-friendly interface. **Built** Settings → Today screen: a checkbox per measurement tile (show/hide) with Up/Down buttons to reorder (mouse alone, no drag), switches to hide Tools, Your data or About this build (weight and measurements always stay; Settings stays in the top bar), "open the number pad in every measurement", and Reset Today to default (keeps language and look). Today says where to bring tiles back when all are hidden. Saved with the other appearance settings (D-023, G-62). Brainstorm section F lists the next customisations (spacing, start screen, units, date style, high contrast, quick notes). **Tests** 451 PASS in UTC, 452 in New York, Settings at 320 dp 2x in Turkish, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations on ordering, move bounds, section hiding and the pad preference each caught. **Next** U002 body and specialties guide.

# CI repair: Windows tests and runner image, 2026-11-07
`ci.yml` had been red for many runs. Causes, all outside the product code: tests compared paths with `/` while Windows builds them with `\`; Windows checkouts turned fixture line endings into CRLF (now `.gitattributes`: fixtures and contracts `-text`); a test used `/custom` as an absolute path (not absolute on Windows); two storage tests set only the Linux data variable (now each host's variable); `ubuntu-latest` moved to 26.04, where Playwright 1.56 cannot install a browser (TS job pinned to ubuntu-24.04); `vite preview` listened on `localhost` (::1) while Playwright waited on 127.0.0.1 (now `--host 127.0.0.1`). Run 42408840657 on fa9febf: all five jobs green, Windows included.

# FORGE U002@v0.32 — body and specialties guide, 2026-11-07 — U002_COMPLETE

**Goal** the owner asked for a Human-Atlas-like guide and medical specialties. **Built** a "Body and specialties" tool on Today: 13 body systems (grouping after the WHO ICD-11 chapters) as clickable tiles; each opens what the system does, its main parts, the specialties that look after it (28, with UEMS and Türkiye TUS names), what Human OS can record for it, a first-stop line (family medicine; 112 in an emergency) and a not-a-diagnosis note; sources listed on the page (SOURCES.md). All text written for the project; nothing copied from the owner's Drive atlases. **Tests** data integrity, links to existing record kinds, scans for diagnosing, judging and treatment words in EN and TR, every system in Turkish at 320 dp and 2x; 456 PASS in UTC, 457 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** U003 glossary and measurement guide.

# FORGE U003@v0.32 — glossary and measurement guide, 2026-11-07 — U003_COMPLETE

**Built** a searchable Glossary on Today (13 entries: blood pressure, resting heart rate, body temperature, SpO2, respiratory rate, weight, height, waist, reference interval, lab flag, unit, correction, variant/genotype), each with what it is, its unit and numbered home steps paraphrased from published guidance (ESH 2021, WHO HEARTS, WHO waist 2008, FDA pulse oximeters; SOURCES.md); "About this measurement" in every measurement sheet opens its entry. No entry gives a target or a range to aim for (scans in EN and TR). **Tests** 461 PASS in UTC, 462 in New York, every entry in Turkish at 320 dp 2x, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations caught. **Next** U007 more customisation (weight pad, start screen, spacing, high contrast).

# FORGE U007@v0.32 — more ways to make it yours, 2026-11-07 — U007_COMPLETE

**Built** a shared number pad (measurement sheets and now the weight card, G-61 closed), the start screen (Today, Timeline or Labs), comfortable or compact spacing, and stronger contrast (black/white ink, outline text at least 7:1 and edges at least 3:1 on the surface, tested in light and dark). Saved with the other appearance settings; Reset Today keeps them. **Tests** 467 PASS in UTC, 468 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations caught. **Next** U008 your numbers over time (plain charts with gaps shown, no target bands).

# FORGE U008@v0.32 — your numbers over time, 2026-11-07 — U008_COMPLETE

**Built** "See over time" from every measurement sheet and from the weight card: the saved readings as dots, joined only when at most 7 days apart (a longer gap is a break, nothing drawn in between), range chips (30 days, 90 days, 1 year, all), click to read a reading, every reading listed as text, blood pressure as circles (systolic) and squares (diastolic) so the two differ without colour; three plain value lines for reading, no bands, no averages. Pure functions in `domain/trends/trend.dart`; no new dependency. **Tests** 473 PASS in UTC, 474 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. Two first mutation attempts did not apply (indentation) and were redone; the isLive mutation is equivalent (recorded). **Next** U009 export for the doctor.

# FORGE U009@v0.32 — summary for a visit, 2026-11-07 — U009_COMPLETE

**Built** "Summary for a visit" on Today: weight, each measurement kind (newest 20, with "showing n of total") and lab results (newest 40), each value exactly as typed with the time it was measured, the person's note, and the lab's printed range and flag labelled as the lab's; a footer says the person recorded it and Human OS does not interpret or score. "Save as a page to print" writes a self-contained HTML page (inline style, no script, no link, every text escaped) where open files are allowed; encrypted builds show it on screen only (same rule as the JSON export). **Tests** 477 PASS in UTC, 478 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations caught. **Next** U010 your own quick notes.

# FORGE U010@v0.32 — your own quick notes, 2026-11-07 — U010_COMPLETE

**Built** under More details in every measurement sheet, the notes the person typed before come back as one-click chips (newest first, once each ignoring case and spaces, at most 8); a chip fills the note, nothing is saved until Save; no built-in vocabulary. **Tests** 481 PASS in UTC, 482 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations on dedup, order and the chip action caught. **Next** R001: an independent review of U001-U010 before more features (they were single-author slices).

# FORGE R001@v0.32 — independent review of U001-U010, 2026-11-07 — R001_COMPLETE

**Reviews** three Sonnet reviewers (medium) in their own worktrees on b135afd: UI/accessibility, wording/medical/safety, test adequacy. **Fixed** the saved visit summary now says when a section shows only the newest readings; a development build in portable mode keeps settings in memory (nothing beside the program); the trend chart has a minimum axis span per measure (a 0.2 kg change no longer fills the chart), locale decimals and first/last dates; settings tile rows and arrows speak their tile's name; the top-bar button is named Settings; glossary search folds Turkish letters; note chips come only from live entries; the body guide drops loose measurement links; Turkish terms (Kontrast, Petrol yeşili, tanı, TUS/DUS branch names); both download workflows publish one at a time, and the Android note says each build has a new key. Two flaky tests were made robust (a read that outlasted one tick on a loaded machine; a minute boundary). **Kept** lab sample dates as calendar days (a suggestion to show local time would shift the day). **Pending** the test-adequacy reviewer had not reported at close; its survivors become a follow-up. **Gates** 13 on one clean revision: 500 PASS in UTC, 501 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm.

# FORGE G002@v0.32 — compare raw DNA with a dbSNP file, 2026-11-07 — closed on the R001 gate run

**Built** on the Genetics page, "Load a dbSNP Summary file" (ncbi.nlm.nih.gov/snp → Send to → File → Format: Summary): the file is read on the device, variants shared with the raw DNA file are listed by rsID with dbSNP's alleles, consequence, positions and clinical significance as dbSNP states them, and whether the file lists an alternate or only the reference allele (indels and A/T, C/G pairs are not compared). Filters: missense only, only with a clinical label. A note says labels are dbSNP's words about the variant, not about the person; the app makes no prediction where dbSNP gives none (D-024, owner's suggestion declined with reason). A test proves the real 2024 MyHeritage header (##fileformat, ##reference=build37, RSID,CHROMOSOME,POSITION,RESULT) is read.

# FORGE U011@v0.32 — reading fonts, 2026-11-07 — closed on the R001 gate run

**Built** Settings → Font: device, Atkinson Hyperlegible Next (legibility) or OpenDyslexic (dyslexia), bundled under SIL OFL 1.1 with licences beside the files and SHA-256 pinned by a test (D-025; the first Atkinson Hyperlegible lacks İ, so the Next version), plus "more space between letters, words and lines". **Next** G003 plant chemicals offline.

# FORGE G003@v0.32 — plant chemicals offline, 2026-11-08 — G003_COMPLETE

**Built** a "Plant chemicals" tool on Today: load a CSV exported from Dr. Duke's Phytochemical and Ethnobotanical Databases (USDA ARS, phytochem.nal.usda.gov → Download these results as CSV), search any column (Turkish letters folded), every cell shown as the database wrote it, and under each row the dose abbreviations explained (orl, ipr, mus, rat, IC50, LD50, LDlo, TD, ADI, ppm, uM) so animal and cell results are recognisable; a note says most doses are not doses for people and a lab activity is not proof of an effect. XLSX is refused with a request for the CSV (no spreadsheet dependency); rows with another column count are counted, not guessed. Nothing is saved or sent. **Tests** 505 PASS in UTC, 506 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations caught. **Next** T001 test-adequacy follow-up.

# FORGE T001@v0.32 — test-adequacy follow-up, 2026-11-08 — T001_COMPLETE

**Input** the Sonnet test-adequacy reviewer ran 139 mutation probes on 6387399; 99 survived. **Built** direct tests for the dbSNP reader (case, gene brackets, continued keys, wide-space positions, comparison rules) and the plant CSV reader (doubled quotes, quoted line breaks, BOM, one column, header only, short and long rows, header cap, byte limits, whole-word dose terms), and behaviour tests for settings (text factors, 64-character cap, equality, Reset keeps fonts, a failed save then a good save, folder creation, wide spacing values, dark contrast ink, Light on a dark device, start screens), note chips (replace, trim, at most 8) and the plant tool (search box cleared on a new file, Turkish dose words and folding). **Fixed** three defects the new tests found: the plant search box kept the old text after a new file while showing all rows; a line break inside a quoted cell merged two words; wide spacing measured every style as 14 px (headings got too little). Remaining survivors (chart painting rules, range-chip day boundaries, summary caps) are G-63. **Gates** 532 PASS in UTC, 533 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** U012 display units and date style.

# FORGE U012@v0.32 — display units, 2026-11-08 — U012_COMPLETE

**Built** Settings → Units: "kg, cm, °C" or "also show lb, in, °F". With US units, a converted value is shown beside the typed one, marked ≈ ("72.4 kg (≈ 159.6 lb)"), in the measurement tiles, Timeline and trend lists and the weight card; entry and storage stay metric (a note says so); no conversion for mmHg, %, bpm or breaths/min. **Tests** 535 PASS in UTC, 536 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations caught. **Next** U013 time and date style.

# FORGE U013@v0.32 — date and time style, 2026-11-08 — U013_COMPLETE

**Built** Settings → Date and time: shown dates as 2026-11-08, 08.11.2026 or 11/08/2026 and times as 20:05 or 8:05 PM (midnight 12:00 AM, noon 12:00 PM), applied at once everywhere times are shown; typing a time stays YYYY-MM-DD HH:MM (a note says so) and lab sample dates stay calendar days. **Tests** 538 PASS in UTC, 539 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations caught. **Next** T002 chart rules as pure functions with tests (G-63).

# FORGE T002@v0.32 — chart rules as pure functions, 2026-11-08 — T002_COMPLETE

**Built** the trend chart's rules moved into tested pure functions: `axisRange` (minimum span centred on the data, 10% padding), `readingLines`, `axisLabel` (one decimal below 100, local separator), `timePositions` (by time, a single point centred) and `rangeStart`/`rangeDays` (30, 90, 365 days; a point exactly at the start counts). Drawing unchanged; existing trend tests pass. Part of G-63 closed. **Tests** 543 PASS in UTC, 544 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations caught. **Next** U014 a calm first run.

# FORGE U014@v0.32 — a calm first run, 2026-11-08 — U014_COMPLETE

**Built** on the first launch of the real app, three short steps: what Human OS does (no "welcome" fluff, DESIGN 7), that it stays on this device and works offline, and choose language, light/dark and font (applied at once); Next, Back, Skip, Start; remembered as `firstRunDone` with the other display preferences; Settings → "Show the introduction again" reopens it and finishing returns to Settings. Shown only when the app has an appearance store (main.dart), so test launches and encrypted gates are unchanged. **Smokes** the web smoke checks the introduction is offered and skips it with one click, also after each reload (the browser build keeps settings in memory, G-62); the first gate run hung on that and was stopped (receipts 0335–0340 kept as history). The Linux smoke now starts as a returning person (preferences seeded) and checks the vault and the preferences stay unchanged. **Tests** 548 PASS in UTC, 549 in New York, web smoke 89/89, Linux integration and runtime, tooling, contracts, pnpm. **Next** G004 ClinVar file comparison.

# FORGE G004@v0.32 — compare raw DNA with ClinVar, 2026-11-08 — G004_COMPLETE

**Built** on the Genetics page, "Load the ClinVar summary file": ClinVar's variant_summary (about 400 MB; plain text, or .gz unpacked on the fly on desktop and phone builds) is read once as a stream, columns found by header name, keeping only rows whose rsID is in the person's raw DNA file (one row per variant, GRCh37 preferred, rows without an rsID skipped, at most 20,000 matches). Each card shows the genotype, ClinVar's alleles and whether the file lists the alternate allele, ClinVar's label, review status and the conditions submitters named, all as ClinVar's words; chips filter by ClinVar's own labels; a note explains that labels are about submissions for a variant, not the person. Large files stream through `PickedGenomeFile.openRead`; gzip is a native adapter behind a conditional import (dart:io stays confined). **Tests** 556 PASS in UTC, 557 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations caught. **Next** R002 independent review of G002–G004 and U011–U014.

# FORGE R002@v0.32 — independent review of G002–G004 and U011–U014, 2026-11-08 — R002_COMPLETE

**Input** two independent Sonnet reviews (safety and wording; UI, accessibility and tests) of the genetics comparisons, plant chemicals, fonts, units, dates and the first run. **Fixed** "reference only" is said only when every letter of the genotype is the reference allele (a letter neither reference nor listed alternate is now "other allele"); the ClinVar 20,000 cap applies only to "Benign"/"Likely benign" rows, so no other label is dropped; carriers are sorted first with a "only variants my file lists" filter and every ClinVar label gets a chip; review-status and zygosity wording made accurate; alleles shown with strand and assembly; RFC 4180 stray quotes and short rows kept; more dose codes explained; the chosen date style everywhere except the visit summary (ISO 24 h for clinicians); converted values spoken; first-run steps announced to screen readers and the introduction offered only where it can be remembered (not in the browser); a progress bar while ClinVar is read. Remaining findings recorded as G-64..G-67. **Gates** 565 PASS in UTC, 566 in New York, web smoke 89/89, Linux integration and runtime, tooling, contracts, pnpm; the first gate run (0374–0380) stopped on the web smoke and is kept as history. **Next** U015 group the Tools tiles and offer the introduction before the vault gate.

# FORGE U015@v0.32 — grouped tools and the introduction before a new vault, 2026-11-08 — U015_COMPLETE

**Built** Today's tools under three headings announced as headings: "App and visits" (Settings, How to, Visit summary), "Words and the body" (Glossary, Body guide), "Read a file" (Plant chemicals, Genetics) (G-65 closed). In encrypted builds a first start with no vault yet shows the introduction before the passphrase screen; language, theme and font apply at once for the session and nothing is written before the vault exists; an existing vault goes straight to unlock (G-64 closed; choices made there are not yet remembered across starts, G-62). **Tests** 571 PASS in UTC, 572 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; a mutation on the no-vault-yet condition caught. **Next** G005 ClinVar card semantics and allele copies (G-66).

# FORGE G005@v0.32 — ClinVar cards: genotype label and letters, 2026-11-08 — G005_COMPLETE

**Built** each ClinVar card now says "Genotype in your file: CT" and, only when the file lists ClinVar's alternate allele, "Letters showing T: 1 of 2" (2 of 2, or 1 of 1 for one-letter calls on X, Y or MT); strand-ambiguous (A/T, C/G), multi-letter and missing calls get no count. It counts letters and interprets nothing. The card is wrapped in MergeSemantics; the test semantics tree already merged its texts, so that part is not distinguished by a test and a device screen-reader check is NOT_RUN (G-66 closed with that note). **Tests** 575 PASS in UTC, 576 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** G006 ClinVar reading off the UI isolate (G-67).

# FORGE G006@v0.32 — the window keeps drawing while ClinVar is read, 2026-11-08 — G006_COMPLETE

**Built** the ClinVar reader pauses every 20,000 lines with a zero-delay timer and reports the line count there, so frames are drawn and the count moves even when a whole file arrives as one burst of lines (web, and files read at once). No new dependency. The per-line work still runs on the UI isolate and a .gz on the web must still be unpacked first (G-67 partly closed). **Tests** 576 PASS in UTC, 577 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; removing the pause caught. **Next** R003 independent review of U015, G005, G006.

# FORGE R003@v0.32 — independent review of U015, G005, G006, 2026-11-08 — R003_COMPLETE

**Input** one independent Sonnet reviewer; no blocking findings. **Fixed** the introduction before a new vault is offered only with an appearance store that keeps nothing, so the no-write-before-vault promise no longer rests on which store main.dart happens to pick; the Turkish letter count reads "Dosyada T olan harf: 1 (toplam 2)"; `lettersShowing` upper-cases the allele; tests added for a persistent store and an unreadable vault (no introduction, the file untouched) and a no-call card (no count); a doc comment moved back to its widget. **Gates** 579 PASS in UTC, 580 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; removing the store guard caught. **Next** M001 phone builds keep data in the app's private folder.

# FORGE M001@v0.32 — phone builds keep data and display choices, 2026-11-08 — M001_COMPLETE

**Built** Android and iOS builds ask their own native side at start (method channel `org.humanhealthos/paths`: Android `Context.filesDir`, iOS Application Support) and keep `HumanHealthOS/` there, so entries and the language, theme and font choice survive closing the app. Same storage policy as desktop: development keeps the labelled log in that app-private folder, staging and production the encrypted vault with nothing written before it exists; environment variables and portable markers are ignored on a phone; a missing channel leaves memory only, as before. No new dependency (path_provider reviewed and not taken, D-026). **Evidence** 586 PASS in UTC, 587 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; dropping the phone branch caught; the Kotlin and Swift code compiled by the CI Android (APK, app bundle) and iOS jobs; a run on a real phone NOT_RUN. The first gate run (0452–0464) went stale when the new tests were made host-neutral after a Windows CI failure. **Next** U016 display choices inside the vault for vault builds.

# FORGE U016@v0.32 — the app is called Human OS everywhere, 2026-11-08 — U016_COMPLETE

**Built** "Human OS" instead of the template name `human_health_os` on the Android launcher, the Windows title bar and file details (FileDescription, ProductName), and the iOS and macOS bundle names; the executable, package id and download names stay as they were, so installers and data folders do not move; a test pins the names (G-20 closed). Re-prioritised from the recommended slice (display choices inside the vault), because every download is a development build and that slice affects no current user; it is now U017. **Tests** 590 PASS in UTC, 591 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** U017 display choices inside the vault.

# FORGE U017@v0.32 — less motion, 2026-11-08 — U017_COMPLETE

**Built** Settings → "Less motion: pages open without sliding" (saved with the other display choices); with it on, or with the device's remove-animations setting, every page simply appears instead of sliding or zooming (a page-transition builder for every platform); otherwise the platform's usual transition (G-49 part closed). Re-prioritised again over display choices inside the vault, which no current download uses (now U018). **Tests** 595 PASS in UTC, 596 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; mutations ignoring the setting or the device flag caught. **Next** R004 independent review of M001, U016, U017.

# FORGE R004@v0.32 — independent review of M001, U016, U017, 2026-11-08 — R004_COMPLETE

**Input** one independent Sonnet reviewer (it stopped at a usage limit after reporting). **Fixed** two blocking privacy findings: Android backup and device-to-device transfer are off (allowBackup=false, data-extraction and full-backup rules excluding every domain), so the app folder never reaches a Google backup or a new phone; on iOS the app folder is created and marked excluded from iCloud and computer backups, and if that fails no folder is given and the app keeps data in memory. Also: a 5-second timeout on the folder channel; the macOS menu says Human OS; less motion keeps the iOS/macOS swipe-back gesture (a still Cupertino page) and forwards the platform's delegated transition. Recorded G-68 (phone backups and exports cannot be opened or shared). **Gates** 598 PASS in UTC, 599 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; the Cupertino-branch mutation caught; CI green on Android, iOS, macOS, Windows and Linux. **Next** M002 phone backups and exports reachable.

# FORGE M002@v0.32 — phone backups and exports can be copied out, 2026-11-08 — M002_COMPLETE

**Built** on phones a backup, an export or the visit summary is saved inside the app and the message says so plainly, with a "Save a copy where I can find it" button that opens the system save dialog (file_picker's saveFile, already a dependency) so the person can keep it in Downloads, a cloud folder or on a USB drive; the app sends nothing anywhere itself; a cancelled dialog changes nothing; desktop builds keep naming the folder and show no button (G-68 closed). **Tests** 604 PASS in UTC, 605 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; the phone-message mutation caught; the dialog on a real phone NOT_RUN. **Next** U018 display choices inside the vault.

# FORGE U018@v0.32 — vault builds remember display choices, 2026-11-08 — U018_COMPLETE

**Built** staging, production and portable builds keep language, theme, font and the other display choices in `<vault>.prefs` beside the vault, sealed under the vault's data key with their own associated data (D-027); written only once the vault is created or unlocked; choices made in the introduction before a new vault are saved when it is created; the next start applies them right after unlock (the gate itself shows defaults); another vault's, a damaged or an unauthentic file is never used and is left as it is (G-62 closed for vault builds). **Gates** 608 PASS in UTC, 609 in New York, web smoke, Linux integration (now expecting the sealed file beside the vault and checking it holds no readable choice) and runtime, tooling, contracts, pnpm; mutations caught. The first gate run (0530–0537) stopped on that integration expectation and is kept as history. **Next** R005 independent security review of M002 and U018.

# FORGE R005@v0.32 — independent security review of M002 and U018, 2026-11-08 — R005_COMPLETE

**Input** one independent Sonnet security reviewer: no blocking findings (nonce use, associated-data separation between log entries, key wraps and preferences, authenticated-only reads, memory-only and failed-unlock paths, restore and passphrase change all hold). **Fixed** display-preference saves run one after another, so two quick changes never write the same temporary file and the last change is kept; a choice changed while a vault's preferences are being read wins over the file; development builds say that a copied backup, export or summary is not encrypted, at the moment the person chooses where to put it; backup names keep only letters, digits and dashes of the vault id. Recorded R-19 (preferences rollback, stale `.prefs` after set-aside; low). **Gates** 613 PASS in UTC, 614 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; both mutations caught. **Next** U019 Today at large text on a narrow phone.

# FORGE U019@v0.32 — measurement tiles follow the text size, 2026-11-08 — U019_COMPLETE

**Built** measurement tiles choose their columns by the width measured in text of the chosen size (`tileColumns`): with large text on a 320 dp phone one tile per row instead of two squeezed ones, two at normal text, three or four in wide windows (G-49 part). **Tests** 615 PASS in UTC, 616 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; ignoring the text scale caught. **Next** U020 Measurements above the weight card as a Today layout choice.

# FORGE U020@v0.32 — Measurements before the weight card, 2026-11-08 — U020_COMPLETE

**Built** Settings → Today → "Measurements before the weight card" ("Ölçümler kilo kartından önce"): Today shows the measurement tiles first; saved with the other display choices; Reset Today clears it (G-49 part; first wording "above" reworded after the judging-word scan). **Tests** 618 PASS in UTC, 619 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; a mutation ignoring the choice caught. **Next** U021 Today's text styles.

# FORGE U021@v0.32 — Today's four type sizes, 2026-11-08 — U021_COMPLETE

**Built** Today, the weight card, the measurement tiles and the Your data card use the four sizes of docs/DESIGN.md: page title, section title, value (one size for every reading, the largest on a tile) and body (captions and labels included); status chips keep their own label size. A test reads the rendered text sizes on Today with readings recorded (G-49 closed with U017, U019, U020). **Tests** 619 PASS in UTC, 620 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; the old weight card caught. **Next** R006 independent review of U019–U021.

# FORGE R006@v0.32 — independent review of U019, U020, U021, 2026-11-08 — R006_COMPLETE

**Input** one independent Sonnet UI and accessibility reviewer: no blocking findings; no overflow anywhere on Today across 320, 360 and 480 dp, system text 1.0, 1.6 and 2.0 and the largest in-app size, in Turkish, with a blood pressure recorded; the in-app text size reaches the tile columns; order of focus and screen reader follows Measurements-first. **Fixed** tool group headings keep a weight cue (semibold); the Today tests record a blood pressure (no overflow at 320 dp 1x and 360 dp 1.3x; a filled tile value at the value size). Recorded G-69: UniProt, an owner request, is not built yet. **Gates** 620 PASS in UTC, 621 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** G007 UniProt offline.

# FORGE G007@v0.32 — UniProt offline, 2026-11-08 — G007_COMPLETE

**Built** on the Genetics page, "Load a UniProt TSV file": a TSV exported from uniprot.org (Download → Format: TSV, with Gene Names, Protein names and Function [CC]) is read on the device, columns by name; each protein card shows the gene, accession, reviewed status, protein names and function as UniProt wrote them, with UniProt and CC BY 4.0 named and a note that the words are about the protein, not the person. Proteins of genes named by the loaded dbSNP and ClinVar files come first; a search finds others; XLSX and other files are refused with a reason; at most 50,000 entries kept (D-028, G-69 closed). **Tests** 627 PASS in UTC, 628 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; ignoring the comparison genes caught. **Next** R007 review of G007.

# FORGE U022@v0.32 — owner's accessibility and discovery preferences, 2026-11-09 — SPECIFIED

Owner-directed continuation from 59c660a; the uploaded v0.27/v0.29 planning documents are older than the verified v0.32 repository and do not replace it. Repository id 1407814610 now resolves to kaansavukduran/human-os (rename verified). No local changes existed. R007 remains pending, not claimed complete.

**Scope and acceptance:** AC-1: independent whole-interface scale 80–200%, 5-point slider, 80/100/125/150/175/200 presets, exact integer input (135 accepted), reset only scale, immediately applied and persisted through existing stores. At narrow widths keep the selected scale and provide horizontal scrolling with a minimum usable layout width; keyboard and device text scaling continue to work. AC-2: EN/TR accessible labels, visible persistence scope near the top, unsupported device language defaults to Turkish; preserve themes, contrast, bundled fonts, text-only sizing and layout. AC-3: optional, silent discovery checklist based only on actually opening Settings, a glossary entry and the usage guide. A set deduplicates visits; disabled discovery stops recording visits and never blocks health features. No clinical values, streaks, sound or animation are rewarded. AC-4: additive preference fields only, old settings still open, Today reset preserves new settings, vault encryption/no-write-before-unlock policy unchanged. AC-5: publishing workflows retain prior releases and tags; repeatable checks, web build and runtime smoke, native CI results recorded separately. No package, signing, device install or updater claim without execution.

**Validation plan:** preference compatibility and reset, exact-scale validation, actual rendered geometry and narrow/200%/keyboard tests, milestone idempotency and disable, sealed preference regression, full Flutter analysis/tests, evidence tooling and state validator, offline web smoke; run existing cross-platform CI after push. No new dependency. Historical missing v0.26 baseline remains missing. Full signed distribution and two-version updater validation are outside this candidate's demonstrated state.

## U022 closure, 2026-11-09T11:49:22Z — U022_COMPLETE

Source **5ef84d30079876c7c7f9f823bac1594000fb71e1**, branch **codex/forge-u022-accessibility**, repository **kaansavukduran/human-os**, baseline 59c660a. New 80–200% whole-interface scale applies to text, buttons, icons and spacing together, has 24 slider intervals, exact integer entry (135/133 accepted), six presets and a scale-only reset. A narrow view pans horizontally without reducing the chosen scale. Device and independent text-only scaling remain; Navigator route and an unsaved weight draft survive scale changes. Settings shows device scope and save status near the top; unsupported device languages use Turkish. Discovery counts three explicitly opened tools once, can be disabled, preserves progress and leaves health entry working. No health/vault schema changed, no dependency added. Existing preferences and encrypted-vault regressions pass. Archived older attachments remain reference material, not a replacement for verified v0.32. AGENTS.md records the owner's continuing requirements. Publishing retains all historical releases/tags; no release or installer was published in this Forge.

**Executed gates on a clean source tree:** 637 Flutter tests PASS with 1 existing skip; analyze no issues; full Dart format 0 changed; web release build COMPILED; appearance browser smoke 24 checks PASS in EN, TR and unsupported-language fallback, including physical mouse/keyboard interactions and rendered scale geometry; normal web regression PASS; state/evidence tooling 16 PASS; independent contracts and TypeScript tests PASS. Receipts: EV-TEST-U022-0010, EV-BUILD-U022-0011, EV-RUNTIME-U022-0012, EV-TEST-U022-0013, EV-TEST-U022-0014, EV-TEST-U022-0015, EV-TEST-U022-0016, EV-TEST-U022-0017, EV-RUNTIME-U022-0018. Runtime images and reports: reports/runtime/u022-final and reports/runtime/u022-regression. The initial restore/status tests assumed all cards remained in a lazy-list cache; they now scroll to the real controls and still verify the write guard after restore. An outer horizontal viewport preserves route-level semantics and focus reveal. No independent reviewer or mutation review is claimed.

**Limits:** native host compile CI follows the push; native installation, signing, notarization, iPhone distribution and trusted in-app updating are not established by this web run. Web preferences remain session-only. The exact v0.26 baseline is still absent; CANDIDATE_UNMERGED remains. Drive destination parent and private visibility were verified, but upload was rejected twice by automatic review (ownership/specific transfer authorization); source ZIP and Git bundle will be prepared, with upload pending explicit confirmation. **Next Forge: R007**, the pending G007 UniProt safety/wording review.

# FORGE R007@v0.32 — G007 review and take-over of Codex U022, 2026-11-10 — R007_COMPLETE

**Input** Codex closed U022 (whole-interface scale 80–200%, optional discovery steps, Turkish when the device language is neither Turkish nor English) on `codex/forge-u022-accessibility`; taken over by fast-forward after a local check (format, analyze, 637 tests). The Sonnet reviewer of G007 stopped at a usage limit, so the lead reviewed. **Fixed** the UniProt gene index and folded search text are built once per file (no re-folding of 20,000 entries per keystroke); download builds are named `0.1.0-dev.<run number>` instead of the fixed `0.1.0-u022`, each with its own pre-release; the Linux integration tests start in English explicitly (they had never run against U022's Turkish default; the first gate run 0634–0641 stopped there and is kept as history). G-70: the live UniProt header was not checked (rest.uniprot.org is blocked here; NOT_RUN). **Gates** 637 PASS in UTC, 638 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** U023 Settings last in the navigation; Updates and About.

# FORGE U023@v0.32 — Settings at the end of the navigation; Updates and about, 2026-11-10 — U023_COMPLETE

**Built** following the owner's app rules (k44 §6, §10): Settings is the last item of the desktop rail and of the phone's "More" sheet, each with a visible "Settings" label (the top-bar shortcut stays); Settings ends with "Updates and about": the installed version and source revision, the releases page to compare against, and a reminder to back up first. The app makes no network calls, so it says it cannot look for updates by itself; an in-app check needs an owner decision (G-71). **Tests** 641 PASS in UTC, 642 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** A001 Aion.

# FORGE A001@v0.32 — Aion, 2026-11-10 — A001_COMPLETE

**Built** Aion, the owner's Human OS character, taken from the owner's main reference in Drive (`Aion_Ana_Karakter_Referansi.png`: pink axolotl, blue-tipped gills, blue eyes, white lab coat with the emblem, DNA tail), cropped and bundled as a 473×480 still picture; shown on the first introduction step and beside the empty weight card, labelled for screen readers ("Aion, the Human OS character, waving"); it says nothing and gives no advice; Settings → "Show Aion" hides it everywhere (saved; Reset Today keeps it) (D-029). The Drive four-move sheet draws the gills fully pink, unlike the current reference, so no animation was made from it. **Tests** 646 PASS in UTC, 647 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** R008 review of U023 and A001.

# FORGE R008@v0.32 — independent review of U023 and A001, 2026-11-10 — R008_COMPLETE

**Input** one independent Sonnet UI, accessibility and wording reviewer: no blocking findings; no overflow at 320 dp, 200% scale, in English and Turkish; the rail Settings item is a focusable, labelled button. **Fixed** one way to open Settings for the top bar, rail and More sheet; Settings shows the running build's version (services), not compile-time values; softer update wording (the app does not look by itself and sends nothing); Aion decoded at its drawn size; the empty weight card drops Aion when narrow in text of the chosen size (the whole-interface scale keeps a 320 dp layout and scrolls); tests for rail semantics, the version value and narrow layouts. **Gates** 647 PASS in UTC, 648 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; the narrow-card mutation caught. **Next** F008 medications and supplements.

# FORGE F008@v0.32 — medicines and supplements, slice 1, 2026-11-10 — F008_COMPLETE

**Built** record schema 6 with three separate kinds: the product (`medication.item`: name, medicine/supplement/other, ingredients, strength and form as typed), the plan (`medication.plan`: schedule in the person's own words, prescribed/own choice/unknown) and each recorded dose (`medication.intake`: taken or skipped, amount as typed, time). A plan never becomes a dose and a dose is never inferred from a plan; changes are new versions. The Medications screen is in the primary navigation; the Timeline shows each in words. The app holds no drug database, no dose rules and no interaction check, and says nothing about a product (D-030). **Gates** 653 PASS in UTC, 654 in New York, web smoke, Linux integration and runtime on the schema-5 fixture, tooling, contracts, pnpm. **Next** R009 independent review of F008; F008-S2 (pause, stop, resume a plan) is prepared.

# FORGE R009@v0.32 — independent review of F008; pause, stop and resume a plan, 2026-11-10 — R009_COMPLETE

**Input** one independent Sonnet reviewer: no blocking findings. **Built** F008 slice 2: a plan can be paused, stopped and resumed; each change is a new plan record and a plan written before has no state and reads as active. **Fixed** a refused change (a double tap on an older view, an item gone) is said in words and only one change runs at a time; the shown plan on equal save times is the one written later, by write order (the first gate run 0712–0715 stopped on this flaky choice and is kept as history); a new wording keeps a paused or stopped plan; the Timeline names a non-active state; "active" instead of "followed" (a plan is not adherence); labelled choice groups, the bottom safe area, a line for earlier doses; Turkish wording. The Turkish date hint YYYY-AA-GG stays (the app's convention). **Gates** 658 PASS in UTC, 659 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm; state round-trip and tie-break mutations caught. **Next** F007-S3 sleep.

# FORGE F007-S3@v0.32 — sleep, 2026-11-10 — F007-S3_COMPLETE

**Built** record schema 7 `sleep.night`: when the person went to bed and when they woke up, and, if said, how waking felt (rested, so-so, tired). The Sleep card on Today shows the last nights with the time in bed between the two times, never called sleep and never scored (D-031). A going-to-bed time without a date is the last such time before waking (23:10 then 07:00 is one night); a blank waking time is now; waking comes after going to bed and less than 24 hours later; each error names its field; clock changes come from the zone the service is given. **Review** one independent Sonnet reviewer before the gates: no blocking findings; field-named errors, the under-24-hours rule, clock-change tests, save-failure handling, sheet insets and safe area, short labels with help text and a line that reads well aloud were fixed; a typed correction was recorded as G-72. **Gates** 668 PASS in UTC, 669 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** G008 typed correction of a night (prepared).

# FORGE G008@v0.32 — correct a sleep night, 2026-11-11 — G008_COMPLETE

**Built** Correct on each night of the Sleep card: the sheet opens with the night's typed times and feeling; saving appends a correction of the shown night and the earlier version stays in history; an older version or another kind's record is refused (G-72, typed correction). **Gates** 669 PASS in UTC, 670 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** F007-S4 how you feel (prepared), with Sleep as a hideable Today section.

# FORGE F007-S4@v0.32 — how you feel, 2026-11-11 — F007-S4_COMPLETE

**Built** record schema 8 `self.feeling_check_in`: energy, mood and stress, each optional, in the person's own words per question (drained/steady/lively, down/even/bright, calm/tense/overwhelmed; Turkish bitkin/dengeli/dinç, keyifsiz/idare eder/keyifli, sakin/gergin/çok gergin); a level not picked stays not given; nothing is scored, summed, trended or advised (D-032). A compact card on Today opens a sheet; Sleep and How you feel are Today sections that Settings can hide (G-72 closed). **Review** one Sonnet reviewer before the gates: no blocking findings; clinical-sounding Turkish words replaced, each chip read with its question, a stale error cleared, consistent format errors, tests for the whole word table, the Timeline line and saved hidden sections. The type-size test now counts supplementary private-use glyphs as icons. **Gates** 679 PASS in UTC, 680 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** F007-S5 nutrition.

# FORGE F007-S5@v0.32 — nutrition, 2026-11-11 — F007-S5_COMPLETE

**Built** record schema 9 `nutrition.food_entry`: what was eaten or drunk and how much, as typed, and optional values copied from a label (energy in kcal or kJ as printed, never converted; protein, carbohydrate, fat, fibre and salt in grams). A label value needs what it is per (100 g, 100 ml, serving, pack, or not stated): the label's numbers are never shown as the amount eaten and never scaled. A blank nutrient is missing, a printed zero stays zero; no food database, no totals, no judgement (D-033). The Nutrition screen is built; the secondary navigation group is now "More areas". **Review** one Sonnet reviewer before the gates found one blocking honesty issue (label values could read as the amount eaten), fixed with the required basis; kJ, units in field labels, number limits and more tests added; focus moving to the field in error is recorded as G-73. A test that wrote a fixed "newer" schema number now uses the current one plus one. **Gates** 688 PASS in UTC, 689 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** G009 correct a food entry (prepared).

# FORGE G009@v0.32 — correct a food entry, 2026-11-11 — G009_COMPLETE

**Built** Correct on each entry of the Nutrition screen: the sheet opens with what was typed (amount, label values and their basis, time); saving appends a correction of the shown entry and the earlier version stays; an older version or another kind's record is refused (G-73, typed correction). The first gate run (0790–0795) was cut off by a container restart and is kept as history. **Gates** 689 PASS in UTC, 690 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** F007-S6 activity (prepared and reviewed).

# FORGE F007-S6@v0.32 — activity, 2026-11-11 — F007-S6_COMPLETE

**Built** record schema 10 `activity.entry`: what it was as typed and optionally minutes (1–1440) and steps (1–200000) as whole numbers; one not given is missing, never zero; nothing is estimated (no calories), added up or merged with device data (D-034). The Activity screen is built, with Correct on each entry. **Review** one Sonnet reviewer before the gates: no blocking findings; stored whole numbers read robustly (an integral 20.0 reads as 20, 20.5 is a format error), a correction without a typed time keeps the entry's own time (activity and food), one error per field cleared on edit, digits-only number fields. All F007 daily domains now have a first slice. **Gates** 694 PASS in UTC, 695 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** R010 cross-domain review (Turkish, mouse use, narrow and large text).

# FORGE R010@v0.32 — cross-domain review of the daily domains, 2026-11-11 — R010_COMPLETE

**Input** one independent Sonnet UX reviewer, with a runtime probe at 320 dp, 200% scale, in Turkish: no overflow and no English on Today's Sleep and How you feel cards and sheets (Nutrition, Activity and Medications were reviewed by reading); no blocking findings. **Fixed** every sheet (sleep, how you feel, food, activity, medications) has a visible Cancel beside Save; a how-you-feel check-in can be corrected from the card (its time kept); stopping a medication plan asks once more; Correct sits under the entry text on Nutrition and Activity so a narrow window never squeezes it; the device capability texts are all in Turkish when the app is (a test checks every text) and no longer call the finished F005/F006 "planned". Pinned sheet buttons, Today jump links or section order, and quick time picks are recorded as G-74. **Gates** 698 PASS in UTC, 699 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** U025 usability follow-ups (G-74).

# FORGE U025@v0.32 — sheet buttons in view, quick time picks, 2026-11-11 — U025_COMPLETE

**Built** for mouse-only use (G-74 from R010): every form sheet (sleep, how you feel, food, activity, medicines) now scrolls its fields while Save and Cancel stay in view at the bottom, on a short window or with large text; the keyboard, when open, lifts the sheet, otherwise the system's bottom area is kept clear. Quick picks fill the time fields by click: going to bed 22:00/23:00/00:00 and waking now/06:00/07:00/08:00; now, an hour ago, this morning 08:00 and yesterday 20:00 for food, activity and doses. The sheets share one frame and one time helper. Today jump links and section order remain in G-74. **Gates** 701 PASS in UTC, 702 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** U026 Today jump links and section order.

# FORGE U026@v0.32 — check-ins at the top of Today, 2026-11-11 — U026_COMPLETE

**Built** a Settings choice, "Sleep and How you feel at the top of Today", that places the two check-in cards right under the date, before the weight and measurement cards (R010 finding: at 200% text they sat far down the page). Saved with the other Today choices; Reset Today clears it. **Gates** 703 PASS in UTC, 704 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** F009 conditions, slice 1.

# FORGE F009@v0.32 — conditions and symptoms, slice 1, 2026-11-11 — F009_COMPLETE

**Built** record schema 11 `condition.entry`: a condition or symptom as the person names it, whether it is current, in the past or not sure, where it comes from (my own account, what a clinician told me, a document I was given) and, optionally, since when as typed. The record state stays "reported" whatever the source; the app confirms, codes, infers and suggests nothing (D-035). The Conditions screen is built, with Correct on each entry. **Review** one Sonnet reviewer before the gates: no blocking findings; the sheet now starts at "not sure" instead of choosing "current" for the person, a stored "since" that is not text is a format error, the Turkish label reads "Durumu: sürüyor", the stored key is `nature`, and tests cover the source chips, the Turkish line, a blank "since" and a wrong-kind correction. **Gates** 710 PASS in UTC, 711 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** R011 compatibility review of record schemas 7–11.

# FORGE R011@v0.32 — compatibility of record schemas 7–11; focus on the field in error, 2026-11-11 — R011_COMPLETE

**Built** by two Opus implementers in separate worktrees, orchestrated and read by the lead. (1) Ten compatibility tests on a real file-backed store: one record of every kind reopens identically with unchanged bytes; each kind is written at exactly its own schema (weight and lab stay at 3); a backup restores the same records and its manifest lists schemas 3–11; the schema-5 fixture still opens and its old records stay byte-identical after new kinds are appended; a store from a newer app is refused whole and left untouched; the checkpoint backup fires once per schema step and a failed checkpoint refuses the write. No product bug found. (2) After a refused save, focus moves to the field the error is about and it scrolls into view (sleep, food, activity and condition sheets; G-73 closed). **Limits** restore of an encrypted backup across the new schemas is not covered by these tests; with no parser hook for a lower maximum schema, refusal is tested one step higher. **Gates** 724 PASS in UTC, 725 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** F009-S2 preventive (implemented, to gate).

# FORGE F009-S2@v0.32 — preventive items, 2026-11-11 — F009-S2_COMPLETE

**Built** by an Opus implementer in a worktree, read by the lead: record schema 12 `preventive.entry`: a vaccination, screening, check-up or other item as the person names it, with done, planned or not sure (the sheet starts at not sure), when as typed, and who it comes from. Planned never reads as done; a screening is kept without its result; the app recommends nothing, keeps no schedule and sends no reminders; the record state stays reported (D-036). The Preventive screen is built with Correct on each entry; the compatibility tests now cover every kind through schema 12. **Gates** 733 PASS in UTC, 734 in New York, web smoke, Linux integration and runtime, tooling, contracts, pnpm. **Next** U028 complete Turkish and the web smoke for the new areas.

# FORGE U028@v0.32 — complete Turkish; web smoke for the new areas, 2026-11-11 — U028_COMPLETE

**Input** a read-only Turkish audit by an Opus reviewer: coverage was close to complete (722 string pairs, none empty), with five must-fix items. **Built** by two Opus implementers in worktrees, merged by the lead. Turkish: build profile names (GELİŞTİRME/TEST/YAYIN) instead of the raw enum; Turkish banners; the 12-hour clock shows ÖÖ/ÖS when the app is Turkish (the pure domain keeps AM/PM by default; typed input stays 24-hour); failure messages carry the error type on a separate "Technical detail" line instead of inside the sentence; planned areas say "Planned for a later version" with no Forge ids, in both languages; the encrypted-backup-needs-its-key error has its own sentence; more natural wording across settings, genetics and status texts. Web smoke (T003): 129 checks (89 before) now cover Medications, Nutrition, Activity, Conditions, Preventive and Today's Sleep and How you feel cards in desktop English, phone English and phone Turkish, including adding an activity and a condition. Docs point CHROME_EXECUTABLE at the stable link. **Gates** 740 PASS in UTC, 741 in New York, web smoke 129 checks, Linux integration and runtime, tooling, contracts, pnpm. **Next** F011-S1 engines in Dart (implemented, to gate).

# FORGE F011-S1@v0.32 — first deterministic engines in Dart, 2026-11-11 — F011-S1_COMPLETE

**Built** by an Opus implementer in a worktree: three engines in pure Dart under `lib/src/domain/engines/` that pass their golden vectors exactly: core derived (MP-CORE-DERIVED-1 1.0.0, 19 vectors), nutrition math (NUTRITION-MATH-1 0.20.0, 5) and lab interpretation (LAB-INTERPRETATION-ENGINE-1 0.24.0, 19): 43 of 73. Every result carries its rule or model id and version, its inputs, the inputs that were missing and its limitations; where the TypeScript reference would throw on a missing list, Dart refuses with MISSING_INPUT. The test lists the two vector files not yet ported (medication safety 10, preventive 20) and fails if a new vector file appears unlisted; a changed MAD constant fails two vectors (D-037). **Limits** domain only: no screen uses the engines yet; not yet independently reviewed (R012 in progress). **Gates** 793 PASS in UTC, 794 in New York, web smoke 129 checks, Linux integration and runtime, tooling, contracts, pnpm. **Next** F011-S2 remaining engines and the R012 review.

# FORGE R012@v0.32 — review of the preventive slice and the Dart engines, 2026-11-12 — R012_COMPLETE

**Input** one independent Opus reviewer, read-only (two usage-limit interruptions; the nutrition-math body and full lab-engine body were not read). **Blocking, preventive:** turning a planned item into done was possible only through Correct, which saved a correction dated when the plan was typed and implied the plan was an error (planned ≠ completed). **Fixed** a correction never turns planned into done (PLANNED_NOT_DONE on the status; carrying out a plan is a new entry); the type starts at "other" so nothing is chosen for the person; storage failures are said in words; a time reads "planned for" on a planned item and "done" on a done item; clearer Turkish; tests for field-named errors, bad stored values and an allowed not-sure-to-done correction; the guard's mutation fails two tests. **Blocking, engines** (rolling statistics with min_count 0 or an empty list; non-finite results returned as OK; the caller's input map kept by reference; vector tests skipping unknown keys) were handed to F011-S2 and land with it. **Gates** 794 PASS in UTC, 795 in New York, web smoke 129 checks, Linux integration and runtime, tooling, contracts, pnpm. **Next** F011-S2 (implemented, to gate).

# FORGE F011-S2@v0.32 — all golden vectors in Dart; engine hardening, 2026-11-12 — F011-S2_COMPLETE

**Built** by an Opus implementer in a worktree: medication safety (10 vectors; every finding says it guarantees nothing; the reference's limitations carried word for word) and preventive (20 vectors) engines in pure Dart, so all 73 golden vectors now pass in Dart. From the R012 review: rolling mean and median refuse an empty or all-missing list and a minimum count that is not a whole number of at least 1 (INVALID_MIN_COUNT); every engine refuses a non-finite result (NON_FINITE_RESULT); a result keeps an unmodifiable copy of its inputs; the vector test asserts every expected key and fails on an unknown one. Mutations of a unit factor and of the day length fail vectors (D-038). The TypeScript reference and the Python verifier still had the same holes (G-75, next). **Limits** domain only: no screen uses the engines yet. **Gates** 857 PASS in UTC, 858 in New York, web smoke 129 checks, Linux integration and runtime, tooling, contracts, pnpm. **Next** G010: G-75 in TypeScript and Python (implemented, to gate).

# FORGE G010@v0.32 — TypeScript and Python match the Dart engines, 2026-11-12 — G010_COMPLETE

**Built** by an Opus implementer in a worktree (G-75 closed): the TypeScript reference refuses the same inputs as the Dart engines (non-finite results; a minimum count that is not a whole number of at least 1; empty or all-missing windows; missing lists), keeps a frozen copy of each result's inputs, and has 40 new hardening tests; the Python verifier now ports all five engines with the same refusals, checks every expected key and runs all 73 vectors (41 before: medication safety, preventive and two recipe vectors had never run). No golden vector changed. **Gates** 857 PASS in UTC, 858 in New York, web smoke 129 checks, Linux integration and runtime, tooling, contracts (73 of 73 vectors), pnpm (domain 113). **Next** U029 derived values in the app.

# FORGE U029@v0.32 — derived values from the person's records, 2026-11-12 — U029_COMPLETE

**Built** by an Opus implementer in a worktree: the first use of the engines in the app. A tile in Today's tools opens "Worked out from your records": body mass index and waist-to-height ratio (MP-CORE-DERIVED-1 1.0.0) from the newest live measured weight, height and waist, each shown as "worked out, not measured" with the model id and version, the records used with their typed values and dates, the gap between their dates, and the engine's limitations; a missing input reads "needs: height", never a number; no category, band, colour or advice (D-039). **Review** an independent Opus review after the gates found that a conflict between a measured and a not-measured version was settled silently; fixed next in R013. **Gates** 866 PASS in UTC, 867 in New York, web smoke 129 checks, Linux integration and runtime, tooling, contracts, pnpm. **Next** R013 review fixes.

# FORGE R013@v0.32 — review of the derived values, 2026-11-12 — R013_COMPLETE

**Input** an independent read-only Opus review of U029. **Blocking:** when the newest weight, height or waist had two live versions and one of them was "not measured", the measured one was used silently, settling a conflict the person must settle. **Fixed** a conflict is never settled, whatever its versions hold; a failed read of the records is said in words instead of a spinner forever; Turkish "Vücut kitle indeksi (VKİ)" and "eksik: …"; a refused formula names its code as "(kod: …)"; "measured N days apart". Tests: the measured-versus-not-measured conflict, a withdrawn newest height falling back to the earlier one, the waist-to-height ratio 0.50 with two decimals and its spoken label; the guard's mutation fails a test. **Gates** 869 PASS in UTC, 870 in New York, web smoke 129 checks, Linux integration and runtime, tooling, contracts, pnpm. **Next** F010-S1 document references (implemented, to gate).

# FORGE F010-S1@v0.32 — document references, 2026-11-12 — F010-S1_COMPLETE

**Built** by an Opus implementer in a worktree: record schema 13 `document.reference`: a health document the person keeps, as typed (title, kind, the document's own date, who issued it, where it is kept); the app never reads, opens, uploads or stores the document, and the document's date stays text, never the record's time. The kind starts at "other"; corrections keep the entry's time. A new Documents area in "More areas" (D-040). The compatibility tests cover every kind through schema 13 and refuse a schema-14 record. Evidence ids passed 999 in this run and read 01000–01010 (valid ids; four-digit numbering continues). **Review** an independent Opus review after the gates: no blocking findings; five should-fix items go to R014. **Gates** 878 PASS in UTC, 879 in New York, web smoke 129 checks, Linux integration and runtime, tooling, contracts, pnpm. **Next** R014 review fixes.
