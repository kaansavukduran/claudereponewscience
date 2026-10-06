# HUMAN OS / HUMAN HEALTH OS
# CLAUDE CODE MASTER DEVELOPMENT + FORGE SPECIFICATION
## Single-file cumulative candidate v0.32 · CLAUDE CODE WEB ONE-SHOT EXECUTION LOCK

**Intended consumer:** Claude Code Web, or Claude Code with a writable project/repository workspace.

**Artifact status:** `CANDIDATE_MASTER_SINGLE_FILE`. This is not a claim that the historical v0.26 full release has been reconstructed or promoted.

# v0.32 FORGE DELTA

v0.32 is an **execution-hardening Forge**, not another broad feature brainstorm.

It closes four practical failure modes in v0.31:

1. legacy passages that could tell Claude Code to stop after Phase 0 even though the user authorized Phase 0 + F001 in one run;
2. F001 acceptance criteria that were correct but not concrete enough to prevent another planning-only iteration;
3. unclear behavior when Claude Code Web can edit files but lacks Flutter or a platform build toolchain;
4. unclear rules for dependency/tool installation versus honest `BLOCKED_ENVIRONMENT` reporting.

No clinical/domain semantics are weakened. No platform target is removed. No runtime/build PASS is claimed by this document.

---

# EXECUTION KERNEL · v0.32 · HIGHEST OPERATIONAL PRIORITY

When this file is attached and the user clearly says to start, build, implement, Forge, or otherwise execute Human OS, **this section is the authoritative runtime instruction**.

It overrides any older passage in this file that says:

- stop after Phase 0;
- wait for a separate `FORGE`;
- initialize only;
- do not implement F001 yet.

Those older passages are retained only as historical/recovery context.

## One-run authorization

The first authorized run is exactly:

```text
BOOT / RECONCILE
→ PHASE 0 INITIALIZATION
→ PHASE 0 SELF-AUDIT / REPAIR
→ F001 IMPLEMENTATION
→ TEST / BUILD
→ FIRST-FAILURE REPAIR
→ RETEST / REGRESSION
→ EVIDENCE + STATE UPDATE
→ FINAL SELF-AUDIT
→ STOP
```

Do **not** begin F002 in the same run.

A routine Phase 0 issue is not permission to stop early. Stop before F001 only for a real hard blocker that cannot be resolved safely from repository evidence and this master.

## Activation

Any clear execution message is sufficient, including:

```text
START HUMAN OS NOW
FORGE
BUILD HUMAN OS
```

Do not require the user to send a second initialization or F001 message.

---

# v0.32 PHASE 0 CONTRACT

Before changing application code:

1. Inspect the actual writable workspace.
2. Inspect Git state if Git exists.
3. Identify existing `pubspec.yaml`, Flutter source, tests, platform folders, CI, build scripts, project-state files and previous Forge evidence.
4. Inspect actual tool availability:
   - Flutter
   - Dart
   - Git
   - browser/Web runtime
   - Android toolchain
   - Linux toolchain
   - Windows toolchain
   - Apple toolchain
   - package/build utilities only when relevant.
5. Reconcile repository reality with any existing Human OS state.
6. Create/update `CLAUDE.md` and canonical state only if an equivalent authoritative mechanism is absent or incomplete.
7. Define the exact F001 baseline and acceptance criteria.
8. Self-audit Phase 0.
9. Continue immediately into F001 unless a hard blocker exists.

Phase 0 is preparation for executable work, not a documentation project. Create only control artifacts that materially help implementation.

---

# v0.32 REPOSITORY BOOTSTRAP DECISION

Do not blindly create nested Flutter projects.

Use this order:

1. **Existing Flutter repository detected:** repair/use it in place.
2. **Existing monorepo with an obvious app location:** use the established app location.
3. **Workspace contains specifications but no app repository:** create the smallest non-destructive app location consistent with the workspace, normally `app/` or `human_health_os/`, and record the choice.
4. **Empty writable workspace:** create `human_health_os/`.
5. **No writable filesystem:** `BLOCKED_ENVIRONMENT`.

Never overwrite unrelated existing files merely to match an example directory tree.

Do not regenerate platform folders over hand-edited platform code without inspection/diff.

---

# v0.32 F001 · EXECUTABLE REPOSITORY HEARTBEAT

F001 is the first genuine application slice.

## F001 user-visible scope

Implement a minimal Human OS shell with exactly these primary destinations:

- Today
- Timeline
- Labs

The shell may expose future destinations only if they already exist in verified repository code, but F001 does not require implementing those future domains.

F001 must contain:

- application entry point;
- Human OS app/root widget;
- responsive navigation;
- Today surface;
- Timeline surface;
- Labs surface;
- explicit empty/unimplemented states instead of fabricated health data;
- a visible development/build-profile indicator when appropriate for non-production builds;
- no required cloud connection;
- no required login;
- no required generative AI;
- no real health-data persistence yet unless an existing verified repository already provides it.

## Responsive behavior

At minimum verify two layout classes:

- narrow/mobile-like viewport: compact navigation such as Material `NavigationBar`;
- wide/desktop-like viewport: side navigation such as Material `NavigationRail`.

The implementation may use the repository's existing adaptive breakpoint. Do not invent a second competing breakpoint system when one already exists.

## F001 semantic safety

F001 must not:

- fabricate medical records to make screens look populated;
- silently introduce a production health database;
- claim encryption before encryption exists;
- introduce remote sync;
- introduce clinical recommendations;
- duplicate platform-specific domain logic into shared UI code.

Synthetic/demo values may appear only when clearly labeled synthetic/demo and only if needed for a test or preview.

---

# v0.32 F001 REQUIRED AUTOMATED CHECKS

Where Flutter execution is available, create/retain tests that objectively demonstrate at least:

1. app/root widget renders;
2. Today is reachable;
3. Timeline is reachable;
4. Labs is reachable;
5. narrow layout exposes compact navigation;
6. wide layout exposes wide/side navigation;
7. switching destinations changes the visible destination;
8. the shell starts without a network dependency.

Do not overfit tests to implementation-private widget trees when user-visible behavior can be tested.

If the repository already has stronger equivalent tests, reuse them.

---

# v0.32 REAL COMMAND GATES

Run commands only when valid for the detected repository/toolchain.

Preferred Flutter/Web sequence:

```bash
flutter doctor -v
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter build web
```

If `dart format --set-exit-if-changed .` fails only because formatting is needed, format the affected Dart files, then rerun the gate.

If the installed Dart/Flutter version does not support a command exactly as written, use the correct equivalent and record the actual command.

## Web runtime smoke

If the environment provides a supported preview/runtime mechanism:

1. launch/preview the built app;
2. verify the shell actually renders;
3. verify Today → Timeline → Labs navigation;
4. verify no immediate fatal console/runtime error blocks the shell;
5. record runtime evidence.

If preview is not available:

`RUNTIME_TESTED = NOT_RUN` or `BLOCKED_ENVIRONMENT`.

A successful `flutter build web` is `COMPILED`, not automatically `RUNTIME_TESTED`.

---

# v0.32 TOOL / DEPENDENCY INSTALL POLICY

Claude Code may perform ordinary **project-scoped dependency resolution** required by the repository, for example:

```text
flutter pub get
```

It may also use already-available package/build tools.

Do not silently perform broad OS mutation merely to force a PASS.

For missing system-level toolchains:

- first report what is missing;
- use a safe project-local/user-local installation only when the environment clearly supports it and it is proportionate to F001;
- do not install unrelated SDKs;
- do not bypass platform restrictions;
- do not fake Apple/Windows/Linux/Android build results from another host.

If installing the missing toolchain would dominate the Forge or require privileged/interactive decisions, mark the affected gate `BLOCKED_ENVIRONMENT` and continue all other supported work.

---

# v0.32 FIRST-FAILURE REPAIR RULE

When a command fails:

1. preserve the exact failing command and exit result;
2. identify the **first actionable/root failure**;
3. fix that failure;
4. rerun the failed gate;
5. rerun downstream gates whose evidence may have been invalidated;
6. do not bury the root failure under secondary diagnostics.

A code edit after a PASS invalidates any earlier evidence that depends on the changed code unless the relevant gate is rerun.

---

# v0.32 F001 DEFINITION OF DONE

`F001_COMPLETE` requires all of the following that are technically possible in the current environment:

- real repository/app source exists;
- entry point exists;
- Today/Timeline/Labs shell implemented;
- responsive narrow/wide navigation implemented;
- required automated tests exist;
- formatter gate passes where applicable;
- analyzer passes;
- Flutter tests pass;
- at least one real build target succeeds if a supported build toolchain exists;
- runtime smoke passes if a runtime/preview facility exists;
- evidence/state files reflect only actual execution;
- final self-audit finds no unresolved F001-blocking issue.

A missing optional runtime preview does not necessarily prevent source/test/build completion, but it prevents a `RUNTIME_TESTED` claim.

Use:

- `F001_COMPLETE`
- `F001_PARTIAL_BLOCKED`
- `INITIALIZATION_BLOCKED`

Never invent `PASS` to avoid `PARTIAL_BLOCKED`.

---

# v0.32 FINAL REPORT CONTRACT

At the end of the single run, return one consolidated report:

```text
# HUMAN OS ONE-SHOT FORGE REPORT

## Repository State
## Source Authority
## Environment / Toolchain
## Phase 0 Changes
## F001 Goal
## F001 Implementation
## Files Changed
## Commands Actually Executed
## Tests Actually Executed
## Build Results
## Runtime Results
## Bugs Found
## Repairs Applied
## Regression / Self-Audit
## Evidence / Receipts
## Known Limitations
## Canonical State Update
## Next Recommended Forge
## Final Status
```

For every build/test target, distinguish:

`PASS`, `FAIL`, `NOT_RUN`, `UNAVAILABLE`, `BLOCKED_ENVIRONMENT`, `BLOCKED_BY_HOST_OS`.

Recommend exactly one next Forge, normally F002 if F001 is complete.

Then STOP.

---

# v0.32 SINGLE-DOCUMENT RULE

This file is intentionally self-contained for Claude Code.

Do not require the user to upload a separate changelog, checksum sidecar, bootstrap prompt, Linux prompt, Windows prompt, Site prompt, or F001 prompt merely to begin development.

Embedded historical/candidate material later in this file is reference material supporting this master.

When operational instructions conflict:

```text
repository reality
> v0.32 EXECUTION KERNEL
> integrated current master sections
> embedded candidate/reference appendices
> historical examples
> assumptions
```

The v0.32 execution kernel may refine **workflow**, but it must not silently weaken health-data semantics, safety boundaries, source provenance, privacy rules, or evidence honesty defined elsewhere in this master.

---


**Purpose:** This file is designed to be sufficient as the single planning/development handoff for starting, resuming, implementing, testing, packaging and iteratively building Human OS with Claude Code. It consolidates the v0.27 repository/bootstrap candidate, v0.28 Linux distribution candidate, v0.29 release-trust layer, v0.30 execution/evidence/implementation governance, v0.31 Claude Code Web one-shot entry path, and the v0.32 execution-lock/F001-hardening increment.

**Important truth state:** This is a **single-file cumulative candidate**, not a promoted full CURRENT release. The underlying candidate explicitly requires the exact full v0.26 baseline before full promotion. Do not erase that distinction.

**Historical parent master:** `HUMAN_OS_CLAUDE_CODE_MASTER_FORGE_v0.29_SINGLE_FILE.md`  
**Parent SHA-256:** `88509a1970e449fb5e32a2e31728261678c512eaf63c8e6f4e2147e9db19fa5a`  
**v0.30 Forge type:** `TRIPLE_GOVERNANCE_FORGE` (execution/resume + evidence/recovery + implementation/parity).
**v0.31 Forge type:** `WEB_ONE_SHOT_ENTRY`.
**v0.32 Forge type:** `EXECUTION_LOCK_AND_F001_HARDENING`.

---

# 0. AUTHORITATIVE STATUS AND SOURCE RULES

## 0.1 Current source state

The currently consolidated candidate lineage is:

- Full baseline required: `LONGEVITY_APP_DEVELOPER_HANDOFF_v0.26.zip`
- Required SHA-256: `687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369`
- Parent candidate: v0.27 repository/bootstrap + supply-chain increment
- Current cumulative candidate: v0.28 Linux cross-distribution increment
- v0.29 enrichment layer: planning/Claude-Code orchestration + release-trust enrichment
- v0.30 Triple Forge layer: execution state machine + evidence receipts/Definition of Done + implementation ladder/parity/recovery governance
- v0.31 Web one-shot layer: Phase 0 + F001 in one authorized run
- v0.32 Execution-lock layer: unambiguous one-shot precedence + executable F001 contract + environment/package-install policy

This file **does not claim** that v0.26 full bytes were merged if they are not actually present in the repository/runtime.

If the exact v0.26 baseline is present, verify its SHA before merging candidate material.

If it is absent, continue implementation work that is safe and additive, but report the release state as candidate/unmerged rather than CURRENT.

## 0.2 Source authority order

When conflicts appear, use this priority:

1. Actual repository/source code and migrations that have been verified.
2. Exact full CURRENT handoff/release artifact if present and hash-verified.
3. This master single-file candidate for v0.27/v0.28/v0.29/v0.30 additions.
4. Candidate addenda embedded in the appendix.
5. Historical/superseded material.
6. Memory or assumptions.

Never allow a summary to silently overwrite verified repository state.

## 0.3 Evidence states

Keep these states distinct:

- PLANNED
- SPECIFIED
- IMPLEMENTED
- STATICALLY_TESTED
- UNIT_TESTED
- INTEGRATION_TESTED
- COMPILED
- RUNTIME_TESTED
- PACKAGED
- SIGNED
- NOTARIZED
- DEPLOYED

If a thing was not executed, use `NOT_RUN`.

If host/tooling prevents it, use `BLOCKED_ENVIRONMENT`.

If evidence is missing, use `UNKNOWN`.

A source file existing is not compilation evidence. A package manifest existing is not runtime evidence. A test definition is not a test execution.

---

# 1. WHAT HUMAN OS IS

Human OS, also called Human Health OS and historically Longevity App, is a **local-first, offline-capable, deterministic personal health operating system**.

“Operating system” is a product metaphor. Human OS is not a hardware kernel. It is a unified system for representing, storing, calculating, comparing, explaining, and orchestrating a person's health state over time.

The core loop is:

```text
INPUT / IMPORT / MEASURE
        ↓
PRESERVE ORIGINAL SOURCE
        ↓
NORMALIZE CAREFULLY
        ↓
CANONICAL HEALTH RECORD
        ↓
DETERMINISTIC CALCULATION / RULE EVALUATION
        ↓
LONGITUDINAL TRACKING
        ↓
COMPARISON / SCENARIO / PERSONAL BASELINE
        ↓
EXPLANATION / EDUCATION
        ↓
OPTIONAL PLAN / TASK / FOLLOW-UP REPRESENTATION
```

Human OS aims to unify, at minimum:

- profile and identity context
- age, height, weight, body composition
- vital signs
- laboratory results and biomarkers
- cardiovascular and metabolic health
- diseases, conditions, symptoms
- condition episodes
- medications and actual intake events
- supplements
- vaccinations and preventive care
- procedures and operations
- chemotherapy, radiotherapy and other treatments
- dermatology / skin
- mental and subjective daily state
- sleep
- activity and exercise
- wearable/device data
- nutrition and foods
- food composition
- documents, reports and attachments
- care pathways
- goals and tasks
- timeline
- Compare / Digital Twin / scenario modeling
- Longevity
- Shortevity
- Learn / education
- provenance and corrections
- import/export
- backup/restore
- offline operation.

Human OS is therefore broader than a fitness tracker, lab viewer, medication reminder, nutrition app, longevity calculator, or document archive. It is the shared health-data and health-reasoning backbone connecting those domains.

---

# 2. HARD SEMANTIC INVARIANTS

These distinctions are non-negotiable:

```text
planned != completed
prescribed != taken
reminder != completion
missing != zero
unknown != false
source text != normalized interpretation
association != causation
risk estimate != diagnosis
screening != diagnosis
scenario != observation
model output != observed fact
reference interval != optimal target
reference interval != clinical decision limit
outside reference != critical result
same display name != same laboratory measurand
```

Represent meaningful health states explicitly, including when relevant:

- OBSERVED
- REPORTED
- PLANNED
- COMPLETED
- DERIVED
- MODELLED
- ASSUMED
- UNKNOWN

Corrections must preserve history. Terminology changes, reference-range changes, model updates, rule updates, and mapping corrections must not silently rewrite original records.

---

# 3. PRODUCT SURFACES

Human OS has **six primary client targets** sharing one canonical core:

1. Android
2. iOS
3. Web / installable PWA-like client
4. Windows desktop
5. macOS desktop
6. Linux desktop

An auxiliary seventh surface exists:

7. Human OS Build Lab, synthetic-first experimentation and teaching surface.

These are not seven independent products.

```text
                    HUMAN OS CORE
                         │
          domain models / engines / rules
                         │
                 repository/service ports
                         │
                platform adapter layer
                         │
 ┌─────────┬─────────┬───────┬─────────┬─────────┬─────────┐
 Android    iOS       Web     Windows   macOS     Linux
```

Build Lab is a controlled synthetic environment using the same semantics where appropriate, but must not silently mix synthetic humans with real users.

---

# 4. PLATFORM TARGETS

## 4.1 Android

Use the shared Flutter application. Android-specific adapters may include:

- Health Connect
- Android notifications
- secure storage
- background jobs
- camera/file import
- permissions.

Expected release artifacts eventually include APK and AAB when appropriate.

## 4.2 iOS

Use the shared Flutter application. iOS-specific adapters may include:

- HealthKit
- notifications
- Keychain
- background capabilities
- camera/files
- Apple permission systems.

## 4.3 Web / PWA

Maintain two distinct web surfaces:

### Private Human OS Web App
May contain real user data. Can offer an installable PWA-like shell where browser/platform support permits.

### Human OS Build Lab
Public/synthetic-first experimentation and teaching surface. No private user data is required.

Never claim native parity for HealthKit, Health Connect, OS keychain, native filesystem, or background services.

## 4.4 Windows

Two first-class distribution modes:

### Portable

```text
HumanHealthOS-Windows-x64-Portable.zip
→ extract
→ HumanHealthOS.exe
→ run
```

This is a Rufus-like user experience. It does not require one physical EXE. Flutter Windows may correctly require EXE + DLLs + data directory + runtime components.

End users must not need Flutter SDK, Dart SDK, Visual Studio, source code, or developer tooling.

Portable persistent health data must use an encrypted portable vault.

### Installed

```text
HumanHealthOS-Setup-x64.exe
```

Normal desktop/game-style installation:

- install location
- Start menu
- optional desktop shortcut
- upgrade
- uninstall.

App uninstall must not silently delete health data.

## 4.5 macOS

Targets can include:

- `.app`
- `.dmg`
- `.pkg`
- App Store archive/submission evidence.

Direct public distribution requires the appropriate signing, Developer ID, Gatekeeper and notarization flow.

Never store health data inside the `.app` bundle.

## 4.6 Linux

Linux is a first-class Flutter desktop target with explicit package families:

### Cross-distro installed
- Flatpak

### Portable
- AppImage when validated
- portable `.tar.zst` fallback

### Debian family
- `.deb`

### Fedora/Nobara family
- `.rpm`

### Optional
- Snap
- Flathub publication
- apt repository
- RPM repository
- ARM64/AArch64 builds when toolchain/runtime evidence exists.

Never claim “all Linux distros supported” from one passing test.

Support states:

- UPSTREAM_SUPPORTED_FLUTTER_TARGET
- HUMAN_OS_TESTED_COMPATIBILITY
- BEST_EFFORT_UNVERIFIED

Nobara PASS must not be inferred from Fedora PASS.

---

# 5. BUILD LAB

Human OS Build Lab is a synthetic interactive laboratory.

It should support synthetic profiles such as:

```text
Synthetic Human A
Synthetic Human B
Synthetic Human C
```

and allow controlled changes to:

- body metrics
- sleep
- activity
- nutrition
- labs
- preventive state
- medications/supplements
- risk-model inputs
- longevity / shortevity factors
- functional state.

Build Lab must clearly label:

- synthetic data
- assumptions
- model outputs
- source/version
- limitations.

A synthetic scenario must never mutate real observed history.

---

# 6. SHARED REPOSITORY ARCHITECTURE

Default architectural direction is a **local-first modular monolith** in Flutter/Dart, not premature microservices.

Recommended initial layout:

