#!/bin/bash
# tools.sh: offers to install what a Startr project needs, asking before each step.
#
#   curl -fsSL https://startr.sh/scripts/tools.sh | bash -s -- TOOL...
#   TOOL: git-release | git-flow-next | runtime
#
# With no terminal (CI, an agent's shell) or STARTR_NONINTERACTIVE=1 it installs
# nothing: it prints the commands and exits 1. It never uninstalls anything.
# Copyright (c) Startr LLC. AGPL-3.0. Source: WEB-Startr.sh/src/scripts/tools.sh
set -u

TAP="sage-is/apps"
KRUN_TAP="libkrun/krun"
# shellcheck disable=SC2016 # kept literal: shown to the person, run by eval on a yes
BREW_INSTALL='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
RUNTIME_INSTALL="brew tap $TAP && brew tap $KRUN_TAP && brew trust --tap $TAP $KRUN_TAP && brew install sage-runtime"
OS="${STARTR_OS:-$(uname -s)}"
ROOT="${STARTR_TEST_ROOT:-}" # tests point this at an empty folder: no brew, no Docker.app

interactive() {
	[ "${STARTR_NONINTERACTIVE:-0}" != 1 ] && { : </dev/tty; } 2>/dev/null
}

# ask QUESTION: yes only when a person at the terminal types y.
ask() {
	interactive || return 1
	local answer
	printf '%s [y/N] ' "$1" >/dev/tty
	read -r answer </dev/tty || return 1
	case "$answer" in y | Y | yes | Yes) return 0 ;; *) return 1 ;; esac
}

# offer WHY COMMAND: show the command, run it only on a yes.
offer() {
	echo "$1"
	echo "  $2"
	if ask "Run it now?"; then eval "$2"; else return 1; fi
}

load_brew() {
	local b
	for b in "$ROOT"/opt/homebrew/bin/brew "$ROOT"/usr/local/bin/brew "$ROOT"/home/linuxbrew/.linuxbrew/bin/brew; do
		[ -x "$b" ] && { eval "$("$b" shellenv)"; return 0; }
	done
	return 1
}

ensure_brew() {
	command -v brew >/dev/null 2>&1 && return 0
	load_brew && return 0
	offer "Homebrew is not installed. The Startr tools install with it:" "$BREW_INSTALL" || return 1
	load_brew || return 1
	echo "Homebrew is installed. New terminals need it on PATH: see the 'Next steps' it printed."
}

need_git_flow_next() {
	if git flow version 2>/dev/null | grep -q git-flow-next; then echo "git-flow-next: installed"; return 0; fi
	if git flow version >/dev/null 2>&1; then
		echo "An older git-flow is installed. Startr needs git-flow-next. Run these yourself:"
		echo "  brew uninstall git-flow-avh git-flow; brew install git-flow-next"
		return 1
	fi
	ensure_brew || { echo "Then: brew install git-flow-next"; return 1; }
	offer "git-flow-next starts release and hotfix branches:" "brew install git-flow-next"
}

need_git_release() {
	command -v git-release >/dev/null 2>&1 && { echo "git-release: installed"; return 0; }
	local cmd="brew tap $TAP && brew trust --tap $TAP && brew install git-release"
	ensure_brew || { echo "Then: $cmd"; return 1; }
	offer "git-release runs a whole release (start, review, finish) in one command:" "$cmd"
}

ensure_sage_runtime() {
	command -v sage-runtime >/dev/null 2>&1 && return 0
	ensure_brew || { echo "Then: $RUNTIME_INSTALL"; return 1; }
	offer "sage-runtime sets up Colima, the container engine we use on Macs:" "$RUNTIME_INSTALL"
}

need_runtime() {
	local engine
	engine="$(docker info --format '{{.OperatingSystem}}' 2>/dev/null)"
	if [ "$OS" != Darwin ]; then
		[ -n "$engine" ] && { echo "docker: running ($engine)"; return 0; }
		echo "Docker is not running. Install Docker Engine for your system:"
		echo "  https://docs.docker.com/engine/install/"
		return 1
	fi
	if [ -n "$engine" ] && [ "$engine" != "Docker Desktop" ]; then
		echo "docker: running ($engine)"
		return 0
	fi
	if [ "$engine" = "Docker Desktop" ] || [ -d "$ROOT/Applications/Docker.app" ]; then
		echo "Docker Desktop is installed. We move Macs to Colima: your volumes are copied"
		echo "across first, and Docker Desktop keeps its own copy until you remove it."
		ensure_sage_runtime || return 1
		offer "First, a list of what would be copied (changes nothing):" "sage-runtime migrate --dry-run" || return 1
		local cmd="sage-runtime migrate"
		ask "Also copy every tagged image (slower)?" && cmd="sage-runtime migrate --images"
		offer "Copy the volumes and point docker at Colima:" "$cmd"
		return
	fi
	ensure_sage_runtime || return 1
	offer "Start Colima and point docker at it:" "sage-runtime use colima"
}

[ $# -gt 0 ] || { sed -n '2,8p' "$0" 2>/dev/null || echo "Usage: tools.sh git-release|git-flow-next|runtime"; exit 2; }
status=0
for tool in "$@"; do
	case "$tool" in
		git-release) need_git_release || status=1 ;;
		git-flow-next) need_git_flow_next || status=1 ;;
		runtime) need_runtime || status=1 ;;
		*) echo "Unknown tool: $tool (git-release, git-flow-next or runtime)"; status=2 ;;
	esac
done
exit "$status"
