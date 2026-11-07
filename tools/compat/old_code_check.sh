#!/usr/bin/env bash
# F007 old-code check (AC-10). This revision's code writes the F007 inputs
# (human_health_os/tool/make_f007_compat_inputs.dart); then the code of an
# OLDER revision reads them in a scratch git worktree, through
# tools/compat/f007_old_code_check_test.dart.
#   tools/compat/old_code_check.sh <older-revision> [f007|f007s2]
#     f007 (default): slice 1 data read by the F006 code (48c3c94)
#     f007s2: slice 2 data read by the slice 1 code (main, 0617601)
# Nothing in this checkout changes: the inputs and the worktree live in a
# temporary folder that is removed at the end.
set -euo pipefail
old=${1:?usage: tools/compat/old_code_check.sh <older-revision> [f007|f007s2]}
mode=${2:-f007}
case "$mode" in
  f007) gen=make_f007_compat_inputs.dart; check=f007_old_code_check_test.dart ;;
  f007s2) gen=make_f007s2_compat_inputs.dart; check=f007s2_old_code_check_test.dart ;;
  *) echo "unknown mode $mode" >&2; exit 2 ;;
esac
root=$(git rev-parse --show-toplevel)
old_rev=$(git -C "$root" rev-parse "$old^{commit}")
new_rev=$(git -C "$root" rev-parse HEAD)
work=$(mktemp -d "${TMPDIR:-/tmp}/hhos-oldcode-XXXXXX")
cleanup() {
  git -C "$root" worktree remove --force "$work/old" >/dev/null 2>&1 || true
  rm -rf "$work"
}
trap cleanup EXIT

# Same rule as tools/evidence/run_gate.py: evidence outputs do not make the source dirty.
if [ -n "$(git -C "$root" status --porcelain --untracked-files=no -- . ':!reports' ':!evidence')" ]; then
  echo "the working tree has uncommitted changes: the inputs would not be those of $new_rev" >&2
  exit 1
fi
echo "inputs written by $new_rev"
(cd "$root/human_health_os" && dart run "tool/$gen" "$work/inputs")
git -C "$root" worktree add --detach "$work/old" "$old_rev" >/dev/null 2>&1
echo "old code checked out at $(git -C "$work/old" rev-parse HEAD)"
cp "$root/tools/compat/$check" \
  "$work/old/human_health_os/test/zz_old_code_check_test.dart"
cd "$work/old/human_health_os"
flutter pub get --offline >/dev/null
F007_COMPAT_DIR="$work/inputs" flutter test test/zz_old_code_check_test.dart
echo "OLD-CODE CHECK PASS ($mode): code at $old_rev refuses the newer data unchanged and opens what the newer build wrote at the older schema, and its checkpoints (inputs from $new_rev)"
