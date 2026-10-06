# Release strategy

Status: **SPECIFIED**. No release artifact exists yet. See `project_state/CURRENT_STATE.json`.

## Channels

development → internal → beta → production. Every build records:
- product version and build number
- source revision
- `pubspec.lock` and `pnpm-lock.yaml` SHA-256
- Flutter, Dart and Node versions
- build host OS and architecture
- profile (`APP_ENV`)
- rule, model and content-pack versions
- artifact SHA-256
- signing state

## Build matrix (each target judged independently)

| Target | Host | Command | Artifact | Signing |
|---|---|---|---|---|
| Web (private app) | Linux | `flutter build web --release --dart-define=APP_ENV=…` | `app/build/web/` | n/a, HTTPS hosting |
| Linux (CI smoke only) | Linux + GTK3 dev libs | `flutter build linux` | bundle | none |
| Android | Linux/macOS + Android SDK, reaching Google Maven | `flutter build apk` and `flutter build appbundle` | APK, AAB | Upload key in protected CI secrets |
| iOS | macOS + Xcode | `flutter build ipa` | IPA | Apple distribution certificate |
| macOS | macOS + Xcode | `flutter build macos`, then create a DMG/PKG | `.app`, DMG | Developer ID + notarization + stapling |
| Windows portable | Windows + VS C++ workload | `flutter build windows`, then zip the `Release` folder with `portable_mode.json` and an empty `UserData/` | `HumanHealthOS-Windows-x64-Portable.zip` | Authenticode on the EXE/DLLs |
| Windows installer | Windows | Installer script (e.g. Inno Setup or MSIX), chosen and recorded at that FORGE | `HumanHealthOS-Setup-x64.exe` | Authenticode |
| Build Lab (synthetic) | Linux | `pnpm --filter @hhos/site build` | static site / artifact | n/a |

Never handcraft an EXE, DMG or APK from the spec. "Portable ZIP exists" ≠ "clean-machine portable PASS". "DMG exists" ≠ "notarized".

## Windows specifics

- **Portable layout:** `HumanHealthOS.exe` + runtime DLLs + `data/` + `portable_mode.json` + `UserData/` (encrypted vault). The vault opens with a passphrase on any PC. The profile identity is a UUID stored inside the vault.
- **Installer:** Start Menu entry, optional desktop shortcut, per-user install by default, clean uninstall that **keeps** `%LOCALAPPDATA%\HumanHealthOS` unless the user explicitly chooses to delete data.

## Updates and rollback

Update metadata covers release ID, platform/architecture, schema compatibility, artifact SHA-256 and signature/attestation locator. HTTPS alone does not make metadata trusted, so production needs signed metadata. Before a schema-changing update the app takes a vault checkpoint. Binary rollback, schema rollback and rule/content-pack rollback are separate operations. Offline, the update status reads "unavailable", never "up to date".

## Supply chain

The lockfiles are committed. Dependency updates go through lockfile diff → license and security review → analyze and test → platform smoke. Public releases need an SPDX or CycloneDX SBOM. Unknown or incompatible licenses block a release. Provenance is recorded and moves toward SLSA, but no SLSA level is claimed. Attestation states are NOT_GENERATED, GENERATED_UNVERIFIED, VERIFIED or INVALID.