```text
lib/
  main.dart
  src/
    app/
    config/
    navigation/
    core/
    domain/
      profile/
      observations/
      labs/
      medications/
      nutrition/
      activity/
      sleep/
      conditions/
      prevention/
      pathways/
      scoring/
      comparison/
    data/
      local/
      import/
      export/
      adapters/
    features/
      today/
      timeline/
      labs/
      medications/
      nutrition/
      activity/
      conditions/
      preventive/
      compare/
      learn/
    presentation/
      theme/
      widgets/
test/
integration_test/
assets/
tool/
docs/
```

Dependency direction:

```text
presentation/features → domain ports/use cases ← data/platform adapters
```

Domain code should not directly depend on HealthKit, Health Connect, SQLite implementation details, HTTP clients, Flutter widgets, or platform file APIs when avoidable.

Remote sync is an adapter, not the canonical health model.

---

# 7. LOCAL-FIRST AND PORTS

Suggested ports/interfaces:

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

At runtime build a capability registry from actual platform capabilities.

Do not show a capability as available merely because another platform supports it.

Core deterministic functions should remain usable offline where technically feasible.

---

# 8. HEALTH DATA MODEL PRINCIPLES

## 8.1 Provenance

Every meaningful health record should support source/provenance such as:

- MANUAL
- DEVICE
- PROVIDER
- DOCUMENT
- API
- DERIVED
- MODELLED
- IMPORTED
- UNKNOWN.

Preserve source identifiers, timestamps, original value, normalized value, correction lineage, and source version when available.

## 8.2 Models / rules / references / records

Keep separate:

- MODEL
- RULE
- REFERENCE DATASET
- HEALTH RECORD
- PLAN
- TASK
- COMPLETION EVENT.

## 8.3 Labs

Preserve:

- original label
- canonical analyte mapping
- unit
- specimen
- method
- laboratory
- date
- reference interval
- source flag
- source/version.

Keep separate:

- reference interval
- clinical decision limit
- critical threshold
- personal baseline
- delta check
- reference change value
- longitudinal comparability.

Same text label must not establish equivalence.

## 8.4 Medications and supplements

Keep separate:

- marketed product
- active ingredient
- plan
- actual intake
- observed exposure
- interaction assessment.

## 8.5 Preventive care

Keep separate:

- eligibility
- recommendation mode
- due state.

Unknown history is not zero history.

Jurisdiction-specific guidelines must not silently fall back to another country.

## 8.6 Conditions and pathways

Self-report is not confirmed diagnosis.

Care pathways can contain goals, tasks, measurements, appointments, education, reviews and dependencies.

Clinical treatment automation remains blocked unless a governed source/evidence pack explicitly enables it.

---

# 9. LONGEVITY AND SHORTEVITY

Longevity is the protective/healthspan perspective.

Shortevity is the burden/risk/harm/function-loss perspective.

Neither should collapse the whole person into a magical single number.

Any lifespan/healthspan model must be labelled MODELLED and expose:

- model ID
- version
- inputs
- missing data
- uncertainty
- limitations.

Never present a model as a known death date.

---

# 10. SECURITY AND PRIVACY

Treat all health data as sensitive.

Architecture should include:

- local encryption strategy
- secure key storage
- portable-vault security
- authentication where required
- authorization
- least privilege
- safe logging
- secret management
- backup security
- export controls
- attachment privacy
- deletion semantics
- auditability.

Never commit:

- API keys
- passwords
- signing private keys
- real health records
- server master secrets.

If secrets are detected, report the location/category without reproducing the value.

---

# 11. PORTABLE VAULT PRINCIPLES

Windows and Linux portable modes share these semantic rules:

- persistent health data is encrypted
- filesystem path is not health-profile identity
- moving the folder does not create a new profile
- a machine-bound credential cannot be the only recovery path
- passphrase/recovery path remains portable
- OS keyring may be a convenience unlock only
- read-only media must not claim successful writes
- updates must preserve vault identity and integrity.

Use reviewed cryptographic libraries. Do not invent custom cryptography.

---

# 12. BUILD PROFILES AND SECRETS

Initial profiles:

- development
- staging
- production.

Non-secret compile-time config may use `--dart-define` where appropriate.

Never put long-lived server secrets in Dart source, committed config, public Web bundles, or public build arguments.

Every build should record:

- product version/build
- source revision
- Flutter version
- Dart version
- build profile
- schema version
- rule/content-pack versions.

---

# 13. DEPENDENCY LOCK, SBOM AND LICENSE POLICY

Human OS is an application. Once the real repository exists, commit `pubspec.lock`.

Dependency update workflow:

```text
update request
→ lockfile diff
→ license/security review
→ flutter analyze
→ flutter test
→ platform smoke/build
→ accept or reject
```

For every material dependency record:

- name
- version
- source
- purpose
- direct/transitive
- license
- native-code presence
- privacy/security relevance.

Public releases should generate an SBOM in SPDX or CycloneDX form.

Unknown/incompatible licensing blocks public distribution until resolved.

Unreviewed arbitrary Git commits, local path dependencies, or unauthenticated archives block production release.

---

# 14. v0.29 RELEASE TRUST / SUPPLY-CHAIN ENRICHMENT

This section is newly added by the single-file Forge enrichment.

## 14.1 Goal

Human OS releases should become **cryptographically traceable and rollback-resistant**, not merely “downloaded over HTTPS”.

Do not claim TUF compliance, SLSA level, reproducible-build guarantee, or formal certification unless the corresponding implementation and evidence actually exist.

## 14.2 Release metadata roles

Adopt a TUF-inspired separation of trust responsibilities, without claiming TUF compatibility unless implemented with a real TUF framework.

Conceptual roles:

### ROOT
Long-lived trust anchor metadata.
Contains trusted public keys / threshold policy for release metadata.
Changes rarely and requires strongest approval.

### TARGETS
Lists authorized release artifacts and their hashes/sizes/platform metadata.

### SNAPSHOT
Binds the current versions of release metadata together so clients can detect inconsistent/mixed states.

### TIMESTAMP
Short-lived freshness metadata so clients can detect freeze/replay of old release state.

Do not use one omnipotent long-lived key for every role in production.

## 14.3 Signature model

Preferred modern signing algorithm for direct release metadata/artifact signatures can be Ed25519 or another reviewed algorithm suitable for the final environment.

Use threshold signatures/approvals for root-level trust where operationally practical.

Private signing keys must never live in the repository or client application.

## 14.4 Update client verification sequence

For direct portable/updater channels:

```text
load trusted root
→ verify metadata signatures
→ verify metadata version/freshness
→ verify snapshot consistency
→ verify target path/platform/architecture
→ verify target size
→ verify target SHA-256
→ download/stage
→ verify artifact again
→ checkpoint vault
→ migrate
→ smoke
→ activate
```

Reject:

- hash mismatch
- expired/frozen metadata
- rollback to older metadata version unless explicitly allowed for recovery
- wrong platform/architecture artifact
- unsigned/invalid metadata
- inconsistent snapshot/targets versions
- downgrade below schema compatibility floor.

## 14.5 Rollback/freeze protections

Store trusted metadata version state locally.

Updater must detect:

- rollback attack
- freeze attack / stale timestamp
- mix-and-match metadata
- artifact substitution
- architecture confusion.

Binary rollback, schema rollback, rule-pack rollback, terminology-pack rollback and data restore are different operations.

## 14.6 VEX

Where vulnerability scanning is used, optionally generate/maintain a VEX-style status record for important findings:

- affected
- not affected
- fixed
- under investigation.

Do not mark “not affected” without a reason/evidence record.

## 14.7 Provenance

For each production artifact record:

- artifact SHA-256
- source revision
- dirty/clean source state
- dependency lock digest
- Flutter/Dart versions
- builder identity
- host/runner image
- build command
- build profile
- target platform/architecture
- signing state
- SBOM digest
- test evidence IDs.

SLSA-compatible provenance is a direction, not a claimed level.

## 14.8 Reproducibility

Separate:

- reproducible inputs
- deterministic build configuration
- byte-identical reproducible output.

Do not claim byte-identical reproducibility until at least two independent builds with controlled environments produce matching artifact digests.

## 14.9 Deterministic archives

When producing ZIP/tar artifacts for release, normalize where practical:

- file ordering
- timestamps
- permissions
- owner/group metadata
- compression settings.

Do not normalize away semantically required executable permissions.

## 14.10 Release-trust acceptance tests

At minimum add tests/fixtures for:

1. valid metadata + valid artifact → accepted
2. artifact hash mismatch → rejected
3. stale/expired timestamp metadata → rejected
4. metadata version rollback → rejected
5. targets/snapshot mismatch → rejected
6. wrong architecture target → rejected
7. missing threshold signature → rejected
8. schema-incompatible downgrade → rejected
9. offline installed app continues while update check becomes unavailable
10. vault checkpoint exists before schema-affecting activation.

---

# 15. CI / BUILD MATRIX

CI stages should evolve toward:

1. source checkout
2. toolchain report
3. dependency restore from lockfile
4. format/static checks
5. unit/widget tests
6. platform build
7. applicable runtime smoke
8. SBOM/license inventory
9. vulnerability/VEX review as configured
10. signing/notarization
11. final hashes
12. provenance/attestation
13. update-metadata generation/signing
14. candidate publication
15. promotion gate.

Typical platform runners:

- Linux: Web, Android, Linux desktop
- Windows: Windows desktop
- macOS: iOS/macOS

Never mark a host-incompatible target PASS merely because static analysis succeeded elsewhere.

---

# 16. LINUX DISTRIBUTION STRATEGY

## 16.1 Tier A upstream-supported targets

Candidate source currently identifies Debian 10–13 and Ubuntu 20.04 LTS–24.04 LTS as Flutter-upstream-supported Linux deployment families.

## 16.2 Tier B explicit Human OS compatibility

Fedora and Nobara require Human OS runtime evidence.

Candidate matrix currently includes:

- Fedora 44
- Nobara 44 Official/KDE
- Nobara 44 GNOME where practical.

Do not infer Nobara PASS from Fedora PASS.

## 16.3 Tier C broad compatibility

Representative families can include:

- Linux Mint
- Pop!_OS
- Zorin
- elementary
- KDE neon
- Arch
- EndeavourOS
- Manjaro
- openSUSE.

These become HUMAN_OS_TESTED_COMPATIBILITY only after exact runtime evidence.

## 16.4 Sessions

Test at minimum where applicable:

- GNOME Wayland
- KDE Wayland
- X11.

Do not force X11 merely because one plugin is broken on Wayland.

## 16.5 Data paths

Installed/native Linux should follow XDG-compatible locations where appropriate:

- data: `$XDG_DATA_HOME` / `~/.local/share`
- config: `$XDG_CONFIG_HOME` / `~/.config`
- cache: `$XDG_CACHE_HOME` / `~/.cache`

Use a secure-storage/keyring adapter where available. If unavailable, do not silently downgrade to plaintext key storage.

---

# 17. FIRST REAL VERTICAL SLICE

The first compiled slice should remain deliberately small:

```text
app starts
→ responsive shell
→ Today
→ Timeline
→ Labs
→ non-production build profile visible
→ no network required
```

Widget/runtime evidence should prove:

1. app starts
2. responsive shell renders
3. destination navigation works
4. Today is visible
5. Labs can be opened
6. no network is required.

Do not expand into deep persistence, wearables, clinical rules, or sync before this checkpoint is real.

The next vertical slice should then add:

```text
local user/profile
→ local database
→ one canonical health record
→ save
→ close/reopen
→ same record restored
```

That is the first genuine Human OS heartbeat.

---

# 18. CLAUDE CODE OPERATING MODE

You are operating as:

- principal software engineer
- repository maintainer
- architecture steward
- test/release engineer
- evidence-honest Forge executor.

Do not behave as a chat-only planning assistant.

When implementation is authorized, inspect and edit the repository, run commands, test, repair, and leave repository-visible state.

Do not create speculative code just to appear productive.

---

# 19. PHASE 0 INITIALIZATION

When Claude Code receives this file for the first time, perform a **planning/initialization pass before broad implementation**.

Tasks:

1. inspect repository root
2. inspect git status and branch
3. inventory supplied Human OS artifacts
4. classify CURRENT / CANDIDATE / HISTORICAL / UNKNOWN
5. verify baseline hashes where files exist
6. inspect Flutter/Dart/Git/toolchains
7. inspect Android/JDK/SDK
8. inspect Windows/macOS/Linux build capabilities of host
9. inspect existing source code
10. preserve unrelated/uncommitted user work
11. determine whether real Flutter repository already exists
12. establish or update `CLAUDE.md`
13. establish/update `docs/` and `project_state/`
14. record architecture and platform matrix
15. record security/data/release strategy
16. record test strategy
17. record Forge roadmap
18. define first bounded Forge
19. define first Forge acceptance criteria
20. stop before broad feature implementation.

If the repository already has an equivalent control/state system, reuse it instead of duplicating it.

Suggested repository-visible control files:

```text
CLAUDE.md

docs/
  HUMAN_OS_OVERVIEW.md
  ARCHITECTURE.md
  DEVELOPMENT_PLAN.md
  ROADMAP.md
  PLATFORM_MATRIX.md
  SECURITY_MODEL.md
  DATA_MODEL.md
  TEST_STRATEGY.md
  RELEASE_STRATEGY.md

project_state/
  CURRENT_STATE.json
  FORGE_LOG.md
  DECISIONS.md
  RISKS.md
  KNOWN_GAPS.md
```

---

# 20. CLAUDE.md CONTRACT

If root `CLAUDE.md` is absent or inadequate, create/update it to contain only the durable operational essentials:

- Human OS identity
- critical semantic invariants
- repository structure
- build/test commands
- Forge workflow
- evidence honesty rules
- security boundaries
- source authority pointers.

Do not copy the entire master specification into CLAUDE.md.

---

# 21. GIT SAFETY

Before modification:

```bash
git status
git branch --show-current
```

Do not erase unrelated work.

Avoid destructive commands such as:

- `git reset --hard`
- `git clean -fd`
- force-push

unless explicitly authorized and genuinely necessary.

Do not create commits unless the user/repository workflow requires it.

---

# 22. FORGE LOOP

A user message whose clear intent is `FORGE` authorizes **one bounded meaningful development increment**.

For every Forge:

## A. ORIENT

Read repository state, specs, current code, tests, migrations, decisions and previous Forge log.

## B. SELECT GAP

Choose the highest-value unresolved gap that fits one bounded iteration.

## C. SPECIFY

Define:

- user-visible goal
- domain/model changes
- schema/migration changes
- UI behavior
- platform effects
- security/privacy effects
- failure modes
- tests
- acceptance criteria.

## D. IMPLEMENT

Actually modify repository code/config/tests/docs as needed.

## E. TEST

Run strongest applicable real checks, for example:

```bash
flutter pub get
flutter analyze
flutter test
dart format --output=none --set-exit-if-changed .
```

Then run/build target-specific commands only when supported by the host/toolchain.

## F. INSPECT FIRST DECISIVE FAILURE

Identify the earliest/root actionable failure, not the loudest secondary cascade.

## G. REPAIR

Fix the underlying issue.

## H. RETEST

Rerun the failed gate.

## I. REGRESSION

Rerun relevant previously passing tests/builds.

## J. AUDIT

Check:

- semantic invariants
- data integrity
- security/privacy
- migrations
- dependency drift
- platform divergence
- unsupported medical claims
- fake PASS claims
- UI dead ends
- offline states
- loading/empty/error/recovery states
- accessibility where relevant
- release evidence.

## K. PACKAGE

Produce only artifacts that actually exist and pass the claimed gates.

## L. UPDATE STATE

Update project_state / Forge log / decisions / risks / known gaps.

## M. STOP

Stop after one coherent iteration and recommend exactly one preferred next Forge.

---

# 23. SELF-AUDIT LOOP

Before declaring a Forge complete, run a second-pass audit independent from implementation enthusiasm.

Ask:

- Did I accidentally change observed/planned/completed semantics?
- Did I collapse missing/unknown into zero/false?
- Did I overwrite provenance/history?
- Did I create platform-specific domain forks?
- Did I add a dependency without license/security/platform review?
- Did I claim a build/test I did not actually run?
- Did I create a migration without rollback/recovery?
- Did I leak secrets or health data into logs/repo?
- Did I create a UI path with no error/empty/offline state?
- Did I overstate a health conclusion?
- Did I package an artifact without hash/provenance?

If yes, repair before completion.

---

# 24. FORGE OUTPUT FORMAT

Each Forge response should end with:

```text
# FORGE <N>

## Goal

## Baseline State

## Implemented

## Files Changed

## Data / Migration Changes

## Security / Privacy Impact

## Tests Actually Executed
command → PASS/FAIL

## Builds Actually Executed
platform → command → PASS/FAIL/NOT_RUN/BLOCKED_ENVIRONMENT

## Bugs Found

## Fixes Applied

## Regression Check

## Artifacts Produced
real paths only

## Known Limitations

## State Update

## Next Recommended Forge
exactly one preferred next increment
```

---

# 25. DEVELOPMENT ROADMAP

Use dependency order, not arbitrary feature dumping.

## Stage A: Foundation

- repository/bootstrap
- responsive app shell
- build profiles/config
- local storage abstraction
- canonical health record infrastructure
- migrations/versioning
- security foundation
- logging/error model.

## Stage B: Core Human

- profile
- timeline
- measurements
- labs
- provenance/corrections.

## Stage C: Daily Human

- nutrition
- activity
- sleep
- subjective state.

## Stage D: Medical

- medications
- supplements
- conditions
- documents
- treatments
- preventive care
- care pathways.

## Stage E: Intelligence

- deterministic engines
- longitudinal comparisons
- personal baselines
- longevity
- shortevity
- missions
- education.

## Stage F: Interoperability

- Health Connect
- HealthKit
- imports/exports
- terminology adapters
- provider/reference adapters.

## Stage G: Sync / Recovery

- account
- encrypted sync
- conflict resolution
- backup
- recovery
- multi-device vault semantics.

## Stage H: Desktop

- Windows portable
- Windows installer
- macOS direct distribution
- Linux Flatpak/AppImage/tar/deb/rpm
- updater/signing.

## Stage I: Web / Build Lab

- private Web App
- PWA shell
- synthetic Build Lab.

## Stage J: Release hardening

- accessibility
- performance
- security review
- SBOM
- license inventory
- vulnerability/VEX workflow
- provenance
- signing/notarization
- update metadata
- reproducibility experiments
- deployment.

---

# 26. FIRST FORGE AFTER INITIALIZATION

Unless repository reality strongly suggests otherwise, the first implementation Forge should be:

**Create/repair the real Flutter repository and prove the first compiled shell.**

Reference sequence:

```bash
flutter doctor -v
flutter create --empty --platforms=android,ios,web,windows,macos,linux human_health_os
flutter pub get
flutter analyze
flutter test
```

Then run/build exactly one host-supported target.

Acceptance:

- repository exists
- shared Flutter project exists
- app launches or a real build artifact exists for at least one supported target
- Today → Labs navigation works
- analyzer passes
- widget tests pass
- no cloud required for shell
- build profile visible
- exact evidence recorded.

Stop there.

Do not jump directly to wearables, sync, clinical intelligence, or store publication before the basic repository heartbeat is real.

---

# 27. SECOND FORGE RECOMMENDATION

After the shell is real, preferred next slice:

```text
local profile
→ encrypted local repository foundation
→ one canonical health record
→ save
→ close/reopen
→ read same record
→ correction/provenance metadata preserved
```

This is the first end-to-end persistent health-data slice.

---

# 28. RUNTIME / RELEASE HONESTY

Examples:

```text
Repository generated          PASS
flutter analyze               PASS
flutter test                  PASS
Web build                     PASS
Web runtime smoke             PASS
Windows build                 NOT_RUN
Linux build                   BLOCKED_ENVIRONMENT
Android build                 NOT_RUN
macOS/iOS build               BLOCKED_BY_HOST_OS
```

Never compress these into “all platforms ready”.

---

# 29. INITIAL CLAUDE CODE START COMMAND

When this single file is supplied to Claude Code for the first time, the execution instruction is:

```text
BEGIN HUMAN OS PHASE 0 INITIALIZATION.

Read this entire master file.
Inspect the actual repository and environment.
Reconcile repository reality with the source-authority rules in this file.
Do not broadly implement Human OS yet.
Create/update the repository-visible development control files, architecture assessment, platform matrix, security/data/release plan, test strategy and dependency-ordered Forge roadmap.
Define exactly one FIRST FORGE with objective acceptance criteria.
Self-audit the initialization artifacts for contradictions and repair them.
Then stop and report INITIALIZATION_COMPLETE or INITIALIZATION_BLOCKED.

Wait for the user to send FORGE before implementing the first bounded increment.
```

Future user command:

```text
FORGE
```

means execute exactly one bounded Forge loop from Section 22.

