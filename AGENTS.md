# Human OS: Codex continuation

The owner's latest explicit request takes priority over attached planning documents.
Read `CLAUDE.md`, the cursor fields of `project_state/CURRENT_STATE.json`, the latest
entry of `project_state/FORGE_LOG.md`, and the relevant source/tests before changing
code. This is the existing Flutter product in `human_health_os/`; do not rebuild
it as a separate website or extend the frozen `apps/client` prototype.

## Owner's product requirements

- Complete each changed user flow in Turkish and English through `lib/src/l10n/strings.dart`.
  Use a supported device language on first launch, otherwise Turkish. Preserve the
  user's selection, typed text, records, settings and migration compatibility.
- Keep Settings easy to reach. Appearance/accessibility includes light, dark,
  system and high contrast, accent, independent text size, bundled Turkish-capable
  reading/dyslexia fonts, motion, density and layout choices. Whole-interface scale
  is independent: 80–200%, five-point slider, exact input, six presets and its own
  reset. Never silently reduce a selected scale; reflow or allow scrolling.
- Keyboard focus, screen-reader labels, touch targets, narrow layouts and 200%
  scale are acceptance requirements. Check real rendered Turkish text.
- Gamification is optional and calm. Reward no clinical value or risky behavior.
  Count only explicit completed actions, deduplicate, retain access to records
  when disabled, and never infer completion from a plan, retry or elapsed time.
- The product targets Windows, Linux, macOS, Android, iPhone and web through its
  existing shared core. Report each build, install, signing and runtime separately.
  Never call an unsigned or untested candidate a stable release.
- Keep all previous GitHub releases, tags and downloads. New ready versions get
  separate versioned releases; do not overwrite old releases. Signed distribution,
  Android signing continuity, Apple signing/notarization/store access and a real
  two-package in-app update drill must be verified before claiming them complete.
- After a successful code push, back up that exact commit's sources as ZIP and
  all accessible Git refs/history as a bundle to the private Drive project folder
  under `1cZxRqTob2e53E6ilMkND782KhIwXnMVJ`. Exclude credentials/signing keys and
  check archives and uploaded metadata. If access is blocked, report pending.
- Answer the owner in the language of their latest message. Explain what changed,
  where to open it, executed checks and remaining blockers briefly. No prose em dashes.

## Forge and verification

One bounded Forge at a time, preserve the repository's evidence receipts and
uncompleted work. Commit source before formal `tools/evidence/run_gate.py` runs.
Update the state, Forge log and gaps with actual evidence and one next Forge.
Use `flutter analyze`, `flutter test`, a real web build and browser smoke for UI
changes; CI is responsible for other hosts. Use existing `pubspec.lock`; a new
dependency needs a recorded license/platform/privacy review. Health semantics,
append-only corrections, encrypted-vault policy and the offline core remain as
specified in `CLAUDE.md`. Never publish a secret, real health record or private
Drive source into the repository.
