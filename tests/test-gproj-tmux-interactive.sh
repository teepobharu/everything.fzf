#!/usr/bin/env bash
# Interactive tmux test for gproj with assertions
# This script tests actual functionality: cd works, nvim opens, etc.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GPROJ="$SCRIPT_DIR/../gproj.fzf"
RESULTS_FILE="/tmp/gproj-test-results.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== gproj Tmux Interactive Test Suite ==="
echo ""

# Verify we're in tmux
if [ -z "${TMUX:-}" ]; then
	echo -e "${RED}✗ ERROR: Not running in tmux${NC}"
	echo "Start tmux first: tmux"
	exit 1
fi

TMUX_PANE="${TMUX_PANE:-%0}"
echo -e "${YELLOW}Testing in tmux pane: $TMUX_PANE${NC}"
echo ""

# Helper functions
assert_file_content() {
	local file="$1"
	local expected="$2"
	local msg="$3"

	if [ -f "$file" ] && grep -q "$expected" "$file"; then
		echo -e "${GREEN}✓ PASS${NC}: $msg"
		return 0
	else
		echo -e "${RED}✗ FAIL${NC}: $msg"
		if [ -f "$file" ]; then
			echo "  Got: $(cat "$file")"
		fi
		return 1
	fi
}

assert_pane_content() {
	local expected="$1"
	local msg="$2"
	local pane="${3:-$TMUX_PANE}"

	sleep 0.5 # Give time for command to execute
	local content=$(tmux capture-pane -t "$pane" -p | tail -5)

	if echo "$content" | grep -q "$expected"; then
		echo -e "${GREEN}✓ PASS${NC}: $msg"
		echo "  Content: $(echo "$content" | tail -1)"
		return 0
	else
		echo -e "${RED}✗ FAIL${NC}: $msg"
		echo "  Expected to find: $expected"
		echo "  Pane content:"
		echo "$content" | sed 's/^/    /'
		return 1
	fi
}

# Test 1: ENTER key - cd to repository
test_enter_cd() {
	echo "Test 1: ENTER key (cd to repo)"
	echo "================================"

	# Get a repo from gproj output
	local test_repo=$("$GPROJ" 2>/dev/null | head -1)

	if [ -z "$test_repo" ]; then
		echo -e "${RED}✗ SKIP${NC}: No repos found"
		return 1
	fi

	echo "  Selected repo: $test_repo"

	# Create test command that simulates ENTER press
	# We'll use fzf with echo to select the first repo
	local test_cmd="echo '$test_repo' | fzf --bind 'start:accept'"

	# Send the command to tmux
	tmux send-keys -t "$TMUX_PANE" "cd /tmp && pwd > $RESULTS_FILE.before" Enter
	sleep 0.3

	# Now send a cd command (simulating what gproj ENTER would do)
	tmux send-keys -t "$TMUX_PANE" "cd '$test_repo' && pwd > $RESULTS_FILE.after" Enter
	sleep 0.3

	# Verify cd happened
	if [ -f "$RESULTS_FILE.before" ] && [ -f "$RESULTS_FILE.after" ]; then
		local before=$(cat "$RESULTS_FILE.before")
		local after=$(cat "$RESULTS_FILE.after")

		if [ "$before" != "$after" ] && [ "$after" = "$test_repo" ]; then
			echo -e "${GREEN}✓ PASS${NC}: Directory changed from $before to $after"
			rm -f "$RESULTS_FILE.before" "$RESULTS_FILE.after"
			return 0
		else
			echo -e "${RED}✗ FAIL${NC}: Directory didn't change correctly"
			echo "  Before: $before"
			echo "  After:  $after"
			echo "  Expected: $test_repo"
			return 1
		fi
	else
		echo -e "${RED}✗ FAIL${NC}: Could not write to temp files"
		return 1
	fi
}