---


# 30. v0.30 TRIPLE FORGE DELTA

v0.30 intentionally performs three tightly related governance Forges in one master-file revision without pretending that three unrelated product features were implemented.

The three tracks are:

### FORGE-A — Execution State + Resume Engine
Make Claude Code able to determine exactly where development stopped, resume safely after interruption, and avoid restarting completed work.

### FORGE-B — Evidence + Definition of Done + Recovery
Make every PASS claim traceable to an actual command/artifact/receipt and make migrations/backups/recovery first-class before private health data becomes durable.

### FORGE-C — Implementation Ladder + Platform Parity
Turn the broad roadmap into a dependency-ordered set of concrete vertical slices with entry/exit gates, while keeping Android/iOS/Web/Windows/macOS/Linux on one canonical core.

These are process/architecture upgrades to the Claude Code development contract. They do not claim that the Flutter application, native packages, encryption, or clinical engines were already implemented.

---

# 31. DEVELOPMENT EXECUTION STATE MACHINE

Claude Code must maintain a **single canonical development cursor** instead of inferring progress from chat prose.

The repository-visible state should conceptually move through:

```text
UNINITIALIZED
   ↓
INITIALIZING
   ↓
READY
   ↓
FORGE_PLANNING
   ↓
IMPLEMENTING
   ↓
TESTING
   ↓
REPAIRING  ←──── failure
   ↓                │
REGRESSION ─────────┘
   ↓
PACKAGING
   ↓
FORGE_COMPLETE
   ↓
READY
```

Exceptional states:

```text
BLOCKED_ENVIRONMENT
BLOCKED_DECISION
RECOVERY_REQUIRED
ROLLBACK_REQUIRED
RELEASE_CANDIDATE
RELEASED
```

## 31.1 Canonical state owner

Use one repository-visible state file, preferably:

`project_state/CURRENT_STATE.json`

If an equivalent existing state file already exists, reuse it instead of creating a competing authority.

Minimum logical fields:

```json
{
  "schema_version": "1",
  "project": "Human OS",
  "product_version": "candidate-or-release-version",
  "development_state": "READY",
  "active_forge": null,
  "last_completed_forge": "F000",
  "baseline": {
    "git_commit": "UNKNOWN",
    "working_tree": "UNKNOWN",
    "master_spec_sha256": "..."
  },
  "verified_gates": [],
  "known_blockers": [],
  "next_recommended_forge": null,
  "updated_at": "RFC3339 timestamp"
}
```

Do not copy this example mechanically if the repository already has a better compatible schema.

## 31.2 Active Forge record

During a Forge, `active_forge` should record enough information to resume after interruption:

```json
{
  "forge_id": "F001",
  "goal": "first compiled shell",
  "status": "TESTING",
  "baseline_commit": "<commit-or-UNKNOWN>",
  "started_at": "...",
  "scope": ["..."],
  "acceptance_criteria": ["..."],
  "completed_steps": ["..."],
  "last_verified_gate": "flutter analyze",
  "next_action": "run flutter test",
  "files_touched": ["..."],
  "migration_ids": [],
  "evidence_ids": ["EV-..."],
  "blocker": null
}
```

The active Forge record is a cursor, not a substitute for Git history or test evidence.

## 31.3 Resume algorithm

When Claude Code starts and finds an existing repository:

1. read `CLAUDE.md`
2. read current state
3. inspect `git status`
4. inspect the active Forge record
5. compare state-declared files against actual working-tree changes
6. identify the last verified gate
7. verify whether prior command evidence still corresponds to the same source tree
8. resume from the first unverified action
9. do not rerun destructive migrations blindly
10. do not mark an interrupted Forge complete merely because code exists.

If state and repository disagree:

`repository reality > state summary`

Record the discrepancy and repair the state file.

## 31.4 Interrupted Forge

An interrupted Forge is not automatically failed.

Use:

- `IN_PROGRESS_RECOVERABLE` when code/state can be safely inspected and resumed
- `RECOVERY_REQUIRED` when a migration/build/update may have partially mutated state
- `BLOCKED_ENVIRONMENT` when required tooling vanished or host capability changed.

Before resuming a partially executed migration or packaging step, inspect its receipts/artifacts.

## 31.5 Idempotence

A repeated Forge command must not blindly redo already completed irreversible operations.

Prefer idempotent scripts/migrations and check-before-create behavior.

Examples:

- creating a directory that already exists should not reset it
- applying a migration already recorded as applied must be rejected or no-op according to the migration framework
- generating platform scaffolding must not overwrite hand-edited platform files without diff/review
- packaging may be rerun from fixed inputs but must create new evidence for the new artifact bytes.

---

# 32. FORGE COMMAND ROUTER AND BATCH AUTHORIZATION

Default command behavior remains:

`FORGE` = exactly one bounded meaningful development increment.

v0.30 additionally defines explicit bounded batching for users who deliberately request several Forges at once.

Accepted intent examples:

```text
FORGE x3
FORGE 3
FORGE FORGE FORGE
```

Interpretation:

- authorize **up to three sequential Forge iterations**
- each Forge remains independently scoped, tested, audited, logged and closed
- do not merge three Forges into one giant uncontrolled diff
- stop early if a blocking failure, migration risk, missing decision, or failing regression gate occurs
- never skip a failed Forge merely to reach the next number.

Batch algorithm:

```text
for each authorized Forge:
    orient
    choose one bounded gap
    implement
    test
    repair
    regression
    audit
    package/evidence
    update state
    close Forge
    if blocking failure: STOP
```

A repeated word is authorization for sequential increments, **not permission to replay already-completed work**.

If the user says only `FORGE` after a previous Forge completed, choose the next highest-value READY item.

---

# 33. EVIDENCE RECEIPT SYSTEM

Human OS development must derive claims from evidence rather than prose memory.

Recommended repository structure:

```text
project_state/
  CURRENT_STATE.json
  FORGE_LOG.md
  DECISIONS.md
  RISKS.md
  KNOWN_GAPS.md

evidence/
  tests/
  builds/
  artifacts/
  migrations/
  releases/
```

Do not commit huge raw logs unnecessarily. Store concise receipts and hashes/paths to larger CI artifacts when appropriate.

## 33.1 Test receipt

A test receipt should record at least:

```json
{
  "evidence_id": "EV-TEST-0001",
  "kind": "TEST",
  "forge_id": "F001",
  "source_revision": "...",
  "working_tree_dirty": false,
  "command": "flutter test",
  "cwd": ".",
  "started_at": "...",
  "finished_at": "...",
  "exit_code": 0,
  "result": "PASS",
  "tool_versions": {
    "flutter": "...",
    "dart": "..."
  },
  "summary": "...",
  "log_sha256": "optional"
}
```

Do not fabricate timestamps, tool versions or exit codes.

## 33.2 Build receipt

A build receipt should identify:

- target platform
- architecture
- build profile
- exact command
- source revision
- dependency lock digest
- toolchain versions
- produced artifact path
- artifact size
- SHA-256
- signing state
- smoke-test state.

A build receipt with no runtime smoke is `COMPILED/PACKAGED`, not necessarily `RUNTIME_TESTED`.

## 33.3 Migration receipt

For every applied persistent-data migration record:

- migration ID
- source schema version
- target schema version
- pre-migration backup/checkpoint state
- start/end time
- result
- record counts or integrity checks when meaningful
- rollback/recovery availability
- error if failed.

## 33.4 Release receipt

A release receipt aggregates actual evidence IDs rather than duplicating test claims in prose.

Example relationships:

```text
Release R0.1.0
 ├─ build EV-BUILD-WIN-001
 ├─ build EV-BUILD-LINUX-001
 ├─ test EV-TEST-CORE-003
 ├─ SBOM EV-SBOM-001
 ├─ provenance EV-PROV-001
 └─ signing EV-SIGN-001
```

## 33.5 Evidence invalidation

Evidence can become stale.

If source code, dependency lock, build profile, migration schema, or relevant configuration changes after a PASS, do not automatically carry the PASS forward.

The Forge should know which gates must be rerun.

---

# 34. DEFINITION OF DONE

A Forge is DONE only when all criteria relevant to its scope are satisfied.

Minimum Definition of Done:

1. scope is explicit
2. acceptance criteria are explicit
3. implementation exists
4. code formatting/static checks applicable to touched code are run
5. relevant tests are run
6. failures are repaired or the Forge is marked BLOCKED/FAIL
7. regression gates are run
8. semantic invariants are audited
9. privacy/security impact is reviewed
10. migrations are evidenced when present
11. documentation/state is updated
12. produced artifacts are hashed when relevant
13. no PASS is claimed without receipt/evidence
14. known limitations are recorded
15. exactly one next preferred Forge is identified.

A Forge is NOT DONE merely because:

- code was generated
- TODOs were written
- tests were authored but not run
- one happy-path screenshot exists
- the app compiled on one platform
- a packaging script exists
- an AI says the design looks correct.

## 34.1 Scope-quality gate

A Forge scope is too large if it simultaneously requires multiple independent irreversible migrations, several unrelated product domains, and multiple new platform integrations.

Split it.

A Forge scope is too small if it changes only comments/naming with no meaningful capability, quality, correctness or maintainability gain unless that exact repair is the blocking issue.

## 34.2 No TODO dumping

Do not replace implementation with dozens of speculative TODOs.

A bounded Forge should close a usable slice and leave a small explicit gap list.

---

# 35. SCHEMA, MIGRATION AND DATA-COMPATIBILITY CONTRACT

Health data survives application versions. Schema evolution therefore becomes a release-critical system.

Maintain separate versions for:

- application product version
- local database schema version
- sync protocol version
- model/rule pack versions
- terminology/reference pack versions.

Do not infer one from another.

## 35.1 Migration graph

Every persistent schema change should have an ordered migration identity.

Example:

```text
schema 1
  ↓ M002
schema 2
  ↓ M003
schema 3
```

Avoid hidden schema mutation during ordinary reads.

## 35.2 Destructive migration rule

Before a destructive or lossy migration:

- prove why it is necessary
- preserve recoverable backup/checkpoint
- define transformation of existing records
- define what cannot be preserved
- test representative old data
- verify post-migration integrity.

For personal health history, “drop and recreate” is not an acceptable production migration strategy except for explicitly disposable synthetic/test data.

## 35.3 Compatibility metadata

A binary should know at minimum:

- schema versions it can read
- schema version it writes
- whether downgrade is supported
- minimum compatible rule/reference pack where required.

If an old binary cannot safely open a newer vault:

**block open and offer recovery/update guidance** rather than attempting unsafe downgrade.

## 35.4 Migration fixtures

Maintain anonymized/synthetic fixtures representing important historical schema versions.

Migration tests should verify:

- record identity preserved
- provenance preserved
- correction lineage preserved
- attachments remain reachable
- unknown/missing states do not become zero/false
- no duplicate events are introduced
- date/time semantics remain stable.

---

# 36. BACKUP, RESTORE AND DISASTER-RECOVERY CONTRACT

Before Human OS becomes trusted with real health history, backup/restore must be testable rather than aspirational.

## 36.1 Backup types

Conceptually support:

### Local encrypted backup
User-controlled encrypted export of the canonical local vault.

### Portable migration backup
Used when moving between installed/portable modes or machines.

### Cloud backup/sync snapshot
Optional later capability. Must not become the only recovery path unless explicitly accepted.

## 36.2 Backup manifest

A backup should be self-describing enough to validate restore:

- backup format version
- source app version
- schema version
- created_at
- profile/vault stable identifier
- encrypted payload digest(s)
- attachment manifest
- algorithm/KDF metadata necessary for supported decryption
- no secret key embedded in plaintext.

## 36.3 Restore gate

Restore sequence:

```text
select backup
→ authenticate/decrypt
→ verify manifest/hash
→ inspect schema compatibility
→ restore into staged destination
→ validate record/attachment integrity
→ switch active vault only after validation
```

Never overwrite the only good live vault before verifying the staged restore.

## 36.4 Restore drill

A public release that claims backup safety should periodically run an actual synthetic restore drill.

`backup created` != `backup restorable`.

---

# 37. PRIVACY-PRESERVING OBSERVABILITY

Human OS needs debugging evidence without turning logs into a second health database.

## 37.1 Default logging rule

Do not log raw health values, diagnoses, document text, medication names, account tokens, encryption keys or attachment contents by default.

Prefer structured operational fields:

- event name
- feature/domain
- anonymized/local correlation ID
- error class
- schema/model version
- platform
- timing/duration
- success/failure.

## 37.2 Redaction

Centralize redaction rather than relying on every developer to remember it.

Test redaction with synthetic sensitive strings.

## 37.3 Crash reporting

If remote crash reporting is introduced:

- disclose it
- minimize payload
- scrub sensitive fields
- respect user/privacy configuration and applicable requirements
- do not upload full database/documents as “debug context”.

## 37.4 Developer diagnostics

A local diagnostics export can include environment/version/test information, but health-content inclusion must be explicit and opt-in.

---

# 38. CROSS-PLATFORM PARITY MATRIX

One shared core does not mean every platform exposes identical native capabilities.

Maintain a matrix such as:

```text
Capability              Android  iOS   Web  Windows  macOS  Linux
Core local records      REQUIRED REQUIRED REQUIRED REQUIRED REQUIRED REQUIRED
Timeline                REQUIRED REQUIRED REQUIRED REQUIRED REQUIRED REQUIRED
Labs                    REQUIRED REQUIRED REQUIRED REQUIRED REQUIRED REQUIRED
Offline deterministic   REQUIRED REQUIRED CONDITIONAL REQUIRED REQUIRED REQUIRED
Health Connect          YES      N/A   NO   NO       NO     NO
HealthKit               N/A      YES   NO   NO       CONDITIONAL* NO
Portable vault          NO       NO    NO   YES      OPTIONAL YES
Native notifications    YES      YES   LIMITED YES    YES    YES
PWA install             N/A      N/A   YES  N/A      N/A    N/A
```

`*` only where Apple APIs and entitlement/platform rules permit; verify implementation reality.

Use states:

- REQUIRED
- SUPPORTED
- PARTIAL
- UNSUPPORTED_BY_PLATFORM
- BLOCKED_ENVIRONMENT
- NOT_IMPLEMENTED
- NOT_TESTED.

Do not hide platform gaps behind generic “cross-platform” wording.

## 38.1 Parity rule

A platform adapter may differ in implementation while preserving canonical semantics.

Example:

```text
Health Connect sleep record ─┐
                            ├→ canonical SleepRecord
HealthKit sleep record ─────┘
```

Provider fields that cannot be represented losslessly remain attached as source metadata/extensions rather than being discarded.

---

# 39. CONCRETE VERTICAL-SLICE DELIVERY LADDER

The roadmap in Section 25 is strategic. This ladder gives Claude Code a more operational default sequence.

Repository reality may change ordering, but dependencies should be respected.

## F001 — Repository heartbeat

Goal:
- actual Flutter repository
- responsive shell
- Today / Timeline / Labs navigation
- build profile indicator
- first host-supported compile/runtime smoke.

Exit:
- analyzer/test PASS
- one host-supported build/runtime receipt
- no domain persistence yet.

## F002 — Local profile + persistence heartbeat

Goal:
- local profile identity
- repository port
- one canonical health-record type
- create/save/read after restart
- provenance + stable ID.

Exit:
- persistence integration test
- migration version initialized
- no plaintext-secret shortcut.

## F003 — Timeline + correction lineage

Goal:
- timeline projection
- edit/correction creates lineage rather than destructive rewrite
- delete semantics differentiated from correction/entered-in-error.

Exit:
- timeline ordering tests
- correction-history tests.

## F004 — Labs vertical slice

Goal:
- manual LabResult entry
- source label/value/unit/date/specimen fields
- range metadata kept distinct from app interpretation
- timeline integration.

Exit:
- missing unit/range remains missing
- source flag preserved
- no diagnosis generated.

## F005 — Import/export + backup foundation

Goal:
- deterministic export of a small canonical subset
- encrypted backup foundation
- staged restore for synthetic profile.

Exit:
- backup→delete test vault→restore→same records
- checksums/manifest verified.

## F006 — Local security hardening

Goal:
- reviewed secret/key abstraction
- native installed vault protection
- Windows/Linux portable-vault mode foundation
- redacted logs.

Exit:
- sensitive-data logging tests
- key-loss/recovery states defined
- no plaintext fallback.

## F007 — Daily domains

Incrementally add bounded slices for:
- measurements
- nutrition
- activity
- sleep
- subjective state.

Do not add all in one Forge; each can be its own Forge.

## F008 — Medication/supplement semantics

Start with:
- ingredient/product separation
- plan vs intake
- observed exposure.

Interaction intelligence comes later after identity and source governance are real.

## F009 — Conditions / preventive / care pathways

Start with provenance and state machines before sophisticated clinical rules.

## F010 — Documents

Attachment storage → metadata → safe extraction candidates → reviewed commit.

Do not let OCR extraction silently mutate canonical health records.

## F011 — Deterministic intelligence

Introduce engines only after canonical inputs exist:
- trends
- personal baselines
- transparent model outputs
- Longevity / Shortevity modules.

Golden vectors required.

## F012 — Build Lab

Reuse canonical model/engines with synthetic-only default data.

Build Lab cannot fork formulas from the product core.

## F013 — Platform health adapters

Separate Forges for:
- Health Connect
- HealthKit
- other provider integrations.

Adapter import receipts and duplicate handling required.

## F014 — Sync/account

Only after local-first correctness and migrations are stable:
- account
- outbox
- encrypted sync strategy
- conflicts
- multi-device recovery.

## F015 — Desktop distribution

Build/test actual:
- Windows portable
- Windows installer
- macOS direct path
- Linux Flatpak/AppImage/tar/deb/rpm as supported.

Packaging PASS is format-specific.

## F016 — Web/PWA production client

Private Web App, storage limits, backup/export, offline shell where supported.

## F017 — Release trust

Implement actual signed update metadata, SBOM, provenance and release promotion workflow.

Do not jump here while builds are still hypothetical.

---

# 40. GOLDEN VECTORS, PROPERTY TESTS AND BUILD LAB FIDELITY

Deterministic health engines require stable test vectors.

## 40.1 Golden vector

A golden vector is a fixed input + versioned expected output used to detect accidental calculation changes.

Each vector should declare:

- engine/rule ID
- engine/rule version
- inputs
- expected outputs
- tolerances where justified
- missing/unknown behavior
- provenance of the vector.

## 40.2 Property/invariant tests

Where useful, test general properties rather than only example numbers.

Examples:

- missing input never silently becomes zero
- scenario edit never mutates source profile
- correction preserves original record
- unit round-trip conversion remains within declared tolerance
- plan creation does not create completion event
- unsupported jurisdiction does not fall back silently.

## 40.3 Build Lab fidelity

When Build Lab uses a production engine:

- import/call the same canonical implementation or package
- do not copy-paste formulas into a separate web-only implementation
- show engine/rule version
- use the same golden vectors in product and Build Lab CI where feasible.

A pretty Build Lab screenshot is not evidence that product calculation parity is correct.

---

# 41. SECURITY THREAT-MODEL CHECKLIST

Before adding a sensitive capability, ask what an attacker or accidental failure can do.

Threat classes to consider:

### Device loss
Can someone with a lost laptop/USB read the portable vault offline?

### Malicious update
Can compromised hosting replace Human OS binaries or metadata?

### Dependency compromise
Can a poisoned package or transitive dependency enter release unnoticed?

### Secret leakage
Can API/signing/encryption secrets enter repo, logs, crash reports or client binaries?

### Path traversal / malicious import
Can a crafted archive/document write outside the intended attachment/import area?

### Database corruption
Can a crash during migration/update leave the only vault unreadable?

### Sync replay/conflict
Can stale remote state overwrite newer local truth?

### Authorization failure
Can one account/profile access another profile's private health data?

### Logging leakage
Can health values/diagnoses appear in CI logs or telemetry?

### Model/rule substitution
Can an outdated or untrusted model/rule pack silently change health conclusions?

For every relevant threat, record:

- asset
- threat
- trust boundary
- mitigation
- residual risk
- test/evidence.

Do not create security theater by checking boxes with no implementation evidence.

---

# 42. CLAUDE CODE BOOT / RESUME ROUTER

> **v0.32 ONE-SHOT PRECEDENCE NOTICE:** This section is retained for later resume/recovery and post-F001 development. For the **first v0.32 one-shot launch**, the `EXECUTION KERNEL · v0.32` at the top of this file overrides any branch below that says to stop after Phase 0, wait for another message, or require a separate `FORGE` before F001. If the user attached this master and clearly authorized execution, Phase 0 and F001 belong to the same bounded first run.

This supersedes a simplistic “always run Phase 0” behavior for later sessions.

