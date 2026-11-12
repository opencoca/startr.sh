help: 
	@echo "================================================"
	@echo "       $(OWNER)/$(PROJECT_NAME) by Startr.Cloud"
	@echo "================================================"
	@echo "This is the default make command."
	@echo "This command lists available make commands."
	@echo ""
	@echo "Usage example:"
	@echo "    make it_run"
	@echo ""
	@echo "Available make commands:"
	@echo ""
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | \
		awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ { \
		if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | \
		grep -E -v -e '^[^[:alnum:]]' -e '^$@$$'
	@echo ""

# Dynamic variable extraction (same as startr.sh)
PROJECTPATH := $(shell git rev-parse --show-toplevel)
PROJECT := $(shell echo $$(basename $(PROJECTPATH)) | tr '[:upper:]' '[:lower:]')
FULL_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
BRANCH := $(shell echo $(FULL_BRANCH) | sed 's/.*\///' | tr '[:upper:]' '[:lower:]')
TAG := $(shell git describe --always --tag)

# Extract owner and project from git remote URL
REMOTE_URL := $(shell git config --get remote.origin.url 2>/dev/null || echo "unknown/unknown")
OWNER := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/]([^/]+)/[^/]+(.git)?$$|\1|')
PROJECT_NAME := $(shell echo $(REMOTE_URL) | sed -E 's|.*[:/][^/]+/([^/]+)(.git)?$$|\1|' | sed 's/\.git$$//')

# Docker container name (dynamic based on project and branch)
CONTAINER := $(PROJECT)-$(BRANCH)

# Load environment variables from .env file if it exists
-include .env

# Default values for environment variables (if not set in .env)
#SERVER__HOST ?= SERVER_
#SERVER__USER ?= root
#SERVER__CONTAINER_FILTER ?= 

it_run:
	@bash -c 'bash <(curl -fsSL $(STARTR_URL)) run'

it_build:
	@bash -c 'bash <(curl -fsSL $(STARTR_URL)) build'

it_build_n_run:
	@bash -c 'bash <(curl -fsSL $(STARTR_URL)) build && bash <(curl -fsSL $(STARTR_URL)) run'

show_vars:
	@echo "=== Dynamic Variables ==="
	@echo "PROJECTPATH=$(PROJECTPATH)"
	@echo "PROJECT=$(PROJECT)"
	@echo "OWNER=$(OWNER)"
	@echo "PROJECT_NAME=$(PROJECT_NAME)"
	@echo "FULL_BRANCH=$(FULL_BRANCH)"
	@echo "BRANCH=$(BRANCH)"
	@echo "TAG=$(TAG)"
	@echo "CONTAINER=$(CONTAINER)"
	@echo "REMOTE_URL=$(REMOTE_URL)"
	@echo ""


update_submodules:
	@echo "Developer instructions: Please update your Dockerfile manually to add the appropriate 'RUN' command for installing git (using apt-get or apk) and to include the submodule update command. Then run 'git submodule update --init --recursive'."

# Check if .gitmodules exists (returns 1 if present, empty otherwise)
HAS_SUBMODULE := $(shell [ -f .gitmodules ] && echo 1)

# Deploying needs the CapRover CLI and a login. Both are checked only
# when you deploy, not every time make reads this file.
deploy:
	@command -v caprover >/dev/null 2>&1 || { echo "CapRover CLI is not installed. Install it with: npm install -g caprover"; exit 1; }
	@caprover ls 2>/dev/null | grep -q "Logged in" || { echo "You are not logged in to CapRover. Run: caprover login"; exit 1; }
	@if [ "$(HAS_SUBMODULE)" = "1" ]; then \
		echo "Submodules detected."; \
		echo "We will create a tar of the project and deploy it"; \
		echo "Creating tar of project..."; \
		echo -e "\a"; \
		git ls-files --recurse-submodules | tar -czf deploy.tar -T -; \
		echo "Deploying to CapRover using the tar file..."; \
		npx caprover deploy -t ./deploy.tar; \
		rm ./deploy.tar; \
	else \
		echo "No submodules detected. Deploying normally..."; \
		npx caprover deploy; \
	fi

things_clean:
	git clean --exclude=!.env -Xdf

