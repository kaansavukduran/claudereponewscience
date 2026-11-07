# Brainstorm: what Human OS could become

Ideas only: nothing here is planned, built or promised (planned is not completed). Each one is checked against the invariants (CLAUDE.md): missing is not zero, no diagnosis or judgement of a value, source text is kept, corrections create new records, the core needs no network and no LLM. Effort: S (a Forge slice), M (a few slices), L (a long arc). Written 2026-11-07; the ranking is a proposal for the owner to change.

## A. Make daily use effortless (highest value for a first-time user)
1. **Quick add from Today (S).** One "Add" button that opens a sheet with the person's most used kinds first (by what they actually saved, not a guess). Fits: Today stays a place for the person's numbers.
2. **Time presets in the entry (S).** Chips "Now", "This morning", "Yesterday evening" next to the When field, still resolved by the typed-time rules. Fits: removes typing the clock format.
3. **A reading is one tap to repeat (S).** "Same as last time" prefill for stable values such as height, with the new time. Never prefilled silently.
4. **Reminders as reminders only (M).** A reminder to measure is not a measurement and never marks anything done (reminder is not completion). Needs platform notification adapters (F013 territory).
5. **Photo of a device screen to the form (M).** On-device recognition fills the fields as a draft the person confirms; the original image is kept as the source. Fits only if the draft is clearly unconfirmed until accepted.

## B. See your own data without being told what it means
6. **Plain timeline views (S/M).** A line per measurement over time with the actual points and gaps shown (gaps are gaps, never interpolated), a date range, and the typed value on tap. No target bands, no colours that judge.
7. **Your own comparison (M).** "Compare two dates" and "this month vs last month" showing both numbers side by side and the difference as arithmetic, labelled as arithmetic. Fits F011 (derived results carry a rule id, inputs and limitations).
8. **Your reference lines (S).** The person can draw a line they chose ("my goal weight") on a chart; it is theirs and is labelled so. A reference interval is not an optimal target, so no built-in lines.
9. **Notes that travel with a value (S, partly built).** Context text exists; a tag shortcut ("fasting", "after walk") from the person's own previous notes, never a fixed clinical vocabulary.

## C. Bring data in without losing its source
10. **Import a lab report as a draft (M/L).** A document is attached, text is extracted for review, nothing mutates a record until accepted (F010 contract). Each value keeps its printed unit, range and flag.
11. **Health Connect / HealthKit adapters (L, blocked here).** Device samples as their own provenance, duplicates handled, never summed blindly (F013).
12. **Export for the doctor (S/M).** A printable summary (PDF) of what was recorded and when, with every value as typed and its source, and an explicit "not a diagnosis" line; no scores. Fits F005 export.

## D. Trust, privacy, safety
13. **A calm first run (S).** Choose a passphrase, see the recovery key once, add one number. Replaces the current gate wording with fewer words and one decision per screen.
14. **App lock and idle lock (M).** Lock after a period (G-36). Fits the encrypted vault.
15. **Passphrase change and key rotation (M).** G-33; restores trust after a shared device.
16. **Emergency note (S).** A person-written text shown on the lock screen if they choose (allergies they typed, a contact). Their words, not the app's advice.
17. **Honest data-loss guardrails (S).** A visible "last backup" age and a one-tap backup; never a nag.

## E. Reach
18. **Windows and macOS installers (L).** Packaging and signing need those hosts (F015). Until then the web build runs locally.
19. **Turkish-first polish (S each).** Plain Turkish for every state, date and decimal comma display (G-43), screen-reader review in both languages.
20. **Family profiles (M).** Separate profiles with separate vaults' identity rules (profile id, not path); a caregiver view that is explicit, never implicit.

## What to avoid
Scores that tell a person they are "good" or "bad"; streak pressure; AI chat that answers medical questions from a person's values; colour-coded values; notifications that imply a diagnosis; anything that needs the network to show the person their own data.

## Suggested order
A1–A3, B6, D13 (daily comfort and first impression), then D14, B7 with F011, C12, C10; platform adapters when hosts exist.
