# Source authority inventory (Phase 0, 2026-10-06; reconciled for v0.31 the same day)

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
| docs/handoff/v0.31/HUMAN_OS_CLAUDE_CODE_MASTER_FORGE_v0.31_CLAUDE_CODE_WEB_ONE_SHOT.md | v0.31 single-file cumulative candidate (v0.27 + v0.28 + v0.29 release trust + v0.30 Triple Forge + v0.31 one-shot contract) | **CANDIDATE — master process/plan authority** (rank 3 in its §0.2: below verified repository code and a hash-verified CURRENT handoff) | 7f999e0f1d09 | Received 2026-10-06. Embeds docs 207–226, JSON contracts and the v0.28 PATCH_MANIFEST (which lists the `repository_bootstrap_overlay/` files by hash, but **not their contents**). Supersedes the master-init digest where they differ; v0.24 stays the product-semantics authority. |
| docs/handoff/claude-code-init/MASTER_INIT_PROMPT_DIGEST.md | 2026-10-06 | PROCESS (digest of the user's earlier master prompt; v0.31 extends and wins on conflict) | — | The user's newest instruction is to develop in FORGE cycles. |
| docs/handoff/v0.25/* | "v0.25" | **REPO_LOCAL_CANDIDATE** | — | Written by an earlier Claude session, **not** by the user. The label collides with the user's own v0.25. |
| docs/PARITY.md, docs/RELEASE_STATUS.md, docs/adr/ADR-IMPL-001 | repo-local | REPO_LOCAL_CANDIDATE / HISTORICAL | — | ADR-IMPL-001 client decision superseded by ADR-IMPL-002. |
| docs/forge/CURRENT.md | repo-local | SUPERSEDED | — | Replaced by `project_state/`. |

## Lineage

v0.24 (have) → v0.25 (user's, **missing**) → v0.26 (user's, **missing**, SHA `687335de…3369`) → v0.27 candidate patch (prompts and addendum received; ZIP and overlay contents **missing**) → v0.28 candidate patch (Linux; prompts received; docs 216–226 now available as v0.31 appendices) → v0.29 release trust → v0.30 Triple Forge → **v0.31 single-file one-shot candidate (have, SHA `7f999e0f…864c`)**.

Release state: **CANDIDATE_UNMERGED**. The exact v0.26 baseline bytes are not in this runtime, so nothing is promoted to CURRENT (v0.31 §0.1).

Repo-local work, in a separate namespace: R1 = "v0.25 connected TS implementation" (commits 368af38, 247f971).

## Missing sources (impact)

1. **v0.26 Master Handoff + Developer Handoff.** The v0.27 merge cannot be validated, and v0.25/v0.26 requirements (docs 187–206) are unknown. Mitigation: treat v0.24 as the semantic authority and v0.27 as process guidance. Request v0.26.
2. **v0.27 patch ZIP / `repository_bootstrap_overlay/` file contents.** v0.31 lists the overlay files and their hashes but not their bytes. FORGE 001 wrote the shell itself to doc 209. If the overlay arrives later, it is diffed in by hash.
3. **v0.24 Developer Handoff ZIP.** Golden vectors were reconstructed from the master text (labelled).

## Conflicts between v0.31 and repository reality (recorded, not silently resolved)

| # | v0.31 says | Repository has | Resolution |
|---|---|---|---|
| C-1 | Ladder ids F001–F017 (§39) | Legacy roadmap F001–F041 with different meanings (e.g. legacy F003 = engines, F004 = vault) | v0.31 ladder ids are canonical from now on; legacy ids are mapped in `docs/ROADMAP.md` (D-011). |
| C-2 | F001 = shell only, "no domain persistence yet" | Persistence heartbeat already implemented pre-v0.31 (legacy FORGE 002) | Repository reality is kept (v0.31 §31.3, §44). F001 is re-verified against v0.31 gates without touching persistence; v0.31 F002 exit gates are reviewed in F002. |
| C-3 | Flatpak/AppStream id `com.humanos.HumanHealthOS` (appendix 219, LINUX_PACKAGING_CONTRACT.json) | Provisional `org.humanhealthos.HumanHealthOS` (F030L-1) | Adopt the spec id when F015-L1 resumes (D-012). |
| C-4 | XDG subdirectory `human-health-os/` (appendix 221) | Development vault in `$XDG_DATA_HOME/HumanHealthOS/` | Adopt in F002 (persistence scope), with a move of dev data or a documented reset (dev builds only). |
| C-5 | Portable tarball layout `HumanHealthOS/` with `licenses/`, `RELEASE_STATE.json`, `CHECKSUMS.sha256`; AppImage `HumanHealthOS-x86_64.AppImage` (appendix 218/225) | `HumanHealthOS-Linux-x86_64-Portable/` without those files; versioned AppImage name | Adopt when F015-L1 resumes. |
| C-6 | Repository tool folder `tool/` (§6) | `tools/` at the repository root (shared with the TS workspace) | Keep `tools/`; recorded as an intentional deviation. |
| C-7 | Evidence under `evidence/` with JSON receipts (§33) | Evidence under `reports/` (prose + JSON) | New gates write receipts to `evidence/`; `reports/` stays as historical evidence (D-011). |
