# Platform matrix

Checked 2026-10-06 in the cloud container: Ubuntu 24.04.5 x86_64, Flutter 3.47.6 / Dart 3.13.5 at `/opt/toolchains/flutter`. Evidence: `reports/toolchain/flutter_doctor_2026-10-06.txt`. Statuses come from the latest FORGE; see `project_state/CURRENT_STATE.json` for the live values.

| Target | Host needed | This container | Blocker | Distribution artifacts (eventual) |
|---|---|---|---|---|
| Web / PWA (private app) | any | **RUNTIME_TESTED** (receipts in `evidence/`; current F001@v0.32 run listed in `CURRENT_STATE.json → verified_gates`): Playwright smoke on Chromium 141 (Today → Timeline → Labs, save → reload, 0 external requests) | PWA install NOT_RUN | static `build/web`, installable PWA |
| **Linux desktop** (product surface, D-008/D-009) | Linux + GTK3 dev | **RUNTIME_TESTED** on Ubuntu 24.04 under Xvfb (X11): launch + `integration_test` (save, relaunch, moved data folder); receipts in `evidence/` | F015-L1 (IN_PROGRESS_RECOVERABLE): tar.zst/deb/rpm/AppImage built UNSIGNED; Ubuntu 24.04 install/launch PASS (X11 + Weston Wayland); Ubuntu 22.04 FAIL (open libGLESv2 dependency); Fedora 44 static rpm checks only; Debian 12/13, Nobara 44, GNOME/KDE Wayland, Flatpak NOT_RUN. Development vault moves to `$XDG_DATA_HOME/human-health-os/` in F002 (C-4). | Flatpak (primary), `x86_64.AppImage`, `Portable.tar.zst`, `.deb`, `.rpm`. ARM64 planned. |
| Android | Android SDK + Google Maven | **BLOCKED_ENVIRONMENT** | no Android SDK; network policy returns 403 for `dl.google.com` / `maven.google.com` | APK, AAB |
| iOS | macOS + Xcode | **BLOCKED_BY_HOST_OS** | Linux host | IPA / TestFlight |
| macOS | macOS + Xcode | **BLOCKED_BY_HOST_OS** | Linux host | `.app`, DMG/PKG (Developer ID + notarization) |
| Windows portable | Windows + VS C++ | **BLOCKED_BY_HOST_OS** | Linux host | `HumanHealthOS-Windows-x64-Portable.zip` |
| Windows installer | Windows | **BLOCKED_BY_HOST_OS** | Linux host | `HumanHealthOS-Setup-x64.exe` |
| Build Lab (synthetic) | any (Node 22) | **AVAILABLE**, built and e2e-tested | — | static site / Claude artifact |

## How to unblock

- **Android:** allow `dl.google.com`, `maven.google.com` and `services.gradle.org` in the environment network policy and install an Android SDK (cmdline-tools). Or build in GitHub Actions on `ubuntu-latest`.
- **iOS and macOS:** a GitHub Actions `macos-latest` runner, or a Mac.
- **Windows:** a GitHub Actions `windows-latest` runner, or a Windows PC. Run `flutter build windows`, then package the ZIP and the installer.
- **Linux:** builds here. Cross-distro launch tests (Fedora/Nobara, Debian 12, Ubuntu 22.04) need containers/VMs in CI. Compatibility floor is GLIBC 2.34 + GTK 3 (see DECISIONS D-008).

## Capability differences that must stay visible in the UI