setup:
	@echo "Setting up local development environment..."
	@if [ ! -f .env ]; then \
		echo "Creating .env file with default values..."; \
		echo "SERVER__HOST=localhost" > .env; \
		echo "SERVER__USER=root" >> .env; \
		echo "SERVER__CONTAINER_FILTER=" >> .env; \
		echo "GITHUB_CLIENT_ID=Ov23lic87oTTC3OljekI" >> .env; \
		echo "GITHUB_CLIENT_SECRET=your_github_client_secret_here" >> .env; \
		echo "NODE_ENV=development" >> .env; \
		echo "You can customize the .env file later."; \
	fi
	@echo "Setup complete! Local development environment is ready."

cep_fix_links:
	@echo "Fixing CEP hard links after git operations..."
	@if [ ! -d src/cep ]; then \
		echo "Creating CEP directory..."; \
		mkdir -p src/cep; \
	fi
	@echo "Recreating hard links for CEP files..."
	@if [ -f src/cep/CONVENTION.instructions.md ]; then \
		rm src/cep/CONVENTION.instructions.md; \
	fi
	@if [ -f src/cep/DEVELOPMENT_WORKFLOW.md ]; then \
		rm src/cep/DEVELOPMENT_WORKFLOW.md; \
	fi
	@ln CONVENTION.instructions.md src/cep/CONVENTION.instructions.md
	@ln docs/DEVELOPMENT_WORKFLOW.md src/cep/DEVELOPMENT_WORKFLOW.md
	@echo "CEP hard links recreated successfully!"
	@echo "Verifying links..."
	@ls -li CONVENTION.instructions.md src/cep/CONVENTION.instructions.md | awk '{print "CONVENTION inode: " $$1}'
	@ls -li docs/DEVELOPMENT_WORKFLOW.md src/cep/DEVELOPMENT_WORKFLOW.md | awk '{print "WORKFLOW inode: " $$1}'

cep_status:
	@echo "=== CEP Hard Links Status ==="
	@if [ -f src/cep/CONVENTION.instructions.md ]; then \
		echo "CONVENTION.instructions.md:"; \
		ls -li CONVENTION.instructions.md src/cep/CONVENTION.instructions.md; \
		if [ "$$(stat -f '%i' CONVENTION.instructions.md 2>/dev/null)" = "$$(stat -f '%i' src/cep/CONVENTION.instructions.md 2>/dev/null)" ]; then \
			echo "✅ Hard link is working"; \
		else \
			echo "❌ Hard link is broken"; \
		fi; \
	else \
		echo "❌ CEP CONVENTION.instructions.md not found"; \
	fi
	@echo ""
	@if [ -f src/cep/DEVELOPMENT_WORKFLOW.md ]; then \
		echo "DEVELOPMENT_WORKFLOW.md:"; \
		ls -li docs/DEVELOPMENT_WORKFLOW.md src/cep/DEVELOPMENT_WORKFLOW.md; \
		if [ "$$(stat -f '%i' docs/DEVELOPMENT_WORKFLOW.md 2>/dev/null)" = "$$(stat -f '%i' src/cep/DEVELOPMENT_WORKFLOW.md 2>/dev/null)" ]; then \
			echo "✅ Hard link is working"; \
		else \
			echo "❌ Hard link is broken"; \
		fi; \
	else \
		echo "❌ CEP DEVELOPMENT_WORKFLOW.md not found"; \
	fi

docs_fix_links:
	@echo "Creating documentation symlinks for website..."
	@mkdir -p src/docs
	@cd src/docs && ln -sf ../../docs/makefile/README.md makefile-guide.md
	@cd src/docs && ln -sf ../../docs/makefile/commands.md makefile-commands.md
	@cd src/docs && ln -sf ../../docs/makefile/variables.md makefile-variables.md
	@cd src/docs && ln -sf ../../docs/makefile/deployment.md makefile-deployment.md
	@cd src/docs && ln -sf ../../docs/makefile/git-flow.md makefile-git-flow.md
	@cd src/docs && ln -sf ../../docs/makefile/worktrees.md makefile-worktrees.md
	@echo "✅ Documentation symlinks created successfully!"