When Claude Code receives this master file, use the following router:

```text
READ MASTER
   ↓
INSPECT REPOSITORY
   ↓
Does canonical project state exist?
   ├─ NO → run PHASE 0 INITIALIZATION → stop
   └─ YES
        ↓
Is an unfinished Forge recorded?
   ├─ YES → reconcile state with git/files/evidence → recover/resume safely
   └─ NO
        ↓
Is initialization complete?
   ├─ NO → complete initialization → stop
   └─ YES → report READY and wait for FORGE unless the user's current command already authorizes it
```

If the user supplied this file together with `FORGE`, `FORGE xN`, or repeated Forge authorization:

1. perform boot/resume routing first
2. do not redo completed initialization
3. execute only the authorized bounded Forge count
4. close each Forge independently
5. stop at the first real blocker.

Historical/multi-turn reference command for a brand-new repository. **Do not use this stop-after-Phase-0 behavior for the first v0.32 one-shot run:**

```text
BEGIN HUMAN OS

Read the entire Human OS master specification.
Inspect repository, Git state, source artifacts and available toolchains.
If project_state/CURRENT_STATE.json or an equivalent canonical state exists, reconcile and resume instead of resetting the project.
If the project is uninitialized, perform Phase 0 only, create/update CLAUDE.md and repository-visible planning/state files, define F001 with objective gates, self-audit, then stop.
Do not claim implementation/build evidence that was not executed.
```

Later-session development command after the first v0.32 one-shot run:

```text
FORGE
```

For three explicitly authorized sequential increments:

```text
FORGE x3
```

or an equivalent clearly intentional repeated Forge command.

---

# 43. CUMULATIVE MASTER SELF-AUDIT CHECKLIST

Before Claude Code treats this master as operational guidance, verify:

- candidate vs CURRENT distinction is retained
- v0.26 baseline requirement is not erased
- six client/platform targets remain Android/iOS/Web/Windows/macOS/Linux
- Build Lab remains auxiliary synthetic surface
- one shared canonical core remains the architecture
- local-first/offline semantics remain
- observed/reported/planned/completed/derived/modelled distinctions remain
- no clinical threshold/rule is invented by this process layer
- Windows portable does not require literal single EXE
- Linux compatibility is evidence-tiered
- package-format PASS is not propagated to other package formats
- Forge batching closes each Forge independently
- state summary never outranks repository reality
- test/build PASS requires execution evidence
- migrations require recovery thinking
- backup creation is not treated as restore proof
- logs do not become hidden PHI stores
- Build Lab cannot fork production calculation logic
- release trust does not claim TUF/SLSA compliance without implementation evidence.

If any item fails, repair the master/state before implementation continues.

---

# 44. CURRENT NEXT DEVELOPMENT PRIORITY

This master is now sufficiently detailed that further planning-only Forge work has diminishing returns.

The preferred next step is **execution**, not another giant architecture document.

Priority:

```text
F001 — Repository heartbeat
```

If a real Flutter repository already exists and F001 evidence already passes, do not recreate it. Advance to the earliest incomplete ladder item supported by actual evidence.

The key rule is:

> plan only until the next safe executable slice is clear, then build and test it.

---

# 45. SINGLE-FILE APPENDIX POLICY

The remainder of this document embeds the v0.27/v0.28 candidate source files. The v0.29/v0.30 orchestration and trust enrichments are integrated directly above rather than duplicated as separate appendices. They are included so Claude Code can inspect the original candidate wording and machine contracts without requiring separate attachments.

If the integrated plan above conflicts with an embedded source, do not silently guess. Use the source-authority rules and repository reality. Record the conflict.



---

# APPENDIX SOURCE: `00_READ_THIS_FIRST.md`

<!-- BEGIN EMBEDDED SOURCE: 00_READ_THIS_FIRST.md -->

# HUMAN HEALTH OS v0.28-candidate — CUMULATIVE CANDIDATE PATCH

Status: `CANDIDATE_DELTA_ONLY`.

Required full baseline:
`LONGEVITY_APP_DEVELOPER_HANDOFF_v0.26.zip`
SHA-256: `687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369`

Parent candidate incorporated and verified:
`LONGEVITY_APP_v0.27_CANDIDATE_PATCH.zip`
SHA-256: `ffd50fd4fa2fc197fc5e118bca72c10e25384bc9cc9a4dcf4154eae7f90e488a`

v0.28 adds first-class Linux distribution planning and packaging scaffolds for Debian/Ubuntu, Fedora/Nobara and broader Linux families through Flatpak/AppImage/native packages.

This cumulative patch includes the v0.27 repository-bootstrap candidate plus the v0.28 Linux delta.

The exact v0.26 baseline bytes are still not present in this active runtime, therefore this artifact does NOT claim full v0.28 CURRENT promotion.

Flutter/Linux compilation and real package/runtime smoke tests remain separately evidenced and are NOT_RUN here when tooling is absent.

<!-- END EMBEDDED SOURCE: 00_READ_THIS_FIRST.md -->


---

# APPENDIX SOURCE: `LONGEVITY_APP_MASTER_ADDENDUM_v0.28_CANDIDATE.md`

<!-- BEGIN EMBEDDED SOURCE: LONGEVITY_APP_MASTER_ADDENDUM_v0.28_CANDIDATE.md -->

# HUMAN HEALTH OS — MASTER ADDENDUM v0.28 CANDIDATE

Status: CANDIDATE_DELTA_ONLY.

This cumulative candidate contains the v0.27 repository-bootstrap/supply-chain increment and v0.28 Linux cross-distribution increment. It requires the exact v0.26 full baseline before CURRENT promotion.

## v0.28 Linux intent

Human OS Linux becomes a first-class shared Flutter target. The packaging strategy is Flatpak + AppImage (when validated) + portable tar fallback + DEB + RPM, with explicit Ubuntu/Debian/Fedora/Nobara smoke evidence and broad derivative coverage through distro-neutral packaging.

## New authoritative addendum files

- `216_LINUX_CROSS_DISTRO_DISTRIBUTION_CONTRACT.md`
- `217_LINUX_DISTRO_FAMILY_AND_SUPPORT_MATRIX.md`
- `218_LINUX_PORTABLE_APPIMAGE_AND_TARBALL.md`
- `219_LINUX_FLATPAK_SANDBOX_PORTALS_AND_PERMISSIONS.md`
- `220_LINUX_DEB_RPM_NATIVE_PACKAGES.md`
- `221_LINUX_DATA_VAULT_XDG_AND_KEYRING.md`
- `222_LINUX_SIGNING_UPDATE_SBOM_AND_RELEASE_PROVENANCE.md`
- `223_LINUX_CI_DISTRO_AND_SESSION_SMOKE_MATRIX.md`
- `224_LINUX_RUNTIME_FAILURE_RECOVERY_AND_DESKTOP_INTEGRATION.md`
- `225_LINUX_RELEASE_ARTIFACT_MATRIX.md`
- `226_LINUX_DISTRIBUTION_SYNTHETIC_FIXTURES.md`

## Runtime honesty

No Linux binary/package was compiled in this Forge because Flutter and Linux package-builder toolchains are not installed in the active runtime. Structural contracts and packaging scaffolds were validated; runtime/package claims remain NOT_RUN.

<!-- END EMBEDDED SOURCE: LONGEVITY_APP_MASTER_ADDENDUM_v0.28_CANDIDATE.md -->


---

# APPENDIX SOURCE: `207_FLUTTER_REPOSITORY_BOOTSTRAP_CONTRACT.md`

<!-- BEGIN EMBEDDED SOURCE: 207_FLUTTER_REPOSITORY_BOOTSTRAP_CONTRACT.md -->

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

<!-- END EMBEDDED SOURCE: 207_FLUTTER_REPOSITORY_BOOTSTRAP_CONTRACT.md -->


---

# APPENDIX SOURCE: `208_REPOSITORY_LAYOUT_AND_ARCHITECTURE.md`

<!-- BEGIN EMBEDDED SOURCE: 208_REPOSITORY_LAYOUT_AND_ARCHITECTURE.md -->

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

<!-- END EMBEDDED SOURCE: 208_REPOSITORY_LAYOUT_AND_ARCHITECTURE.md -->


---

# APPENDIX SOURCE: `209_FIRST_APP_SHELL_VERTICAL_SLICE.md`

<!-- BEGIN EMBEDDED SOURCE: 209_FIRST_APP_SHELL_VERTICAL_SLICE.md -->

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

<!-- END EMBEDDED SOURCE: 209_FIRST_APP_SHELL_VERTICAL_SLICE.md -->


---

# APPENDIX SOURCE: `210_LOCAL_FIRST_PORTS_AND_PLATFORM_ADAPTERS.md`

<!-- BEGIN EMBEDDED SOURCE: 210_LOCAL_FIRST_PORTS_AND_PLATFORM_ADAPTERS.md -->

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

<!-- END EMBEDDED SOURCE: 210_LOCAL_FIRST_PORTS_AND_PLATFORM_ADAPTERS.md -->


---

# APPENDIX SOURCE: `211_BUILD_PROFILES_CONFIGURATION_AND_SECRETS.md`

<!-- BEGIN EMBEDDED SOURCE: 211_BUILD_PROFILES_CONFIGURATION_AND_SECRETS.md -->

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

<!-- END EMBEDDED SOURCE: 211_BUILD_PROFILES_CONFIGURATION_AND_SECRETS.md -->


---

# APPENDIX SOURCE: `212_DEPENDENCY_LOCK_SBOM_LICENSE_AND_SUPPLY_CHAIN.md`

<!-- BEGIN EMBEDDED SOURCE: 212_DEPENDENCY_LOCK_SBOM_LICENSE_AND_SUPPLY_CHAIN.md -->

# DEPENDENCY LOCK, SBOM, LICENSE AND SUPPLY CHAIN

Human Health OS is an application, so the real repository commits `pubspec.lock` once created. Production builds use the committed lock rather than silently refreshing package versions.

Dependency updates follow: `update request → lockfile diff → license/security review → analyze/test → platform smoke → accept`.

Record dependency name, version, source, purpose, direct/transitive state, license, native-code presence and privacy/security relevance.

Public release generates a Software Bill of Materials (SBOM), preferably SPDX or CycloneDX. Unknown/incompatible license state blocks public distribution until resolved.

Unreviewed arbitrary Git commits, local path dependencies or unauthenticated archives block production release.

Vulnerability findings are triage inputs. Check affected version, reachability, platform exposure, fix/workaround and regression risk.

<!-- END EMBEDDED SOURCE: 212_DEPENDENCY_LOCK_SBOM_LICENSE_AND_SUPPLY_CHAIN.md -->


---

# APPENDIX SOURCE: `213_CI_BUILD_MATRIX_PROVENANCE_AND_ATTESTATION.md`

<!-- BEGIN EMBEDDED SOURCE: 213_CI_BUILD_MATRIX_PROVENANCE_AND_ATTESTATION.md -->

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

<!-- END EMBEDDED SOURCE: 213_CI_BUILD_MATRIX_PROVENANCE_AND_ATTESTATION.md -->


---

# APPENDIX SOURCE: `214_RELEASE_CHANNEL_UPDATE_METADATA_AND_ROLLBACK.md`

<!-- BEGIN EMBEDDED SOURCE: 214_RELEASE_CHANNEL_UPDATE_METADATA_AND_ROLLBACK.md -->

# RELEASE CHANNEL, UPDATE METADATA AND ROLLBACK

Channels: development, internal, beta, production.

Update metadata can include release ID, product/build, platform/architecture, schema compatibility, download locator, artifact SHA-256, signature/attestation locator and release notes.

Do not trust mutable update metadata solely because transport uses HTTPS. Production updater needs an authenticated/signature strategy appropriate to its final design.

Before schema-affecting update create a consistent vault checkpoint/backup and migration plan. Binary rollback, schema rollback and rule/content-pack rollback are distinct.

Offline means the installed app continues; update status becomes unavailable, never fake success.

<!-- END EMBEDDED SOURCE: 214_RELEASE_CHANNEL_UPDATE_METADATA_AND_ROLLBACK.md -->


---

# APPENDIX SOURCE: `215_FIRST_COMPILED_SLICE_ACCEPTANCE_GATE.md`

<!-- BEGIN EMBEDDED SOURCE: 215_FIRST_COMPILED_SLICE_ACCEPTANCE_GATE.md -->

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

<!-- END EMBEDDED SOURCE: 215_FIRST_COMPILED_SLICE_ACCEPTANCE_GATE.md -->


---

# APPENDIX SOURCE: `216_LINUX_CROSS_DISTRO_DISTRIBUTION_CONTRACT.md`

<!-- BEGIN EMBEDDED SOURCE: 216_LINUX_CROSS_DISTRO_DISTRIBUTION_CONTRACT.md -->

# LINUX CROSS-DISTRIBUTION CONTRACT

## Goal

Human Health OS Linux must be usable across the major desktop Linux families without creating a separate health application for each distribution.

Target families:
- Debian / Ubuntu and derivatives
- Fedora / Nobara and RPM-family desktops
- Arch-family desktops
- openSUSE-family desktops
- other modern distributions through distro-neutral packaging when compatible.

The shared Flutter/Dart Human OS core remains identical to Android/iOS/Web/Windows/macOS.

## Honest support levels

Do not claim "every Linux distro is supported" from one successful build.

Use three states:

### UPSTREAM_SUPPORTED_FLUTTER_TARGET
Current Flutter documentation explicitly lists the target OS/version/architecture.

### HUMAN_OS_TESTED_COMPATIBILITY
Not necessarily listed by Flutter upstream, but Human OS has executed its own install/start/persist/offline smoke suite on the exact distro/release/desktop session.

### BEST_EFFORT_UNVERIFIED
Packaging is intended to work, but no current runtime evidence exists.

## Required distribution channels

Linux production planning includes:
1. Flatpak as the primary distro-neutral installed channel.
2. AppImage as the primary portable single-file-style channel when its runtime/FUSE tests pass.
3. Portable release bundle/tar archive fallback for systems where AppImage cannot run.
4. `.deb` packages for Debian/Ubuntu families.
5. `.rpm` packages for Fedora/Nobara/RPM families.
6. Snap as optional, not the sole Ubuntu/Linux channel.

No one package format is allowed to define Linux support alone.

## Architectures

Plan for:
- x86_64 first
- arm64/aarch64 when Flutter/plugins/build hosts support it and runtime tests pass.

Architecture is explicit in artifact metadata and filenames.

## Desktop sessions

Runtime test matrix should include Wayland first-class coverage and X11 compatibility where the distro still provides it.
Nobara must be tested on its actually supported desktop/session combinations rather than assuming Fedora behavior is identical.

<!-- END EMBEDDED SOURCE: 216_LINUX_CROSS_DISTRO_DISTRIBUTION_CONTRACT.md -->


---

# APPENDIX SOURCE: `217_LINUX_DISTRO_FAMILY_AND_SUPPORT_MATRIX.md`

<!-- BEGIN EMBEDDED SOURCE: 217_LINUX_DISTRO_FAMILY_AND_SUPPORT_MATRIX.md -->

# LINUX DISTRO FAMILY AND SUPPORT MATRIX

Checked: 2026-10-06.

## Tier A: Flutter upstream-supported Linux deployment targets

Current Flutter supported-platform documentation lists:
- Debian 10–13, x64 and arm64
- Ubuntu 20.04 LTS–24.04 LTS, x64 and arm64.

These are the first Linux release-gate targets.

Recommended concrete Human OS smoke set:
- Debian 12 x86_64
- Debian 13 x86_64
- Ubuntu 22.04 LTS x86_64
- Ubuntu 24.04 LTS x86_64
- arm64 representatives when CI hardware is available.

## Tier B: explicit Human OS compatibility targets

### Fedora

Current stable checked release on 2026-10-06: Fedora 44.
Fedora 45 is still beta/pre-release at the checked date.

Required compatibility smoke:
- Fedora Workstation 44
- Fedora KDE 44 when practical.

When Fedora 45 becomes final, add it through a versioned compatibility update rather than silently changing the test baseline.

### Nobara

Current checked Nobara release: Nobara 44.
Nobara describes itself as Fedora-based but independent, with modified packages/repositories.

Required compatibility smoke:
- Nobara 44 Official/KDE
- Nobara 44 GNOME when practical.

Do not infer Nobara PASS from Fedora PASS.

## Tier C: broad compatibility targets

Use Flatpak/AppImage and selected native-package smoke coverage for representative families:
- Linux Mint / Pop!_OS / Zorin / elementary / KDE neon
- Arch / EndeavourOS / Manjaro
- openSUSE Tumbleweed / Leap
- other modern desktop distributions.

These become `HUMAN_OS_TESTED_COMPATIBILITY` only after exact release/session evidence exists.

## Immutable/atomic distributions

Fedora Atomic desktops/Bazzite-like systems should prefer Flatpak or another supported user-facing channel instead of forcing host-RPM mutation.

## Rule

`derived from the same family != runtime proven compatible`

<!-- END EMBEDDED SOURCE: 217_LINUX_DISTRO_FAMILY_AND_SUPPORT_MATRIX.md -->


---

# APPENDIX SOURCE: `218_LINUX_PORTABLE_APPIMAGE_AND_TARBALL.md`

<!-- BEGIN EMBEDDED SOURCE: 218_LINUX_PORTABLE_APPIMAGE_AND_TARBALL.md -->

# LINUX PORTABLE: APPIMAGE + BUNDLE FALLBACK

## AppImage target

Preferred portable artifact when validated:

`HumanHealthOS-x86_64.AppImage`

User flow:
`download → mark executable → run`

This is the closest Linux analogue to a single portable executable.

## Important limitation

AppImage commonly depends on FUSE behavior. Some distributions/configurations require additional FUSE compatibility packages or extract-and-run fallback.

Therefore AppImage is not the only Linux release channel.

## Portable bundle fallback

Also support a release-bundle archive:

`HumanHealthOS-Linux-x86_64-Portable.tar.zst`

Layout:
```text
HumanHealthOS/
  human_health_os
  lib/
  data/
  licenses/
  RELEASE_STATE.json
  CHECKSUMS.sha256
  portable_mode.json
  UserData/            # created after launch
```

The Flutter release `bundle/` directory is the source of executable/lib/data payload.

## System-library boundary

Flutter's Linux release bundle can still depend on system libraries.
Use `ldd` during release validation and record required host libraries.

Do not call a tarball universal if its glibc/GTK/system-library floor excludes the target distro.

## Portable vault

Portable Linux follows the same health-data rules as Windows portable:
- explicit portable mode
- encrypted persistent vault
- no plaintext health DB beside executable/AppImage
- path move does not create a new profile
- machine keyring is convenience only, not the sole recovery path.

## AppImage portable home/config

If AppImage-specific portable directory conventions are used, treat them as filesystem placement only.
Human OS vault encryption and canonical profile identity remain product-controlled.

<!-- END EMBEDDED SOURCE: 218_LINUX_PORTABLE_APPIMAGE_AND_TARBALL.md -->


---

# APPENDIX SOURCE: `219_LINUX_FLATPAK_SANDBOX_PORTALS_AND_PERMISSIONS.md`

<!-- BEGIN EMBEDDED SOURCE: 219_LINUX_FLATPAK_SANDBOX_PORTALS_AND_PERMISSIONS.md -->

# LINUX FLATPAK, SANDBOX, PORTALS AND PERMISSIONS

## Role

Flatpak is the primary distro-neutral installed Linux channel.

Flatpak is designed to be distribution-agnostic and can run on many Linux distributions with Flatpak support.

Target application ID:
`com.humanos.HumanHealthOS`

## Sandbox principle

Use the least privilege needed.

Prefer portals for:
- file open/save
- document import/export
- notifications when supported
- opening URIs
- desktop integration.

Do not request broad host filesystem access merely for convenience.

## Health data

The Flatpak sandbox's persistent app-data area can contain the local encrypted health vault.

Explicit exports/backups use user-selected portal destinations.

## Network

If local-only mode is selected, the product must remain usable without network service.
Network permission in packaging does not mean every feature may silently transmit health data.

## Devices/native health APIs

Linux desktop does not inherit Android Health Connect or Apple HealthKit capabilities.
Any Linux-specific device integration is a separate adapter with separate permissions/evidence.

## Distribution

A production Flatpak plan may support:
- a downloadable Flatpak bundle/repository
- Flathub submission when policy/review requirements are met.

Flathub publication is `NOT_CLAIMED` until actual submission/acceptance evidence exists.

<!-- END EMBEDDED SOURCE: 219_LINUX_FLATPAK_SANDBOX_PORTALS_AND_PERMISSIONS.md -->


---

# APPENDIX SOURCE: `220_LINUX_DEB_RPM_NATIVE_PACKAGES.md`

