#!/usr/bin/env bash
# Tests tool/no_focused_tests.sh against fake test trees.
#
#     tool/no_focused_tests_test.sh

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
failures=0
check() {
  if [[ $2 == "$3" ]]; then printf 'ok   %s\n' "$1"; else
    printf 'FAIL %s: expected [%s], got [%s]\n' "$1" "$2" "$3"
    failures=$((failures + 1))
  fi
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

status() { bash "$here/no_focused_tests.sh" "$@" > /dev/null 2>&1 && echo 0 || echo 1; }

mkdir -p "$tmp/clean/nested"
cat > "$tmp/clean/nested/a_test.dart" <<'DART'
void main() {
  test('holds', () {});
  group('a group', () {});
}
DART
check "passes a tree with no focused test" "0" "$(status "$tmp/clean")"

mkdir -p "$tmp/solo"
printf "void main() {\n  test('x', () {}, solo: true);\n}\n" > "$tmp/solo/a_test.dart"
check "rejects solo:" "1" "$(status "$tmp/solo")"

mkdir -p "$tmp/only"
printf "void main() {\n  test.only('x', () {});\n}\n" > "$tmp/only/a_test.dart"
check "rejects .only(" "1" "$(status "$tmp/only")"

mkdir -p "$tmp/mixed"
cp "$tmp/clean/nested/a_test.dart" "$tmp/mixed/ok_test.dart"
cp "$tmp/solo/a_test.dart" "$tmp/mixed/bad_test.dart"
check "rejects when only one file is focused" "1" "$(status "$tmp/clean" "$tmp/mixed")"

check "passes when a directory is absent" "0" "$(status "$tmp/clean" "$tmp/nope")"

if ((failures)); then
  printf '\n%d check(s) failed\n' "$failures"
  exit 1
fi
printf '\nall checks passed\n'
