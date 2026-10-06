# Source authority inventory (Phase 0, 2026-10-06)

| Path | Declared version | Class | SHA-256 (first 12) | Notes |
|---|---|---|---|---|
| docs/handoff/v0.24/LONGEVITY_APP_MASTER_HANDOFF_v0.24.md | v0.24 | **AUTHORITATIVE_CURRENT** (product semantics) | 1ce767250719 | Received from user. 24k lines, 186 source docs, highest IDs FR-455 / AT-1108. |
| docs/handoff/v0.24/BUILD_LONGEVITY_APP_v0.24.txt | v0.24 | AUTHORITATIVE_CURRENT (app build prompt) | cb7186fcbdbd | Prefers Flutter. |
| docs/handoff/v0.24/BUILD_HUMAN_HEALTH_OS_SITE_v0.24.txt | v0.24 (header says v0.15, sections to v0.24) | AUTHORITATIVE_CURRENT (Site/Build Lab prompt) | 5ac5670df0a1 | |
| docs/handoff/v0.24/LONGEVITY_APP_DEVELOPER_HANDOFF_v0.24_SHA256.txt | v0.24 | AUTHORITATIVE_CURRENT (checksum only) | 1826d94fcedb | The ZIP itself (`d0eb812b…e699`) was **never supplied**. |
| docs/handoff/v0.27-candidate/LONGEVITY_APP_MASTER_ADDENDUM_v0.27_CANDIDATE.md | v0.27 candidate | **CANDIDATE** (adopted as engineering guidance) | ab85ed6d9768 | Additive to v0.26. Docs 207–215. |
| docs/handoff/v0.27-candidate/BUILD_LONGEVITY_APP_v0.27_CANDIDATE.txt | v0.27 candidate | CANDIDATE | bcd2dffe7e45 | Requires v0.26 baseline `687335de…3369`. **Baseline absent.** |
| docs/handoff/v0.27-candidate/BUILD_FLUTTER_REPOSITORY_BOOTSTRAP_v0.27.txt | v0.27 | CANDIDATE | ae53fde48178 | Shell before persistence. |
| docs/handoff/v0.27-candidate/BUILD_HUMAN_HEALTH_OS_SITE_v0.27_ADDENDUM.txt | v0.27 | ADDENDUM | 1d1cee2cefb1 | Private Web App ≠ synthetic Site Lab. |
| docs/handoff/v0.27-candidate/BUILD_WINDOWS_PORTABLE_DESKTOP_v0.27_ADDENDUM.txt | v0.27 | ADDENDUM | 1fb81a6cfb2a | Real Windows host only. |
| docs/handoff/v0.27-candidate/LONGEVITY_APP_v0.27_CANDIDATE_PATCH_SHA256.txt | v0.27 | CANDIDATE (checksum only) | 08a251fec2bb | The patch ZIP (`ffd50fd4…488a`) and its `repository_bootstrap_overlay/` were **never supplied**. |
| docs/handoff/v0.28-candidate/* (master addendum, 4 build prompts, `BUILD_LINUX_DESKTOP_DISTRIBUTION_v0.28.txt`, checksum) | v0.28 candidate (Linux first-class) | **CANDIDATE** (adopted as engineering guidance; D-009) | patch ZIP `9e314c1bc822…a600` | Prompts and addendum received. The ZIP with docs 216–226 (Linux contracts, fixtures, packaging scaffolds) was **not supplied**. It still depends on the unavailable v0.26 baseline. |
| docs/handoff/claude-code-init/MASTER_INIT_PROMPT_DIGEST.md | 2026-10-06 | **AUTHORITATIVE_CURRENT** (process rules, digest of the user's master prompt) | — | The user's newest instruction is to develop in FORGE cycles. |
| docs/handoff/v0.25/* | "v0.25" | **REPO_LOCAL_CANDIDATE** | — | Written by an earlier Claude session, **not** by the user. The label collides with the user's own v0.25. |
| docs/PARITY.md, docs/RELEASE_STATUS.md, docs/adr/ADR-IMPL-001 | repo-local | REPO_LOCAL_CANDIDATE / HISTORICAL | — | ADR-IMPL-001 client decision superseded by ADR-IMPL-002. |
| docs/forge/CURRENT.md | repo-local | SUPERSEDED | — | Replaced by `project_state/`. |

## Lineage

v0.24 (have) → v0.25 (user's, **missing**) → v0.26 (user's, **missing**, SHA `687335de…3369`) → v0.27 candidate patch (have the prompts and addendum, **missing** the ZIP and overlay) → v0.28 candidate patch (Linux; prompts and addendum received, ZIP `9e314c1b…a600` with docs 216–226 missing).

Repo-local work, in a separate namespace: R1 = "v0.25 connected TS implementation" (commits 368af38, 247f971).

## Missing sources (impact)

1. **v0.26 Master Handoff + Developer Handoff.** The v0.27 merge cannot be validated, and v0.25/v0.26 requirements (docs 187–206) are unknown. Mitigation: treat v0.24 as the semantic authority and v0.27 as process guidance. Request v0.26.
2. **v0.27 patch ZIP / `repository_bootstrap_overlay/`.** FORGE 001 writes the shell itself, to the v0.27 doc 209 spec. If the overlay arrives later, it is diffed in.
3. **v0.24 Developer Handoff ZIP.** Golden vectors were reconstructed from the master text (labelled).