<!-- BEGIN EMBEDDED SOURCE: 220_LINUX_DEB_RPM_NATIVE_PACKAGES.md -->

# LINUX DEB / RPM NATIVE PACKAGES

## Debian / Ubuntu

Native artifact examples:
- `human-health-os_<version>_amd64.deb`
- `human-health-os_<version>_arm64.deb`

Use appropriate package metadata, dependency declarations, desktop entry, icons, license files and uninstall behavior.

Install/uninstall must keep application binaries separate from the user's health vault.
Removing the package must not silently delete personal health data.

## Fedora / Nobara

Native artifact examples:
- `human-health-os-<version>-1.x86_64.rpm`
- `human-health-os-<version>-1.aarch64.rpm`

Nobara is Fedora-based but modifies packages/repos and update behavior, so RPM install and runtime tests must run on Nobara itself.

## Native-package principle

`.deb` and `.rpm` improve desktop integration, but they are not the cross-distro compatibility layer.
Flatpak/AppImage remain available to avoid maintaining bespoke packages for every derivative.

## Desktop integration

Native packages should install, when appropriate:
- executable/app payload
- `.desktop` launcher
- icons
- AppStream/metainfo
- MIME associations only when genuinely implemented
- license/notices.

## Update ownership

If package-manager/repository updates are used, do not run a competing in-app binary updater for the same installation mode.
The application may notify that an update exists but should defer binary replacement to the selected package channel.

<!-- END EMBEDDED SOURCE: 220_LINUX_DEB_RPM_NATIVE_PACKAGES.md -->


---

# APPENDIX SOURCE: `221_LINUX_DATA_VAULT_XDG_AND_KEYRING.md`

<!-- BEGIN EMBEDDED SOURCE: 221_LINUX_DATA_VAULT_XDG_AND_KEYRING.md -->

# LINUX DATA VAULT, XDG PATHS AND KEYRING

## Installed/native mode

Respect XDG Base Directory conventions where compatible:
- data: `$XDG_DATA_HOME` or `~/.local/share`
- config: `$XDG_CONFIG_HOME` or `~/.config`
- cache: `$XDG_CACHE_HOME` or `~/.cache`.

Exact subdirectory:
`human-health-os/`

## Keys

Use an audited Linux secure-storage adapter where available, for example a Secret Service-compatible backend or desktop keyring integration.

Do not assume GNOME and KDE expose identical keyring behavior.

If secure-storage capability is unavailable:
- do not silently downgrade to plaintext key storage,
- require a safe fallback such as user passphrase-protected vault,
- expose capability state.

## Flatpak

Sandbox storage paths are implementation details; canonical health-record IDs remain independent of the package format.

## Portable Linux

Portable mode requires a portable recovery/passphrase path.
A Secret Service/KWallet entry may improve convenience but cannot be the only way to reopen the vault on another machine.

## File permissions

Private vault/config files should be user-only where the filesystem supports POSIX permissions.
Permission hardening complements encryption; it does not replace encryption.

<!-- END EMBEDDED SOURCE: 221_LINUX_DATA_VAULT_XDG_AND_KEYRING.md -->


---

# APPENDIX SOURCE: `222_LINUX_SIGNING_UPDATE_SBOM_AND_RELEASE_PROVENANCE.md`

<!-- BEGIN EMBEDDED SOURCE: 222_LINUX_SIGNING_UPDATE_SBOM_AND_RELEASE_PROVENANCE.md -->

# LINUX SIGNING, UPDATE, SBOM AND RELEASE PROVENANCE

Every Linux artifact records:
- product version
- source revision
- Flutter/Dart version
- architecture
- distro/build-container identity
- package format
- SHA-256
- dependency lock digest
- SBOM state
- signing state
- smoke-test state.

## Package/channel signatures

Use the signing model appropriate to the distribution channel:
- Flatpak repository/Flathub model
- signed apt repository when provided
- signed RPM repository when provided
- detached/release signatures for direct portable artifacts when implemented.

Do not claim package-manager trust from a raw downloadable file alone.

## Updates

Update mechanism depends on install mode:
- Flatpak → Flatpak channel
- apt/deb repository → apt
- RPM repository → dnf/rpm channel
- Snap → snap channel
- AppImage/direct portable → Human OS verified portable update protocol
- raw portable tarball → verified replace/stage flow.

## SBOM

Linux artifacts participate in the v0.27 SBOM/license/provenance requirements.
Bundled shared libraries must be represented in inventory according to the chosen SBOM tooling.

<!-- END EMBEDDED SOURCE: 222_LINUX_SIGNING_UPDATE_SBOM_AND_RELEASE_PROVENANCE.md -->


---

# APPENDIX SOURCE: `223_LINUX_CI_DISTRO_AND_SESSION_SMOKE_MATRIX.md`

<!-- BEGIN EMBEDDED SOURCE: 223_LINUX_CI_DISTRO_AND_SESSION_SMOKE_MATRIX.md -->

# LINUX CI, DISTRO AND SESSION SMOKE MATRIX

## Build host

At minimum run:
- `flutter doctor -v`
- `flutter analyze`
- `flutter test`
- `flutter build linux --release`
- `ldd` against the release executable.

## Required runtime smoke classes

For each gated distro/session:
1. install/run selected artifact
2. launch app
3. create local-only profile
4. create one canonical health record
5. close/reopen
6. confirm persistence
7. run offline
8. export to user-selected location
9. reopen encrypted vault
10. uninstall/remove app and verify vault retention policy.

## Initial distro matrix

Release gate set:
- Ubuntu 22.04 LTS x86_64
- Ubuntu 24.04 LTS x86_64
- Debian 12 x86_64
- Debian 13 x86_64
- Fedora 44 x86_64
- Nobara 44 Official/KDE x86_64

Additional when infrastructure permits:
- Nobara 44 GNOME
- Fedora KDE 44
- x64 Arch representative
- x64 openSUSE representative
- arm64 Debian/Ubuntu representative.

## Sessions

At minimum exercise:
- Wayland GNOME
- Wayland KDE
- X11 on a distro/session where supported.

Nobara PASS is recorded separately from Fedora PASS.

## Package matrix

Not every package format must run on every distro.
Examples:
- `.deb` → Debian/Ubuntu family
- `.rpm` → Fedora/Nobara family
- Flatpak → broad supported distro set
- AppImage → broad set when FUSE/runtime requirements pass.

<!-- END EMBEDDED SOURCE: 223_LINUX_CI_DISTRO_AND_SESSION_SMOKE_MATRIX.md -->


---

# APPENDIX SOURCE: `224_LINUX_RUNTIME_FAILURE_RECOVERY_AND_DESKTOP_INTEGRATION.md`

<!-- BEGIN EMBEDDED SOURCE: 224_LINUX_RUNTIME_FAILURE_RECOVERY_AND_DESKTOP_INTEGRATION.md -->

# LINUX RUNTIME FAILURE, RECOVERY AND DESKTOP INTEGRATION

Handle these states explicitly:
- missing system library
- unsupported glibc/ABI
- AppImage FUSE unavailable
- Flatpak portal denied/unavailable
- Secret Service/keyring unavailable
- read-only portable vault
- Wayland-specific integration failure
- X11-specific integration failure
- GPU/renderer startup failure
- package-manager update conflict
- insufficient disk space
- vault migration failure.

## Missing dependency

Do not crash into an opaque terminal error if a known dependency check can identify the problem.
Provide the package-format/distro-appropriate recovery message without blindly issuing privileged commands.

## AppImage FUSE

If FUSE is unavailable:
- explain the limitation,
- offer the supported extract-and-run or alternate Flatpak/native package path,
- do not tell users to weaken container/system security controls casually.

## Wayland / X11

Do not force X11 because one plugin failed on Wayland.
Prefer fixing/replacing the incompatible adapter.

## Desktop environments

Human OS UI remains toolkit-native Flutter UI; system integration must be tested on GNOME and KDE at minimum.

<!-- END EMBEDDED SOURCE: 224_LINUX_RUNTIME_FAILURE_RECOVERY_AND_DESKTOP_INTEGRATION.md -->


---

# APPENDIX SOURCE: `225_LINUX_RELEASE_ARTIFACT_MATRIX.md`

<!-- BEGIN EMBEDDED SOURCE: 225_LINUX_RELEASE_ARTIFACT_MATRIX.md -->

# LINUX RELEASE ARTIFACT MATRIX

## Required Linux release outputs

### Cross-distro installed
`HumanHealthOS.flatpak` or equivalent Flatpak repository/bundle artifact.

### Portable
`HumanHealthOS-x86_64.AppImage`

If AppImage release gate fails, status must be FAIL/NOT_SHIPPED and the tar bundle remains the portable fallback.

### Portable bundle fallback
`HumanHealthOS-Linux-x86_64-Portable.tar.zst`

### Debian family
`human-health-os_<version>_amd64.deb`

### Fedora/Nobara family
`human-health-os-<version>-1.x86_64.rpm`

## Conditional
- arm64/aarch64 equivalents
- Snap
- apt repository metadata/signatures
- RPM repository metadata/signatures
- Flathub publication.

## Artifact truth

Each artifact carries:
- BUILT / NOT_BUILT
- HASHED / NOT_HASHED
- SIGNED / UNSIGNED / NOT_APPLICABLE
- INSTALLED_TESTED / NOT_RUN
- DISTRO_TEST_MATRIX refs.

One passing Flatpak test does not imply RPM/DEB/AppImage PASS.

<!-- END EMBEDDED SOURCE: 225_LINUX_RELEASE_ARTIFACT_MATRIX.md -->


---

# APPENDIX SOURCE: `226_LINUX_DISTRIBUTION_SYNTHETIC_FIXTURES.md`

<!-- BEGIN EMBEDDED SOURCE: 226_LINUX_DISTRIBUTION_SYNTHETIC_FIXTURES.md -->

# LINUX DISTRIBUTION SYNTHETIC FIXTURES

Machine assets:
- `LINUX_DISTRIBUTION_MATRIX.json`
- `LINUX_PACKAGING_CONTRACT.json`
- `LINUX_SMOKE_MATRIX.json`
- `linux_distribution_fixtures.json`
- `reference_code/validate_v028_linux_candidate.py`

Fixture coverage:
- Debian/Ubuntu explicit target family
- Fedora/Nobara distinct runtime evidence
- Flatpak distro-neutral role
- AppImage FUSE caveat
- DEB/RPM family routing
- portable encrypted vault
- XDG installed data locations
- keyring unavailable does not allow plaintext fallback
- package-manager update ownership
- Wayland/KDE/GNOME session coverage
- compiled Linux build stays NOT_RUN without Flutter.

<!-- END EMBEDDED SOURCE: 226_LINUX_DISTRIBUTION_SYNTHETIC_FIXTURES.md -->


---

# APPENDIX SOURCE: `BUILD_LONGEVITY_APP_v0.28_CANDIDATE.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_LONGEVITY_APP_v0.28_CANDIDATE.txt -->

BUILD HUMAN HEALTH OS FROM VERIFIED v0.26 + v0.27 CANDIDATE PATCH

Required baseline SHA-256: 687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369
STOP if it differs.

1. `flutter doctor -v`
2. `flutter create --empty --platforms=android,ios,web,windows,macos,linux human_health_os`
3. Overlay candidate `lib/` and `test/`.
4. Keep tool-generated platform folders and SDK constraints.
5. `flutter pub get`
6. `flutter analyze`
7. `flutter test`
8. Run/build one supported target.
9. Fix first decisive failure and rerun.
10. Only after shell checkpoint expand local encrypted storage → canonical records → import/export → domain engines → native health adapters → remote sync.

Preserve v0.26 health/safety/domain contracts. This patch extends, never replaces, v0.26.

Commit `pubspec.lock`. Generate dependency inventory, license report and SPDX/CycloneDX SBOM for public release. Record artifact hash, source revision, lockfile hash, Flutter/Dart versions, host/runner, profile and command.

Never embed server master secrets in client builds. Report every target independently PASS/FAIL/NOT_RUN. Never claim an artifact exists unless it actually exists.


V0.28 LINUX DISTRIBUTION ADDENDUM
- Treat Linux as a first-class desktop target in the shared Flutter codebase.
- Required Linux release strategy: Flatpak + AppImage when validated + portable tar.zst fallback + DEB + RPM.
- Debian/Ubuntu are upstream-supported Flutter target families according to the checked support matrix; Fedora/Nobara require Human OS runtime evidence.
- Nobara and Fedora have independent smoke receipts.
- Installed data follows XDG-compatible paths; portable data uses encrypted portable vault semantics.
- GNOME/KDE Wayland are first-class test sessions; X11 is tested where supported.
- Execute BUILD_LINUX_DESKTOP_DISTRIBUTION_v0.28.txt after the first Flutter Linux release bundle is real.

<!-- END EMBEDDED SOURCE: BUILD_LONGEVITY_APP_v0.28_CANDIDATE.txt -->


---

# APPENDIX SOURCE: `BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.28.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.28.txt -->

TASK: turn Human Health OS from specification into its first real Flutter repository.

Use installed Flutter toolchain. Create the six-platform app, overlay supplied lib/test, run pub get/analyze/test, run/build one supported target, fix the first decisive failure, and record exact PASS/FAIL/NOT_RUN. Stop at a working shell before persistence. Then expand: local storage ports → encrypted repository → canonical health records → import/export → health modules → native adapters → remote sync.

Never claim compilation or platform artifacts without actual evidence.


V0.28 LINUX GATE
The repository must retain the Linux platform generated by Flutter. On a Linux build host, the first desktop compilation target should be `flutter build linux --release`; then inspect `ldd` and route the real bundle through the Linux packaging scaffold. Linux packaging PASS remains separate from compilation PASS.

<!-- END EMBEDDED SOURCE: BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.28.txt -->


---

# APPENDIX SOURCE: `BUILD_WINDOWS_PORTABLE_DESKTOP_v0.28_ADDENDUM.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_WINDOWS_PORTABLE_DESKTOP_v0.28_ADDENDUM.txt -->

V0.27 WINDOWS ADDENDUM

On an actual Windows build host: flutter doctor -v → flutter pub get → flutter analyze → flutter test → flutter build windows. Only then package portable ZIP and Setup EXE, apply encrypted-vault contract, perform clean-machine/offline smoke, sign production bytes, hash final artifacts and generate SBOM/license/provenance evidence. Do not handcraft a fake EXE from the specification bundle.


V0.28 CROSS-DESKTOP PARITY
Windows and Linux portable modes share vault identity/encryption/update semantics, but their packaging is platform-specific. Do not reuse Windows DLL/installer assumptions on Linux.

<!-- END EMBEDDED SOURCE: BUILD_WINDOWS_PORTABLE_DESKTOP_v0.28_ADDENDUM.txt -->


---

# APPENDIX SOURCE: `BUILD_LINUX_DESKTOP_DISTRIBUTION_v0.28.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_LINUX_DESKTOP_DISTRIBUTION_v0.28.txt -->

BUILD HUMAN HEALTH OS — LINUX CROSS-DISTRIBUTION DESKTOP v0.28 CANDIDATE

GOAL
Build the same Human Health OS Flutter desktop client for Linux with explicit compatibility across Debian/Ubuntu and Human-OS-tested Fedora/Nobara targets, plus broad distro-neutral channels.

DO NOT CREATE A SEPARATE LINUX HEALTH MODEL.
Shared domain/data/rule semantics remain identical across Android/iOS/Web/Windows/macOS/Linux.

FIRST BUILD
1. Verify Flutter Linux toolchain with `flutter doctor -v`.
2. Run `flutter analyze` and `flutter test`.
3. Run `flutter build linux --release`.
4. Inspect the actual bundle directory and run `ldd` against the executable.
5. Do not package until the release bundle launches successfully on the build host.

REQUIRED PACKAGE CHANNELS
A. Flatpak, primary cross-distro installed channel.
B. AppImage, portable single-file-style channel if FUSE/runtime compatibility passes.
C. Portable `.tar.zst` release-bundle fallback.
D. `.deb` for Debian/Ubuntu family.
E. `.rpm` for Fedora/Nobara family.

OPTIONAL
- Snap
- Flathub publication
- apt repository
- RPM repository
- arm64/aarch64 package set when build/runtime evidence exists.

DISTRO GATES
At minimum test:
- Ubuntu 22.04 LTS x86_64
- Ubuntu 24.04 LTS x86_64
- Debian 12 x86_64
- Debian 13 x86_64
- Fedora 44 x86_64
- Nobara 44 Official/KDE x86_64

Do not infer Nobara PASS from Fedora PASS.
Do not call Fedora/Nobara upstream-Flutter-supported unless current Flutter documentation explicitly says so.

BROAD COMPATIBILITY
After required gates, test representative Mint/Pop!_OS/Arch/Endeavour/Manjaro/openSUSE systems as resources permit.
Use Flatpak/AppImage rather than building a bespoke native package for every derivative.

PORTABLE SECURITY
Portable Linux persistent health data must be encrypted.
Do not store plaintext health DB beside AppImage/executable.
A Linux desktop keyring can be convenience unlock, not the only portable recovery path.

INSTALLED DATA
Use XDG-compatible data/config/cache locations and an audited secure-storage adapter.
If keyring/Secret Service is unavailable, do not silently persist plaintext keys.

FLATPAK
Use least privilege and portals for user-selected file import/export where possible.
Do not request full host filesystem access just to simplify implementation.

APPIMAGE
Record FUSE requirements and test them.
If FUSE prevents launch, ship/point to Flatpak/native package/portable tar fallback rather than claiming universal AppImage support.

SESSIONS
Test Wayland GNOME and Wayland KDE. Test X11 where supported.
Do not force X11 just because a plugin has a Wayland defect.

UPDATES
Package manager/channel owns binary updates for Flatpak/DEB/RPM/Snap installs.
Portable direct artifacts use the verified Human OS portable update protocol.

DELIVER REAL EVIDENCE
For every produced package record:
- file path
- architecture
- SHA-256
- package format
- source revision
- Flutter/Dart version
- dependency lock digest
- SBOM state
- signing state
- exact distro/session smoke results.

Never mark a package PASS because another package format or related distro passed.
If Flutter/tooling is unavailable, report NOT_RUN/BLOCKED_ENVIRONMENT instead of inventing artifacts.

<!-- END EMBEDDED SOURCE: BUILD_LINUX_DESKTOP_DISTRIBUTION_v0.28.txt -->


---

# APPENDIX SOURCE: `BUILD_HUMAN_HEALTH_OS_SITE_v0.28_ADDENDUM.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_HUMAN_HEALTH_OS_SITE_v0.28_ADDENDUM.txt -->

V0.27 WEB ADDENDUM

Create real Flutter repository → overlay → analyze/test → build Web → runtime smoke Today→Labs. Keep private Web App separate from synthetic Site Lab. Do not embed production server master secrets. Public release includes dependency/SBOM/license/provenance evidence.


V0.28 PLATFORM DISCLOSURE
The Site/Web UI can show Linux as a product target, but must distinguish planned, built, and distro-tested artifacts. Do not claim "all Linux distributions supported" without current distro/session evidence.

<!-- END EMBEDDED SOURCE: BUILD_HUMAN_HEALTH_OS_SITE_v0.28_ADDENDUM.txt -->


---

# APPENDIX SOURCE: `REQUIREMENTS_ADDENDUM_v0.27.md`

<!-- BEGIN EMBEDDED SOURCE: REQUIREMENTS_ADDENDUM_v0.27.md -->

# v0.27 Candidate Requirements

## FR-521 — Tool-generated Flutter Repository

## FR-522 — Repository Bootstrap Overlay

## FR-523 — First Compile Before Expansion

## FR-524 — Responsive Cross-platform Shell

## FR-525 — Shared Canonical Navigation

## FR-526 — Local-first Domain Ports

## FR-527 — Runtime Capability Registry

## FR-528 — Offline Deterministic Core

## FR-529 — Development/Staging/Production Profiles

## FR-530 — No Client Master Secrets

## FR-531 — Build Identity Metadata

## FR-532 — Application Lockfile

## FR-533 — Controlled Dependency Update

## FR-534 — Dependency Inventory

## FR-535 — SBOM Release Artifact

## FR-536 — License Inventory

## FR-537 — Unreviewed Git/Path Dependency Gate

## FR-538 — CI Toolchain Report

## FR-539 — Cross-platform CI Matrix

## FR-540 — Build Provenance

## FR-541 — Attestation State

## FR-542 — No Fake Reproducibility

## FR-543 — Protected Release Secrets

## FR-544 — Release Channels

## FR-545 — Authenticated Update Metadata

## FR-546 — Schema-aware Rollback

## FR-547 — Offline Update Honesty

