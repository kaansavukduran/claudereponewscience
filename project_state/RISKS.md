# Risks

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R-01 | Missing v0.25/v0.26 handoffs hide requirements, and v0.27 cannot be merged against its baseline | High | High | Use v0.24 as the semantic authority. Request v0.26 and diff it when received. |
| R-02 | The Dart and TS engines drift | Medium | High | Shared golden vectors gate both implementations. Add numeric vectors for composites, compare and missions before porting them. |
| R-03 | No GitHub push access, so work exists only in this ephemeral container | High | High | Bundle file sent to the user. Ask the user to connect GitHub. |
| R-04 | Android, iOS, macOS and Windows cannot be built here | Certain | Medium | CI matrix on GitHub runners. Report each target independently. Never claim PASS for one host based on another. |
| R-05 | The encrypted portable vault is designed incorrectly (machine-bound only, path-as-identity) | Medium | High | Dedicated F004 with tests for passphrase unlock, path moves and a corrupt header. |
| R-06 | Browser storage eviction loses web health data | Medium | High | Show the limitation in the UI. Export is the durable path. Sync comes later. |
| R-07 | Dependency sprawl and licence issues | Medium | Medium | Recorded review per package. Lockfiles committed. SBOM before public release. |
| R-08 | Synthetic Build Lab data leaks into real profiles | Low | High | Separate app and storage. SYNTHETIC profile type labelled everywhere. |
| R-09 | The Flutter web smoke depends on the CanvasKit CDN | Medium | Low | Build with `--no-web-resources-cdn`. |
| R-10 | Clinical over-claiming (scores read as risk or lifespan) | Medium | High | Result classes, MODELLED labels, no external model without a licence and fixtures. |
| R-11 | Flutter web fails at startup when the browser reports a non-BCP-47 locale (seen: headless Chromium in a POSIX-locale container reports `en-US@posix` → `RangeError: Incorrect locale information provided`) | Low on real browsers, certain in misconfigured CI | High (blank app) | Smoke tests pin `en-US`/`tr-TR`. Linux runs set `LANG=C.UTF-8`. Track upstream. Consider a defensive bootstrap that normalises `navigator.languages` before engine start (needs a custom `flutter_bootstrap.js`; evaluate in F034). |
| R-12 | Capability and description strings are English-only while labels are EN/TR | Certain | Low | Move all UI copy to ARB (`flutter gen-l10n`) in FORGE 002/021. |
| R-13 | Development builds store health entries **unencrypted** on disk or in browser storage, and someone uses a dev build with real data | Medium | High | Production and portable builds cannot persist (tested). Every dev surface shows "not encrypted (development)" and "not for clinical decisions". F004 replaces the payload with an encrypted envelope. |
