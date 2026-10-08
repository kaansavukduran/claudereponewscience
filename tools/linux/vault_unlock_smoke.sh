#!/usr/bin/env bash
# F006 runtime smoke: drive the real Linux release binary through the vault
# gate with the keyboard (xdotool, inside xvfb-run). A wrong passphrase must
# be refused; the right one, typed without clicking the field again, must
# open the vault; the vault file must not change, must still be an encrypted
# envelope and must be the only file in the data folder; neither passphrase
# may appear in the output. The app reports these steps as redacted events
# on stdout ("[hhos] vault_…", master §37).
# Usage: vault_unlock_smoke.sh <label> <out-dir> <home> <passphrase> -- <command...>
set -u
LABEL=$1; OUT=$2; HOMEDIR=$3; PASS=$4; shift 5
WRONG='not the passphrase'
mkdir -p "$OUT"
LOG="$OUT/$LABEL.log"
DATA="$HOMEDIR/.local/share/human-health-os"
VAULT="$DATA/vault.hhosvault"
if [ ! -f "$VAULT" ]; then echo "# result: FAIL no vault at <home>/.local/share/human-health-os"; exit 1; fi
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
xdotool type --delay 40 "$WRONG"; xdotool key Return
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
# Still an encrypted envelope (line 1 is its header), never plaintext.
if head -n 1 "$VAULT" | grep -q '^{"format":"hhos-vault-enc","envelope_version":1,'; then
  echo "# vault header: hhos-vault-enc v1" >> "$LOG"
else echo "# vault header: MISSING" >> "$LOG"; RC=1; fi
files=$(find "$DATA" -type f | sort)
echo "# files: $(echo "$files" | sed "s|^$HOMEDIR|<home>|" | tr '\n' ' ')" >> "$LOG"
if [ "$files" = "$VAULT" ]; then echo "# data folder: only the vault" >> "$LOG"
else echo "# data folder: EXTRA FILES" >> "$LOG"; RC=1; fi
# Fixed strings (-F): a passphrase is text, not a pattern.
for p in "$PASS" "$WRONG"; do
  if grep -q -F -- "$p" "$LOG"; then echo "# passphrase in output: YES" >> "$LOG"; RC=1
  else echo "# passphrase in output: no" >> "$LOG"; fi
done
echo "# result: $([ $RC = 0 ] && echo PASS || echo FAIL)" >> "$LOG"
cat "$LOG"
exit $RC