## FR-548 — First Compiled Slice Evidence Layers

## FR-549 — Basic Shell Smoke

## FR-550 — Host-incompatible Build Honesty

## FR-551 — Flutter Version-gated Windows Flavor

## FR-552 — Candidate Baseline Guard

## FR-553 — No Candidate Auto-promotion

## FR-554 — Bootstrap Source Review

## FR-555 — Next Build Agent Handoff

<!-- END EMBEDDED SOURCE: REQUIREMENTS_ADDENDUM_v0.27.md -->


---

# APPENDIX SOURCE: `REQUIREMENTS_ADDENDUM_v0.28.md`

<!-- BEGIN EMBEDDED SOURCE: REQUIREMENTS_ADDENDUM_v0.28.md -->

# v0.28 Candidate Requirements

## FR-556 — Linux First-class Desktop Target

## FR-557 — Cross-distro Support-state Taxonomy

## FR-558 — Ubuntu Upstream Support Recognition

## FR-559 — Debian Upstream Support Recognition

## FR-560 — Fedora Explicit Compatibility Gate

## FR-561 — Nobara Explicit Compatibility Gate

## FR-562 — No Fedora-to-Nobara PASS Inference

## FR-563 — Flatpak Primary Cross-distro Channel

## FR-564 — AppImage Portable Channel

## FR-565 — AppImage FUSE Caveat

## FR-566 — Portable Tar Bundle Fallback

## FR-567 — Debian DEB Package

## FR-568 — Fedora/Nobara RPM Package

## FR-569 — Optional Snap Channel

## FR-570 — Linux x86_64 First Architecture

## FR-571 — Linux arm64 Conditional Architecture

## FR-572 — Linux Flutter Release Build

## FR-573 — Linux ldd Dependency Inspection

## FR-574 — Linux XDG Data Paths

## FR-575 — Linux Secure Storage Adapter

## FR-576 — Linux No Plaintext Key Fallback

## FR-577 — Linux Portable Encrypted Vault

## FR-578 — Linux Path-independent Profile Identity

## FR-579 — Flatpak Least Privilege

## FR-580 — Flatpak Portal File Access

## FR-581 — Package-channel Update Ownership

## FR-582 — Linux Release Provenance

## FR-583 — Linux SBOM Participation

## FR-584 — GNOME Wayland Smoke

## FR-585 — KDE Wayland Smoke

## FR-586 — X11 Conditional Smoke

## FR-587 — Fedora 44 Smoke

## FR-588 — Nobara 44 Smoke

## FR-589 — Ubuntu 22.04/24.04 Smoke

## FR-590 — Debian 12/13 Smoke

## FR-591 — Broad Derivative Compatibility

## FR-592 — Package-specific PASS State

## FR-593 — Linux Failure Recovery

## FR-594 — Linux Packaging Scaffold

## FR-595 — Dedicated Linux Build Prompt

<!-- END EMBEDDED SOURCE: REQUIREMENTS_ADDENDUM_v0.28.md -->


---

# APPENDIX SOURCE: `ACCEPTANCE_TEST_ADDENDUM_v0.27.md`

<!-- BEGIN EMBEDDED SOURCE: ACCEPTANCE_TEST_ADDENDUM_v0.27.md -->

# v0.27 Candidate Acceptance Tests

AT-828 Exact required v0.26 SHA is recorded.
AT-829 Candidate status is CANDIDATE_DELTA_ONLY.
AT-830 Bootstrap uses flutter create.
AT-831 Bootstrap requests six platforms.
AT-832 Overlay has lib/main.dart.
AT-833 Overlay has app root.
AT-834 Overlay has responsive shell.
AT-835 Overlay has build-profile config.
AT-836 Overlay has widget smoke test.
AT-837 Overlay uses no third-party Dart package in first slice.
AT-838 Today destination exists.
AT-839 Labs destination exists.
AT-840 Compare destination exists.
AT-841 Learn destination exists.
AT-842 Wide shell uses NavigationRail.
AT-843 Narrow shell uses NavigationBar.
AT-844 Build profile uses compile-time environment.
AT-845 No long-lived secret marker in overlay.
AT-846 Ports spec separates domain/platform adapters.
AT-847 HealthKit/Health Connect are adapters.
AT-848 Web native-health parity is not assumed.
AT-849 Application lockfile policy commits pubspec.lock.
AT-850 Dependency update uses lockfile diff/tests.
AT-851 SBOM accepts SPDX.
AT-852 SBOM accepts CycloneDX.
AT-853 SBOM generation is NOT_RUN.
AT-854 Unreviewed Git/path dependency blocks public release.
AT-855 Provenance records artifact digest.
AT-856 Provenance records source revision.
AT-857 Provenance records Flutter/Dart versions.
AT-858 Attestation generated vs verified states differ.
AT-859 Bit-identical reproducibility is not claimed by default.
AT-860 CI matrix does not fake host-incompatible PASS.
AT-861 Release secrets are protected.
AT-862 Update metadata includes artifact digest by contract.
AT-863 Offline update cannot fake success.
AT-864 Binary/schema rollback are separate.
AT-865 Compiled-slice gate separates V0-V4.
AT-866 Runtime smoke checks title.
AT-867 Runtime smoke checks Today.
AT-868 Runtime smoke checks Labs navigation.
AT-869 Flutter compile remains NOT_RUN.
AT-870 Windows compile remains NOT_RUN.
AT-871 Android compile remains NOT_RUN.
AT-872 Apple builds remain NOT_RUN.
AT-873 Structural validator passes.
AT-874 JSON files parse.
AT-875 Manifest hashes all patch files except itself.
AT-876 ZIP integrity passes.
AT-877 Promotion is blocked without baseline bytes.
AT-878 Build prompt follows bootstrap→test→run/build→expand.
AT-879 Overlay brace-balance check passes.

<!-- END EMBEDDED SOURCE: ACCEPTANCE_TEST_ADDENDUM_v0.27.md -->


---

# APPENDIX SOURCE: `ACCEPTANCE_TEST_ADDENDUM_v0.28.md`

<!-- BEGIN EMBEDDED SOURCE: ACCEPTANCE_TEST_ADDENDUM_v0.28.md -->

# v0.28 Candidate Acceptance Tests

AT-880 Linux appears as first-class shared Flutter desktop target.
AT-881 Support taxonomy distinguishes upstream-supported, Human-OS-tested, and unverified.
AT-882 Ubuntu support matrix records 20.04–24.04 LTS.
AT-883 Debian support matrix records 10–13.
AT-884 Fedora 44 starts NOT_RUN until Human OS smoke executes.
AT-885 Nobara 44 starts NOT_RUN until Human OS smoke executes.
AT-886 Nobara PASS cannot be inferred from Fedora PASS.
AT-887 Flatpak is primary cross-distro installed channel.
AT-888 AppImage is a portable channel.
AT-889 AppImage contract records FUSE caveat.
AT-890 AppImage is not the sole Linux channel.
AT-891 Portable tar.zst fallback exists in contract.
AT-892 DEB artifact routes to Debian/Ubuntu family.
AT-893 RPM artifact routes to Fedora/Nobara family.
AT-894 Snap is optional rather than mandatory.
AT-895 x86_64 is first Linux release architecture.
AT-896 arm64/aarch64 requires actual toolchain/runtime evidence.
AT-897 Linux build command is flutter build linux --release.
AT-898 ldd inspection is a release gate.
AT-899 Installed data contract uses XDG directories.
AT-900 Linux secure-storage adapter is explicit.
AT-901 No secure storage capability does not allow plaintext key fallback.
AT-902 Portable Linux health vault must be encrypted.
AT-903 Moving portable Linux bundle does not create new profile.
AT-904 Flatpak contract uses least privilege.
AT-905 Flatpak import/export prefers portals.
AT-906 Flatpak package channel owns Flatpak binary updates.
AT-907 DEB/RPM package-manager channel owns native binary updates.
AT-908 Portable direct artifact uses verified staged updater.
AT-909 Linux artifact provenance includes distro/build-host identity.
AT-910 Linux bundled libraries participate in SBOM/license inventory.
AT-911 GNOME Wayland is required smoke class.
AT-912 KDE Wayland is required smoke class.
AT-913 X11 is tested only where supported.
AT-914 Fedora 44 exact smoke receipt required before PASS.
AT-915 Nobara 44 exact smoke receipt required before PASS.
AT-916 Ubuntu 22.04 and 24.04 exact smoke receipts required.
AT-917 Debian 12 and 13 exact smoke receipts required.
AT-918 Broad derivatives remain unverified until exact smoke evidence.
AT-919 One package format PASS does not imply another format PASS.
AT-920 Missing system library has explicit recovery state.
AT-921 FUSE unavailable has AppImage alternate-channel recovery.
AT-922 Keyring unavailable has safe fallback state.
AT-923 Wayland plugin failure does not justify forced X11 globally.
AT-924 Linux packaging scaffold includes desktop entry.
AT-925 Linux packaging scaffold includes metainfo.
AT-926 Linux packaging scaffold includes DEB template.
AT-927 Linux packaging scaffold includes RPM template.
AT-928 Linux packaging scaffold includes Flatpak template.
AT-929 Portable bundle staging script refuses missing Flutter bundle.
AT-930 Dedicated Linux build prompt exists.
AT-931 Linux distribution fixture validator passes.
AT-932 JSON assets parse recursively.
AT-933 Cumulative candidate preserves v0.27 bootstrap overlay.
AT-934 Parent candidate SHA-256 is verified.
AT-935 Full baseline merge remains blocked without v0.26 bytes.
AT-936 Flutter toolchain remains NOT_RUN if absent.
AT-937 Linux release build remains NOT_RUN if Flutter is absent.
AT-938 Flatpak package build remains NOT_RUN if tooling is absent.
AT-939 AppImage build remains NOT_RUN if tooling is absent.
AT-940 RPM build remains NOT_RUN if tooling is absent.
AT-941 DEB package is not fabricated without compiled binary.
AT-942 Candidate ZIP integrity passes.
AT-943 Candidate manifest hashes every file except itself.

<!-- END EMBEDDED SOURCE: ACCEPTANCE_TEST_ADDENDUM_v0.28.md -->


---

# APPENDIX SOURCE: `ARCHITECTURE_DECISIONS_ADDENDUM_v0.27.md`

<!-- BEGIN EMBEDDED SOURCE: ARCHITECTURE_DECISIONS_ADDENDUM_v0.27.md -->

# Architecture Decisions

## ADR-155 — Generate platform runners from actual Flutter toolchain

## ADR-156 — Compile minimal shell before deep features

## ADR-157 — Start as local-first modular monolith

## ADR-158 — Keep domain independent of platform adapters

## ADR-159 — Commit application lockfile

## ADR-160 — Require SBOM/license inventory for public release

## ADR-161 — Separate provenance generation from verification

## ADR-162 — Forbid production client master secrets

## ADR-163 — Separate schema rollback from binary rollback

## ADR-164 — Keep v0.27 candidate until exact v0.26 merge

<!-- END EMBEDDED SOURCE: ARCHITECTURE_DECISIONS_ADDENDUM_v0.27.md -->


---

# APPENDIX SOURCE: `ARCHITECTURE_DECISIONS_ADDENDUM_v0.28.md`

<!-- BEGIN EMBEDDED SOURCE: ARCHITECTURE_DECISIONS_ADDENDUM_v0.28.md -->

# v0.28 Architecture Decisions

## ADR-1581 — Linux compatibility is evidence-tiered, not assumed universal
Decision: Flutter-upstream support, Human OS tested compatibility and best-effort/unverified are separate states.

## ADR-1582 — Flatpak is the primary cross-distro installed channel
Decision: Native DEB/RPM improve integration but do not define universal Linux support.

## ADR-1583 — AppImage is portable but not the sole Linux channel
Decision: FUSE/runtime variability requires Flatpak/native/tar fallback.

## ADR-1584 — Fedora and Nobara require separate runtime receipts
Decision: Nobara package/session differences prevent family inference.

## ADR-1585 — Linux installed and portable vault modes remain distinct
Decision: XDG/keyring semantics do not replace portable passphrase recovery.

## ADR-1586 — Package manager owns binary updates for package-manager installs
Decision: Avoid competing self-updaters for Flatpak/APT/RPM/Snap modes.

## ADR-1587 — Wayland is first-class
Decision: Do not force global X11 fallback to hide plugin defects.

## ADR-1588 — Linux packaging PASS is format-specific
Decision: Flatpak, AppImage, DEB, RPM and portable bundle retain separate evidence.

<!-- END EMBEDDED SOURCE: ARCHITECTURE_DECISIONS_ADDENDUM_v0.28.md -->


---

# APPENDIX SOURCE: `FAILURE_MODES_ADDENDUM_v0.27.md`

<!-- BEGIN EMBEDDED SOURCE: FAILURE_MODES_ADDENDUM_v0.27.md -->

# Failure Modes

## FM-149 — Coding agent invents native runner files

## FM-150 — Feature avalanche before first compile

## FM-151 — Domain directly imports platform storage/health APIs

## FM-152 — Production silently refreshes dependencies

## FM-153 — Unknown dependency/license enters public build

## FM-154 — Artifact cannot be traced to source/build

## FM-155 — Attestation JSON mistaken for verified attestation

## FM-156 — Secret embedded in client build

## FM-157 — Older binary corrupts newer schema

## FM-158 — Unsupported platform marked PASS

## FM-159 — Candidate promoted without baseline merge

<!-- END EMBEDDED SOURCE: FAILURE_MODES_ADDENDUM_v0.27.md -->


---

# APPENDIX SOURCE: `FAILURE_MODES_ADDENDUM_v0.28.md`

<!-- BEGIN EMBEDDED SOURCE: FAILURE_MODES_ADDENDUM_v0.28.md -->

# v0.28 Failure Modes

## FM-1591 — Claiming all Linux distros from one Ubuntu run
Prevention: Use evidence-tiered distro matrix.

## FM-1592 — Assuming Nobara equals Fedora runtime
Prevention: Require exact Nobara smoke receipt.

## FM-1593 — AppImage fails because FUSE is unavailable
Prevention: Offer Flatpak/native/tar fallback and explicit recovery.

## FM-1594 — Portable vault key exists only in local keyring
Prevention: Require portable passphrase/recovery path.

## FM-1595 — Flatpak asks for entire home filesystem
Prevention: Use least privilege and portals.

## FM-1596 — Native package uninstall deletes health vault
Prevention: Separate package files from user data.

## FM-1597 — Competing in-app updater fights apt/dnf/Flatpak
Prevention: Package channel owns binary update.

## FM-1598 — Wayland bug hidden by forced X11
Prevention: Fix adapter or mark session-specific limitation.

## FM-1599 — glibc/system ABI makes tar bundle fail
Prevention: Record ldd/system-library floor and exact distro smoke.

## FM-15910 — Package format PASS propagated to other formats
Prevention: Keep per-format evidence state.

<!-- END EMBEDDED SOURCE: FAILURE_MODES_ADDENDUM_v0.28.md -->


---

# APPENDIX SOURCE: `IMPLEMENTATION_PHASE_ADDENDUM_v0.27.md`

<!-- BEGIN EMBEDDED SOURCE: IMPLEMENTATION_PHASE_ADDENDUM_v0.27.md -->

# P4U — Compilable Repository Bootstrap + Supply-chain Provenance

Implement tool-generated Flutter repository, source overlay, responsive shell, ports/adapters, build profiles, lockfile, dependency/SBOM/license workflow, CI matrix, provenance/attestation and update metadata.

Exit: candidate structural gates PASS; exact v0.26 merge required before CURRENT. Compilation stays separately evidenced.

<!-- END EMBEDDED SOURCE: IMPLEMENTATION_PHASE_ADDENDUM_v0.27.md -->


---

# APPENDIX SOURCE: `IMPLEMENTATION_PHASE_ADDENDUM_v0.28.md`

<!-- BEGIN EMBEDDED SOURCE: IMPLEMENTATION_PHASE_ADDENDUM_v0.28.md -->

# P4V — Linux Cross-distribution Desktop Release

Implement Flutter Linux build, distro-neutral Flatpak/AppImage/tar channels, DEB/RPM family packages, XDG/keyring/portable-vault semantics, Wayland/X11 session testing and exact Fedora/Nobara/Ubuntu/Debian smoke evidence.

Exit:
- AT-880 through AT-943 pass as applicable.
- compiled/package/runtime states remain independently evidenced.
- v0.26 full baseline merge is still required before CURRENT promotion.

<!-- END EMBEDDED SOURCE: IMPLEMENTATION_PHASE_ADDENDUM_v0.28.md -->


---

# APPENDIX SOURCE: `TECHNICAL_SOURCE_ADDENDUM_v0.27.md`

<!-- BEGIN EMBEDDED SOURCE: TECHNICAL_SOURCE_ADDENDUM_v0.27.md -->

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

<!-- END EMBEDDED SOURCE: TECHNICAL_SOURCE_ADDENDUM_v0.27.md -->


---

# APPENDIX SOURCE: `TECHNICAL_SOURCE_ADDENDUM_v0.28.md`

<!-- BEGIN EMBEDDED SOURCE: TECHNICAL_SOURCE_ADDENDUM_v0.28.md -->

# TECHNICAL SOURCE ADDENDUM v0.28

Checked: 2026-10-06.

Flutter Linux:
- https://docs.flutter.dev/reference/supported-platforms
- https://docs.flutter.dev/platform-integration/linux/setup
- https://docs.flutter.dev/platform-integration/linux/building
- https://docs.flutter.dev/platform-integration/desktop

Observed:
- Flutter currently lists Debian 10–13 and Ubuntu 20.04 LTS–24.04 LTS for Linux deployment on x64/arm64.
- `flutter build linux --release` produces a bundle containing executable plus `lib` and `data`; target systems still need compatible OS libraries, which can be inspected with `ldd`.

Flatpak:
- https://flatpak.org/faq.html
- https://docs.flatpak.org/en/latest/getting-started.html

Observed:
- Flatpak is designed as a distribution-agnostic Linux application deployment mechanism.

AppImage:
- https://docs.appimage.org/introduction/
- https://docs.appimage.org/user-guide/troubleshooting/fuse.html

Observed:
- AppImage targets broad Linux portability but FUSE availability can affect execution, so it cannot be the sole Human OS Linux channel.

Fedora:
- https://fedoraproject.org/
- https://www.fedoraproject.org/workstation/download/

Observed:
- Fedora 44 is the current stable release at the checked date; Fedora 45 is beta/pre-release.

Nobara:
- https://nobaraproject.org/
- https://nobaraproject.org/download.html
- https://wiki.nobaraproject.org/modifications/packages

Observed:
- Nobara 44 is the checked current release.
- Nobara is Fedora-based but independent and carries package/repository modifications, so Fedora runtime evidence cannot substitute for Nobara testing.

<!-- END EMBEDDED SOURCE: TECHNICAL_SOURCE_ADDENDUM_v0.28.md -->


---

# APPENDIX SOURCE: `REPOSITORY_BOOTSTRAP_CONTRACT.json`

<!-- BEGIN EMBEDDED SOURCE: REPOSITORY_BOOTSTRAP_CONTRACT.json -->

```json
{
  "version": "v0.27-candidate",
  "project_name": "human_health_os",
  "bootstrap_command": "flutter create --empty --platforms=android,ios,web,windows,macos,linux human_health_os",
  "architecture": "MODULAR_MONOLITH_LOCAL_FIRST",
  "overlay_directory": "repository_bootstrap_overlay",
  "required_first_checks": [
    "flutter analyze",
    "flutter test"
  ],
  "destinations": [
    "Today",
    "Timeline",
    "Labs",
    "Medications",
    "Nutrition",
    "Activity",
    "Conditions",
    "Preventive",
    "Compare",
    "Learn"
  ],
  "compile_status": "NOT_RUN",
  "authoring_runtime_flutter_available": false
}
```

<!-- END EMBEDDED SOURCE: REPOSITORY_BOOTSTRAP_CONTRACT.json -->


---

# APPENDIX SOURCE: `BUILD_PROVENANCE_CONTRACT.json`

<!-- BEGIN EMBEDDED SOURCE: BUILD_PROVENANCE_CONTRACT.json -->

```json
{
  "version": "v0.27-candidate",
  "fields": [
    "artifact_name",
    "artifact_sha256",
    "source_revision",
    "lockfile_sha256",
    "flutter_version",
    "dart_version",
    "host_os",
    "runner_image",
    "build_profile",
    "build_command",
    "builder_id",
    "attestation_state"
  ],
  "attestation_states": [
    "NOT_GENERATED",
    "GENERATED_UNVERIFIED",
    "VERIFIED",
    "INVALID"
  ],
  "bit_reproducible_claim_default": false
}
```

