# Git Flow Release Guide

This guide covers the release targets in the Startr Makefile.

## Set up once

Get the standard Makefile:

```bash
curl -fsSL https://startr.sh/Makefile -o Makefile
```

For a container project, add the block from `https://startr.sh/Makefile.docker` after the standard variables.

Initialize Git Flow once in the repository, using `master` and `develop` and tags that start with `v`:

```bash
git flow init -d -m master -e develop -t v
```

The Makefile uses `git-flow-next` to start branches and `git-release` to run a whole release.

If either tool is missing, the Makefile runs the Startr tool installer, `startr.sh/scripts/tools.sh`. It asks before each install, Homebrew included, and installs nothing without a person at a terminal.

## Make a release

Start a release branch with one of these targets:

```bash
make patch_release
make minor_release
make major_release
```

Versions come from the newest tag matching `v[0-9]*`; other tags are ignored.

If the repository has no matching tag, the first release starts from `0.0.0`, so `make patch_release` starts `0.0.1`.

For a hotfix or a chosen version, see [Use hotfixes and custom versions](#use-hotfixes-and-custom-versions).

Commit the release changes, such as the version and `CHANGELOG`, on the release or hotfix branch.

Finish the release or hotfix:

```bash
make release_finish
```

`make hotfix_finish` is the same target.

## Understand what the finish does

1. It refuses to finish if tracked files are uncommitted or more than one release or hotfix branch exists.
2. If the repository has a `test` target, it runs `make test` on the branch; if tests fail, nothing is merged, tagged, or pushed.
3. If there is no `test` target, it reports that the release finishes untested.
4. It merges the branch into `master`.
5. It tags `master` with the release version, such as `v2.1.0`.
6. It merges that tag into `develop`, so `git describe` on `develop` sees it.
7. It deletes the release or hotfix branch.
8. It pushes `develop`, `master`, and the tag; it never pushes the release or hotfix branch.

The finish uses plain Git, not `git flow release finish`, which left releases half-done more than once.

## Handle problems

Re-running `make release_finish` is safe because completed steps are skipped.

After a merge conflict, resolve it, commit the resolution, and run `make release_finish` again.

If a push fails after the branch was deleted, run `make release_finish` again; it pushes the newest tag when `origin` does not have it.

If tests fail, nothing has been merged, tagged, or pushed; fix the tests and run `make release_finish` again.

If there is nothing left to finish, the target reports `Nothing to finish`.

Preview the finish plan without changing anything:

```bash
make -n release_finish
```

## Use hotfixes and custom versions

A hotfix branches from `master` and adds a fourth version number, such as `1.2.3.1`, then `1.2.3.2`.

Start a hotfix with:

```bash
make hotfix
```

Start a release at a chosen version with:

```bash
make custom_release VER=2.1.0
```

Without a valid `VER`, such as `2.1.0` or `2.1.0.1`, the target refuses to start.

## Run a whole release with make release

Run the interactive release command:

```bash
make release
```

`git-release` asks for the release type, starts the release, pauses for review in interactive mode, and finishes it.

It then offers `it_build_multi_arch_push_GHCR` and `it_deploy` if the Makefile has those targets.

## Take the block into an existing Makefile

Replace everything between the two release-block marker lines with the Startr release block.

You can also paste the block at the end of the Makefile and delete the old release targets.

Keep your own targets outside the markers; updating later uses the same swap.

## Check commands at a glance

| Command | Purpose |
| --- | --- |
| `make patch_release` | Start a patch release branch. |
| `make minor_release` | Start a minor release branch. |
| `make major_release` | Start a major release branch. |
| `make hotfix` | Start a hotfix branch from `master`. |
| `make custom_release VER=X.Y.Z` | Start a release at a chosen version. |
| `make release_finish` | Finish a release or hotfix, then push `develop`, `master` and the tag. |
| `make hotfix_finish` | Finish a hotfix; same target as `release_finish`. |
| `make release` | Run the interactive whole-release flow. |
| `make -n release_finish` | Print the finish plan without changing anything. |
