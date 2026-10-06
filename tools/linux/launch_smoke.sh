#!/usr/bin/env bash
# Launch one Human OS build under the current display (run inside xvfb-run or
# a Wayland compositor), check it is still alive after 12 s, take a screenshot
# when an X display exists, stop it, and report what it wrote.
# Usage: launch_smoke.sh <label> <out-dir> <watch-dir> -- <command...>
set -u
LABEL=$1; OUT=$2; WATCH=$3; shift 4
mkdir -p "$OUT"
LOG="$OUT/$LABEL.log"
# Graphics driver caches (Mesa shader cache) are not app data; count them apart.
list_files() { find "$WATCH" -type f -not -path '*/.cache/mesa_shader_cache/*' 2>/dev/null | sort; }
before=$(list_files | md5sum)
{
  echo "# $LABEL $(date -u +%FT%TZ)"
  echo "# host: $(. /etc/os-release; echo "$PRETTY_NAME"), $(uname -m), glibc $(ldd --version | head -1 | awk '{print $NF}')"
  echo "# display: DISPLAY=${DISPLAY:-} WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-} GDK_BACKEND=${GDK_BACKEND:-}"
  echo "# command: $*"
} > "$LOG"
"$@" >> "$LOG" 2>&1 &
PID=$!
sleep 12
if kill -0 "$PID" 2>/dev/null; then
  echo "# liveness: alive after 12 s" >> "$LOG"; RC=0
else
  wait "$PID"; echo "# liveness: exited early with status $?" >> "$LOG"; RC=1
fi
if [ -n "${DISPLAY:-}" ] && command -v import >/dev/null; then
  import -window root "$OUT/$LABEL.png" 2>>"$LOG" && echo "# screenshot: $LABEL.png" >> "$LOG"
elif [ -n "${DISPLAY:-}" ] && command -v xwd >/dev/null; then
  xwd -root -silent > "$OUT/$LABEL.xwd" 2>>"$LOG" && echo "# screenshot: $LABEL.xwd (convert to PNG outside)" >> "$LOG"
fi
kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null
after=$(list_files | md5sum)
if [ "$before" = "$after" ]; then echo "# app files under watched dir: unchanged" >> "$LOG"
else echo "# app files under watched dir: CHANGED" >> "$LOG"; list_files | sed "s|^$WATCH|<watch>|" >> "$LOG"; fi
echo "# mesa shader cache files (driver, not app data): $(find "$WATCH" -path '*/.cache/mesa_shader_cache/*' -type f 2>/dev/null | wc -l)" >> "$LOG"
echo "# result: $([ $RC = 0 ] && echo PASS || echo FAIL)" >> "$LOG"
exit $RC