| Capability | Android | iOS | Web | Windows | macOS | Linux |
|---|---|---|---|---|---|---|
| Health platform | Health Connect | HealthKit | — | — | (HealthKit not on macOS for this app) | — |
| Key storage | Keystore (planned) | Keychain (planned) | WebCrypto non-extractable + passphrase (planned, G-32) | passphrase + recovery key (F006, not compiled here); DPAPI convenience planned (G-13) | passphrase + recovery key (F006, not compiled here); Keychain convenience planned | passphrase + recovery key (F006, tested); Secret Service convenience planned (G-13) |
| Durable local storage (target) | yes | yes | can be evicted, so export is the durable path | yes | yes | yes (`$XDG_DATA_HOME/human-health-os`, C-4) |
| Durable local storage (F002, dev builds only, **unencrypted**) | no (memory + notice) | no (memory + notice) | `localStorage` | `%LOCALAPPDATA%` (not compiled here) | Application Support (not compiled here) | `$XDG_DATA_HOME/human-health-os/` (tested; the pre-F002 `HumanHealthOS/` folder is moved by rename on first start) |
| Durable local storage (F006, staging/production/portable, **encrypted**) | no (memory + notice) | no (memory + notice) | no: memory only (G-32) | `%LOCALAPPDATA%` or `UserData\` beside the EXE (not compiled here) | Application Support (not compiled here) | `$XDG_DATA_HOME/human-health-os/vault.hhosvault` or `UserData/` beside the binary (tested) |
| Background work | WorkManager | limited BGTasks | none | none | limited | none |

## Cross-platform parity (v0.31 §38), implementation reality on 2026-10-08

States: REQUIRED (target), SUPPORTED, PARTIAL, UNSUPPORTED_BY_PLATFORM, BLOCKED_ENVIRONMENT, NOT_IMPLEMENTED, NOT_TESTED.

| Capability | Android | iOS | Web | Windows | macOS | Linux |
|---|---|---|---|---|---|---|
| Shell + navigation | NOT_TESTED (BLOCKED_ENVIRONMENT) | NOT_TESTED (BLOCKED_BY_HOST_OS) | SUPPORTED (runtime smoke) | NOT_TESTED (BLOCKED_BY_HOST_OS) | NOT_TESTED (BLOCKED_BY_HOST_OS) | SUPPORTED (launch + integration test, Ubuntu 24.04) |
| Core local records | NOT_IMPLEMENTED (memory only) | NOT_IMPLEMENTED (memory only) | PARTIAL (development builds only, unencrypted localStorage; other builds memory only, G-32) | NOT_TESTED (BLOCKED_BY_HOST_OS; same Dart code: encrypted vault, development log) | NOT_TESTED (BLOCKED_BY_HOST_OS; same Dart code) | SUPPORTED (encrypted vault for staging/production/portable, development log labelled unencrypted; EV-TEST-F006-0024, EV-RUNTIME-F006-0009) |
| Timeline | NOT_TESTED (BLOCKED_ENVIRONMENT) | NOT_TESTED (BLOCKED_BY_HOST_OS) | SUPPORTED (F003, smoke EV-RUNTIME-F003-0001; again in EV-RUNTIME-F006-0007) | NOT_TESTED (BLOCKED_BY_HOST_OS) | NOT_TESTED (BLOCKED_BY_HOST_OS) | SUPPORTED (F003, EV-TEST-F003-0006, EV-RUNTIME-F003-0002; again in EV-TEST-F006-0024) |
| Labs | NOT_TESTED (BLOCKED_ENVIRONMENT) | NOT_TESTED (BLOCKED_BY_HOST_OS) | SUPPORTED (F004, smoke EV-RUNTIME-F004-0001; again in EV-RUNTIME-F006-0007) | NOT_TESTED (BLOCKED_BY_HOST_OS) | NOT_TESTED (BLOCKED_BY_HOST_OS) | SUPPORTED (F004, EV-TEST-F004-0006, EV-RUNTIME-F004-0002; again in EV-TEST-F006-0024) |
| Offline deterministic core | REQUIRED | REQUIRED | SUPPORTED (0 network requests in smoke) | REQUIRED | REQUIRED | SUPPORTED (no network code; architecture test) |
| Health Connect | NOT_IMPLEMENTED | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM |
| HealthKit | UNSUPPORTED_BY_PLATFORM | NOT_IMPLEMENTED | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | NOT_IMPLEMENTED (conditional) | UNSUPPORTED_BY_PLATFORM |
| Encrypted / portable vault | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED (G-32) | IMPLEMENTED (not compiled here) | IMPLEMENTED (not compiled here) | INTEGRATION_TESTED (EV-TEST-F006-0024) + RUNTIME_TESTED (EV-RUNTIME-F006-0008, EV-RUNTIME-F006-0009; Ubuntu 24.04, X11) |
| Native notifications | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED |
| PWA install | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | NOT_TESTED | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM |

