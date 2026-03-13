#!/usr/bin/env bash
set -euo pipefail

# Basic smoke test for gproj discovery on a small temporary tree
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT

mkdir -p "$ROOT/foo/.git" "$ROOT/bar/.git" "$ROOT/skipme/node_modules/irrelevant/.git"
# Initialize proper git repos
git -C "$ROOT/foo" init >/dev/null 2>&1
git -C "$ROOT/bar" init >/dev/null 2>&1
git -C "$ROOT/skipme/node_modules/irrelevant" init >/dev/null 2>&1

export EVERYTHING_FZF_ROOTS="$ROOT"
export EVERYTHING_FZF_IGNORES="node_modules"

# Mock fzf to just output the list
function fzf() { cat; }
export -f fzf

OUT=$("$(dirname "$0")/../gproj.fzf" 2>/dev/null)

if ! echo "$OUT" | grep -q "$ROOT/foo"; then
	echo "Expected $ROOT/foo in output" >&2
	echo "Got: $OUT" >&2
	exit 2
fi

if ! echo "$OUT" | grep -q "$ROOT/bar"; then
	echo "Expected $ROOT/bar in output" >&2
	echo "Got: $OUT" >&2
	exit 2
fi

if echo "$OUT" | grep -q "node_modules"; then
	echo "Should not include node_modules paths" >&2
	echo "Got: $OUT" >&2
	exit 2
fi

echo "✓ test passed"
