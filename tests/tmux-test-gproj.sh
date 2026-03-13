#!/usr/bin/env bash
# Interactive test helper for gproj in tmux
# This script helps set up a tmux session for testing gproj interactively

set -euo pipefail

SESSION_NAME="gproj-test-$$"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== gproj tmux Interactive Test Helper ==="
echo ""

# Check if already in tmux
if [ -n "${TMUX:-}" ]; then
	echo "⚠️  You're already in a tmux session!"
	echo "Please run this script from outside tmux."
	echo ""
	echo "To exit current tmux session: Ctrl-b d (detach) or 'exit'"
	exit 1
fi

# Check tmux is installed
if ! command -v tmux >/dev/null 2>&1; then
	echo "❌ tmux is not installed!"
	echo "Install with: brew install tmux"
	exit 1
fi

echo "Creating new tmux session: $SESSION_NAME"
echo ""
echo "Test Instructions:"
echo "=================="
echo ""
echo "1. Basic test - ENTER key (cd to repo)"
echo "   - Run: gproj"
echo "   - Press ENTER on any repo"
echo "   - Run: pwd"
echo "   - Expected: You should be in the selected repo directory"
echo ""
echo "2. Test CTRL-V (cd + open nvim)"
echo "   - Run: gproj"
echo "   - Press CTRL-V on any repo"
echo "   - Expected: nvim opens in that directory"
echo "   - Exit nvim with :q"
echo "   - Run: pwd"
echo "   - Expected: Still in the selected repo directory"
echo ""
echo "3. Test CTRL-E (cd + open VSCode)"
echo "   - Run: gproj"
echo "   - Press CTRL-E on any repo"
echo "   - Expected: VSCode opens in that directory"
echo "   - Close VSCode"
echo "   - Run: pwd"
echo "   - Expected: Still in the selected repo directory"
echo ""
echo "4. Test CTRL-O (print path only)"
echo "   - Run: SELECTED=\$(gproj)"
echo "   - Press CTRL-O on any repo"
echo "   - Run: echo \$SELECTED"
echo "   - Expected: Path is stored but pwd hasn't changed"
echo ""
echo "5. Test with debug mode"
echo "   - Run: GPROJ_DEBUG=1 gproj"
echo "   - Expected: See timing info before fzf opens"
echo ""
echo "6. Test cache"
echo "   - Run: time gproj  # First run"
echo "   - ESC to exit"
echo "   - Run: time gproj  # Second run (should be faster)"
echo ""
echo "7. To exit this test session: Ctrl-b d (detach) or 'exit'"
echo ""
echo "Press ENTER to start tmux test session..."
read -r

# Create tmux session with helpful setup
tmux new-session -s "$SESSION_NAME" -d
tmux send-keys -t "$SESSION_NAME" "cd $SCRIPT_DIR/../.." Enter
tmux send-keys -t "$SESSION_NAME" "clear" Enter
tmux send-keys -t "$SESSION_NAME" "echo '=== gproj Interactive Test Session ==='" Enter
tmux send-keys -t "$SESSION_NAME" "echo 'Run: gproj'" Enter
tmux send-keys -t "$SESSION_NAME" "echo 'Keys: ENTER=cd | CTRL-V=nvim | CTRL-E=code | CTRL-O=print | ESC=cancel'" Enter
tmux send-keys -t "$SESSION_NAME" "echo ''" Enter
tmux send-keys -t "$SESSION_NAME" "echo 'Current directory:'" Enter
tmux send-keys -t "$SESSION_NAME" "pwd" Enter
tmux send-keys -t "$SESSION_NAME" "echo ''" Enter

# Attach to session
tmux attach-session -t "$SESSION_NAME"

# Cleanup after detach
echo ""
echo "Test session detached."
echo "To reattach: tmux attach -t $SESSION_NAME"
echo "To kill session: tmux kill-session -t $SESSION_NAME"
