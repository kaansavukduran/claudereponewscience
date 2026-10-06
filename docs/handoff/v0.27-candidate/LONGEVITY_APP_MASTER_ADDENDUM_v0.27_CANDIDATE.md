# LONGEVITY APP / HUMAN HEALTH OS — MASTER ADDENDUM v0.27 CANDIDATE

Baseline required: v0.26 SHA-256 `687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369`.

This is additive and does not replace the v0.26 Master Handoff.


---

<!-- SOURCE: 207_FLUTTER_REPOSITORY_BOOTSTRAP_CONTRACT.md -->

# FLUTTER REPOSITORY BOOTSTRAP CONTRACT

Use the installed Flutter CLI to create the real repository rather than freezing generated native runner files in the handoff.

Reference sequence:

```bash
flutter doctor -v
flutter create --empty --platforms=android,ios,web,windows,macos,linux human_health_os
cd human_health_os
flutter pub get
flutter analyze
flutter test
```

Then run/build only targets supported by the real host/toolchain.

This candidate supplies `repository_bootstrap_overlay/`. The coding agent creates a real Flutter app first, then overlays the provided `lib/` and `test/` files while keeping tool-generated platform runners and SDK constraints.

First objective: `bootstrap → analyze → test → run shell → build one supported target`. Do not expand into storage/clinical complexity before this checkpoint.

Record Flutter version, Dart version, host OS, `flutter doctor -v`, commands, outputs and PASS/FAIL/NOT_RUN. Source files alone are not compilation evidence.


---

<!-- SOURCE: 208_REPOSITORY_LAYOUT_AND_ARCHITECTURE.md -->

# REPOSITORY LAYOUT AND ARCHITECTURE

Initial architecture is a local-first modular monolith, not a premature microservice fleet.

```text
lib/
  main.dart
  src/
    app/
    config/
    navigation/
    core/
    domain/
      profile/ observations/ labs/ medications/ nutrition/
      activity/ sleep/ conditions/ prevention/ pathways/
      scoring/ comparison/
    data/
      local/ import/ export/ adapters/
    features/
      today/ timeline/ labs/ medications/ nutrition/ activity/
      conditions/ preventive/ compare/ learn/
    presentation/
      theme/ widgets/
test/
integration_test/
assets/
tool/
docs/
```

Preferred dependency direction:

`presentation/features → domain ports/use cases ← data adapters`

Domain code should not directly import HealthKit, Health Connect, SQLite implementation, HTTP client or Flutter screen widgets when avoidable. Remote sync is an adapter, not the canonical health model.


---

<!-- SOURCE: 209_FIRST_APP_SHELL_VERTICAL_SLICE.md -->

# FIRST APP SHELL VERTICAL SLICE

Initial destinations:
- Today
- Timeline
- Labs
- Medications
- Nutrition
- Activity
- Conditions
- Preventive
- Compare
- Learn

Wide layouts use a navigation rail/sidebar. Narrow layouts use compact mobile navigation.

The first compiled slice proves only:
1. app starts
2. responsive shell renders
3. destinations change
4. non-production build profile can be seen
5. no network is required
6. widget test sees Today
7. widget test navigates to Labs.

It does NOT prove clinical calculations, encrypted persistence, wearable integrations or store readiness.


---

<!-- SOURCE: 210_LOCAL_FIRST_PORTS_AND_PLATFORM_ADAPTERS.md -->

# LOCAL-FIRST PORTS AND PLATFORM ADAPTERS

Suggested ports:
- HealthRepository
- AttachmentRepository
- SecretStore
- Clock
- IdGenerator
- FilePickerPort
- ExportPort
- HealthPlatformPort
- NotificationPort
- ConnectivityPort
- RemoteSyncPort
- TerminologyPort.

Mobile adapters may implement Apple Health/HealthKit or Android Health Connect. Desktop adapters implement encrypted local vault/file picking/notifications. Web uses browser persistence/export/sync with explicit native-capability limits.

At startup build a capability registry from actual runtime capabilities. Do not show an integration as working merely because another platform supports it.

Deterministic local records/calculations/comparison/rule evaluation remain usable offline. Current external knowledge may explicitly require connectivity/freshness.


---

<!-- SOURCE: 211_BUILD_PROFILES_CONFIGURATION_AND_SECRETS.md -->

# BUILD PROFILES, CONFIGURATION AND SECRETS

Initial profiles: development, staging, production.

Non-secret compile-time config may use `--dart-define`, for example:

```bash
flutter run --dart-define=APP_ENV=development
flutter build web --dart-define=APP_ENV=production
```

Windows native flavor support is used only after checking the installed Flutter version supports it.

