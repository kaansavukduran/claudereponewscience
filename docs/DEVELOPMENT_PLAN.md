# Development plan

## Toolchain bootstrap (cloud container or a fresh Linux machine)

```bash
# Flutter stable (pinned 3.47.6 / Dart 3.13.5), verified against the release manifest SHA-256
curl -sSLo flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.6-stable.tar.xz
echo "f1631b9c2c8b3529323db412b0d1beacf4a748f8783b0d7cf599a8fd5f461675  flutter.tar.xz" | sha256sum -c -
mkdir -p /opt/toolchains && tar xf flutter.tar.xz -C /opt/toolchains
git config --global --add safe.directory /opt/toolchains/flutter
export PATH=/opt/toolchains/flutter/bin:$PATH
flutter config --no-analytics && flutter precache --web
export CHROME_EXECUTABLE=/opt/pw-browsers/chromium-1194/chrome-linux/chrome   # Playwright Chromium
```

Cloud sessions start from a fresh container, so this has to be repeated each time. A SessionStart hook can automate it. That is recommended, but not configured yet.

## Working agreement per FORGE

1. **Orient.** Read `project_state/CURRENT_STATE.json`, the latest entry in `FORGE_LOG.md`, `git status`, and the docs relevant to the gap.
2. **Specify.** Write the goal, behaviour, data/migration effects, security effects, failure modes, tests and acceptance criteria into the FORGE log entry before coding.
3. **Implement.** Keep changes small and vertical. Domain code stays pure Dart. Add no package without a decision record.
4. **Test.** Run `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`, then builds and smoke where available. For the TS side, run `pnpm typecheck`, `pnpm test` and `python3 tools/verify_contracts.py` if contracts were touched.
5. **First failure.** Fix the root cause, re-run, then run regression.
6. **Audit.** Check invariants, fake completion, dead UI, offline behaviour, error states, platform divergence and secrets.
7. **Package.** Produce only real artifacts. Record their hashes in `reports/`.
8. **State.** Update `CURRENT_STATE.json`, `FORGE_LOG.md`, `RISKS.md` and `KNOWN_GAPS.md`. Commit on the designated branch and push. If the push is blocked, say so.

## Definition of done for one FORGE

Every acceptance criterion carries an executed command and a PASS. Any criterion that could not run is marked BLOCKED or NOT_RUN with the exact reason. No acceptance criterion is silently dropped.
