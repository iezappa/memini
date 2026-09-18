#!/usr/bin/env bash
# Fails when a test tree contains a focused test.
#
#     tool/no_focused_tests.sh test integration_test
#
# `solo:` and `.only(` run one test and skip the rest of the file. That is a
# fine thing to do while chasing a failure locally and a silent hole in CI,
# which would go on reporting green over a suite that barely ran. Directories
# that do not exist are ignored, so callers can name optional trees.

set -euo pipefail

roots=()
for root in "$@"; do
  [[ -d $root ]] && roots+=("$root")
done
((${#roots[@]})) || exit 0

# `solo:` only counts as a named argument, never as part of a longer word.
found=$(grep -rnE '(^|[^[:alnum:]_])solo:|\.only\(' \
  --include='*.dart' "${roots[@]}" || true)

if [[ -n $found ]]; then
  while IFS= read -r line; do
    echo "::error::focused test: ${line}"
  done <<<"$found"
  echo "Remove solo: and .only( — they narrow the suite CI reports on." >&2
  exit 1
fi
