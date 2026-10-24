#!/bin/bash
# tests/run.sh: fast local tests for what startr.sh hands out. Run: make test
#
# Everything happens in a temp folder against a fixture site on 127.0.0.1.
# Release targets run for real, but only in scratch repos whose origin is a
# bare repo in that folder. Nothing installs: STARTR_NONINTERACTIVE=1.
# shellcheck disable=SC2016 # Make recipes and fake scripts are single-quoted on purpose
set -u

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TAP_DIR="${STARTR_TAP_DIR:-$ROOT_DIR/../homebrew-apps}"
WORK="$(mktemp -d)"
SERVER_PID=""
cleanup() {
	[ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null
	rm -rf "$WORK"
}
trap cleanup EXIT

pass=0
fail=0
ok() { pass=$((pass + 1)); echo "ok   $1"; }
bad() { fail=$((fail + 1)); echo "FAIL $1"; [ -n "${2:-}" ] && printf '%s\n' "$2" | tail -15 | sed 's/^/     /'; }
# expect NAME: the last command's output is in $out and its status in $rc.
expect_ok() { if [ "$rc" = 0 ]; then ok "$1"; else bad "$1 (exit $rc)" "$out"; fi; }
expect_fail() { if [ "$rc" != 0 ]; then ok "$1"; else bad "$1 (expected a failure)" "$out"; fi; }
expect_has() { if printf '%s' "$out" | grep -qF -- "$2"; then ok "$1"; else bad "$1 (no '$2')" "$out"; fi; }
expect_lacks() { if printf '%s' "$out" | grep -qF -- "$2"; then bad "$1 (found '$2')" "$out"; else ok "$1"; fi; }
assert() { local name="$1"; shift; if "$@"; then ok "$name"; else bad "$name"; fi; }
capture() { out="$("$@" 2>&1)"; rc=$?; }

# --- Isolation: our own git config, a fixed PATH, nothing interactive ---
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$WORK/gitconfig"
git config --global user.name "Startr Test"
git config --global user.email "test@startr.invalid"
git config --global init.defaultBranch master
git config --global advice.detachedHead false
export STARTR_NONINTERACTIVE=1 MAKEFLAGS='' MAKELEVEL=''
export STARTR_TEST_ROOT="$WORK/emptyroot" # tools.sh sees no brew and no Docker.app there
mkdir -p "$STARTR_TEST_ROOT"
FAKE="$WORK/fakebin"
mkdir -p "$FAKE"
# Exactly the brew tools the tests need (git, git-flow-next, shellcheck) plus the
# system's own. Nothing else from brew is on the PATH, so an installed git-release
# or sage-runtime cannot change a result.
HB="$WORK/hb"
mkdir -p "$HB"
for t in git git-flow shellcheck; do
	p="$(type -P "$t")" || { echo "Needs $t"; exit 1; } # a path, never a shell function
	ln -s "$p" "$HB/$t"
done
BASE_PATH="$FAKE:$HB:/usr/bin:/bin"
export PATH="$BASE_PATH"
fake() { printf '#!/bin/bash\n%s\n' "$2" > "$FAKE/$1"; chmod +x "$FAKE/$1"; }
unfake() { rm -f "$FAKE/$1"; }
fake docker 'case "$*" in "info --format"*) echo "Ubuntu 24.04 LTS (colima)";; info*) exit 0;; *) echo "docker $*" >> "'"$WORK"'/docker.log";; esac'

# --- Fixture site: good/ serves what we publish; broken/ serves the home page as
# /Makefile (what a wrong address returned); old/ serves the v1 Makefile (no marker).
WWW="$WORK/www"
for site in good broken old; do mkdir -p "$WWW/$site/scripts" "$WWW/$site/cep"; done
cp "$ROOT_DIR/templates/Makefile.base" "$WWW/good/Makefile"
cp "$ROOT_DIR/templates/Makefile.docker" "$WWW/good/Makefile.docker"
cp "$ROOT_DIR/src/index.njk" "$WWW/broken/Makefile"
cp "$ROOT_DIR/tests/fixtures/Makefile.v1" "$WWW/old/Makefile"
for site in good broken old; do
	cp "$ROOT_DIR/src/scripts/tools.sh" "$WWW/$site/scripts/tools.sh"
	cp "$ROOT_DIR"/src/cep/*.md "$WWW/$site/cep/"
done
PORT="$(python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1])')"
python3 -m http.server --bind 127.0.0.1 --directory "$WWW" "$PORT" >/dev/null 2>&1 &
SERVER_PID=$!
export STARTR_URL="http://127.0.0.1:$PORT/good"
for _ in $(seq 50); do curl -fs "$STARTR_URL/Makefile" -o /dev/null && break; sleep 0.1; done
case "$STARTR_URL" in http://127.0.0.1:*) ;; *) echo "STARTR_URL must point at 127.0.0.1"; exit 1 ;; esac
curl -fs "$STARTR_URL/Makefile" -o /dev/null || { echo "Fixture server did not start"; exit 1; }

# new_repo DIR: master + develop, git-flow-next set up, the template Makefile, a bare origin.
new_repo() {
	command git init -q --bare "$1.origin.git"
	command git init -q "$1"
	(
		cd "$1" || exit 1
		git commit -q --allow-empty -m init
		git remote add origin "$1.origin.git"
		git flow init -d -m master -e develop -t v >/dev/null 2>&1
		cp "$ROOT_DIR/templates/Makefile.base" Makefile
		git add Makefile && git commit -q -m "Add Makefile"
		git push -q origin master develop
	)
}
origin_has() { git --git-dir="$1.origin.git" rev-parse -q --verify "$2" >/dev/null; }
release_commit() { echo "$1" > VERSION && git add VERSION && git commit -q -m "Release $1"; }

echo "== The release block is the same everywhere"
block() { sed -n '/>>> startr release block v2/,/<<< startr release block v2/p' "$1"; }
assert "Makefile and templates/Makefile.base carry the same block" \
	diff <(block "$ROOT_DIR/Makefile") <(block "$ROOT_DIR/templates/Makefile.base")
assert "the block is not empty" test -n "$(block "$ROOT_DIR/templates/Makefile.base")"

echo "== First release, finish, re-run"
R="$WORK/first"
new_repo "$R"
cd "$R" || exit 1
capture make -s patch_release
expect_ok "patch_release starts from no tags"
assert "the first release is 0.0.1" test "$(git branch --show-current)" = release/0.0.1
release_commit 0.0.1
refs_before="$(git for-each-ref)"
capture make -n release_finish
assert "make -n release_finish changes nothing" test "$refs_before" = "$(git for-each-ref)"
capture make -s release_finish
expect_ok "release_finish succeeds"
expect_has "it says there is no test target" "finishes untested"
assert "tag v0.0.1 exists" git rev-parse -q --verify refs/tags/v0.0.1
assert "master has the release" git merge-base --is-ancestor v0.0.1 master
assert "develop has the release" git merge-base --is-ancestor v0.0.1 develop
assert "the release branch is gone" test -z "$(git branch --list 'release/*')"
assert "origin got master" test "$(git rev-parse master)" = "$(git --git-dir="$R.origin.git" rev-parse master)"
assert "origin got develop" test "$(git rev-parse develop)" = "$(git --git-dir="$R.origin.git" rev-parse develop)"
assert "origin got the tag" origin_has "$R" refs/tags/v0.0.1
capture make -s release_finish
expect_has "a second finish has nothing to do" "Nothing to finish"

echo "== A failed push is resumed"
capture make -s patch_release
release_commit 0.0.2
mv "$R.origin.git" "$R.away.git"
capture make -s release_finish
expect_fail "the finish fails when origin is unreachable"
mv "$R.away.git" "$R.origin.git"
capture make -s release_finish
expect_has "the re-run pushes what is missing" "not on origin yet"
assert "origin got v0.0.2" origin_has "$R" refs/tags/v0.0.2

echo "== A conflict stops the finish; re-running resumes"
capture make -s patch_release
echo release > NOTES && git add NOTES && git commit -q -m "Notes on the release"
git checkout -q develop && echo develop > NOTES && git add NOTES && git commit -q -m "Notes on develop"
capture make -s release_finish
expect_fail "the finish stops on the conflict"
echo resolved > NOTES && git add NOTES && git commit -q --no-edit
capture make -s release_finish
expect_ok "the re-run finishes"
assert "one merge of release/0.0.3 into master" \
	test "$(git log --merges --oneline --grep "Merge branch 'release/0.0.3'" master | wc -l | tr -d ' ')" = 1
assert "one tag v0.0.3" test "$(git tag -l v0.0.3 | wc -l | tr -d ' ')" = 1
assert "origin got v0.0.3" origin_has "$R" refs/tags/v0.0.3

echo "== Version numbers"
git tag -a v1.2.3 -m v1.2.3 master
git tag git-release-v9.9.9 master
git tag v-notes master
lastv() { make -pRrq -f Makefile : 2>/dev/null | sed -n 's/^LAST_VERSION := //p'; }
assert "stray tags are ignored" test "$(lastv)" = 1.2.3
capture make -s hotfix
assert "a hotfix from 1.2.3 is 1.2.3.1" test "$(git branch --show-current)" = hotfix/1.2.3.1
git checkout -q develop && git branch -q -D hotfix/1.2.3.1
capture make -s custom_release
expect_fail "custom_release without VER refuses"
expect_has "and says how to call it" "VER=X.Y.Z"
capture make -s custom_release VER=2.1
expect_fail "custom_release with a bad VER refuses"
capture make -s custom_release VER=2.1.0
assert "custom_release VER=2.1.0 starts release/2.1.0" test "$(git branch --show-current)" = release/2.1.0
git checkout -q -b hotfix/9.9.9.1 master
capture make -s release_finish
expect_has "two branches to finish is an error" "More than one branch"
git checkout -q develop && git branch -q -D release/2.1.0 hotfix/9.9.9.1

echo "== help and deploy checks"
fake caprover "touch '$WORK/caprover.called'"
capture make -s help
expect_has "help lists patch_release" "patch_release"
assert "help does not list itself" bash -c "! printf '%s\n' \"\$1\" | grep -qx help" _ "$out"
assert "help never calls caprover" test ! -e "$WORK/caprover.called"
unfake caprover

echo "== The test gate"
T="$WORK/gate"
new_repo "$T"
cd "$T" || exit 1
printf '\ntest:\n\t@echo run >> %s/canary; exit 1; $(MAKE) -v\n' "$WORK" >> Makefile
git commit -q -am "A failing test target"
git push -q origin develop
capture make -s patch_release
release_commit 0.0.1
master_before="$(git rev-parse master)"
capture make -s release_finish
expect_fail "failing tests stop the finish"
expect_has "and say nothing moved" "nothing merged, tagged or pushed"
assert "master is unchanged" test "$(git rev-parse master)" = "$master_before"
assert "no tag was made" test -z "$(git tag -l 'v*')"
assert "origin got no tag" bash -c "! git --git-dir='$T.origin.git' rev-parse -q --verify refs/tags/v0.0.1 >/dev/null"
rm -f "$WORK/canary"
make -pRrq -f Makefile : >/dev/null 2>&1
assert "the target lookup runs no recipe, even one with \$(MAKE)" test ! -e "$WORK/canary"
git checkout -q release/0.0.1
printf 'test:\n\t@echo run >> %s/canary\n' "$WORK" > test.mk
sed '/^test:/,$d' Makefile > Makefile.new && cat Makefile.new > Makefile && rm Makefile.new
echo "-include test.mk" >> Makefile
git add Makefile test.mk && git commit -q -m "A passing test target"
capture make -s release_finish
expect_ok "passing tests let the finish run"
expect_has "and the finish says it ran them" "make test on release/0.0.1"
assert "the tests ran once" test "$(wc -l < "$WORK/canary" | tr -d ' ')" = 1

echo "== make release without git-release"
capture make -s release
expect_fail "make release fails without git-release"
expect_has "and offers the brew line" "brew install git-release"

if [ -x "$TAP_DIR/git-release" ]; then
	echo "== git-release from the tap"
	G="$WORK/gitrelease"
	new_repo "$G"
	cd "$G" || exit 1
	printf '\nit_deploy:\n\t@echo run >> %s/deploy.canary; $(MAKE) -v >/dev/null\n' "$WORK" >> Makefile
	git commit -q -am "A deploy canary"
	git push -q origin develop
	capture env PATH="$TAP_DIR:$BASE_PATH" git-release patch
	expect_ok "git-release patch runs start to finish"
	assert "git-release tagged v0.0.1" origin_has "$G" refs/tags/v0.0.1
	assert "its target checks run no recipe (it_deploy ran once)" \
		test "$(wc -l < "$WORK/deploy.canary" 2>/dev/null | tr -d ' ')" = 1
else
	echo "skip git-release from the tap (no $TAP_DIR/git-release)"
fi

echo "== tools.sh"
TOOLS="$ROOT_DIR/src/scripts/tools.sh"
EMPTY="$STARTR_TEST_ROOT"
tools() { capture env STARTR_TEST_ROOT="$EMPTY" PATH="$FAKE:/usr/bin:/bin" bash "$TOOLS" "$@"; }
tools runtime
expect_ok "runtime: docker on Colima is fine"
fake git-release 'exit 0'
tools git-release
expect_ok "git-release: installed is fine"
unfake git-release
tools git-release
expect_fail "git-release missing, no brew: fails"
expect_has "and shows the Homebrew installer" "Homebrew/install/HEAD/install.sh"
fake docker 'case "$*" in "info --format"*) echo "Docker Desktop";; *) exit 0;; esac'
fake sage-runtime 'echo "sage-runtime $*" >> "'"$WORK"'/sage-runtime.log"'
tools runtime
expect_fail "runtime: Docker Desktop, no terminal: installs nothing"
expect_has "and shows sage-runtime migrate" "sage-runtime migrate"
assert "and ran no sage-runtime command" test ! -e "$WORK/sage-runtime.log"
unfake docker
unfake sage-runtime
tools runtime
expect_fail "runtime: no docker on a Mac"
expect_has "offers sage-runtime" "brew install sage-runtime"
capture env STARTR_TEST_ROOT="$EMPTY" STARTR_OS=Linux PATH="$FAKE:/usr/bin:/bin" bash "$TOOLS" runtime
expect_fail "runtime: no docker on Linux"
expect_has "points at Docker Engine" "docs.docker.com/engine/install"
expect_lacks "and offers no brew" "brew"

echo "== Makefile.docker"
D="$WORK/docker"
command git init -q "$D"
cd "$D" || exit 1
git commit -q --allow-empty -m init
cat "$ROOT_DIR/templates/Makefile.base" "$ROOT_DIR/templates/Makefile.docker" > Makefile
printf 'print-%%:\n\t@echo $($*)\n' > print.mk
rt() { PATH="$FAKE:/usr/bin:/bin" make -s -f Makefile -f print.mk print-CONTAINER_RUNTIME 2>/dev/null; }
fake docker 'exit 0'
fake podman 'exit 0'
assert "docker wins when both are installed" test "$(rt)" = docker
unfake docker
assert "podman when it is the only one" test "$(rt)" = podman
unfake podman
fake docker 'case "$*" in info*) exit 1;; *) echo "docker $*" >> "'"$WORK"'/docker.log";; esac'
rm -f "$WORK/docker.log"
capture make -s it_build
expect_fail "it_build stops when no engine runs"
assert "and never calls docker build" bash -c "! grep -q build '$WORK/docker.log' 2>/dev/null"

echo "== CEP"
fake docker 'case "$*" in "info --format"*) echo "Ubuntu 24.04 LTS (colima)";; *) exit 0;; esac'
CEP="$ROOT_DIR/src/cep/index.njk"
C="$WORK/cep-empty"
command git init -q "$C"
cd "$C" || exit 1
capture bash "$CEP"
expect_ok "CEP runs in an empty repo"
assert "it writes the standard Makefile" grep -qF '## >>> startr release block v2' Makefile
assert "it writes CONVENTION.instructions.md" test -s CONVENTION.instructions.md
assert "it writes docs/DEVELOPMENT_WORKFLOW.md" test -s docs/DEVELOPMENT_WORKFLOW.md
assert "it writes no scripts/release.sh" test ! -e scripts/release.sh
C="$WORK/cep-existing"
command git init -q "$C"
cd "$C" || exit 1
printf 'keep:\n\t@echo mine\n' > Makefile
cp Makefile "$WORK/Makefile.mine"
capture bash "$CEP"
assert "an existing Makefile is left byte for byte" cmp -s Makefile "$WORK/Makefile.mine"
C="$WORK/cep-broken"
command git init -q "$C"
cd "$C" || exit 1
capture env STARTR_URL="http://127.0.0.1:$PORT/broken" bash "$CEP"
expect_fail "CEP fails when /Makefile is the wrong page"
assert "and writes no Makefile" test ! -e Makefile
expect_has "and says so" "did not return the standard Makefile"
C="$WORK/cep-old"
command git init -q "$C"
cd "$C" || exit 1
capture env STARTR_URL="http://127.0.0.1:$PORT/old" bash "$CEP"
expect_fail "CEP refuses a Makefile without the v2 marker"
assert "and writes no Makefile" test ! -e Makefile
# `curl | bash` feeds the script on stdin. In a session with no terminal, a prompt
# must take its default; a plain `read` would swallow a line of the script instead.
detached() { python3 -c 'import os, sys; os.setsid(); os.execvp(sys.argv[1], sys.argv[1:])' "$@"; }
C="$WORK/cep-piped"
command git init -q "$C"
cd "$C" || exit 1
capture detached bash -c 'cat "$1" | env -u STARTR_NONINTERACTIVE bash' _ "$CEP"
expect_ok "CEP piped into bash with no terminal runs"
assert "and its prompts took their defaults (Makefile fetched)" grep -qF '## >>> startr release block v2' Makefile
# With a terminal attached, CEP and tools.sh must ask there, not read stdin.
# press_enter.py answers every prompt with Enter: default Yes for the Makefile,
# default No for every install.
C="$WORK/cep-terminal"
command git init -q "$C"
cd "$C" || exit 1
capture env -u STARTR_NONINTERACTIVE python3 "$ROOT_DIR/tests/press_enter.py" bash -c 'cat "$1" | bash' _ "$CEP"
expect_ok "CEP piped into bash at a terminal runs"
assert "it asked at the terminal and fetched the Makefile" grep -qF '## >>> startr release block v2' Makefile
expect_has "tools.sh asked before installing" "Run it now? [y/N]"

echo "== Lint"
for f in "$ROOT_DIR/src/scripts/tools.sh" "$ROOT_DIR/tests/run.sh" "$ROOT_DIR/tests/site.sh"; do
	assert "shellcheck $(basename "$f")" shellcheck -x "$f"
done
for f in "$ROOT_DIR"/src/seatbelts/*.sh; do
	assert "shellcheck errors: $(basename "$f")" shellcheck -S error "$f"
done
for f in "$ROOT_DIR/src/index.njk" "$ROOT_DIR/src/cep/index.njk"; do
	assert "bash -n $(basename "$(dirname "$f")")/$(basename "$f")" bash -n "$f"
	# The page shows its script inside <pre>: a "<" before a letter or "/" would read as a tag.
	assert "no tag-like text in the listing of $(basename "$(dirname "$f")")" \
		bash -c "sed -n '/^#--><pre/,\$p' '$f' | sed '1d;\$d' | grep -qE '<[A-Za-z/!?]' && exit 1 || exit 0"
done

echo
echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
