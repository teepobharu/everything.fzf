#!/usr/bin/env bash
set -euo pipefail

# Benchmark script for gproj performance testing
# Creates a test directory tree with various depths and repo counts

echo "=== gproj Performance Benchmark ==="
echo ""

# Create test structure
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT

echo "Creating test repository tree at $ROOT..."
echo ""

# Create repos at different depths
mkdir -p "$ROOT/shallow1/.git"
mkdir -p "$ROOT/shallow2/.git"
mkdir -p "$ROOT/level1/repo1/.git"
mkdir -p "$ROOT/level1/repo2/.git"
mkdir -p "$ROOT/level1/level2/repo3/.git"
mkdir -p "$ROOT/level1/level2/level3/repo4/.git"

# Create some noise directories
mkdir -p "$ROOT/level1/node_modules/should-ignore/.git"
mkdir -p "$ROOT/noise1/noise2/noise3"

# Initialize real git repos
for dir in "$ROOT"/{shallow1,shallow2,level1/repo1,level1/repo2,level1/level2/repo3,level1/level2/level3/repo4}; do
	git -C "$dir" init >/dev/null 2>&1
done

echo "Test structure created:"
echo "  - 6 valid repos at various depths"
echo "  - 1 ignored repo in node_modules"
echo "  - Some noise directories"
echo ""

# Mock fzf to just output first result
function fzf() { head -1; }
export -f fzf

export EVERYTHING_FZF_ROOTS="$ROOT"
export EVERYTHING_FZF_IGNORES="node_modules"

echo "=== Running with DEBUG mode ==="
echo ""
GPROJ_DEBUG=1 "$(dirname "$0")/../gproj.fzf" >/dev/null 2>&1 || true

echo ""
echo "=== Performance Analysis ==="
echo ""

# Run multiple times to get average
RUNS=5
echo "Running $RUNS iterations to measure consistency..."
echo ""

TOTAL_MS=0
for i in $(seq 1 $RUNS); do
	START=$(date +%s%N 2>/dev/null || echo "0")
	"$(dirname "$0")/../gproj.fzf" >/dev/null 2>&1 || true
	END=$(date +%s%N 2>/dev/null || echo "0")

	if [ "$START" != "0" ] && [ "$END" != "0" ]; then
		ELAPSED_MS=$(((END - START) / 1000000))
		TOTAL_MS=$((TOTAL_MS + ELAPSED_MS))
		echo "  Run $i: ${ELAPSED_MS}ms"
	fi
done

if [ "$TOTAL_MS" -gt 0 ]; then
	AVG_MS=$((TOTAL_MS / RUNS))
	echo ""
	echo "Average: ${AVG_MS}ms"
fi

echo ""
echo "=== Recommendations ==="
echo ""

if command -v fd >/dev/null 2>&1; then
	echo "✓ fd is installed - using fast path"
else
	echo "⚠ fd is not installed - using slower find fallback"
	echo "  Install fd for better performance: brew install fd"
fi

echo ""
echo "To test on your actual directories:"
echo "  GPROJ_DEBUG=1 gproj"
echo ""
echo "To see what's slowing things down, check:"
echo "  - Number of .git directories found"
echo "  - Time spent in 'find-git-dirs' phase"
echo "  - Preview script execution (happens on hover in fzf)"
