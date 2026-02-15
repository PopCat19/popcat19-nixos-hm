#!/usr/bin/env bash
# test-profile-manager.sh
#
# Purpose: Non-interactive tests for profile-manager.sh
#
# This script:
# - Validates list, show, get-host commands
# - Tests error handling for invalid inputs
# - Provides pass/fail output for CI integration
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER="$SCRIPT_DIR/profile-manager.sh"

# Colors (disabled for non-interactive use)
if [[ -t 1 ]]; then
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	NC='\033[0m'
else
	RED=''
	GREEN=''
	NC=''
fi

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

pass() {
	echo -e "${GREEN}PASS${NC}: $1"
	((TESTS_PASSED++)) || true
}

fail() {
	echo -e "${RED}FAIL${NC}: $1"
	((TESTS_FAILED++)) || true
}

echo "=== Profile Manager Tests ==="
echo ""

# Test 1: List profiles
echo -n "Test 1: list command... "
if "$PROFILE_MANAGER" list >/dev/null 2>&1; then
	pass "list command executes successfully"
else
	fail "list command failed"
fi

# Test 2: Show profile (default should exist)
echo -n "Test 2: show command with valid profile... "
if "$PROFILE_MANAGER" show default >/dev/null 2>&1; then
	pass "show command for 'default' profile"
else
	fail "show command for 'default' profile"
fi

# Test 3: Get host profile (use actual host name)
echo -n "Test 3: get-host command with valid host... "
if "$PROFILE_MANAGER" get-host popcat19-nixos0 >/dev/null 2>&1; then
	pass "get-host command for 'popcat19-nixos0'"
else
	fail "get-host command for 'popcat19-nixos0'"
fi

# Test 4: Invalid profile error handling
echo -n "Test 4: show command with invalid profile... "
output=$("$PROFILE_MANAGER" show nonexistent 2>&1 || true)
if echo "$output" | grep -q "Error"; then
	pass "error handling for nonexistent profile"
else
	fail "error handling for nonexistent profile"
fi

# Test 5: Invalid host error handling
echo -n "Test 5: get-host command with invalid host... "
output=$("$PROFILE_MANAGER" get-host nonexistent 2>&1 || true)
if echo "$output" | grep -q "Error"; then
	pass "error handling for nonexistent host"
else
	fail "error handling for nonexistent host"
fi

# Test 6: Help command
echo -n "Test 6: help command... "
if "$PROFILE_MANAGER" help >/dev/null 2>&1; then
	pass "help command executes successfully"
else
	fail "help command failed"
fi

# Test 7: Invalid command error handling
echo -n "Test 7: invalid command error handling... "
output=$("$PROFILE_MANAGER" invalidcmd 2>&1 || true)
if echo "$output" | grep -q "Error"; then
	pass "error handling for invalid command"
else
	fail "error handling for invalid command"
fi

# Summary
echo ""
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
	echo ""
	echo -e "${RED}Some tests failed!${NC}"
	exit 1
else
	echo ""
	echo -e "${GREEN}All tests passed!${NC}"
	exit 0
fi