docs_status:
	@echo "=== Documentation Symlinks Status ==="
	@for doc in makefile-guide makefile-commands makefile-variables makefile-deployment makefile-git-flow makefile-worktrees; do \
		if [ -L "src/docs/$$doc.md" ]; then \
			echo "$$doc.md:"; \
			ls -la "src/docs/$$doc.md"; \
			if [ -f "src/docs/$$doc.md" ]; then \
				echo "✅ Symlink is working"; \
			else \
				echo "❌ Symlink is broken"; \
			fi; \
		else \
			echo "❌ $$doc.md symlink not found"; \
		fi; \
		echo ""; \
	done

install_hooks:
	@echo "Installing git hooks..."
	@if [ ! -d scripts/hooks ]; then \
		echo "❌ scripts/hooks directory not found"; \
		exit 1; \
	fi
	@for hook in scripts/hooks/*; do \
		if [ -f "$$hook" ]; then \
			hook_name=$$(basename "$$hook"); \
			echo "Installing $$hook_name hook..."; \
			cp "$$hook" ".git/hooks/$$hook_name"; \
			chmod +x ".git/hooks/$$hook_name"; \
			echo "✅ $$hook_name hook installed"; \
		fi; \
	done
	@echo "🎉 All hooks installed successfully!"

uninstall_hooks:
	@echo "Uninstalling project-specific git hooks..."
	@for hook in scripts/hooks/*; do \
		if [ -f "$$hook" ]; then \
			hook_name=$$(basename "$$hook"); \
			if [ -f ".git/hooks/$$hook_name" ]; then \
				echo "Removing $$hook_name hook..."; \
				rm ".git/hooks/$$hook_name"; \
				echo "✅ $$hook_name hook removed"; \
			fi; \
		fi; \
	done
	@echo "🎉 All project hooks uninstalled!"

# ---------------------------------------------------------------------------
# Tests: `make test` is fast and local only; `make test_site` builds the
# site in a node container and checks what it would publish.
# ---------------------------------------------------------------------------
test:
	@bash tests/run.sh

test_site:
	@bash tests/site.sh

# ---------------------------------------------------------------------------
# Release flow: the same block startr.sh hands out in templates/Makefile.base
# ---------------------------------------------------------------------------
## >>> startr release block v2 (startr.sh/Makefile, 2026-10-21) >>>
## git-flow-next starts a release or hotfix branch; plain git finishes it.
## Each finish step skips itself once done, so re-running a finish is safe.
## The finish runs `make test` first, when the repo has a test target.
## To update a repo, replace everything between the two marker lines.
## Guide: https://startr.sh/docs/makefile-git-flow/
STARTR_URL ?= https://startr.sh
STARTR_TOOLS = curl -fsSL $(STARTR_URL)/scripts/tools.sh | bash -s --
LAST_VERSION := $(or $(shell git tag -l 'v[0-9]*' --sort=-v:refname 2>/dev/null | head -n 1 | sed 's/^v//'),0.0.0)

.PHONY: require_gitflow_next patch_release minor_release major_release \
        hotfix custom_release release_finish hotfix_finish release

require_gitflow_next:
	@git flow version 2>/dev/null | grep -q git-flow-next || { $(STARTR_TOOLS) git-flow-next; git flow version 2>/dev/null | grep -q git-flow-next; }
	@git config --get-regexp '^gitflow\.(initialized|branch\.develop)' >/dev/null || { echo "git-flow is not set up here. Run: git flow init -d -m master -e develop -t v"; exit 1; }

define release_next_step
	@echo "Next: commit the release changes (version, CHANGELOG), then run: make release_finish"
endef

patch_release: require_gitflow_next
	git flow release start $$(echo $(LAST_VERSION) | awk -F. '{print $$1"."$$2"."$$3+1}')
	$(release_next_step)

minor_release: require_gitflow_next
	git flow release start $$(echo $(LAST_VERSION) | awk -F. '{print $$1"."$$2+1".0"}')
	$(release_next_step)

major_release: require_gitflow_next
	git flow release start $$(echo $(LAST_VERSION) | awk -F. '{print $$1+1".0.0"}')
	$(release_next_step)

## A hotfix bumps a fourth number: 1.2.3 -> 1.2.3.1 -> 1.2.3.2
hotfix: require_gitflow_next
	git flow hotfix start $$(echo $(LAST_VERSION) | awk -F. '{if (NF < 4) print $$1"."$$2"."$$3".1"; else print $$1"."$$2"."$$3"."$$4+1}')
	$(release_next_step)

## make custom_release VER=2.1.0
custom_release: require_gitflow_next
	@echo "$(VER)" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$$' || { echo "Usage: make custom_release VER=X.Y.Z"; exit 1; }
	git flow release start $(VER)
	$(release_next_step)

## The finish, in order: tests on the branch, merge it into master, tag
## master, merge the tag into develop (so `git describe` there sees it),
## delete the branch, then push develop, master and the tag.
## The branch name gives the version. With the branch gone, a re-run
## pushes the newest tag if origin lacks it. The topic branch is never pushed.
## $(MAKE) sits inside this define, so `make -n release_finish` runs nothing.
define finish_flow
	@set -e; \
	brs="$$(git for-each-ref --format='%(refname:short)' refs/heads/release refs/heads/hotfix)"; \
	if [ "$$(echo "$$brs" | grep -c .)" -gt 1 ]; then echo "More than one branch to finish:"; echo "$$brs"; exit 1; fi; \
	br="$$brs"; \
	if [ -n "$$br" ]; then ver="$${br#*/}"; \
	else \
		ver="$(LAST_VERSION)"; \
		git rev-parse -q --verify "refs/tags/v$$ver" >/dev/null || { echo "Nothing to finish: no release/* or hotfix/* branch."; exit 0; }; \
		if git ls-remote --exit-code --tags origin "refs/tags/v$$ver" >/dev/null 2>&1; then echo "Nothing to finish: v$$ver is already on origin."; exit 0; fi; \
		echo "No branch to finish, but v$$ver is not on origin yet: pushing it."; \
	fi; \
	tag="v$$ver"; \
	master="$$(git config --get gitflow.branch.master 2>/dev/null || echo master)"; \
	develop="$$(git config --get gitflow.branch.develop 2>/dev/null || echo develop)"; \
	if [ -n "$$(git status --porcelain --untracked-files=no)" ]; then \
		echo "Uncommitted changes: commit or stash them first."; git status --short; exit 1; \
	fi; \
	echo "=== Finishing $$ver ==="; \
	if [ -n "$$br" ]; then \
		if $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | grep -q '^test:'; then \
			git checkout -q "$$br"; \
			echo "--- make test on $$br ---"; \
			$(MAKE) test || { echo "Tests failed: nothing merged, tagged or pushed."; exit 1; }; \
		else echo "No test target: this release finishes untested."; fi; \
		git checkout -q "$$master"; \
		if git merge-base --is-ancestor "$$br" HEAD; then echo "  $$master already has $$br"; \
		else git merge --no-ff --no-verify -m "Merge branch '$$br'" "$$br"; fi; \
	fi; \
	if git rev-parse -q --verify "refs/tags/$$tag" >/dev/null; then echo "  tag $$tag exists"; \
	else git tag -a "$$tag" -m "Release $$tag" "$$master"; fi; \
	git checkout -q "$$develop"; \
	if git merge-base --is-ancestor "$$tag" HEAD; then echo "  $$develop already has $$tag"; \
	else git merge --no-ff --no-verify -m "Merge tag '$$tag' into $$develop" "$$tag"; fi; \
	if [ -n "$$br" ]; then git branch -d "$$br"; fi; \
	git push origin "$$develop" "$$master" "refs/tags/$$tag"; \
	echo "=== $$ver done: pushed $$develop, $$master and $$tag ==="
endef

release_finish:
	$(finish_flow)

hotfix_finish: release_finish

## Interactive release: git-release (sage-is/apps tap) runs start, review, finish
release:
	@command -v git-release >/dev/null || { $(STARTR_TOOLS) git-release; command -v git-release >/dev/null; }
	@git-release
## <<< startr release block v2 <<<

## >>> startr worktree block v1 (startr.sh/Makefile, 2026-11-12) >>>
## One checkout per repo. A worktree is for one parallel task, and it goes
## the day its branch lands; a landed branch goes too. wt_check fails while
## either lingers, so the rule is a gate, not a memory.
## To update a repo, replace everything between the two marker lines.
## Guide: https://startr.sh/docs/makefile-worktrees/
##   make wt NAME=quick-note       feature/quick-note from WT_BASE, in ../<repo>-wt/quick-note
##   make wt NAME=fix/typo         a name with a slash is the branch; the folder is fix-typo
##   make wt_list                  each worktree and spare branch: ahead/behind, changes, age
##   make wt_done NAME=quick-note  clean and landed only: removes the worktree and its branch
##   make wt_tidy                  wt_done for every clean, landed worktree and branch
##   make wt_check                 fails on a landed worktree or branch, or one over WT_DAYS
## "Landed" means merging the branch into WT_BASE changes nothing: merged,
## squashed or rebased in. The remote branch is never touched.
WT_BASE ?= $(shell for b in develop main master; do git rev-parse -q --verify "refs/heads/$$b" >/dev/null && { echo $$b; break; }; done)
WT_MAX ?= 3
WT_DAYS ?= 3
WT_KEEP ?= develop main master gh-pages

.PHONY: wt wt_list wt_done wt_tidy wt_check

## Shell functions the five targets share. Every worktree but the main
## checkout prints as "path<TAB>branch" ("-" when detached).
define wt_sh
tab=$$(printf '\t'); now=$$(date +%s); base="$(WT_BASE)"; \
main=$$(cd "$$(git rev-parse --path-format=absolute --git-common-dir)/.." && pwd); \
root="$$main-wt"; \
git worktree prune; \
worktrees() { git worktree list --porcelain | awk '/^worktree /{n++; p=substr($$0,10)} n>1 && /^branch /{print p "\t" substr($$0,19)} n>1 && /^detached/{print p "\t-"}'; }; \
spare_branches() { held=$$(git worktree list --porcelain | sed -n 's|^branch refs/heads/||p'); \
	git for-each-ref --format='%(refname:short)' refs/heads | while read -r b; do \
	case " $(WT_KEEP) $$base " in *" $$b "*) continue;; esac; \
	printf '%s\n' "$$held" | grep -qxF "$$b" || echo "$$b"; done; }; \
contained() { git merge-base --is-ancestor "$$1" "$$base" && return 0; \
	t=$$(git merge-tree --write-tree "$$base" "$$1" 2>/dev/null) && [ "$$t" = "$$(git rev-parse "$$base^{tree}")" ]; }; \
worked() { [ "$$(git reflog show "refs/heads/$$1" 2>/dev/null | wc -l | tr -d ' ')" -gt 1 ]; }; \
age() { c=$$(git reflog show --date=unix --format=%gd "refs/heads/$$1" 2>/dev/null | tail -1 | sed -n 's/.*@{\([0-9]*\)}$$/\1/p'); \
	[ -n "$$c" ] && echo $$(( (now - c) / 86400 )) || echo 0; }; \
changes() { git -C "$$1" status --porcelain | wc -l | tr -d ' '; }; \
remove_one() { if [ -n "$$1" ]; then git worktree remove "$$1" || return 1; echo "Removed $$1"; fi; \
	if [ "$$2" != "-" ]; then git branch -D "$$2" >/dev/null && echo "Deleted $$2 (its work is in $$base)"; \
	git rev-parse -q --verify "refs/remotes/origin/$$2" >/dev/null && echo "  origin still has it: git push origin --delete $$2"; fi; \
	rmdir "$$root" 2>/dev/null; true; }
endef

## The bodies of wt_list and wt_check, shared with wt and wt_tidy. They are
## defines, not recursive $(MAKE) calls, so `make -n wt` runs nothing.
define wt_list_sh
echo "base: $${base:-none}"; \
worktrees | while IFS="$$tab" read -r p b; do \
	n=$$(changes "$$p"); line="$$p  $$b  $$n changed"; \
	if [ "$$b" != "-" ] && [ -n "$$base" ]; then \
		line="$$line  +$$(git rev-list --count "$$base..$$b")/-$$(git rev-list --count "$$b..$$base")  $$(age "$$b")d"; \
		[ "$$n" = 0 ] && worked "$$b" && contained "$$b" && line="$$line  LANDED: make wt_done"; \
	fi; echo "$$line"; done; \
[ -n "$$base" ] && spare_branches | while read -r b; do \
	line="branch $$b  +$$(git rev-list --count "$$base..$$b")/-$$(git rev-list --count "$$b..$$base")  $$(age "$$b")d"; \
	contained "$$b" && line="$$line  LANDED: make wt_done NAME=$$b"; echo "$$line"; done; true
endef

define wt_check_sh
[ -n "$$base" ] || { echo "wt_check: no develop, main or master branch here; skipped"; exit 0; }; \
bad=$$( worktrees | while IFS="$$tab" read -r p b; do \
	[ "$$b" = "-" ] && continue; \
	[ "$$(changes "$$p")" = 0 ] && worked "$$b" && contained "$$b" && { echo "  landed worktree: $$p ($$b)"; continue; }; \
	[ "$$(age "$$b")" -le $(WT_DAYS) ] || echo "  $$(age "$$b") days old: $$p ($$b); land it or make wt_done"; done; \
	spare_branches | while read -r b; do contained "$$b" && echo "  landed branch: $$b"; done ); \
[ -z "$$bad" ] || { echo "wt_check failed (WT_DAYS=$(WT_DAYS)):"; echo "$$bad"; echo "make wt_tidy clears what landed; land or drop the rest."; exit 1; }
endef

wt:
	@[ "$(origin NAME)" = "command line" ] || { echo "Usage: make wt NAME=quick-note"; exit 1; }; \
	$(wt_sh); [ -n "$$base" ] || { echo "No develop, main or master branch: set WT_BASE"; exit 1; }; \
	case "$(NAME)" in */*) b="$(NAME)";; *) b="feature/$(NAME)";; esac; \
	dir="$$root/$$(echo "$(NAME)" | tr / -)"; \
	open=$$(worktrees | wc -l | tr -d ' '); \
	[ "$$open" -lt $(WT_MAX) ] || { echo "$$open worktrees open, and WT_MAX is $(WT_MAX). Land one, then make wt_done."; worktrees; exit 1; }; \
	( $(wt_check_sh) ) || { echo "Clear those before a new worktree."; exit 1; }; \
	! git rev-parse -q --verify "refs/heads/$$b" >/dev/null || { echo "$$b already exists"; exit 1; }; \
	git worktree add -q -b "$$b" "$$dir" "$$base" && \
	echo "Ready: cd $$dir ($$b from $$base). When it lands: make wt_done NAME=$(NAME)"

