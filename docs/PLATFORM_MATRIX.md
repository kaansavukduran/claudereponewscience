# Platform matrix

Checked 2026-10-06 in the cloud container: Ubuntu 24.04.5 x86_64, Flutter 3.47.6 / Dart 3.13.5 at `/opt/toolchains/flutter`. Evidence: `reports/toolchain/flutter_doctor_2026-10-06.txt`. Statuses come from the latest FORGE; see `project_state/CURRENT_STATE.json` for the live values.

| Target | Host needed | This container | Blocker | Distribution artifacts (eventual) |
|---|---|---|---|---|
| Web / PWA (private app) | any | **AVAILABLE** (Chromium at `/opt/pw-browsers/chromium-1194`) | — | static `build/web`, installable PWA |
| Linux desktop (CI smoke only) | Linux + GTK3 dev | MISSING `libgtk-3-dev` | install GTK3 dev packages | bundle |
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
- **Linux smoke:** `apt-get install libgtk-3-dev` (environment change; optional).

## Capability differences that must stay visible in the UI

| Capability | Android | iOS | Web | Windows | macOS |
|---|---|---|---|---|---|
| Health platform | Health Connect | HealthKit | — | — | (HealthKit not on macOS for this app) |
| Key storage | Keystore | Keychain | WebCrypto non-extractable + passphrase | DPAPI (optional) + passphrase | Keychain |
| Durable local storage | yes | yes | can be evicted, so export is the durable path | yes | yes |
| Background work | WorkManager | limited BGTasks | none | none | limited |
