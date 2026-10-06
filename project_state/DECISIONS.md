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

Flutter app packages (FORGE 002, from `flutter pub deps --no-dev`): **no direct third-party runtime package**. Direct runtime dependencies are SDK packages (`flutter`, `flutter_localizations`). Their transitive runtime packages are pinned by the Flutter SDK and fetched from pub.dev: characters 1.4.1, clock 1.1.3, collection 1.19.1, intl 0.20.3, material_color_utilities 0.13.0, meta 1.18.3, path 1.9.1, vector_math 2.4.0 (all Dart-team packages, BSD-3-Clause). `flutter_lints` 6.0.0 is a hosted **dev** dependency. `integration_test` is an SDK dev dependency. An SBOM is still NOT_GENERATED. Root dev dependency `@playwright/test@1.56.1` (Apache-2.0) is used for the Build Lab and Flutter web smoke tests, and is pinned to the version of the preinstalled Chromium.

## D-008: Linux is a first-class product surface (user instruction, 2026-10-06)

The user added: "Linux version too: it must work on Nobara/Fedora derivatives and on Ubuntu/Debian derivatives." Linux is therefore the **sixth primary surface**, not a CI-only smoke target. It uses the same Flutter app, the same vault rules (XDG data dir, or `UserData/` in portable mode) and the same honesty rules.

- **Compatibility floor:** the bundle built in FORGE 001 requires at most `GLIBC_2.34` (checked with `objdump -T`), plus GTK 3, libepoxy and libstdc++. That covers Fedora ≥ 35 / Nobara, Ubuntu ≥ 22.04, Debian ≥ 12 and their derivatives. Debian 11 and Ubuntu 20.04 (glibc 2.31) are **not** covered unless release builds move to an older-glibc builder. Release builds should run on the oldest supported base (Ubuntu 22.04 runner) so the floor does not drift upward.
- **Distribution formats** (each verified independently on real distros before it counts as PASS):
  1. Portable `HumanHealthOS-Linux-x64-Portable.tar.gz`: bundle + `portable_mode.json` + `UserData/` (the Rufus-like experience).
  2. AppImage: one-file portable that runs across distros.
  3. `.deb` for Ubuntu/Debian.
  4. `.rpm` for Fedora/Nobara.
  5. Flatpak (Flathub-ready manifest), which suits Fedora/Nobara users.
- **Testing:** the build-and-launch smoke runs here on Ubuntu 24.04. Fedora/Nobara and Debian launch tests need containers or VMs (`fedora:latest`, `debian:12`, `ubuntu:22.04`) in CI. They stay NOT_RUN until executed.

## D-009: Linux distribution layer aligned with the v0.28 candidate report (2026-10-06)

The user shared the v0.28 Forge report. Its Linux design is adopted on top of D-008:

- **Channels:** Flatpak is the primary cross-distro install channel. The AppImage `HumanHealthOS-x86_64.AppImage` is the Rufus-like portable option. Because of AppImage's FUSE dependency it is never the only channel; `--appimage-extract-and-run` is the documented fallback. The portable fallback `HumanHealthOS-Linux-x86_64-Portable.tar.zst` carries the real Flutter `bundle/`. Native packages: `human-health-os_<version>_amd64.deb` (Ubuntu/Debian) and `human-health-os-<version>-1.x86_64.rpm` (Fedora/Nobara). Snap is optional. ARM64 is planned and is not PASS without a real toolchain and runtime test.
- **Test matrix:** Ubuntu 22.04 and 24.04, Debian 12 and 13, Fedora 44, Nobara 44 (Official/KDE and GNOME). Sessions: GNOME + Wayland, KDE + Wayland, and X11 where supported. A Wayland bug is never "fixed" by forcing the whole app onto X11. Fedora PASS does **not** count as Nobara PASS. Mint, Pop!_OS, Zorin, elementary, KDE neon, Arch, EndeavourOS, Manjaro and openSUSE are in the broad-compatibility tier. Being in the same family ≠ tested compatibility.
- **Data on Linux:** `XDG_DATA_HOME` (vault), `XDG_CONFIG_HOME` (settings) and `XDG_CACHE_HOME` (disposable cache). Keys use a Secret Service/keyring adapter. If no keyring exists, **writing a plaintext key is forbidden**; the passphrase-only vault path is used instead. Portable Linux uses the same encrypted vault rules as portable Windows.

**Correction this repo adds (evidence-based).** The report cites Flutter's support matrix (Debian 10–13, Ubuntu 20.04–24.04). Upstream support does not make *our* binary run there. The bundle built in FORGE 001 on Ubuntu 24.04 needs `GLIBC_2.34` (measured with `objdump -T`). Debian 10 (glibc 2.28), Debian 11 and Ubuntu 20.04 (glibc 2.31) would fail to start the native `.deb`, `tar.zst` or AppImage builds. To cover them, the release builder must run on the oldest targeted glibc (for example a Debian 10 or 11 build container), or those versions are dropped from the native-package matrix. Flatpak is unaffected because its runtime ships its own glibc. Until that builder exists, the native-package floor is glibc 2.34: Fedora ≥ 35/Nobara, Ubuntu ≥ 22.04, Debian ≥ 12.

## D-010: Staging previews never persist unencrypted; provisional Linux app id (2026-10-06, F030L-1)

Only `development` builds (run from source) may keep the unencrypted development log. `staging` joins `production` as memory-only until the encrypted vault, so no distributed artifact writes plaintext health data (v0.28 portable/installed rules). Linux GTK application id, desktop file and AppStream id were set to the provisional `org.humanhealthos.HumanHealthOS`; superseded by D-012. The runner is compiled with `GLIB_VERSION_MIN_REQUIRED/MAX_ALLOWED = 2.64` so a GLib 2.80 build host does not raise the runtime floor (found on Ubuntu 22.04).

## D-011: Adopt the v0.31 master as process authority (2026-10-06)

The user supplied `HUMAN_OS_CLAUDE_CODE_MASTER_FORGE_v0.31_CLAUDE_CODE_WEB_ONE_SHOT.md` and ordered its one-shot contract (Phase 0 + F001, then stop). Consequences:
- **Forge ids:** the v0.31 vertical-slice ladder (F001–F017, §39) is canonical. Legacy roadmap ids are mapped in `docs/ROADMAP.md`. The interrupted legacy F030L-1 becomes **F015-L1** (Linux part of desktop distribution).
- **State machine:** `project_state/CURRENT_STATE.json` (schema 2) carries `development_state`, `active_forge`, `suspended_forges`, `verified_gates`, `known_blockers`, `baseline` and `next_recommended_forge` (§31). Repository reality outranks the state file.
- **Evidence receipts:** gates run through `tools/evidence/run_gate.py`, which writes machine-generated JSON receipts to `evidence/{tests,builds,runtime}/` (real timestamps, exit codes, tool versions, source revision, dirty flag, log digest). No PASS without a receipt (§33, §34). Raw logs stay out of git.
- **Definition of Done:** v0.31 §34 applies to every Forge.
- Repository reality wins where v0.31 assumes a fresh repository (conflicts C-1…C-7 in `SOURCES.md`).

## D-012: Linux identifiers follow the v0.31 packaging contract (2026-10-06, applied later)

`com.humanos.HumanHealthOS` (app id), `HumanHealthOS-x86_64.AppImage`, the appendix-218 tarball layout and the `human-health-os/` XDG subdirectory are the target names. They are applied in F015-L1 (packaging) and F002 (XDG path), not in F001, so F001 does not widen into packaging or persistence.

