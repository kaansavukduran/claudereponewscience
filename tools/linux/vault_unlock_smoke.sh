#!/usr/bin/env bash
# F006 runtime smoke: drive the real Linux release binary through the vault
# gate with the keyboard (xdotool, inside xvfb-run). A wrong passphrase must
# be refused; the right one, typed without clicking the field again, must
# open the vault; the vault file must not change. The app reports these
# steps as redacted events on stdout ("[hhos] vault_…", master §37).
# Usage: vault_unlock_smoke.sh <label> <out-dir> <home> <passphrase> -- <command...>
set -u
LABEL=$1; OUT=$2; HOMEDIR=$3; PASS=$4; shift 5
mkdir -p "$OUT"
LOG="$OUT/$LABEL.log"
VAULT="$HOMEDIR/.local/share/human-health-os/vault.hhosvault"
before=$(sha256sum "$VAULT" | cut -d' ' -f1)
{
  echo "# $LABEL $(date -u +%FT%TZ)"
  echo "# host: $(. /etc/os-release; echo "$PRETTY_NAME"), $(uname -m)"
  echo "# display: DISPLAY=${DISPLAY:-}"
  echo "# command: $*"
  echo "# vault sha256 before: $before"
} > "$LOG"
"$@" >> "$LOG" 2>&1 &
PID=$!
RC=0
sleep 8
shot() { import -window root "$OUT/$LABEL-$1.png" 2>>"$LOG" && echo "# screenshot: $LABEL-$1.png" >> "$LOG"; }
shot locked
# The passphrase field is the first field of the gate: focus it once.
xdotool mousemove 640 156 click 1; sleep 1
xdotool type --delay 40 'not the passphrase'; xdotool key Return
sleep 6
shot wrong
grep -q '\[hhos\] vault_unlock_failed error=CryptoFailure(NOT_AUTHENTIC)' "$LOG" \
  && echo "# step: wrong passphrase refused" >> "$LOG" \
  || { echo "# step: FAIL no refusal event" >> "$LOG"; RC=1; }
# No click: the field must have its focus back after the wrong try.
xdotool type --delay 40 "$PASS"; xdotool key Return
sleep 8
shot unlocked
grep -q '\[hhos\] vault_unlocked' "$LOG" \
  && echo "# step: right passphrase opened the vault" >> "$LOG" \
  || { echo "# step: FAIL no unlock event" >> "$LOG"; RC=1; }
if kill -0 "$PID" 2>/dev/null; then echo "# liveness: alive" >> "$LOG"; else echo "# liveness: exited early" >> "$LOG"; RC=1; fi
kill "$PID" 2>/dev/null; wait "$PID" 2>/dev/null
after=$(sha256sum "$VAULT" | cut -d' ' -f1)
echo "# vault sha256 after: $after" >> "$LOG"
if [ "$before" = "$after" ]; then echo "# vault file: unchanged" >> "$LOG"
else echo "# vault file: CHANGED" >> "$LOG"; RC=1; fi
echo "# files: $(find "$HOMEDIR/.local/share/human-health-os" -type f | sed "s|^$HOMEDIR|<home>|" | tr '\n' ' ')" >> "$LOG"
if grep -q -- "$PASS" "$LOG"; then echo "# passphrase in output: YES" >> "$LOG"; RC=1
else echo "# passphrase in output: no" >> "$LOG"; fi
echo "# result: $([ $RC = 0 ] && echo PASS || echo FAIL)" >> "$LOG"
cat "$LOG"
exit $RC
