#!/usr/bin/env bash
# Tests tool/generate_sw.sh against a fake build directory.
#
#     tool/generate_sw_test.sh

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

mkdir -p "$tmp/web/assets"
cp "$here/../web/sw.js" "$tmp/web/sw.js"
cp "$here/../web/sw-killswitch.js" "$tmp/web/sw-killswitch.js"
echo main > "$tmp/web/main.dart.js"
echo shell > "$tmp/web/index.html"
echo font > "$tmp/web/assets/a.ttf"
echo '{}' > "$tmp/web/version.json"
echo '{}' > "$tmp/web/update.json"
echo shell > "$tmp/web/404.html"
echo stub > "$tmp/web/flutter_service_worker.js"
printf 'name: memini\nversion: 1.2.3+4\n' > "$tmp/pubspec.yaml"

sh "$here/generate_sw.sh" "$tmp/web" "$tmp/pubspec.yaml" > /dev/null

sw="$(cat "$tmp/web/sw.js")"
check "injects the version" "yes" "$(grep -qF "const APP_VERSION = '1.2.3+4';" <<<"$sw" && echo yes || echo no)"
check "no placeholder left" "no" "$(grep -qF '/*__PRECACHE_MANIFEST__*/' <<<"$sw" && echo yes || echo no)"
for f in main.dart.js index.html assets/a.ttf; do
  check "precaches $f" "yes" "$(grep -qF "\"url\":\"$f\"" <<<"$sw" && echo yes || echo no)"
done
for f in version.json update.json 404.html flutter_service_worker.js sw.js sw-killswitch.js; do
  check "never precaches $f" "no" "$(grep -qF "\"url\":\"$f\"" <<<"$sw" && echo yes || echo no)"
done

before="$(cat "$tmp/web/sw.js")"
echo changed > "$tmp/web/main.dart.js"
cp "$here/../web/sw.js" "$tmp/web/sw.js"
sh "$here/generate_sw.sh" "$tmp/web" "$tmp/pubspec.yaml" > /dev/null
check "a changed file changes sw.js" "yes" "$([[ $before != "$(cat "$tmp/web/sw.js")" ]] && echo yes || echo no)"

cp "$here/../web/sw-killswitch.js" "$tmp/web/sw.js"
sh "$here/generate_sw.sh" "$tmp/web" "$tmp/pubspec.yaml" > /dev/null
check "leaves a kill switch untouched" "yes" "$(cmp -s "$tmp/web/sw.js" "$here/../web/sw-killswitch.js" && echo yes || echo no)"

check "bootstrap never passes serviceWorkerSettings" "no" \
  "$(grep -v '^\s*//' "$here/../web/flutter_bootstrap.js" | grep -q serviceWorkerSettings && echo yes || echo no)"
check "sw.js never skips waiting on install" "no" \
  "$(grep -A3 "addEventListener('install'" "$here/../web/sw.js" | grep -q skipWaiting && echo yes || echo no)"

exit "$failures"
