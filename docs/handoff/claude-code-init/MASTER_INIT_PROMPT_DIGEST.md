# Claude Code master initialization prompt: normative digest

Source: the user's "HUMAN OS / HUMAN HEALTH OS — CLAUDE CODE MASTER DEVELOPMENT INITIALIZATION PROMPT" (40 sections), delivered in chat on 2026-10-06. This file is a **digest**, not the verbatim text. Section numbers match the original prompt. Where this digest and the original differ, the original wins.

Follow-up instruction from the same user, given after the prompt: "bu uygulamayı geliştir döngüsel olarak" (develop this application in cycles). This authorizes running consecutive bounded FORGE iterations. Each iteration still ends with its own report and state update.

## Identity (§1–4)

- Human OS, Human Health OS and Longevity App are one product: a local-first, offline-capable, deterministic personal health operating system. "Operating system" means a unified system for a person's health state over time, not a kernel.
- There are **five primary surfaces** from one shared core: Android, iOS, Web/installable web app, Windows (portable ZIP with `HumanHealthOS.exe`, plus `HumanHealthOS-Setup-x64.exe`), and macOS (`.app`, DMG/PKG).
- The **Build Lab** is an auxiliary synthetic laboratory, not a sixth platform. It must never mix synthetic subjects with real users.

## Invariants (§2, §12–19)

planned ≠ completed · missing ≠ zero · unknown ≠ false · source text ≠ normalized interpretation · association ≠ causation · risk estimate ≠ diagnosis · model output ≠ observed reality · scenario ≠ observation · recommendation ≠ completed action · reminder ≠ completion · prescription ≠ ingestion · screening ≠ diagnosis · reference interval ≠ optimal target ≠ clinical decision limit · out-of-range ≠ critical · same display name ≠ same measurand · self-report ≠ confirmed diagnosis · duplicate ingredient ≠ toxicity · interaction ≠ contraindication · "no interaction found" ≠ guaranteed safe · unknown history ≠ zero history · mission ≠ completed behaviour.

Keep these record states distinct: OBSERVED, REPORTED, PLANNED, COMPLETED, DERIVED, MODELLED, ASSUMED, UNKNOWN. Historical truth must stay reconstructable when terminology, ranges, models, rules or mappings change.

Keep these artifact categories separate: MODEL, RULE, REFERENCE DATASET, HEALTH RECORD, PLAN, TASK, COMPLETION EVENT.

## Architecture (§5–7, §10–11)

- One shared core (models, engines, repositories). Platform-specific behaviour lives behind adapters: Health Connect, HealthKit, secure storage, notifications, filesystem, browser storage, updater.
- The prompt prefers one Flutter/Dart client for all five surfaces, unless the repository proves another architecture was already accepted. Do not discard viable existing work.
- The core needs no generative AI, LLM or cloud for its deterministic functions.
- **Portable Windows vault:** encrypted, movable between PCs, unlocked by a passphrase plus a recovery mechanism. Machine-bound unlock is an optional convenience only. A filesystem path is never a profile identity. No plaintext SQLite beside the EXE in production.
- Health data is never stored inside the macOS `.app`. Uninstalling the app never deletes health data.
- Deterministic means the same validated input with the same model or rule version gives the same result. Each result exposes its inputs, model/rule ID and version, timestamp, limitations and missing inputs.

## Security (§8–9, §28–29)

Provenance on every record: MANUAL, DEVICE, PROVIDER, DOCUMENT, API, DERIVED, MODELLED, IMPORTED or UNKNOWN. Store created_at, observed_at and effective_at, the source and source version, the original and normalized values, and the correction lineage. Never commit secrets or real health data, and report any found secret without reproducing its value. Add dependencies deliberately and commit lockfiles. Plan for an SBOM. Never claim a supply-chain level that was not achieved.

## Method: FORGE (§21–22, §36–38)

One FORGE is one bounded, meaningful increment, run in this order: ORIENT → SELECT GAP → SPECIFY → IMPLEMENT → TEST → INSPECT FIRST FAILURE → REPAIR → RETEST → REGRESSION → AUDIT → PACKAGE → STOP, then recommend the next increment.

`FORGE: <scope>` uses the requested scope when it is coherent.

Every FORGE report uses these headings: Goal, Baseline State, Implemented, Files Changed, Data/Migration Changes, Security/Privacy Impact, Tests Actually Executed (command, result, PASS/FAIL), Builds Actually Executed (platform, command, PASS/FAIL/NOT_RUN), Bugs Found, Fixes Applied, Regression Check, Artifacts Produced (real paths only), Known Limitations, State Update, Next Recommended Forge.

The honesty ladder: PLANNED < SPECIFIED < IMPLEMENTED < STATICALLY_TESTED < UNIT_TESTED < INTEGRATION_TESTED < COMPILED < RUNTIME_TESTED < PACKAGED < SIGNED < NOTARIZED < DEPLOYED. Never collapse these levels. Use NOT_RUN, BLOCKED_ENVIRONMENT or UNKNOWN when a step was not proven.

## State files (§23–24)

`CLAUDE.md`, plus `docs/{HUMAN_OS_OVERVIEW, ARCHITECTURE, DEVELOPMENT_PLAN, ROADMAP, PLATFORM_MATRIX, SECURITY_MODEL, DATA_MODEL, TEST_STRATEGY, RELEASE_STRATEGY}.md` and `project_state/{CURRENT_STATE.json, FORGE_LOG.md, DECISIONS.md, RISKS.md, KNOWN_GAPS.md}`. Reuse an existing state mechanism instead of creating a competing one.

## Git (§26)

Inspect state first. Never run `reset --hard`, `clean -fd` or a force push. Preserve the user's work. Commit only when the workflow asks for it. This environment's session instructions do ask for commits and pushes to the designated branch.
