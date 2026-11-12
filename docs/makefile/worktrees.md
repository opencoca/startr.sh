# Worktree Guide

This guide covers the worktree targets in the Startr Makefile.

Work happens in one checkout, on `develop` or one short branch from it. A worktree is for one parallel task, such as a second agent session. It goes the day its branch lands, and a landed branch goes with it. Two checkouts left open for days is how a branch falls far behind `develop`.

## Get the block

A new project gets it with the standard Makefile:

```bash
curl -fsSL https://startr.sh/Makefile -o Makefile
```

An existing Makefile takes it, or updates it, with:

```bash
curl -fsSL https://startr.sh/scripts/take_block.sh | sh -s worktree Makefile
```

The script replaces what lies between the block's two marker lines, or appends the block when there are none. It refuses a Makefile that already defines one of the block's targets. The write keeps the file's inode, so a hardlinked Makefile stays linked.

## The targets

| Target | What it does |
| --- | --- |
| `make wt NAME=quick-note` | Creates `feature/quick-note` from `WT_BASE` in `../<repo>-wt/quick-note`. A name with a slash, such as `fix/typo`, is the branch itself; its folder is `fix-typo`. |
| `make wt_list` | Lists each worktree and each spare branch: commits ahead and behind, uncommitted changes, age in days, and whether it has landed. |
| `make wt_done NAME=quick-note` | Removes the worktree and deletes its branch. It refuses uncommitted changes, work not yet in `WT_BASE`, and a run from inside the worktree. |
| `make wt_tidy` | Runs `wt_done` for every clean, landed worktree and every landed spare branch, then lists what is left. |
| `make wt_check` | Fails on a landed worktree, a landed spare branch, or a worktree older than `WT_DAYS`. |

`wt` runs the same check first, so a new worktree waits until the old ones are cleared. It also refuses a fourth open worktree.

## What "landed" means

A branch has landed when merging it into `WT_BASE` would change nothing. That covers a normal merge, a squash merge and a rebase. A clean worktree on a fresh branch with no commits is not landed; `wt_check` flags it only once it passes `WT_DAYS`.

A spare branch is a local branch that no worktree holds and that is not in `WT_KEEP`. The remote branch is never touched. When origin still has one, `wt_done` prints the command to delete it.

## Settings

| Variable | Default | Meaning |
| --- | --- | --- |
| `WT_BASE` | `develop`, else `main`, else `master` | The branch work lands in. |
| `WT_MAX` | `3` | The most worktrees open at once, besides the main checkout. |
| `WT_DAYS` | `3` | The age at which `wt_check` fails a worktree. |
| `WT_KEEP` | `develop main master gh-pages` | Branches never counted as spare. |

`NAME` must come from the command line. A `NAME` in `.env` is ignored, so a stray setting never creates or removes a worktree.

## Make it a gate

Add `wt_check` to the project's `test` target, so a lingering worktree fails the tests:

```make
test: wt_check
```

With no `develop`, `main` or `master` branch, as in some CI checkouts, `wt_check` skips itself.

## `make -n`

`make -n wt NAME=x` prints the recipe and runs nothing. The shared shell lives in `define` blocks, not in recursive `$(MAKE)` calls, so dry runs stay dry.
