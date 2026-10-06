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