Never put long-lived server master secrets in Dart source, dart-defines, committed config or a public Web bundle. Use server-side secret management and short-lived/user-scoped credentials.

Every build should record product version/build, source revision when available, Flutter/Dart versions, profile and rule/content-pack versions.


---

<!-- SOURCE: 212_DEPENDENCY_LOCK_SBOM_LICENSE_AND_SUPPLY_CHAIN.md -->

# DEPENDENCY LOCK, SBOM, LICENSE AND SUPPLY CHAIN

Human Health OS is an application, so the real repository commits `pubspec.lock` once created. Production builds use the committed lock rather than silently refreshing package versions.

Dependency updates follow: `update request → lockfile diff → license/security review → analyze/test → platform smoke → accept`.

Record dependency name, version, source, purpose, direct/transitive state, license, native-code presence and privacy/security relevance.

Public release generates a Software Bill of Materials (SBOM), preferably SPDX or CycloneDX. Unknown/incompatible license state blocks public distribution until resolved.

Unreviewed arbitrary Git commits, local path dependencies or unauthenticated archives block production release.

Vulnerability findings are triage inputs. Check affected version, reachability, platform exposure, fix/workaround and regression risk.


---

<!-- SOURCE: 213_CI_BUILD_MATRIX_PROVENANCE_AND_ATTESTATION.md -->

# CI BUILD MATRIX, PROVENANCE AND ATTESTATION

CI stages:
1 source checkout
2 toolchain report
3 dependency restore from lockfile
4 format/static checks
5 unit/widget tests
6 platform build
7 applicable smoke
8 SBOM/license inventory
9 protected signing/notarization
10 final hashes
11 provenance/attestation
12 candidate publication.

Typical matrix: Web/Android on Linux runners, Windows on Windows runners, iOS/macOS on macOS runners. Never mark a host-incompatible platform PASS because source analysis passed elsewhere.

Build provenance records what source/input produced an artifact, what builder/process produced it, and the output digest. SLSA-compatible provenance is a preferred direction when supported, but this candidate claims no SLSA level.

Attestation states: NOT_GENERATED, GENERATED_UNVERIFIED, VERIFIED, INVALID.

Reproducible inputs and bit-identical reproducible output are separate claims.


---

<!-- SOURCE: 214_RELEASE_CHANNEL_UPDATE_METADATA_AND_ROLLBACK.md -->

# RELEASE CHANNEL, UPDATE METADATA AND ROLLBACK

Channels: development, internal, beta, production.

Update metadata can include release ID, product/build, platform/architecture, schema compatibility, download locator, artifact SHA-256, signature/attestation locator and release notes.

Do not trust mutable update metadata solely because transport uses HTTPS. Production updater needs an authenticated/signature strategy appropriate to its final design.

Before schema-affecting update create a consistent vault checkpoint/backup and migration plan. Binary rollback, schema rollback and rule/content-pack rollback are distinct.

Offline means the installed app continues; update status becomes unavailable, never fake success.


---

<!-- SOURCE: 215_FIRST_COMPILED_SLICE_ACCEPTANCE_GATE.md -->

# FIRST COMPILED SLICE ACCEPTANCE GATE

Evidence layers remain independent:

- V0 specification exists
- V1 `flutter analyze` + `flutter test` actually executed
- V2 at least one real build artifact exists and is hashed
- V3 one actual target starts and shows Human Health OS → Today → Labs navigation
- V4 each additional target gets its own result.

Example:

```text
Repository generated          PASS
flutter analyze               PASS
flutter test                  PASS
Web build                     PASS
Web runtime smoke             PASS
Windows build                 NOT_RUN
Android build                 NOT_RUN
iOS build                     NOT_RUN
```

Fix the first decisive failure before expanding deep storage/wearables/clinical modules.

Full v0.27 release still requires the exact v0.26 baseline merge and normal release gates.


---

# TECHNICAL SOURCE ADDENDUM v0.27

Checked: 2026-10-06.

Flutter official references:
- https://docs.flutter.dev/reference/create-new-app
- https://docs.flutter.dev/platform-integration/desktop
- https://docs.flutter.dev/deployment/windows
- https://docs.flutter.dev/deployment/flavors-windows

Dart dependency locking:
- https://dart.dev/tools/pub/cmd/pub-get
- https://dart.dev/tools/pub/versioning

SPDX:
- https://spdx.dev/use/specifications/

SLSA provenance:
- https://slsa.dev/spec/v1.2/provenance
- https://slsa.dev/spec/v1.2/build-track-basics

Observed design inputs:
- create the actual Flutter repository with the installed toolchain
- application projects commit `pubspec.lock`
- SPDX 3.0 is listed as current
- SLSA provenance describes how an artifact was produced and ties outputs to build inputs/process.
