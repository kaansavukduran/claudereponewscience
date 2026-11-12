# AIONIA standard: how it applies to Human OS

**Normative source:** "AIONIA — Evrensel Dijital Ürün, Tasarım ve Kalite Standartları", version **1.2**, 12 November 2026 (owner's Google Doc `16jj2cwbm8SiVWqDy3N3dzqxTlLoK7JR2_aH6hl4noWY`). Drive is the normative document; this file records how this repository applies it. Read on 2026-11-12; no earlier repo copy existed, so there is no version mismatch to report.

## Product type and scope

Human OS is a **health application** (Flutter: Android, iOS, web, Windows, macOS, Linux), not a game. Under §11 (v1.1) and §14.12 (v1.2) the following apply:

| Standard part | Applies | Note |
|---|---|---|
| §11 universal product rules (usability for everyone, accessibility, honest states, technical quality, privacy) | **Yes** | Already the method in `docs/DESIGN.md` and the invariants in `CLAUDE.md`. |
| §14 v1.2 UI/UX, information architecture, visual consistency, platform adaptation, accessibility, interaction states, anti-AI-slop, tokens, measurable quality, design regression, quality gates | **Yes** | Implemented through `docs/DESIGN_BRIEF.md`, the theme tokens and the U030 Forge. |
| §1–§4 universe, canon, pixel art, sprite sheets | **No** (§11: no forced mascot, pixel art or lore in health apps) | Aion, the owner's own character, appears only where the owner asked (D-029), from the approved Drive reference, and can be hidden in Settings. |
| §5–§6, §12, §13 game play, Godot, game regression, mandatory gamepad | **No** (games only) | Keyboard and mouse use stay required by the owner's own rules. |

## What "done" means here (§7, §14.10, §14.11)

Every check is reported as **PASS / FAIL / NOT TESTED** with its evidence and version. "Works" is said only for something run and observed. Real-device checks that this container cannot run (phones, tablets, Windows, macOS) are NOT TESTED, never assumed. Old complaints become permanent regression tests (`project_state/KNOWN_GAPS.md`, `human_health_os/test/`).

## Change record

- 2026-11-12: first record, standard v1.2 (U030).
