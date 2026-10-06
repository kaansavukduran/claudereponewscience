#!/usr/bin/env bash
# Static compatibility gate: every undefined dynamic symbol of the runner and
# the bundled Flutter engine must be defined by the shared libraries of a
# target distro root filesystem (e.g. a debootstrap or container rootfs).
# Usage: check_symbols.sh <bundle-dir> <rootfs>
set -euo pipefail
BUNDLE=$1; ROOT=$2
LIBDIRS=("$ROOT/usr/lib/x86_64-linux-gnu" "$ROOT/lib/x86_64-linux-gnu" "$ROOT/usr/lib64" "$ROOT/lib64")
defined=$(mktemp); trap 'rm -f "$defined"' EXIT
for obj in "$BUNDLE/human_health_os" "$BUNDLE/lib/libflutter_linux_gtk.so"; do
  for so in $(objdump -p "$obj" | awk '/NEEDED/{print $2}'); do
    [ -e "$BUNDLE/lib/$so" ] && continue
    found=""
    for d in "${LIBDIRS[@]}"; do [ -e "$d/$so" ] && { found="$d/$so"; break; }; done
    if [ -z "$found" ]; then echo "MISSING LIBRARY in rootfs: $so (needed by $(basename "$obj"))"; continue; fi
    nm -D --defined-only "$(readlink -f "$found")" | awk '{print $NF}' | sed 's/@.*//' >> "$defined"
  done
done
# Symbols the bundle itself provides (e.g. fl_* from the Flutter engine).
for so in "$BUNDLE"/lib/*.so; do nm -D --defined-only "$so" | awk '{print $NF}' | sed 's/@.*//' >> "$defined"; done
sort -u -o "$defined" "$defined"
bad=0
for obj in "$BUNDLE/human_health_os" "$BUNDLE/lib/libflutter_linux_gtk.so"; do
  while read -r sym; do
    grep -qxF "$sym" "$defined" || { echo "UNRESOLVED $(basename "$obj"): $sym"; bad=1; }
  # Strong references only ("U"); weak ones ("w") may legally stay unresolved.
  done < <(nm -D --undefined-only "$obj" | awk '$1=="U"{print $2}' | sed 's/@.*//' | sort -u)
done
[ $bad = 0 ] && echo "OK: all undefined symbols resolve against $(. "$ROOT/etc/os-release"; echo "$PRETTY_NAME")"
exit $bad
