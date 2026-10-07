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