<!-- END EMBEDDED SOURCE: BUILD_PROVENANCE_CONTRACT.json -->


---

# APPENDIX SOURCE: `SUPPLY_CHAIN_POLICY.json`

<!-- BEGIN EMBEDDED SOURCE: SUPPLY_CHAIN_POLICY.json -->

```json
{
  "version": "v0.27-candidate",
  "lockfile": {
    "file": "pubspec.lock",
    "commit_for_application": true,
    "implicit_production_refresh": false
  },
  "sbom": {
    "required_for_public_release": true,
    "accepted_formats": [
      "SPDX",
      "CycloneDX"
    ],
    "generated_status": "NOT_RUN"
  },
  "dependency_review_fields": [
    "name",
    "version",
    "source",
    "purpose",
    "direct_or_transitive",
    "license",
    "native_code",
    "privacy_security_relevance"
  ],
  "unreviewed_git_or_path_dependency_public_release": "BLOCK"
}
```

<!-- END EMBEDDED SOURCE: SUPPLY_CHAIN_POLICY.json -->


---

# APPENDIX SOURCE: `LINUX_DISTRIBUTION_MATRIX.json`

<!-- BEGIN EMBEDDED SOURCE: LINUX_DISTRIBUTION_MATRIX.json -->

```json
{
  "version": "v0.28-candidate",
  "checked_at": "2026-10-06",
  "support_states": [
    "UPSTREAM_SUPPORTED_FLUTTER_TARGET",
    "HUMAN_OS_TESTED_COMPATIBILITY",
    "BEST_EFFORT_UNVERIFIED"
  ],
  "upstream_flutter": {
    "ubuntu": {
      "versions": [
        "20.04 LTS",
        "22.04 LTS",
        "24.04 LTS"
      ],
      "architectures": [
        "x64",
        "arm64"
      ]
    },
    "debian": {
      "versions": [
        "10",
        "11",
        "12",
        "13"
      ],
      "architectures": [
        "x64",
        "arm64"
      ]
    }
  },
  "human_os_release_gate": [
    {
      "distro": "Ubuntu",
      "version": "22.04 LTS",
      "arch": "x86_64",
      "session": "GNOME/Wayland",
      "status": "NOT_RUN"
    },
    {
      "distro": "Ubuntu",
      "version": "24.04 LTS",
      "arch": "x86_64",
      "session": "GNOME/Wayland",
      "status": "NOT_RUN"
    },
    {
      "distro": "Debian",
      "version": "12",
      "arch": "x86_64",
      "session": "GNOME or KDE",
      "status": "NOT_RUN"
    },
    {
      "distro": "Debian",
      "version": "13",
      "arch": "x86_64",
      "session": "GNOME or KDE",
      "status": "NOT_RUN"
    },
    {
      "distro": "Fedora",
      "version": "44",
      "arch": "x86_64",
      "session": "GNOME/Wayland",
      "status": "NOT_RUN"
    },
    {
      "distro": "Nobara",
      "version": "44",
      "arch": "x86_64",
      "session": "Official/KDE/Wayland",
      "status": "NOT_RUN"
    }
  ],
  "broad_targets": [
    "Linux Mint",
    "Pop!_OS",
    "Zorin OS",
    "elementary OS",
    "KDE neon",
    "Arch Linux",
    "EndeavourOS",
    "Manjaro",
    "openSUSE Tumbleweed",
    "openSUSE Leap"
  ],
  "rule": "family relationship does not create runtime PASS"
}
```

<!-- END EMBEDDED SOURCE: LINUX_DISTRIBUTION_MATRIX.json -->


---

# APPENDIX SOURCE: `LINUX_PACKAGING_CONTRACT.json`

<!-- BEGIN EMBEDDED SOURCE: LINUX_PACKAGING_CONTRACT.json -->

```json
{
  "version": "v0.28-candidate",
  "app_id": "com.humanos.HumanHealthOS",
  "required_channels": {
    "flatpak": {
      "role": "PRIMARY_CROSS_DISTRO_INSTALLED",
      "artifact": "HumanHealthOS.flatpak",
      "runtime_status": "NOT_RUN"
    },
    "appimage": {
      "role": "PRIMARY_PORTABLE_IF_VALIDATED",
      "artifact": "HumanHealthOS-x86_64.AppImage",
      "runtime_status": "NOT_RUN",
      "fuse_caveat": true
    },
    "tar_bundle": {
      "role": "PORTABLE_FALLBACK",
      "artifact": "HumanHealthOS-Linux-x86_64-Portable.tar.zst",
      "runtime_status": "NOT_RUN"
    },
    "deb": {
      "role": "DEBIAN_UBUNTU_NATIVE",
      "artifact": "human-health-os_<version>_amd64.deb",
      "runtime_status": "NOT_RUN"
    },
    "rpm": {
      "role": "FEDORA_NOBARA_NATIVE",
      "artifact": "human-health-os-<version>-1.x86_64.rpm",
      "runtime_status": "NOT_RUN"
    }
  },
  "optional_channels": [
    "snap",
    "flathub",
    "apt_repository",
    "rpm_repository"
  ],
  "portable_vault_encrypted": true,
  "plaintext_health_db_forbidden": true,
  "single_channel_claims_all_linux_forbidden": true
}
```

<!-- END EMBEDDED SOURCE: LINUX_PACKAGING_CONTRACT.json -->


---

# APPENDIX SOURCE: `LINUX_SMOKE_MATRIX.json`

<!-- BEGIN EMBEDDED SOURCE: LINUX_SMOKE_MATRIX.json -->

```json
{
  "version": "v0.28-candidate",
  "required_steps": [
    "launch",
    "create_local_profile",
    "save_record",
    "close_reopen",
    "verify_record",
    "offline_run",
    "export",
    "vault_reopen",
    "uninstall_data_retention"
  ],
  "sessions": [
    "GNOME_WAYLAND",
    "KDE_WAYLAND",
    "X11_WHERE_SUPPORTED"
  ],
  "host_checks": [
    "flutter doctor -v",
    "flutter analyze",
    "flutter test",
    "flutter build linux --release",
    "ldd <release-executable>"
  ],
  "all_runtime_status": "NOT_RUN"
}
```

<!-- END EMBEDDED SOURCE: LINUX_SMOKE_MATRIX.json -->


---

# APPENDIX SOURCE: `linux_distribution_fixtures.json`

<!-- BEGIN EMBEDDED SOURCE: linux_distribution_fixtures.json -->

```json
{
  "version": "v0.28-candidate",
  "cases": [
    {
      "id": "LNX-001",
      "expected": "Ubuntu and Debian are explicit upstream-supported Flutter Linux targets"
    },
    {
      "id": "LNX-002",
      "expected": "Fedora and Nobara require Human OS runtime evidence separate from upstream Flutter support"
    },
    {
      "id": "LNX-003",
      "expected": "Nobara PASS cannot be inferred from Fedora PASS"
    },
    {
      "id": "LNX-004",
      "expected": "Flatpak is primary cross-distro installed channel"
    },
    {
      "id": "LNX-005",
      "expected": "AppImage is portable but has FUSE/runtime caveat"
    },
    {
      "id": "LNX-006",
      "expected": "AppImage is not sole Linux channel"
    },
    {
      "id": "LNX-007",
      "expected": "DEB routes to Debian/Ubuntu family"
    },
    {
      "id": "LNX-008",
      "expected": "RPM routes to Fedora/Nobara family"
    },
    {
      "id": "LNX-009",
      "expected": "portable Linux vault is encrypted"
    },
    {
      "id": "LNX-010",
      "expected": "keyring unavailable never permits plaintext key fallback"
    },
    {
      "id": "LNX-011",
      "expected": "installed mode follows XDG path contract"
    },
    {
      "id": "LNX-012",
      "expected": "Flatpak portal/filesystem permissions use least privilege"
    },
    {
      "id": "LNX-013",
      "expected": "package-manager installation owns binary update flow"
    },
    {
      "id": "LNX-014",
      "expected": "Wayland GNOME and KDE are runtime smoke classes"
    },
    {
      "id": "LNX-015",
      "expected": "X11 is tested only where supported"
    },
    {
      "id": "LNX-016",
      "expected": "Linux x86_64 is first release architecture"
    },
    {
      "id": "LNX-017",
      "expected": "arm64 is conditional on toolchain/plugins/runtime evidence"
    },
    {
      "id": "LNX-018",
      "expected": "compiled Linux build remains NOT_RUN without Flutter toolchain"
    },
    {
      "id": "LNX-019",
      "expected": "one package format PASS never implies all formats PASS"
    },
    {
      "id": "LNX-020",
      "expected": "broad distro compatibility remains unverified until exact smoke evidence"
    }
  ]
}
```

<!-- END EMBEDDED SOURCE: linux_distribution_fixtures.json -->


---

# APPENDIX SOURCE: `REQUIREMENTS_TRACEABILITY_ADDENDUM.json`

<!-- BEGIN EMBEDDED SOURCE: REQUIREMENTS_TRACEABILITY_ADDENDUM.json -->

```json
{
  "version": "v0.27-candidate",
  "requirements": {
    "FR-521": [
      "AT-830",
      "AT-831"
    ],
    "FR-522": [
      "AT-832",
      "AT-833",
      "AT-834",
      "AT-836"
    ],
    "FR-523": [
      "AT-830"
    ],
    "FR-524": [
      "AT-842",
      "AT-843"
    ],
    "FR-525": [
      "AT-832"
    ],
    "FR-526": [
      "AT-833"
    ],
    "FR-527": [
      "AT-834"
    ],
    "FR-528": [
      "AT-835"
    ],
    "FR-529": [
      "AT-836"
    ],
    "FR-530": [
      "AT-845"
    ],
    "FR-531": [
      "AT-838"
    ],
    "FR-532": [
      "AT-849"
    ],
    "FR-533": [
      "AT-840"
    ],
    "FR-534": [
      "AT-841"
    ],
    "FR-535": [
      "AT-851",
      "AT-852",
      "AT-853"
    ],
    "FR-536": [
      "AT-843"
    ],
    "FR-537": [
      "AT-844"
    ],
    "FR-538": [
      "AT-845"
    ],
    "FR-539": [
      "AT-846"
    ],
    "FR-540": [
      "AT-855",
      "AT-856",
      "AT-857"
    ],
    "FR-541": [
      "AT-858"
    ],
    "FR-542": [
      "AT-859"
    ],
    "FR-543": [
      "AT-850"
    ],
    "FR-544": [
      "AT-851"
    ],
    "FR-545": [
      "AT-852"
    ],
    "FR-546": [
      "AT-853"
    ],
    "FR-547": [
      "AT-854"
    ],
    "FR-548": [
      "AT-865"
    ],
    "FR-549": [
      "AT-866",
      "AT-867",
      "AT-868"
    ],
    "FR-550": [
      "AT-857"
    ],
    "FR-551": [
      "AT-858"
    ],
    "FR-552": [
      "AT-828"
    ],
    "FR-553": [
      "AT-829",
      "AT-877"
    ],
    "FR-554": [
      "AT-873",
      "AT-874",
      "AT-879"
    ],
    "FR-555": [
      "AT-878"
    ]
  }
}
```

<!-- END EMBEDDED SOURCE: REQUIREMENTS_TRACEABILITY_ADDENDUM.json -->


---

# APPENDIX SOURCE: `REQUIREMENTS_TRACEABILITY_ADDENDUM_v0.28.json`

<!-- BEGIN EMBEDDED SOURCE: REQUIREMENTS_TRACEABILITY_ADDENDUM_v0.28.json -->

```json
{
  "version": "v0.28-candidate",
  "requirements": {
    "FR-556": [
      "AT-880",
      "AT-931"
    ],
    "FR-557": [
      "AT-881"
    ],
    "FR-558": [
      "AT-882"
    ],
    "FR-559": [
      "AT-883"
    ],
    "FR-560": [
      "AT-884",
      "AT-931"
    ],
    "FR-561": [
      "AT-885",
      "AT-931"
    ],
    "FR-562": [
      "AT-886"
    ],
    "FR-563": [
      "AT-887",
      "AT-931"
    ],
    "FR-564": [
      "AT-888",
      "AT-931"
    ],
    "FR-565": [
      "AT-889"
    ],
    "FR-566": [
      "AT-890"
    ],
    "FR-567": [
      "AT-891",
      "AT-931"
    ],
    "FR-568": [
      "AT-892",
      "AT-931"
    ],
    "FR-569": [
      "AT-893"
    ],
    "FR-570": [
      "AT-894"
    ],
    "FR-571": [
      "AT-895"
    ],
    "FR-572": [
      "AT-896"
    ],
    "FR-573": [
      "AT-897"
    ],
    "FR-574": [
      "AT-898",
      "AT-931"
    ],
    "FR-575": [
      "AT-899"
    ],
    "FR-576": [
      "AT-900"
    ],
    "FR-577": [
      "AT-901",
      "AT-931"
    ],
    "FR-578": [
      "AT-902"
    ],
    "FR-579": [
      "AT-903",
      "AT-931"
    ],
    "FR-580": [
      "AT-904"
    ],
    "FR-581": [
      "AT-905"
    ],
    "FR-582": [
      "AT-906"
    ],
    "FR-583": [
      "AT-907"
    ],
    "FR-584": [
      "AT-908",
      "AT-931"
    ],
    "FR-585": [
      "AT-909"
    ],
    "FR-586": [
      "AT-910"
    ],
    "FR-587": [
      "AT-911",
      "AT-931"
    ],
    "FR-588": [
      "AT-912",
      "AT-931"
    ],
    "FR-589": [
      "AT-913",
      "AT-931"
    ],
    "FR-590": [
      "AT-914",
      "AT-931"
    ],
    "FR-591": [
      "AT-915",
      "AT-931"
    ],
    "FR-592": [
      "AT-916"
    ],
    "FR-593": [
      "AT-917"
    ],
    "FR-594": [
      "AT-918"
    ],
    "FR-595": [
      "AT-919",
      "AT-931"
    ]
  }
}
```

<!-- END EMBEDDED SOURCE: REQUIREMENTS_TRACEABILITY_ADDENDUM_v0.28.json -->


---

# APPENDIX SOURCE: `V027_CANDIDATE_EXECUTION_EVIDENCE.json`

<!-- BEGIN EMBEDDED SOURCE: V027_CANDIDATE_EXECUTION_EVIDENCE.json -->

```json
{
  "version": "v0.27-candidate",
  "status": "CANDIDATE_DELTA_ONLY",
  "baseline_required_sha256": "687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369",
  "baseline_bytes_available_in_runtime": false,
  "structural_validator": {
    "status": "PASS",
    "output": "PASS: v0.27 candidate structural validator"
  },
  "json_parse_recursive": "PASS",
  "dart_overlay_brace_balance": "PASS",
  "flutter_toolchain_available_in_runtime": false,
  "flutter_analyze": "NOT_RUN",
  "flutter_test": "NOT_RUN",
  "web_build": "NOT_RUN",
  "windows_build": "NOT_RUN",
  "android_build": "NOT_RUN",
  "ios_macos_build": "NOT_RUN",
  "full_v027_merge": "BLOCKED_BASELINE_BYTES_NOT_AVAILABLE",
  "current_promotion": "NOT_PERFORMED"
}
```

<!-- END EMBEDDED SOURCE: V027_CANDIDATE_EXECUTION_EVIDENCE.json -->


---

# APPENDIX SOURCE: `V028_CANDIDATE_EXECUTION_EVIDENCE.json`

<!-- BEGIN EMBEDDED SOURCE: V028_CANDIDATE_EXECUTION_EVIDENCE.json -->

```json
{
  "version": "v0.28-candidate",
  "status": "CANDIDATE_DELTA_ONLY",
  "required_baseline_sha256": "687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369",
  "parent_candidate_sha256_verified": "PASS",
  "v027_structural_validator": {
    "status": "PASS",
    "output": "PASS: v0.27 candidate structural validator"
  },
  "v028_linux_structural_validator": {
    "status": "PASS",
    "output": "PASS: v0.28 Linux candidate structural validator"
  },
  "json_parse_recursive": "PASS",
  "identifier_addendum_uniqueness": "PASS",
  "traceability_addendum": "PASS",
  "host": {
    "os": "Debian GNU/Linux 13 (trixie)",
    "arch": "x86_64",
    "tools": {
      "flutter": false,
      "dart": false,
      "flatpak": false,
      "flatpak-builder": false,
      "appimagetool": false,
      "rpmbuild": false,
      "dpkg-deb": true,
      "snapcraft": false,
      "ldd": true
    }
  },
  "flutter_analyze": "NOT_RUN",
  "flutter_test": "NOT_RUN",
  "linux_build": "NOT_RUN",
  "flatpak_build": "NOT_RUN",
  "appimage_build": "NOT_RUN",
  "rpm_build": "NOT_RUN",
  "deb_build": "NOT_RUN_NO_COMPILED_BINARY",
  "fedora_smoke": "NOT_RUN",
  "nobara_smoke": "NOT_RUN",
  "ubuntu_smoke": "NOT_RUN",
  "debian_smoke": "NOT_RUN",
  "full_v028_merge": "BLOCKED_BASELINE_BYTES_NOT_AVAILABLE",
  "current_promotion": "NOT_PERFORMED"
}
```

<!-- END EMBEDDED SOURCE: V028_CANDIDATE_EXECUTION_EVIDENCE.json -->


---

# APPENDIX SOURCE: `BASELINE_REQUIREMENT.json`

<!-- BEGIN EMBEDDED SOURCE: BASELINE_REQUIREMENT.json -->

```json
{
  "candidate_version": "v0.28-candidate",
  "required_baseline": {
    "artifact": "LONGEVITY_APP_DEVELOPER_HANDOFF_v0.26.zip",
    "sha256": "687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369"
  },
  "parent_candidate": {
    "artifact": "LONGEVITY_APP_v0.27_CANDIDATE_PATCH.zip",
    "sha256": "ffd50fd4fa2fc197fc5e118bca72c10e25384bc9cc9a4dcf4154eae7f90e488a",
    "verified": true
  },
  "design_delta": "READY",
  "current_promotion": "BLOCKED_BASELINE_BYTES_NOT_AVAILABLE",
  "linux_compiled_runtime": "NOT_RUN"
}
```

<!-- END EMBEDDED SOURCE: BASELINE_REQUIREMENT.json -->


---

# APPENDIX SOURCE: `PATCH_MANIFEST.json`

<!-- BEGIN EMBEDDED SOURCE: PATCH_MANIFEST.json -->