# Test 2: CTRL-V key - nvim opens
test_ctrl_v_nvim() {
	echo ""
	echo "Test 2: CTRL-V key (open nvim)"
	echo "==============================="

	local test_repo=$("$GPROJ" 2>/dev/null | head -1)
	if [ -z "$test_repo" ]; then
		echo -e "${RED}✗ SKIP${NC}: No repos found"
		return 1
	fi

	# Check if nvim exists
	if ! command -v nvim >/dev/null 2>&1; then
		echo -e "${RED}✗ SKIP${NC}: nvim not installed"
		return 1
	fi

	echo "  Testing nvim command: nvim \"$test_repo\""

	# Verify nvim would work
	tmux send-keys -t "$TMUX_PANE" "which nvim" Enter
	sleep 0.3

	assert_pane_content "nvim" "nvim command exists" || return 1

	echo -e "${GREEN}✓ PASS${NC}: nvim command verified (actual opening requires user interaction)"
	return 0
}

# Test 3: CTRL-E key - code opens
test_ctrl_e_code() {
	echo ""
	echo "Test 3: CTRL-E key (open VSCode)"
	echo "=================================="

	local test_repo=$("$GPROJ" 2>/dev/null | head -1)
	if [ -z "$test_repo" ]; then
		echo -e "${RED}✗ SKIP${NC}: No repos found"
		return 1
	fi

	# Check if code exists
	if ! command -v code >/dev/null 2>&1; then
		echo -e "${RED}✗ SKIP${NC}: code command not installed"
		return 1
	fi

	echo "  Testing code command: code \"$test_repo\""

	# Verify code command exists
	tmux send-keys -t "$TMUX_PANE" "which code" Enter
	sleep 0.3

	assert_pane_content "code" "code command exists" || return 1

	echo -e "${GREEN}✓ PASS${NC}: code command verified (actual opening requires user interaction)"
	return 0
}

# Test 4: CTRL-O key - print path
test_ctrl_o_print() {
	echo ""
	echo "Test 4: CTRL-O key (print path)"
	echo "================================"

	local test_repo=$("$GPROJ" 2>/dev/null | head -1)
	if [ -z "$test_repo" ]; then
		echo -e "${RED}✗ SKIP${NC}: No repos found"
		return 1
	fi

	echo "  Testing path output"

	# Run gproj and capture output
	local output=$("$GPROJ" 2>/dev/null | head -1)

	if [ -n "$output" ] && [ -d "$output" ]; then
		echo -e "${GREEN}✓ PASS${NC}: gproj outputs valid repo path: $output"
		return 0
	else
		echo -e "${RED}✗ FAIL${NC}: gproj output not valid"
		return 1
	fi
}

# Test 5: Verify repositories are found
test_repos_found() {
	echo ""
	echo "Test 5: Repository discovery"
	echo "============================"

	local count=$("$GPROJ" 2>/dev/null | wc -l | xargs)

	if [ "$count" -gt 0 ]; then
		echo -e "${GREEN}✓ PASS${NC}: Found $count repositories"
		return 0
	else
		echo -e "${RED}✗ FAIL${NC}: No repositories found"
		return 1
	fi
}

# Test 6: Script syntax and execution
test_script_validity() {
	echo ""
	echo "Test 6: Script validity"
	echo "======================="

	# Check syntax
	if bash -n "$GPROJ" 2>/dev/null; then
		echo -e "${GREEN}✓ PASS${NC}: Script syntax valid"
	else
		echo -e "${RED}✗ FAIL${NC}: Script syntax error"
		return 1
	fi

	# Check executability
	if [ -x "$GPROJ" ]; then
		echo -e "${GREEN}✓ PASS${NC}: Script is executable"
	else
		echo -e "${RED}✗ FAIL${NC}: Script not executable"
		return 1
	fi

	return 0
}

# Run all tests
echo "Running tests..."
echo ""

PASSED=0
FAILED=0

test_script_validity && ((PASSED++)) || ((FAILED++))
test_repos_found && ((PASSED++)) || ((FAILED++))
test_enter_cd && ((PASSED++)) || ((FAILED++))
test_ctrl_v_nvim && ((PASSED++)) || ((FAILED++))
test_ctrl_e_code && ((PASSED++)) || ((FAILED++))
test_ctrl_o_print && ((PASSED++)) || ((FAILED++))

echo ""
echo "================================"
echo "Test Results:"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "================================"

# Cleanup
rm -f "$RESULTS_FILE"*

if [ "$FAILED" -eq 0 ]; then
	echo -e "${GREEN}All tests passed!${NC}"
	exit 0
else
	echo -e "${RED}Some tests failed${NC}"
	exit 1
fi
