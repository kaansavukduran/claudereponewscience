#!/usr/bin/env bash
# F007 runtime smoke: start the real Linux binary (development profile) on a
# vault that holds record schema 4 (measurements), scroll Today to the
# Measurements card with the mouse wheel (xdotool, inside xvfb-run) and take
# screenshots. Opening must not write: the vault keeps its sha256 and stays
# the only file in the data folder, and the app reports no error event. The
# values on screen are read from the screenshots.
# Usage: measurements_smoke.sh <label> <out-dir> <home> -- <command...>
set -u
LABEL=$1; OUT=$2; HOMEDIR=$3; shift 4
mkdir -p "$OUT"
LOG="$OUT/$LABEL.log"
DATA="$HOMEDIR/.local/share/human-health-os"
VAULT="$DATA/vault.hhoslog.jsonl"
if [ ! -f "$VAULT" ]; then echo "# result: FAIL no vault at <home>/.local/share/human-health-os"; exit 1; fi
before=$(sha256sum "$VAULT" | cut -d' ' -f1)
# A returning person: the short introduction (U014) was already seen. The
# file holds display preferences only and must stay unchanged too.
PREFS="$DATA/appearance.json"
printf '{"format":"hhos.appearance","version":1,"firstRunDone":true}' > "$PREFS"
prefs_before=$(sha256sum "$PREFS" | cut -d' ' -f1)
{
  echo "# $LABEL $(date -u +%FT%TZ)"
  echo "# host: $(. /etc/os-release; echo "$PRETTY_NAME"), $(uname -m)"
  echo "# display: DISPLAY=${DISPLAY:-}"
  echo "# command: $*"
  echo "# vault sha256 before: $before"
  echo "# vault record schemas: $(grep -o '"schema_version":[0-9]*' "$VAULT" | sort | uniq -c | tr '\n' ' ')"
} > "$LOG"
"$@" >> "$LOG" 2>&1 &
PID=$!
RC=0
sleep 10
shot() { import -window root "$OUT/$LABEL-$1.png" 2>>"$LOG" && echo "# screenshot: $LABEL-$1.png" >> "$LOG"; }
shot today
# Wheel over the list (right of the navigation rail) until the card is up.
xdotool mousemove 900 450
for _ in $(seq 1 8); do xdotool click 5; sleep 0.2; done
sleep 2
shot measurements
for _ in $(seq 1 6); do xdotool click 5; sleep 0.2; done
sleep 2
shot history
if kill -0 "$PID" 2>/dev/null; then echo "# liveness: alive" >> "$LOG"; else echo "# liveness: exited early" >> "$LOG"; RC=1; fi
kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null
after=$(sha256sum "$VAULT" | cut -d' ' -f1)
echo "# vault sha256 after: $after" >> "$LOG"
if [ "$before" = "$after" ]; then echo "# vault file: unchanged" >> "$LOG"
else echo "# vault file: CHANGED" >> "$LOG"; RC=1; fi
files=$(find "$DATA" -type f | sort)
echo "# files: $(echo "$files" | sed "s|^$HOMEDIR|<home>|" | tr '\n' ' ')" >> "$LOG"
expected=$(printf '%s\n%s' "$PREFS" "$VAULT" | sort)
if [ "$files" = "$expected" ]; then echo "# data folder: only the vault and the display preferences" >> "$LOG"
else echo "# data folder: EXTRA FILES" >> "$LOG"; RC=1; fi
if [ "$(sha256sum "$PREFS" | cut -d' ' -f1)" = "$prefs_before" ]; then echo "# preferences: unchanged" >> "$LOG"
else echo "# preferences: CHANGED" >> "$LOG"; RC=1; fi
if grep -q 'RECORD_SCHEMA_NEWER\|vaultUnreadable\|error=' "$LOG"; then
  echo "# error events: YES" >> "$LOG"; RC=1
else echo "# error events: none" >> "$LOG"; fi
echo "# result: $([ $RC = 0 ] && echo PASS || echo FAIL)" >> "$LOG"
cat "$LOG"
exit $RC