wt_list:
	@$(wt_sh); $(wt_list_sh)

wt_done:
	@[ "$(origin NAME)" = "command line" ] || { echo "Usage: make wt_done NAME=quick-note"; exit 1; }; \
	$(wt_sh); [ -n "$$base" ] || { echo "No develop, main or master branch: set WT_BASE"; exit 1; }; \
	case "$(NAME)" in */*) want="$(NAME)";; *) want="feature/$(NAME)";; esac; \
	dir="$$root/$$(echo "$(NAME)" | tr / -)"; \
	hit=$$(worktrees | awk -F"$$tab" -v d="$$dir" -v b="$$want" '$$1==d || $$2==b {print; exit}'); \
	if [ -n "$$hit" ]; then p=$${hit%%"$$tab"*}; b=$${hit#*"$$tab"}; \
	elif git rev-parse -q --verify "refs/heads/$$want" >/dev/null; then p=; b="$$want"; \
	else echo "No worktree at $$dir and no branch $$want"; exit 1; fi; \
	if [ -n "$$p" ]; then \
		case "$$(pwd -P)/" in "$$(cd "$$p" && pwd -P)/"*) echo "Run it from $$main, not from inside the worktree"; exit 1;; esac; \
		n=$$(changes "$$p"); [ "$$n" = 0 ] || { echo "$$p has $$n uncommitted changes:"; git -C "$$p" status --short; exit 1; }; \
	fi; \
	[ "$$b" = "-" ] || contained "$$b" || { echo "$$b is not in $$base yet: $$(git rev-list --count "$$base..$$b") commits to land"; exit 1; }; \
	remove_one "$$p" "$$b"

wt_tidy:
	@$(wt_sh); [ -n "$$base" ] || { echo "No develop, main or master branch: set WT_BASE"; exit 1; }; \
	worktrees | while IFS="$$tab" read -r p b; do \
		[ "$$b" != "-" ] && [ "$$(changes "$$p")" = 0 ] && worked "$$b" && contained "$$b" && remove_one "$$p" "$$b"; done; \
	spare_branches | while read -r b; do contained "$$b" && remove_one "" "$$b"; done; \
	$(wt_list_sh)

wt_check:
	@$(wt_sh); $(wt_check_sh)
## <<< startr worktree block v1 <<<
