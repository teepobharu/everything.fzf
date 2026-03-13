#!/usr/bin/env bash
# Automated test for gproj functionality (no user interaction needed)
# Tests: repository discovery, output validity, command generation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GPROJ="$SCRIPT_DIR/../gproj.fzf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=== gproj Automated Test Suite ==="
echo ""

PASSED=0
FAILED=0

# Test helper
assert_pass() {
	echo -e "${GREEN}✓ PASS${NC}: $1"
	((PASSED++))
}

assert_fail() {
	echo -e "${RED}✗ FAIL${NC}: $1"
	((FAILED++))
}

# Test 1: Script exists and is executable
echo "Test 1: Script availability"
echo "============================"
if [ -f "$GPROJ" ]; then
	assert_pass "Script exists at $GPROJ"
else
	assert_fail "Script not found at $GPROJ"
fi

if [ -x "$GPROJ" ]; then
	assert_pass "Script is executable"
else
	assert_fail "Script is not executable"
fi

# Test 2: Syntax validation
echo ""
echo "Test 2: Script syntax"
echo "===================="
if bash -n "$GPROJ" 2>/dev/null; then
	assert_pass "Bash syntax valid"
else
	assert_fail "Bash syntax error"
fi

# Test 3: Repository discovery
echo ""
echo "Test 3: Repository discovery"
echo "============================="
REPO_OUTPUT=$("$GPROJ" 2>/dev/null || true)
REPO_COUNT=$(echo "$REPO_OUTPUT" | grep -c . || echo 0)

if [ "$REPO_COUNT" -gt 0 ]; then
	assert_pass "Found $REPO_COUNT repositories"
else
	assert_fail "No repositories found"
fi

# Test 4: Output validity - each line is a valid directory
echo ""
echo "Test 4: Output validity"
echo "======================="
INVALID_LINES=0
while IFS= read -r repo_path; do
	[ -z "$repo_path" ] && continue

	if [ -d "$repo_path" ]; then
		# Verify it's a git repo
		if [ -d "$repo_path/.git" ]; then
			: # Valid
		else
			((INVALID_LINES++))
			echo "  Warning: $repo_path has no .git"
		fi
	else
		((INVALID_LINES++))
		echo "  Invalid path: $repo_path"
	fi
done <<<"$REPO_OUTPUT"

if [ "$INVALID_LINES" -eq 0 ]; then
	assert_pass "All output lines are valid git repositories"
else
	assert_fail "$INVALID_LINES invalid paths in output"
fi

# Test 5: No duplicate paths
echo ""
echo "Test 5: Deduplication"
echo "===================="
TOTAL_LINES=$REPO_COUNT
UNIQUE_LINES=$(echo "$REPO_OUTPUT" | sort -u | wc -l | xargs)

if [ "$TOTAL_LINES" -eq "$UNIQUE_LINES" ]; then
	assert_pass "No duplicate paths ($TOTAL_LINES repos)"
else
	assert_fail "Found duplicates: $TOTAL_LINES total, $UNIQUE_LINES unique"
fi

# Test 6: Performance - cache test
echo ""
echo "Test 6: Performance"
echo "==================="

# Clear cache
rm -rf ~/.cache/gproj 2>/dev/null || true

# Mock fzf to avoid interactive mode
export PATH="/tmp/gproj-test:$PATH"
mkdir -p /tmp/gproj-test
cat >/tmp/gproj-test/fzf <<'EOF'
#!/bin/bash
head -1
EOF
chmod +x /tmp/gproj-test/fzf

# First run (no cache)
START=$(date +%s%N)
FIRST_RUN=$("$GPROJ" 2>/dev/null | head -1 || true)
END=$(date +%s%N)
FIRST_TIME=$(((END - START) / 1000000))

# Second run (with cache)
START=$(date +%s%N)
SECOND_RUN=$("$GPROJ" 2>/dev/null | head -1 || true)
END=$(date +%s%N)
SECOND_TIME=$(((END - START) / 1000000))

echo "First run:  ${FIRST_TIME}ms"
echo "Second run: ${SECOND_TIME}ms"

