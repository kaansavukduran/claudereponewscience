# Design method: calm clinical, no slop

Human OS shows a person's own health data. The interface has one job: let a person put a number in and find it again, without noise. This file is the method every screen is built and reviewed with. It was written from scratch for this project; it borrows the idea of an "anti-slop" checklist (name the generic patterns, then avoid them on purpose), not any code or text.

## What "slop" means here
Interfaces that look generated: the same card repeated with an icon, a title and a line of text; a screen that explains itself more than it helps; decoration that carries no meaning (gradients, emoji, chips on everything); technical facts about the app in front of facts about the person; every control visible at once.

## Principles
1. **One job per screen or sheet.** Today shows the person's numbers. Adding a number is its own sheet. Backups and build facts are further down and quiet.
2. **Data first, machinery last.** Values, then actions, then settings, then "about this build". Words such as schema, provenance, or record kind never lead a screen.
3. **One accent, calm neutrals.** A muted teal for actions and focus; near-white surfaces; hairline borders instead of shadows. Colour never judges a value: a number is never green, amber or red. Red is for errors in the entry only.
4. **Four type sizes.** Page title, section title, value (large, tabular figures), body/caption. Numbers are the largest thing on a tile.
5. **An 8 dp rhythm, one container level.** No card inside a card. Sections are separated by space and a title, tiles by hairlines.
6. **Progressive disclosure.** The common path is the value and Save. "When" and the note sit under "More details", closed by default.
7. **Plain words, short sentences.** The same words in every place for the same thing. No fluff ("Welcome", "Let's get started"), no repeated disclaimers: the no-judgement promise is said once per area, not once per control.
8. **Forgiving defaults.** Empty means "now"; every entry can be corrected or withdrawn; an error says what to change in the entry, never what is wrong with the person.
9. **Accessible by construction.** 48 dp targets, text up to 2x without clipping, 320 dp wide, a spoken summary for every value, errors announced, meaning never by colour alone.
10. **Honest states.** Missing is shown as missing ("Not recorded yet"), never 0 and never a blank that looks like a value.

## Slop audit (run on every screen change)
Score each item pass or fail; any fail is fixed or recorded with a reason.
- [ ] Is the first thing on screen about the person, not the app?
- [ ] At most one container level; no repeated icon-title-text card grid?
- [ ] At most one accent colour; no colour that judges a value?
- [ ] No emoji or decoration without meaning; no gradient?
- [ ] Is every visible sentence needed, and said once?
- [ ] Is the common path one tap, one field, one button?
- [ ] Are advanced fields closed by default?
- [ ] Do numbers use tabular figures and the largest size on the tile?
- [ ] 320 dp at 2x text, TR and EN, no clipping or overflow?
- [ ] Empty, error and saved states all written?
- [ ] Spoken label for each value and each error?
- [ ] Before/after screenshots at phone and desktop width kept as evidence?

## Tokens (see `lib/src/presentation/theme/human_os_theme.dart`)
Accent teal `#1F6F78` (dark mode `#7FC4CB`); surface `#F6F8F8` / card `#FFFFFF` / hairline `#DDE4E4`; text `#1B2B2E`. Radius 12 dp. Spacing 4 / 8 / 12 / 16 / 24 / 32. The development-build strip is a quiet neutral band with a small label, not a coloured alert.

## Brainstorm and backlog
Ideas that fit the invariants (planned is not completed; missing is not zero; no diagnosis) are collected in `docs/BRAINSTORM.md`.
