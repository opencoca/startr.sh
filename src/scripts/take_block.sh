#!/bin/sh
# take_block.sh: take or update one marked block of the Startr standard Makefile.
#
#   sh take_block.sh worktree Makefile
#   curl -fsSL https://startr.sh/scripts/take_block.sh | sh -s worktree Makefile
#
# NAME is release or worktree. SOURCE defaults to https://startr.sh/Makefile; a
# local file works too. A Makefile that has the block gets it replaced in place,
# any version; one without it gets the block appended. It refuses a Makefile
# that already defines one of the block's targets outside the block.
# The write keeps the file's inode, so a hardlinked Makefile stays linked.
set -eu

name="${1:-}" target="${2:-}" src="${3:-https://startr.sh/Makefile}"
case "$name" in release | worktree) ;; *)
	echo "Usage: take_block.sh release|worktree TARGET_MAKEFILE [SOURCE]" >&2
	exit 2
	;;
esac
[ -f "$target" ] || { echo "No file: $target" >&2; exit 1; }
open="^## >>> startr $name block"
close="^## <<< startr $name block"

blk="$(mktemp)" rest="$(mktemp)" new="$(mktemp)" orig="$(mktemp)"
trap 'rm -f "$blk" "$rest" "$new" "$orig"' EXIT

case "$src" in
http://* | https://*) curl -fsSL "$src" ;;
*) cat "$src" ;;
esac | awk -v o="$open" -v c="$close" '$0 ~ o {on=1} on {print} on && $0 ~ c {exit}' >"$blk"
tail -n 1 "$blk" | grep -q "$close" || { echo "No complete $name block in $src" >&2; exit 1; }

opens=$(grep -c "$open" "$target" || true)
closes=$(grep -c "$close" "$target" || true)
[ "$opens" = "$closes" ] && [ "$opens" -le 1 ] || {
	echo "$target: $opens opening and $closes closing $name markers; fix it by hand" >&2
	exit 1
}

# What the target defines outside the block must not clash with the block.
awk -v o="$open" -v c="$close" '$0 ~ o {skip=1} !skip {print} skip && $0 ~ c {skip=0}' "$target" >"$rest"
clash=$(sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\):.*/\1/p' "$blk" | while read -r t; do
	grep -q "^$t:" "$rest" && echo "$t"
done) || true
if [ -n "$clash" ]; then
	echo "$target already defines $(echo "$clash" | tr '\n' ' ')outside the $name block; rename or remove them first" >&2
	exit 1
fi

if [ "$opens" = 1 ]; then
	awk -v o="$open" -v c="$close" -v f="$blk" '
		$0 ~ o {while ((getline l < f) > 0) print l; skip=1; next}
		skip && $0 ~ c {skip=0; next}
		!skip {print}' "$target" >"$new"
else
	{
		cat "$target"
		[ -z "$(tail -c 1 "$target")" ] || echo
		echo
		cat "$blk"
	} >"$new"
fi

if cmp -s "$new" "$target"; then
	echo "$target: the $name block is already current"
	exit 0
fi

# Make must still read the file: a probe rule from stdin gives make a goal
# that runs nothing, so only a parse error fails.
parses() { (cd "$(dirname "$1")" && printf '__take_block_probe: ;\n' | make -s -f "$(basename "$1")" -f - -n __take_block_probe >/dev/null 2>&1); }
cp "$target" "$orig"
cat "$new" >"$target"
if parses "$orig" && ! parses "$target"; then
	cat "$orig" >"$target"
	echo "$target: make could not read it with the $name block; left unchanged" >&2
	exit 1
fi
echo "$target: took the $name block"