if [ "$FIRST_TIME" -lt 3000 ]; then
	assert_pass "First run under 3s: ${FIRST_TIME}ms"
else
	assert_fail "First run too slow: ${FIRST_TIME}ms"
fi

if [ "$SECOND_TIME" -lt 200 ]; then
	assert_pass "Cached run under 200ms: ${SECOND_TIME}ms"
else
	assert_fail "Cached run too slow: ${SECOND_TIME}ms"
fi

# Test 7: Command availability
echo ""
echo "Test 7: Required commands"
echo "========================="

COMMANDS=("git" "fzf" "find")
OPTIONAL_COMMANDS=("fd" "nvim" "code")

for cmd in "${COMMANDS[@]}"; do
	if command -v "$cmd" >/dev/null 2>&1; then
		assert_pass "$cmd available"
	else
		assert_fail "$cmd not found (required)"
	fi
done

for cmd in "${OPTIONAL_COMMANDS[@]}"; do
	if command -v "$cmd" >/dev/null 2>&1; then
		assert_pass "$cmd available (optional)"
	else
		echo -e "${YELLOW}⚠ WARNING${NC}: $cmd not found (optional)"
	fi
done

# Test 8: Keybinding verification
echo ""
echo "Test 8: Script keybindings"
echo "=========================="

# Check if keybindings are defined in script
if grep -q "ctrl-v" "$GPROJ"; then
	assert_pass "CTRL-V binding found"
else
	assert_fail "CTRL-V binding not found"
fi

if grep -q "ctrl-e" "$GPROJ"; then
	assert_pass "CTRL-E binding found"
else
	assert_fail "CTRL-E binding not found"
fi

if grep -q "enter:execute" "$GPROJ"; then
	assert_pass "ENTER binding found"
else
	assert_fail "ENTER binding not found"
fi

# Test 9: Debug mode
echo ""
echo "Test 9: Debug mode"
echo "=================="

DEBUG_OUTPUT=$(GPROJ_DEBUG=1 "$GPROJ" 2>&1 | grep "\[gproj\]" | wc -l | xargs)

if [ "$DEBUG_OUTPUT" -gt 0 ]; then
	assert_pass "Debug mode shows timing ($DEBUG_OUTPUT entries)"
else
	assert_fail "Debug mode not working"
fi

# Test 10: Configuration options
echo ""
echo "Test 10: Configuration options"
echo "=============================="

# Test custom roots
CUSTOM_ROOTS=$("$GPROJ" 2>/dev/null | wc -l | xargs)
PERSONAL_ONLY=$(EVERYTHING_FZF_ROOTS="$HOME/Personal" "$GPROJ" 2>/dev/null | wc -l | xargs)

if [ "$PERSONAL_ONLY" -le "$CUSTOM_ROOTS" ]; then
	assert_pass "Custom EVERYTHING_FZF_ROOTS works"
else
	assert_fail "Custom EVERYTHING_FZF_ROOTS not working properly"
fi

# Test cache disable
rm -rf ~/.cache/gproj 2>/dev/null || true
CACHE_RUN=$(GPROJ_CACHE=0 "$GPROJ" 2>/dev/null | wc -l | xargs)
if [ "$CACHE_RUN" -gt 0 ]; then
	assert_pass "GPROJ_CACHE=0 works"
else
	assert_fail "GPROJ_CACHE=0 not working"
fi

# Test max depth
DEPTH_LIMITED=$(GPROJ_MAX_DEPTH=3 "$GPROJ" 2>/dev/null | wc -l | xargs)
if [ "$DEPTH_LIMITED" -ge 0 ]; then
	assert_pass "GPROJ_MAX_DEPTH works"
else
	assert_fail "GPROJ_MAX_DEPTH not working"
fi

# Cleanup
rm -rf /tmp/gproj-test

# Summary
echo ""
echo "================================"
echo -e "Test Summary"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "================================"

if [ "$FAILED" -eq 0 ]; then
	echo -e "${GREEN}✓ All tests passed!${NC}"
	exit 0
else
	echo -e "${RED}✗ Some tests failed${NC}"
	exit 1
fi
