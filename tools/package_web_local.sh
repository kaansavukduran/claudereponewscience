#!/usr/bin/env bash
# Builds the web app (development profile, no CDN) and packs it with the
# local launcher files into downloads/Human-OS-web-<revision>.zip: unzip, double-click
# Human-OS-baslat.bat (Windows) or run Human-OS-baslat.sh, nothing to install.
# The zip is produced by `flutter build web`; nothing is hand-made.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
rev=$(git -C "$root" rev-parse --short=12 HEAD)
full=$(git -C "$root" rev-parse HEAD)
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
(cd "$root/human_health_os" && flutter build web --release --no-web-resources-cdn \
  --dart-define=APP_ENV=development --dart-define=APP_VERSION=0.1.0+1 \
  --dart-define=SOURCE_REVISION="$full")
mkdir -p "$stage/Human-OS-web/app"
cp -r "$root/human_health_os/build/web/." "$stage/Human-OS-web/app/"
cp "$root"/packaging/web-local/* "$stage/Human-OS-web/"
echo "$full" > "$stage/Human-OS-web/REVISION.txt"
mkdir -p "$root/downloads"
out="$root/downloads/Human-OS-web-$rev.zip"
rm -f "$out"
(cd "$stage" && python3 -c "
import os, sys, zipfile
out = sys.argv[1]
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for d, _, fs in os.walk('Human-OS-web'):
        for f in sorted(fs):
            p = os.path.join(d, f)
            z.write(p, p)
" "$out")
sha256sum "$out" | tee "$out.sha256"
ls -la "$out"
