# Design brief: Human OS (AIONIA v1.2 §14.1)

**Product:** Human OS, a personal, offline-first health record. A person types what they measured, took, ate, felt or were told, keeps it private on their own device, and finds it again with its history.

**Target users**
- One adult keeping their own record, in Turkish or English, often on a phone and also on a computer.
- People with low vision (text up to 200%, high contrast), dyslexia (dedicated font), or limited dexterity (large targets, mouse-only and keyboard-only paths).
- First-time and occasional users (plain words, forgiving defaults, every entry correctable).
- Not clinicians and not a care team: no diagnosis, no advice, no scores.

**Main tasks**
1. Record a value or an event in under a minute (weight, measurement, sleep, how you feel, food, activity, medicine dose).
2. Find it again with its history and corrections (Timeline, each area's list).
3. Keep the data safe: backup, restore, encrypted vault.
4. Look at things a person keeps over time: lab results as printed, conditions, preventive items, documents.

**Target devices:** small phone (≥ 320 dp wide), large phone, tablet (portrait and landscape), desktop window (≥ 1024 wide with a side rail), web browser. Touch, mouse, keyboard and screen reader.

**Tone:** calm, clinical, warm, precise. Health data is personal; the app is quiet and trustworthy, never cheerful at the person's expense.

**Three design adjectives:** calm · honest · precise.

**Three anti-patterns to avoid**
1. Judging colours or badges on health values (a number is never green, amber or red).
2. Repeated icon-title-text card grids and decoration without meaning (gradients, emoji, sparkles).
3. App machinery before the person's data (schema words, build facts, provenance codes leading a screen).

**Brand and universe:** Human OS is an independent application of the owner. Fragaria Interactive and the AIONIA universe are not shown as brands in the product. Aion (the owner's character, from the approved reference) is a quiet companion on empty states and the introduction only, and can be turned off.

**Visual language (tokens in `human_health_os/lib/src/presentation/theme/human_os_theme.dart`):** one muted teal accent, near-white surfaces, hairline borders instead of shadows, radius 12, an 8 dp rhythm, four type sizes, Material icons in one outlined family, motion only as feedback and off when the system or the person asks for reduced motion. Light and dark themes; high-contrast mode.

**Example screens:** Today (weight, measurements, sleep, how you feel, tools), Timeline, Labs, Medications, and the "More areas" group (Nutrition, Activity, Conditions, Preventive, Documents), Settings last.

**Navigation by task, not by code module:** primary bar = Today, Timeline, Labs, Medications; the rest under "More areas"; Settings always last with a visible label.
