# Platform matrix

Checked 2026-10-06 in the cloud container: Ubuntu 24.04.5 x86_64, Flutter 3.47.6 / Dart 3.13.5 at `/opt/toolchains/flutter`. Evidence: `reports/toolchain/flutter_doctor_2026-10-06.txt`. Statuses come from the latest FORGE; see `project_state/CURRENT_STATE.json` for the live values.

| Target | Host needed | This container | Blocker | Distribution artifacts (eventual) |
|---|---|---|---|---|
| Web / PWA (private app) | any | **RUNTIME_TESTED** (F002): Playwright smoke 26/26 on Chromium 1194 incl. save → reload → persisted | PWA install NOT_RUN | static `build/web`, installable PWA |
| **Linux desktop** (product surface, D-008/D-009) | Linux + GTK3 dev | **RUNTIME_TESTED** (F002) on Ubuntu 24.04 under Xvfb (X11): `integration_test` saves, relaunches and survives a moved data folder | Not PACKAGED. Wayland, Fedora/Nobara, Debian, Ubuntu 22.04: NOT_RUN. | Flatpak (primary), `x86_64.AppImage`, `Portable.tar.zst`, `.deb`, `.rpm`. ARM64 planned. |
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
| Key storage | Keystore | Keychain | WebCrypto non-extractable + passphrase | DPAPI (optional) + passphrase | Keychain | Secret Service/libsecret (optional) + passphrase |
| Durable local storage (target) | yes | yes | can be evicted, so export is the durable path | yes | yes | yes (`$XDG_DATA_HOME/HumanHealthOS`) |
| Durable local storage (F002, dev builds only, **unencrypted**) | no (memory + notice) | no (memory + notice) | `localStorage` | `%LOCALAPPDATA%` (not compiled here) | Application Support (not compiled here) | XDG data dir (tested) |
| Background work | WorkManager | limited BGTasks | none | none | limited | none |

## Cross-platform parity (v0.31 §38), implementation reality on 2026-10-06

States: REQUIRED (target), SUPPORTED, PARTIAL, UNSUPPORTED_BY_PLATFORM, BLOCKED_ENVIRONMENT, NOT_IMPLEMENTED, NOT_TESTED.

| Capability | Android | iOS | Web | Windows | macOS | Linux |
|---|---|---|---|---|---|---|
| Shell + navigation | NOT_TESTED (BLOCKED_ENVIRONMENT) | NOT_TESTED (BLOCKED_BY_HOST_OS) | SUPPORTED (runtime smoke) | NOT_TESTED (BLOCKED_BY_HOST_OS) | NOT_TESTED (BLOCKED_BY_HOST_OS) | SUPPORTED (launch + integration test, Ubuntu 24.04) |
| Core local records | NOT_IMPLEMENTED (memory only) | NOT_IMPLEMENTED (memory only) | PARTIAL (dev builds, unencrypted localStorage) | PARTIAL (dev builds, unencrypted; not compiled here) | PARTIAL (dev builds, unencrypted; not compiled here) | PARTIAL (dev builds, unencrypted, tested) |
| Timeline | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED |
| Labs | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED |
| Offline deterministic core | REQUIRED | REQUIRED | SUPPORTED (0 network requests in smoke) | REQUIRED | REQUIRED | SUPPORTED (no network code; architecture test) |
| Health Connect | NOT_IMPLEMENTED | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM |
| HealthKit | UNSUPPORTED_BY_PLATFORM | NOT_IMPLEMENTED | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | NOT_IMPLEMENTED (conditional) | UNSUPPORTED_BY_PLATFORM |
| Encrypted / portable vault | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED (portable mode memory-only) |
| Native notifications | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED | NOT_IMPLEMENTED |
| PWA install | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | NOT_TESTED | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM | UNSUPPORTED_BY_PLATFORM |

