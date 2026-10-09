#!/usr/bin/env bash
# F007 old-code check (AC-10). This revision's code writes the F007 inputs
# (human_health_os/tool/make_f007_compat_inputs.dart); then the code of an
# OLDER revision reads them in a scratch git worktree, through
# tools/compat/f007_old_code_check_test.dart.
#   tools/compat/old_code_check.sh <older-revision>      (F007: 48c3c94)
# Nothing in this checkout changes: the inputs and the worktree live in a
# temporary folder that is removed at the end.
set -euo pipefail
old=${1:?usage: tools/compat/old_code_check.sh <older-revision>}
root=$(git rev-parse --show-toplevel)
old_rev=$(git -C "$root" rev-parse "$old^{commit}")
new_rev=$(git -C "$root" rev-parse HEAD)
work=$(mktemp -d "${TMPDIR:-/tmp}/hhos-oldcode-XXXXXX")
cleanup() {
  git -C "$root" worktree remove --force "$work/old" >/dev/null 2>&1 || true
  rm -rf "$work"
}
trap cleanup EXIT

echo "inputs written by $new_rev"
(cd "$root/human_health_os" && dart run tool/make_f007_compat_inputs.dart "$work/inputs")
git -C "$root" worktree add --detach "$work/old" "$old_rev" >/dev/null 2>&1
echo "old code checked out at $(git -C "$work/old" rev-parse HEAD)"
cp "$root/tools/compat/f007_old_code_check_test.dart" \
  "$work/old/human_health_os/test/zz_f007_old_code_check_test.dart"
cd "$work/old/human_health_os"
flutter pub get --offline >/dev/null
F007_COMPAT_DIR="$work/inputs" flutter test test/zz_f007_old_code_check_test.dart
echo "OLD-CODE CHECK PASS: code at $old_rev refuses the F007 data unchanged and opens what F007 wrote at schema 3 and its checkpoints (inputs from $new_rev)"
