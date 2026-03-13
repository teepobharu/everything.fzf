#!/usr/bin/env bash
# Simple assertion-based test for gproj

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GPROJ="$SCRIPT_DIR/../gproj.fzf"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== gproj Simple Test Suite ==="
echo ""

PASSED=0
FAILED=0

# Test 1: Script exists
if [ -f "$GPROJ" ] && [ -x "$GPROJ" ]; then
  echo -e "${GREEN}✓${NC} Script exists and is executable"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} Script not found or not executable"
  ((FAILED++))
  exit 1
fi

# Test 2: Syntax valid
if bash -n "$GPROJ" 2>/dev/null; then
  echo -e "${GREEN}✓${NC} Bash syntax valid"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} Bash syntax error"
  ((FAILED++))
fi

# Test 3: Repos found
echo "Discovering repositories..."
REPO_COUNT=$(timeout 30 "$GPROJ" 2>/dev/null | wc -l | xargs)

if [ "$REPO_COUNT" -gt 0 ]; then
  echo -e "${GREEN}✓${NC} Found $REPO_COUNT repositories"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} No repositories found"
  ((FAILED++))
fi

# Test 4: Verify each repo is valid
echo "Validating repository paths..."
INVALID=0
while IFS= read -r repo || [ -n "$repo" ]; do
  [ -z "$repo" ] && continue
  if ! [ -d "$repo/.git" ]; then
    echo -e "${RED}✗${NC} Invalid repo: $repo"
    ((INVALID++))
  fi
done < <(timeout 30 "$GPROJ" 2>/dev/null)

if [ "$INVALID" -eq 0 ]; then
  echo -e "${GREEN}✓${NC} All repositories valid"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} $INVALID invalid repositories"
  ((FAILED++))
fi

# Test 5: Performance test
echo "Testing performance..."
rm -rf ~/.cache/gproj 2>/dev/null || true

# Mock fzf
export PATH="/tmp/gproj-mock:$PATH"
mkdir -p /tmp/gproj-mock
cat > /tmp/gproj-mock/fzf <<'MOCKFZF'
#!/bin/bash
head -1
MOCKFZF
chmod +x /tmp/gproj-mock/fzf

START=$(date +%s%N)
timeout 30 "$GPROJ" 2>/dev/null > /dev/null || true
END=$(date +%s%N)
TIME_MS=$(( (END - START) / 1000000 ))

if [ "$TIME_MS" -lt 3000 ]; then
  echo -e "${GREEN}✓${NC} Performance OK: ${TIME_MS}ms"
  ((PASSED++))
else
  echo -e "${RED}✗${NC} Too slow: ${TIME_MS}ms"
  ((FAILED++))
fi

rm -rf /tmp/gproj-mock

# Summary
echo ""
echo "================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "================================"

exit $FAILED