```json
{
  "project": "Human Health OS",
  "candidate_version": "v0.28-candidate",
  "status": "CANDIDATE_DELTA_ONLY",
  "required_baseline_sha256": "687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369",
  "parent_candidate_sha256": "ffd50fd4fa2fc197fc5e118bca72c10e25384bc9cc9a4dcf4154eae7f90e488a",
  "purpose": "cumulative v0.27 repository bootstrap + v0.28 Linux cross-distribution packaging/support matrix",
  "file_count_excluding_manifest": 72,
  "validation": {
    "v027_structural_validator": "PASS",
    "v028_linux_structural_validator": "PASS",
    "json_parse_recursive": "PASS",
    "identifier_addendum_uniqueness": "PASS",
    "linux_compilation": "NOT_RUN",
    "full_baseline_merge": "BLOCKED_BASELINE_BYTES_NOT_AVAILABLE"
  },
  "files": [
    {
      "file": "00_READ_THIS_FIRST.md",
      "bytes": 969,
      "sha256": "987fed08cc741e5798cde477c10c49cf03ece1b4f2d6e0b09a44c9df7adae4d3"
    },
    {
      "file": "207_FLUTTER_REPOSITORY_BOOTSTRAP_CONTRACT.md",
      "bytes": 993,
      "sha256": "6e69e46d831f2a61dcac06d3cce51b721a7eef47fe682870f1874be989fed361"
    },
    {
      "file": "208_REPOSITORY_LAYOUT_AND_ARCHITECTURE.md",
      "bytes": 931,
      "sha256": "c869abf837ee9bacb7d7c084c5a29ff857a5b1ae0808feaf60e57ad44884e1c9"
    },
    {
      "file": "209_FIRST_APP_SHELL_VERTICAL_SLICE.md",
      "bytes": 595,
      "sha256": "f38d4041930e84372acb4f23be2c7c602ee460f264999c53dda3e99648b32be1"
    },
    {
      "file": "210_LOCAL_FIRST_PORTS_AND_PLATFORM_ADAPTERS.md",
      "bytes": 825,
      "sha256": "c2c131af8f7bcffc95632c64b0b2e58188a0638b9b9389d01dda6b662bdef7cc"
    },
    {
      "file": "211_BUILD_PROFILES_CONFIGURATION_AND_SECRETS.md",
      "bytes": 714,
      "sha256": "3ef1c468dea198218e5a641a0b99064a2335c12c84de1590cc72c0ed4dd71d34"
    },
    {
      "file": "212_DEPENDENCY_LOCK_SBOM_LICENSE_AND_SUPPLY_CHAIN.md",
      "bytes": 934,
      "sha256": "16f1460c95c45f28fe0b9f271b9b620397f602215015b97764daa0cd351c55c4"
    },
    {
      "file": "213_CI_BUILD_MATRIX_PROVENANCE_AND_ATTESTATION.md",
      "bytes": 914,
      "sha256": "eeaaae4627dfad5d00cc51a9bffe6d59d4d65b60c286e48d999c59e60e1aa25f"
    },
    {
      "file": "214_RELEASE_CHANNEL_UPDATE_METADATA_AND_ROLLBACK.md",
      "bytes": 728,
      "sha256": "e1c4e84238758f935dcb259b5a1c3e0da3d49a54d8035f75aa067dab75442ab3"
    },
    {
      "file": "215_FIRST_COMPILED_SLICE_ACCEPTANCE_GATE.md",
      "bytes": 849,
      "sha256": "c4b737a0c3b0864a4098ff0ce1d97e47df0235706b26b2187775d33ff4ebdae3"
    },
    {
      "file": "216_LINUX_CROSS_DISTRO_DISTRIBUTION_CONTRACT.md",
      "bytes": 2044,
      "sha256": "bf70cf5d17aed1a1a597abff2de4ccab1ea2f00fade92d0fe9b1c192f6631b37"
    },
    {
      "file": "217_LINUX_DISTRO_FAMILY_AND_SUPPORT_MATRIX.md",
      "bytes": 1811,
      "sha256": "f2b3d490aadb715c6df04284935db64d2377460d08dfc75aedd16b6052bf08c3"
    },
    {
      "file": "218_LINUX_PORTABLE_APPIMAGE_AND_TARBALL.md",
      "bytes": 1690,
      "sha256": "8f35156bba3b62cc72858d2dea9f5ac7e1a092b4241e8fc8763b18e61db2d514"
    },
    {
      "file": "219_LINUX_FLATPAK_SANDBOX_PORTALS_AND_PERMISSIONS.md",
      "bytes": 1380,
      "sha256": "962f734e4113228817bc87610c1ebf4fac979e89da71e4b746e9a0096d694aa4"
    },
    {
      "file": "220_LINUX_DEB_RPM_NATIVE_PACKAGES.md",
      "bytes": 1418,
      "sha256": "c3bc2b45db5b39e2d78e084f0987f258d78b5dedd5276758d20f952bf1e716fd"
    },
    {
      "file": "221_LINUX_DATA_VAULT_XDG_AND_KEYRING.md",
      "bytes": 1236,
      "sha256": "78f3cf3c13dc9dba50e8c5e32d2bf994e5529e9a1b6438f8e2a97b9db28b609b"
    },
    {
      "file": "222_LINUX_SIGNING_UPDATE_SBOM_AND_RELEASE_PROVENANCE.md",
      "bytes": 1139,
      "sha256": "9ff8bf8c2aa93cfc0190517b29be342980654f2a0e20723b3e002ed59ba99180"
    },
    {
      "file": "223_LINUX_CI_DISTRO_AND_SESSION_SMOKE_MATRIX.md",
      "bytes": 1335,
      "sha256": "3d1a6c04ac193bf43f964d31f9d79c1df42a1377f9de42be83debe3dd167ed20"
    },
    {
      "file": "224_LINUX_RUNTIME_FAILURE_RECOVERY_AND_DESKTOP_INTEGRATION.md",
      "bytes": 1173,
      "sha256": "b26acefbe131c41f816e3bbf42b99adfc508a11338d3739781adf5b1eeee3e5a"
    },
    {
      "file": "225_LINUX_RELEASE_ARTIFACT_MATRIX.md",
      "bytes": 920,
      "sha256": "8784955024e6bec3ac329bd745b6635b7b5dd0591337496208f7d06b3823c7dd"
    },
    {
      "file": "226_LINUX_DISTRIBUTION_SYNTHETIC_FIXTURES.md",
      "bytes": 661,
      "sha256": "22ad67476f04389689b696c2ac45ecdd430eda2988572b6aebcba2374d93e8f0"
    },
    {
      "file": "ACCEPTANCE_TEST_ADDENDUM_v0.27.md",
      "bytes": 2289,
      "sha256": "389b0d94fee010e4e186282455832b174e2e3bf3e527eaf355f76e03cea7655f"
    },
    {
      "file": "ACCEPTANCE_TEST_ADDENDUM_v0.28.md",
      "bytes": 3667,
      "sha256": "77a48e6cef9af8e38ca7a54bdec284ccbbffed793becead27b9b9ece949f2d35"
    },
    {
      "file": "ARCHITECTURE_DECISIONS_ADDENDUM_v0.27.md",
      "bytes": 625,
      "sha256": "31a2eee830f1f9963f2c5575ec9666d520a6e09305c4643fae92cecbf8dc5671"
    },
    {
      "file": "ARCHITECTURE_DECISIONS_ADDENDUM_v0.28.md",
      "bytes": 1218,
      "sha256": "d7513f86896261fed486c38d2e84c4e0f81d8ac36f6fa2790907c7fd711ad68b"
    },
    {
      "file": "BASELINE_REQUIREMENT.json",
      "bytes": 537,
      "sha256": "a80fc60fc1114dae012686089854bbd8c9b338dad0a3645c489083d23f18f9e3"
    },
    {
      "file": "BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.27.txt",
      "bytes": 579,
      "sha256": "ae53fde48178368ddc2f5c1426e65a5ff0d185fd5a1792507175f089cd5e5d9e"
    },
    {
      "file": "BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.28.txt",
      "bytes": 913,
      "sha256": "25163854313ea8e729d96e9f63f11724f9557f2db754a42893f7ea82480bce18"
    },
    {
      "file": "BUILD_HUMAN_HEALTH_OS_SITE_v0.27_ADDENDUM.txt",
      "bytes": 297,
      "sha256": "1d1cee2cefb15a65b4fadb0954d3ec8a55c19b1aeb19489322d6516dd61d3319"
    },
    {
      "file": "BUILD_HUMAN_HEALTH_OS_SITE_v0.28_ADDENDUM.txt",
      "bytes": 533,
      "sha256": "6e06a6e5cc7133b877b7bb800e2d7ab169bac6fc93f6bcb35304c7127ec0598f"
    },
    {
      "file": "BUILD_LINUX_DESKTOP_DISTRIBUTION_v0.28.txt",
      "bytes": 3199,
      "sha256": "1b92b5c911d792e58825736f8cefb26490126bdcfd87029ba6b719115454d3b0"
    },
    {
      "file": "BUILD_LONGEVITY_APP_v0.27_CANDIDATE.txt",
      "bytes": 1179,
      "sha256": "bcd2dffe7e45e720d77aab409578d9d03d4c1c61f66ad916ce6a6915ba177435"
    },
    {
      "file": "BUILD_LONGEVITY_APP_v0.28_CANDIDATE.txt",
      "bytes": 1900,
      "sha256": "812a2ca8313e22ae4472d2ac1f4f64392f587048561cf9fda2c6d1809347a351"
    },
    {
      "file": "BUILD_PROVENANCE_CONTRACT.json",
      "bytes": 459,
      "sha256": "6a230cf7481eb98aba19d4d7328bfade07c1f885fc13bb1c445a147ce984f8ff"
    },
    {
      "file": "BUILD_WINDOWS_PORTABLE_DESKTOP_v0.27_ADDENDUM.txt",
      "bytes": 424,
      "sha256": "1fb81a6cfb2ad6dd1439f35b48322589f1db3b1654e1013bccf1f122d974d2ad"
    },
    {
      "file": "BUILD_WINDOWS_PORTABLE_DESKTOP_v0.28_ADDENDUM.txt",
      "bytes": 635,
      "sha256": "043a8d356d1f789b26651b7948b3e3f5c908f9d33a796d622e8c467a54c03b56"
    },
    {
      "file": "FAILURE_MODES_ADDENDUM_v0.27.md",
      "bytes": 639,
      "sha256": "ffe175fb7c2a539fce3341551cce0885f98f8a92baf53244b5db86f8f570a599"
    },
    {
      "file": "FAILURE_MODES_ADDENDUM_v0.28.md",
      "bytes": 1149,
      "sha256": "10f4b5b3a585a5aed277ac777a3be4541dfa8c14ec94cb1257e6511fda3866a6"
    },
    {
      "file": "IMPLEMENTATION_PHASE_ADDENDUM_v0.27.md",
      "bytes": 402,
      "sha256": "e0b6b4e57289216dfe70b6a68e05f8c94e4a2a4eff6b7566cbf7eb452fc6232e"
    },
    {
      "file": "IMPLEMENTATION_PHASE_ADDENDUM_v0.28.md",
      "bytes": 463,
      "sha256": "f6f1999ff6d3cb41d827b90924f4b838c5c688a33ab6def10a0a16c5b99671e5"
    },
    {
      "file": "LINUX_DISTRIBUTION_MATRIX.json",
      "bytes": 1777,
      "sha256": "09bcc10b2b0ece12e9ea96f912665fb9211a591852443544f39010553966bc71"
    },
    {
      "file": "LINUX_PACKAGING_CONTRACT.json",
      "bytes": 1130,
      "sha256": "75899e774523779b898fe699e3990a657b8e56939c860e3f570b52b914cfe818"
    },
    {
      "file": "LINUX_SMOKE_MATRIX.json",
      "bytes": 530,
      "sha256": "7d54bafffb72bf5356377225a5cd3163c4fd6edf93765cdabcd293f1464778a8"
    },
    {
      "file": "LONGEVITY_APP_MASTER_ADDENDUM_v0.28_CANDIDATE.md",
      "bytes": 1456,
      "sha256": "c5705e0ba0ad02689b9ec3c9f1d7a72e473db8d72fe11eacd766fd69dd7cde60"
    },
    {
      "file": "REPOSITORY_BOOTSTRAP_CONTRACT.json",
      "bytes": 626,
      "sha256": "a07e592dcee31166e77e099682bd62fdfa2c8982506385fb4bb56bc8c14d53dd"
    },
    {
      "file": "REQUIREMENTS_ADDENDUM_v0.27.md",
      "bytes": 1474,
      "sha256": "42d4135eed8d7b2ee5893309f591ff0892478bd30dc27e528a524efd841369b1"
    },
    {
      "file": "REQUIREMENTS_ADDENDUM_v0.28.md",
      "bytes": 1745,
      "sha256": "637cd62385e0ec596eff978d36a177d617ff82446227540fa6e242d4a223dd55"
    },
    {
      "file": "REQUIREMENTS_TRACEABILITY_ADDENDUM.json",
      "bytes": 1613,
      "sha256": "d6cfddb1a72e640250429d8f52eb7009e17a9202d83e9038cad7183c8af6cc30"
    },
    {
      "file": "REQUIREMENTS_TRACEABILITY_ADDENDUM_v0.28.json",
      "bytes": 1851,
      "sha256": "c379c7d70d095e28993f9d52ac2fa42b158c4fc734cc99703c1286174c8ff01e"
    },
    {
      "file": "SUPPLY_CHAIN_POLICY.json",
      "bytes": 569,
      "sha256": "d6092b2c5a1fc81ec69cf4d81554c0955048612d9775423a7fd933e5abe7b538"
    },
    {
      "file": "TECHNICAL_SOURCE_ADDENDUM_v0.27.md",
      "bytes": 822,
      "sha256": "b46ee4b6cc0e1dab688e9c63e8ba3e2c6e97ad8a1d356f41223c689343c42d71"
    },
    {
      "file": "TECHNICAL_SOURCE_ADDENDUM_v0.28.md",
      "bytes": 1615,
      "sha256": "8f0164db40a34549aa87b5492f6c2269b01b02c5bcfa6003e3aa04df0e2c7b74"
    },
    {
      "file": "V027_CANDIDATE_EXECUTION_EVIDENCE.json",
      "bytes": 736,
      "sha256": "20e91069211b39dfb7ce9e82600b961a40f055753624243fadf3ccbc8cb95cee"
    },
    {
      "file": "V028_CANDIDATE_EXECUTION_EVIDENCE.json",
      "bytes": 1341,
      "sha256": "5c84f639caa2d22022a7df9df2070670c6f5fe039cf53d097ebab1dbeeb56db4"
    },
    {
      "file": "linux_distribution_fixtures.json",
      "bytes": 2206,
      "sha256": "baba20b14cc9dc1f9665d2cf6e208387f932b7f2d760680171ca957e490eb98c"
    },
    {
      "file": "reference_code/validate_v027_candidate.py",
      "bytes": 2320,
      "sha256": "c298e0220b0b6e757215a7c5d25cc88fdb3470a83ca6030962d02bd9fe1fd49e"
    },
    {
      "file": "reference_code/validate_v028_linux_candidate.py",
      "bytes": 1650,
      "sha256": "80c5a6d0a7215489817004e343ea7ef7169e161a13bd772d6bbbb585076a1d57"
    },
    {
      "file": "repository_bootstrap_overlay/README_OVERLAY.md",
      "bytes": 563,
      "sha256": "fa6f0a5eb6954739b8ebe9b74e87eb84f66e64364617802823e1d9aa86296b2b"
    },
    {
      "file": "repository_bootstrap_overlay/lib/main.dart",
      "bytes": 181,
      "sha256": "40c7809d2413c0ccfbb9d5b74a221020af950802338495e067be8c146189fa44"
    },
    {
      "file": "repository_bootstrap_overlay/lib/src/app/human_health_os_app.dart",
      "bytes": 567,
      "sha256": "af9a092f8a49d3da2d0884ca6d1d95ed0bc54e7c0c12538795ff9666cce8666e"
    },
    {
      "file": "repository_bootstrap_overlay/lib/src/config/build_profile.dart",
      "bytes": 347,
      "sha256": "470e605bf7c303bf77835661d1ffc229653511f2c85df6f14b06aa256709450e"
    },
    {
      "file": "repository_bootstrap_overlay/lib/src/navigation/app_destination.dart",
      "bytes": 878,
      "sha256": "2d0ef9a7332eaf1134012d4b6a143f07e907d654bdb8a9b1a96dc5709a750517"
    },
    {
      "file": "repository_bootstrap_overlay/lib/src/navigation/responsive_shell.dart",
      "bytes": 2942,
      "sha256": "3eb4f0a2cb723b3a47e6f0044a864cfa30dddaa720af4734fa2eeca6ae10b9e4"
    },
    {
      "file": "repository_bootstrap_overlay/packaging/linux/README.md",
      "bytes": 552,
      "sha256": "2fce68d38d02686fd39cb4ba9289790d385165181e1ca5c292a1dd738b666f3f"
    },
    {
      "file": "repository_bootstrap_overlay/packaging/linux/com.humanos.HumanHealthOS.desktop",
      "bytes": 237,
      "sha256": "4c854f1de7ca98cee9711929a197689229d3979aab7c0d6883e2860e4ac48090"
    },
    {
      "file": "repository_bootstrap_overlay/packaging/linux/com.humanos.HumanHealthOS.metainfo.xml",
      "bytes": 564,
      "sha256": "0b812c281e9770a6f474bcb4407d788521fb1478a31bd6a2e9cadc729bc7e1ad"
    },
    {
      "file": "repository_bootstrap_overlay/packaging/linux/deb/control.template",
      "bytes": 312,
      "sha256": "e89c406893f97954a08420554f9876d32fe056dc6b65e9780a677aa3a24427a0"
    },
    {
      "file": "repository_bootstrap_overlay/packaging/linux/flatpak/com.humanos.HumanHealthOS.yml.template",
      "bytes": 497,
      "sha256": "0414a9ecf2deee31aebbbe272068080be1e7f1563b7c963d33d4079964dc8b9a"
    },
    {
      "file": "repository_bootstrap_overlay/packaging/linux/rpm/human-health-os.spec.template",
      "bytes": 330,
      "sha256": "eb14a28f02a6afb27e9b09fcef6b7fd30abbadce83dc31dc1ca369bd20dd05f3"
    },
    {
      "file": "repository_bootstrap_overlay/test/app_smoke_test.dart",
      "bytes": 645,
      "sha256": "7bb903d9402181a2a6add0f27e3677885b57ae6c88c87d10307a0d5f8e1765fc"
    },
    {
      "file": "repository_bootstrap_overlay/tool/linux/check_linux_release_host.sh",
      "bytes": 417,
      "sha256": "34c44a189e7239ceee500274fc33de4e46498d31dc9342d42c56a299f7e30697"
    },
    {
      "file": "repository_bootstrap_overlay/tool/linux/package_portable_bundle.sh",
      "bytes": 654,
      "sha256": "b854be0f95a08319577c4dc96cae5012fdbdb97514143a9d013b4fe52f07b0cf"
    }
  ]
}
```

<!-- END EMBEDDED SOURCE: PATCH_MANIFEST.json -->


---

# APPENDIX SOURCE: `BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.27.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.27.txt -->

TASK: turn Human Health OS from specification into its first real Flutter repository.

Use installed Flutter toolchain. Create the six-platform app, overlay supplied lib/test, run pub get/analyze/test, run/build one supported target, fix the first decisive failure, and record exact PASS/FAIL/NOT_RUN. Stop at a working shell before persistence. Then expand: local storage ports → encrypted repository → canonical health records → import/export → health modules → native adapters → remote sync.

Never claim compilation or platform artifacts without actual evidence.

<!-- END EMBEDDED SOURCE: BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.27.txt -->


---

# APPENDIX SOURCE: `BUILD_HUMAN_HEALTH_OS_SITE_v0.27_ADDENDUM.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_HUMAN_HEALTH_OS_SITE_v0.27_ADDENDUM.txt -->

V0.27 WEB ADDENDUM

Create real Flutter repository → overlay → analyze/test → build Web → runtime smoke Today→Labs. Keep private Web App separate from synthetic Site Lab. Do not embed production server master secrets. Public release includes dependency/SBOM/license/provenance evidence.

<!-- END EMBEDDED SOURCE: BUILD_HUMAN_HEALTH_OS_SITE_v0.27_ADDENDUM.txt -->


---

# APPENDIX SOURCE: `BUILD_LONGEVITY_APP_v0.27_CANDIDATE.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_LONGEVITY_APP_v0.27_CANDIDATE.txt -->

BUILD HUMAN HEALTH OS FROM VERIFIED v0.26 + v0.27 CANDIDATE PATCH

Required baseline SHA-256: 687335dedb86d654f77a13ca069c2c61688b93e0f7e437bb379e1d3c3b0b3369
STOP if it differs.

1. `flutter doctor -v`
2. `flutter create --empty --platforms=android,ios,web,windows,macos,linux human_health_os`
3. Overlay candidate `lib/` and `test/`.
4. Keep tool-generated platform folders and SDK constraints.
5. `flutter pub get`
6. `flutter analyze`
7. `flutter test`
8. Run/build one supported target.
9. Fix first decisive failure and rerun.
10. Only after shell checkpoint expand local encrypted storage → canonical records → import/export → domain engines → native health adapters → remote sync.

Preserve v0.26 health/safety/domain contracts. This patch extends, never replaces, v0.26.

Commit `pubspec.lock`. Generate dependency inventory, license report and SPDX/CycloneDX SBOM for public release. Record artifact hash, source revision, lockfile hash, Flutter/Dart versions, host/runner, profile and command.

Never embed server master secrets in client builds. Report every target independently PASS/FAIL/NOT_RUN. Never claim an artifact exists unless it actually exists.

<!-- END EMBEDDED SOURCE: BUILD_LONGEVITY_APP_v0.27_CANDIDATE.txt -->


---

# APPENDIX SOURCE: `BUILD_WINDOWS_PORTABLE_DESKTOP_v0.27_ADDENDUM.txt`

<!-- BEGIN EMBEDDED SOURCE: BUILD_WINDOWS_PORTABLE_DESKTOP_v0.27_ADDENDUM.txt -->

V0.27 WINDOWS ADDENDUM

On an actual Windows build host: flutter doctor -v → flutter pub get → flutter analyze → flutter test → flutter build windows. Only then package portable ZIP and Setup EXE, apply encrypted-vault contract, perform clean-machine/offline smoke, sign production bytes, hash final artifacts and generate SBOM/license/provenance evidence. Do not handcraft a fake EXE from the specification bundle.

<!-- END EMBEDDED SOURCE: BUILD_WINDOWS_PORTABLE_DESKTOP_v0.27_ADDENDUM.txt -->
