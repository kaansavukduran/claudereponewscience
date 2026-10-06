# Decisions

## ADR-IMPL-002: Flutter for the five product surfaces; TypeScript kept as reference oracle and Build Lab (2026-10-06, ACCEPTED)

**Context.** The user's master prompt and the v0.24/v0.27 handoffs prefer one Flutter/Dart client for Android, iOS, Web/PWA, Windows (portable and installer) and macOS. ADR-IMPL-001 chose TypeScript only because Flutter was not installed at the time. That decision was never accepted by the user. Flutter 3.47.6 can now be installed in this container (storage.googleapis.com and pub.dev are reachable).

**Decision.**
1. `human_health_os/` (Flutter, created with `flutter create --empty --platforms=android,ios,web,windows,macos,linux`) is the product for all five surfaces.
2. The domain core is pure Dart in `lib/src/domain`, ported engine by engine. Each engine must pass the same `contracts/golden_vectors`.
3. `packages/domain` (TS) remains the reference oracle (differential testing). `apps/site` remains the **Build Lab** (synthetic, separate). `services/api` remains the reference for sync semantics. `apps/client` is frozen and retired at parity.

**Alternatives considered.** (a) TypeScript everywhere (Capacitor + Tauri/Electron). It keeps one runtime core, but it goes against the explicit Flutter preference and the Windows-portable expectations, and it adds a third desktop runtime. (b) Flutter for everything, rebuilding the Build Lab now. That throws away a tested, working Lab and its cross-language parity checks for no user value.

**Consequences.** There are two implementations of each engine, held together only by vectors. Composites, compare and missions need numeric vectors **before** they are ported (gap G-07). Reversible: no code is deleted.

## D-003: First FORGE is the shell (v0.27 doc 209); persistence heartbeat is FORGE 002

The master prompt §32 describes the first vertical slice as including persistence. The v0.27 candidate says "stop at a working shell before persistence". Both are satisfied in order: F001 shell, then F002 heartbeat. Rationale: prove the compile and runtime gate first, so persistence failures are not confused with toolchain failures.

## D-004: Location and naming

The Flutter project lives at `human_health_os/` (the name in the v0.27 command). The Dart package is `human_health_os` and the org is `org.humanhealthos`. Repo-local milestones use `R<n>`. The user's handoff versions (`v0.x`) are never reused for repo-local work, which avoids collisions like the earlier "v0.25" label.

## D-005: Canonical term "Shortevity"

v0.24 uses "Shortevity". "Shortgevity" appears in the newest prose and is treated as an alias.

## D-006: Commits and pushes

The environment workflow requires commits and pushes to `claude/code-capabilities-kz21fr`. Pushes currently fail with 403 (no GitHub access for Claude). Commits are kept locally and in a git bundle until access is granted.

## D-007: Dependency policy

Flutter app: use the SDK first (`flutter`, `flutter_localizations`, `flutter_test`, `flutter_lints`). Each third-party package needs a recorded entry here before it is added. The entry covers purpose, license, maintenance (recent releases, open security issues), platform coverage (android/ios/web/windows/macos/linux), native code, privacy impact, and why the SDK cannot do the job. Commit `pubspec.lock`. CI uses `flutter pub get --enforce-lockfile`. Updates follow lockfile diff → review → analyze/test → platform smoke. No git or path dependencies in release builds. TypeScript side: the same rules apply with `pnpm-lock.yaml` and `--frozen-lockfile`.

Current third-party runtime packages in the Flutter app: **none** (FORGE 001). Root dev dependency `@playwright/test@1.56.1` (Apache-2.0) is used for the Build Lab and Flutter web smoke tests, and is pinned to the version of the preinstalled Chromium.
