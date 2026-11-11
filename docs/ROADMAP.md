# Roadmap

**Canonical Forge ids follow the vertical-slice ladder** of the master (§39; unchanged from v0.31 to v0.32; decisions D-011, D-013). A ladder id re-run under a newer master contract is recorded as `F00n@v0.xx`. Each Forge closes one usable slice under the v0.31 Definition of Done (§34). Live status is in `project_state/CURRENT_STATE.json`; this table is a summary and loses to it.

| Id | Slice | Exit gate (master §39) | Status (2026-10-08) | Legacy ids folded in |
|---|---|---|---|---|
| **F001** | Repository heartbeat: Flutter repo, responsive shell, Today / Timeline / Labs navigation, build-profile indicator, first host-supported build + runtime smoke | analyze/test PASS; one host build + runtime **receipt**; no new persistence | DONE as `F001@v0.31` (14 receipt-backed gates); **re-certification `F001@v0.32` in progress** against the v0.32 kernel contract (exactly three primary destinations, console-error smoke, behavioral offline start) | F001 |
| F002 | Local profile + persistence heartbeat: profile identity, repository port, one canonical record, save/read after restart, provenance + stable id | persistence integration test; migration version initialized; no plaintext-secret shortcut | **DONE (F002@v0.32, receipts EV-*-F002-0001…0009)**: vault format 1 with compatibility metadata, migration graph + receipts + v1 fixture, replay validation, `human-health-os/` XDG move (C-4), storage reason codes | FORGE 002 |
| F003 | Timeline + correction lineage | timeline ordering + correction-history tests | **DONE (F003@v0.32, receipts EV-*-F003-0001…0009)**: record schema 2 (`amend_reason`), timeline projection with correction / entered-in-error / delete / conflict semantics, Timeline screen | F006 |
| F004 | Labs vertical slice | missing unit/range stays missing; source flag kept; no diagnosis | **DONE (F004@v0.32, receipts EV-*-F004-0001…0009)**: record schema 3 `lab.result` with printed details (flag, range, specimen, laboratory) kept verbatim; Labs screen; no interpretation (engine port F011) | F008, F009 |
| F005 | Import/export + backup foundation | backup → delete test vault → restore → same records; manifest checksums | **DONE (F005@v0.32, receipts EV-*-F005-0010…0019)**: backup bundle (manifest + SHA-256, payload byte-identical), staged restore gate, restore drill, deterministic export; unencrypted until F006 | F005, F025, F029 |
| F006 | Local security hardening: key abstraction, installed vault protection, portable vault foundation, redacted logs | logging tests; key-loss/recovery states; no plaintext fallback | **DONE (F006@v0.32, receipts EV-*-F006-0019…0028)**: encrypted vault `hhos-vault-enc` v1 (Argon2id + ChaCha20-Poly1305, D-016) for staging, production and portable desktop builds; vault gate with every key state (EN/TR); encrypted backups; redacted logs. Linux runtime-tested; web non-development memory-only (G-32). **MVP ladder F002–F006 complete (D-014)** | F004, F030K |
| F007 | Daily domains (measurements, nutrition, activity, sleep, subjective state), one Forge each | per-slice tests | **Slice 1 (measurements) DONE (F007@v0.32, receipts EV-*-F007-0057…0070)**: record schema 4 (RS-004, additive): waist circumference, resting heart rate and blood pressure (structured systolic/diastolic) typed by hand, kept as typed, never judged; Measurements card on Today, Timeline rows and correction; automatic checkpoint backup before the first measurement; old-code check on main 48c3c94 (D-018). **Slice 2 DONE (F007-S2@v0.32, receipts EV-*-F007-0086…0099)**: record schema 5 (height, body temperature, SpO2, respiratory rate), time of a measurement with clock-change rules, weight entry rules, calm clinical redesign of Today (D-019). **G001 DONE (G001@v0.32, receipts EV-*-F007-0127…0139)**: offline raw DNA file import (23andMe, AncestryDNA, MyHeritage, FamilyTreeDNA): searchable variant list, local annotation packs with an invented demo pack (D-021, D-022). The user-directed U-series (first-run, mouse-only entry, body and specialty guide, glossary: D-020) is next; **Slice 3 (sleep) IMPLEMENTED (F007-S3)**: record schema 7 `sleep.night` (two typed times, optional feeling; time in bed, not time asleep; D-031), Sleep card on Today. **Slice 4 (how you feel) IMPLEMENTED (F007-S4)**: record schema 8 `self.feeling_check_in` (energy, mood, stress as the person's own words; D-032). **Slice 5 (nutrition) IMPLEMENTED (F007-S5)**: record schema 9 `nutrition.food_entry` (as typed; label values with their basis; D-033), Nutrition screen. **Slice 6 (activity) IMPLEMENTED (F007-S6)**: record schema 10 `activity.entry` (typed by hand; whole minutes and steps; nothing estimated; D-034), Activity screen. All F007 daily domains now have a first slice | F007, F010–F012 |
| F008 | Medication / supplement semantics (product ≠ ingredient, plan ≠ intake) | separation tests | **Slice 1 DONE (F008@v0.32)**: record schema 6 (RS-006): `medication.item`, `medication.plan`, `medication.intake` as separate records; Medications screen (add, plan, record a dose taken or skipped); counts only from doses; no drug database, dose rules or interaction checks (D-030). **Slice 2 (R009)**: a plan can be paused, stopped and resumed (new plan records; missing state = active). Not yet: reminders, product catalogue, ingredient-level views | F013 |
| F009 | Conditions / preventive / care pathways (provenance + state machines first) | state-machine tests | **Slice 1 IMPLEMENTED (F009)**: record schema 11 `condition.entry` (as named; current, past or unsure; who it comes from; never confirmed by the app; D-035), Conditions screen. **Slice 2 IMPLEMENTED (F009-S2)**: record schema 12 `preventive.entry` (vaccination, screening, check-up as named; done, planned or unsure; planned is not done; no result kept; nothing recommended, scheduled or reminded; D-036), Preventive screen. Not yet: treatments, care pathways | F014, F016 |
| F010 | Documents (attachment → metadata → reviewed extraction) | OCR never mutates records silently | NOT_STARTED | F015 |
| F011 | Deterministic intelligence (trends, baselines, Longevity/Shortevity) with golden vectors | vectors pass in Dart, TS and Python | **IN PROGRESS (slice 1, D-037)**: Dart engines `MP-CORE-DERIVED-1`, `NUTRITION-MATH-1`, `LAB-INTERPRETATION-ENGINE-1` pass 43 of 73 golden vectors (core derived 19/19, lab interpretation 19/19, nutrition 5/5) in `test/domain/f011_golden_vectors_test.dart`; medication safety (10) and preventive (20) not yet ported; domain only, nothing wired to the UI | F003, F017–F022 |
| F012 | Build Lab on the shared core (synthetic only) | no forked formulas | TS Build Lab exists (`apps/site`), not yet on the Dart core | F036 |
| F013 | Platform health adapters (Health Connect, HealthKit) | import receipts, duplicate handling | BLOCKED_ENVIRONMENT here (Android SDK unavailable, Apple hosts absent) | F023, F024 |
| F014 | Sync / account | after local-first + migrations are stable | NOT_STARTED (TS reference API, dev auth only) | F027, F028 |
| F015 | Desktop distribution (Windows portable/installer, macOS, Linux Flatpak/AppImage/tar/deb/rpm) | format-specific PASS | **F015-L1 (Linux) IN_PROGRESS_RECOVERABLE**: four real packages built; Ubuntu 24.04 install/launch PASS; Ubuntu 22.04 FAIL (open libGLESv2 dependency defect); Windows/macOS BLOCKED_BY_HOST_OS | F030L, F030, F031, F032 |
| F016 | Web/PWA production client | storage limits, backup/export, offline shell | Web build + smoke exist; no PWA install, no export | F034, F035 |
| F017 | Release trust (signed update metadata, SBOM, provenance, promotion) | v0.29 §14.10 tests | NOT_STARTED (do not jump here while builds are hypothetical) | F033, F037–F041 |

Ordering rule: dependency order, one bounded slice per Forge, F002 before anything that stores more data.

## Legacy roadmap (pre-v0.31 ids, kept for traceability; superseded by the table above)

### FOUNDATION
- **F001 – Flutter bootstrap + responsive shell.** `flutter create --empty` for 6 platforms. Ten destinations with rail/bar navigation. Visible build-profile badge. Widget tests. Web build and Playwright runtime smoke. Linux, Android, iOS, macOS and Windows are reported independently (v0.27 gate V1–V3). — *Done: RUNTIME_TESTED on web and Linux (FORGE 001).*
- **F002 – Local heartbeat.** Profile plus one canonical record (body weight) through the `HealthRepository` port. In-memory and file-backed vault adapters. Save, restart, and get the same record back. Missing ≠ 0 in the UI. *(The user's §32 first vertical slice.)* — *Done: RUNTIME_TESTED on web and Linux for development builds (FORGE 002). Development storage is unencrypted and labelled; since F006@v0.32 staging, production and portable desktop builds persist only through the encrypted vault.*
- **F003 – Dart core-derived engines** (`lib/src/domain/scoring`). Must pass `contracts/golden_vectors/core_derived_vectors.json` exactly like TS and Python. The architecture test that blocks Flutter imports in the domain already exists (F002).
- **F004 – Encrypted vault v1.** Versioned header, passphrase KDF, wrapped data key, wrong-passphrase and corrupt-header handling, and a portable-path-move test (same profile UUID). Web uses WebCrypto plus an export warning.
- F005 – Schema migrations and backup/restore of the vault (checkpoint before migrate).

### CORE HUMAN
- F006 – Timeline (an index over canonical records), corrections with `supersedes` lineage, and tombstones.
- F007 – Measurements and vitals (weight, height, waist, blood pressure, resting heart rate) with units and provenance, plus BMI/WHtR results.
- F008 – Labs: sessions and results (PRESENT, NOT_REPORTED, UNREADABLE), reference-interval snapshots, and trend with method discontinuity.
- F009 – Lab interpretation engine (Dart port, lab vectors).

### DAILY HUMAN
- F010 – Mind check-in (1–10) and symptoms. F011 – Sleep and activity (manual first). F012 – Nutrition: foods, snapshots, recipes (nutrition vectors).

### MEDICAL
- F013 – Products, ingredients, plan versus intake, and safety engine (med-safety vectors). F014 – Conditions (provenance states) and treatments. F015 – Documents and attachments with staged lab extraction candidates. F016 – Preventive engine (preventive vectors, jurisdiction packs).

### INTELLIGENCE
- F017 – Protection/Burden/Function/Coverage composites. Numeric vectors are added first, then the port. F018 – Compare and scenarios. F019 – Personal baselines and early-warning patterns. F020 – Daily missions with plan ≠ completion. F021 – Learn (EDU pack moved to JSON/ARB so the Build Lab and the app share it). F022 – Longevity/Shortevity dashboard (MODELLED labels, no date-of-death).

### INTEROPERABILITY
- F023 – Capability registry, Health Connect adapter (Android host). F024 – HealthKit adapter (macOS host). F025 – Portable export and import bundle. F026 – Terminology adapters (LOINC, UCUM) after licence review.

### SYNC
- F027 – Accounts with a real identity provider. F028 – Encrypted sync with idempotency, revisions and conflicts (semantics from `services/api`). F029 – Backup and recovery.

### DESKTOP
- F030L – Linux distribution (D-008/D-009): Flatpak (primary), AppImage (portable, FUSE fallback documented), `Portable.tar.zst`, `.deb`, `.rpm`. Builder on the glibc floor. Launch smoke on Ubuntu 22.04/24.04, Debian 12/13, Fedora 44, Nobara 44 (KDE and GNOME), on Wayland and X11. Each one is reported separately.
- F030K – Linux keyring adapter (Secret Service), with no plaintext-key fallback, and XDG config/cache split. Lands together with or after F004 (encrypted vault).
- F030 – Windows build plus portable ZIP (`portable_mode.json`, `UserData/` vault). F031 – Windows installer (data survives uninstall). F032 – macOS app plus DMG (Application Support storage). F033 – Signed update metadata.

### WEB
- F034 – PWA manifest, service worker and install. Browser-limit disclosures. F035 – Retire `apps/client` once parity exists. F036 – The Build Lab reads shared JSON packs, so the same content feeds the app and the Lab.

### RELEASE
- F037 – Accessibility pass (semantics, text scale, contrast). F038 – Performance budgets. F039 – Security review against SECURITY_MODEL. F040 – SBOM, licenses and provenance. F041 – Signing, notarization and store submission, each on its own host.
