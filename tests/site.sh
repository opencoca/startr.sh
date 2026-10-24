#!/bin/bash
# tests/site.sh: build the site in a node container and check what it would publish.
# Run: make test_site, or `bash tests/site.sh DIR` to keep the build in DIR/dist.
#
# The repo goes into the container as a tar stream and dist/ comes back the same
# way, so nothing is mounted (no stale virtiofs entries) and npm never runs on the host.
# npm install, not npm ci: package-lock.json has drifted from package.json (2026-10-21).
# --ignore-scripts: install scripts are where npm worms run, and this build needs none.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
NODE_IMAGE="${NODE_IMAGE:-node:24-alpine}" # Node 20 is past end of life
if [ $# -gt 0 ]; then OUT="$1"; mkdir -p "$OUT"; else OUT="$(mktemp -d)"; trap 'rm -rf "$OUT"' EXIT; fi
rm -rf "$OUT/dist"

cd "$ROOT_DIR"
export COPYFILE_DISABLE=1 # macOS tar would add ._ AppleDouble files that Eleventy reads as data
echo "Building the site in $NODE_IMAGE..."
# Tracked files deleted in the working tree are still listed: skip them.
git ls-files -co --exclude-standard -z |
	while IFS= read -r -d '' f; do if [ -e "$f" ] || [ -L "$f" ]; then printf '%s\0' "$f"; fi; done |
	tar --null -cf - -T - |
	docker run --rm -i "$NODE_IMAGE" sh -c \
		'mkdir -p /w && cd /w && tar -xf - && npm install --ignore-scripts --no-audit --no-fund --loglevel=error >&2 && npm run build >&2 && tar -cf - dist' |
	tar -xf - -C "$OUT"

pass=0
fail=0
check() {
	local name="$1"
	shift
	if "$@"; then pass=$((pass + 1)); echo "ok   $name"; else fail=$((fail + 1)); echo "FAIL $name"; fi
}
D="$OUT/dist"
check "/Makefile is templates/Makefile.base" cmp -s "$D/Makefile" templates/Makefile.base
check "/Makefile.docker is templates/Makefile.docker" cmp -s "$D/Makefile.docker" templates/Makefile.docker
check "/scripts/tools.sh is src/scripts/tools.sh" cmp -s "$D/scripts/tools.sh" src/scripts/tools.sh
check "/404.html exists" test -s "$D/404.html"
check "/scripts/release.sh is gone" test ! -e "$D/scripts/release.sh"
check "/resources/Makefile is gone" test ! -e "$D/resources/Makefile"
check "/_redirects is gone" test ! -e "$D/_redirects"
check "the git-flow guide is built" test -s "$D/docs/makefile-git-flow/index.html"
check "the CEP page is still a bash script" bash -n "$D/cep/index.html"
check "the home page is still a bash script" bash -n "$D/index.html"
check "the CEP page still renders its HTML" grep -q '<html' "$D/cep/index.html"

echo
echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
