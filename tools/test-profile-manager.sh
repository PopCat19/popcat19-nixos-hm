#!/usr/bin/env bash
# test-profile-manager.sh
#
# Purpose: Test runner wrapper for profile manager tests
#
# This script:
# - Runs the new modular test suite
# - Provides backward compatibility with existing CI
# - Falls back to basic CLI tests if module tests fail
#
# Usage:
#   ./tools/test-profile-manager.sh           # Run all tests
#   ./tools/test-profile-manager.sh cli       # Run CLI tests only
#   ./tools/test-profile-manager.sh modules   # Run module tests only

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROFILE_MANAGER="$PROJECT_ROOT/tools/profile-manager.sh"
TEST_RUNNER="$PROJECT_ROOT/tools/profile-manager/tests/runner.sh"

# Colors (disabled for non-interactive use)
if [[ -t 1 ]]; then
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	BLUE='\033[0;34m'
	NC='\033[0m'
else
	RED=''
	GREEN=''
	BLUE=''
	NC=''
fi

# -----------------------------------------------------------------------------
# CLI Integration Tests
# -----------------------------------------------------------------------------

run_cli_tests() {
	echo -e "${BLUE}=== CLI Integration Tests ===${NC}"
	echo ""

	local tests_passed=0
	local tests_failed=0

	pass() {
		echo -e "${GREEN}PASS${NC}: $1"
		((tests_passed++)) || true
	}

	fail() {
		echo -e "${RED}FAIL${NC}: $1"
		((tests_failed++)) || true
	}

	# Test 1: List profiles
	echo -n "Test: list command... "
	if "$PROFILE_MANAGER" list >/dev/null 2>&1; then
		pass "list command executes successfully"
	else
		fail "list command failed"
	fi

	# Test 2: Show profile (default should exist)
	echo -n "Test: show command with valid profile... "
	if "$PROFILE_MANAGER" show default >/dev/null 2>&1; then
		pass "show command for 'default' profile"
	else
		fail "show command for 'default' profile"
	fi

	# Test 3: Get host profile (use actual host name)
	echo -n "Test: get-host command with valid host... "
	local first_host
	first_host=$("$PROFILE_MANAGER" hosts 2>/dev/null | grep -E '^\s*-' | head -1 | sed 's/.*- //') || true
	if [[ -n "$first_host" ]]; then
		if "$PROFILE_MANAGER" get-host "$first_host" >/dev/null 2>&1; then
			pass "get-host command for '$first_host'"
		else
			fail "get-host command for '$first_host'"
		fi
	else
		pass "get-host command (skipped - no hosts)"
	fi

	# Test 4: Invalid profile error handling
	echo -n "Test: show command with invalid profile... "
	local output
	output=$("$PROFILE_MANAGER" show nonexistent 2>&1 || true)
	if echo "$output" | grep -q "Error"; then
		pass "error handling for nonexistent profile"
	else
		fail "error handling for nonexistent profile"
	fi

	# Test 5: Invalid host error handling
	echo -n "Test: get-host command with invalid host... "
	output=$("$PROFILE_MANAGER" get-host nonexistent 2>&1 || true)
	if echo "$output" | grep -q "Error"; then
		pass "error handling for nonexistent host"
	else
		fail "error handling for nonexistent host"
	fi

	# Test 6: Help command
	echo -n "Test: help command... "
	if "$PROFILE_MANAGER" help >/dev/null 2>&1; then
		pass "help command executes successfully"
	else
		fail "help command failed"
	fi

	# Test 7: Invalid command error handling
	echo -n "Test: invalid command error handling... "
	output=$("$PROFILE_MANAGER" invalidcmd 2>&1 || true)
	if echo "$output" | grep -q "Error"; then
		pass "error handling for invalid command"
	else
		fail "error handling for invalid command"
	fi

	# Test 8: Error messages include suggestions
	echo -n "Test: error messages include suggestions... "
	output=$("$PROFILE_MANAGER" show nonexistent 2>&1 || true)
	if echo "$output" | grep -q "Run"; then
		pass "error messages include actionable suggestions"
	else
		fail "error messages missing suggestions"
	fi

	# Summary
	echo ""
	echo -e "${BLUE}CLI Test Summary:${NC}"
	echo -e "  ${GREEN}Passed:${NC} $tests_passed"
	echo -e "  ${RED}Failed:${NC} $tests_failed"

	if [[ $tests_failed -gt 0 ]]; then
		return 1
	fi
	return 0
}

# -----------------------------------------------------------------------------
# Module Unit Tests
# -----------------------------------------------------------------------------

run_module_tests() {
	if [[ -f "$TEST_RUNNER" ]]; then
		echo -e "${BLUE}=== Module Unit Tests ===${NC}"
		echo ""
		"$TEST_RUNNER"
		return $?
	else
		echo -e "${RED}Error:${NC} Test runner not found: $TEST_RUNNER"
		return 1
	fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
	local mode="${1:-all}"
	local overall_failed=0

	echo ""
	echo -e "${BLUE}========================================${NC}"
	echo -e "${BLUE}   Profile Manager Test Suite${NC}"
	echo -e "${BLUE}========================================${NC}"
	echo ""

	case "$mode" in
	cli)
		run_cli_tests || overall_failed=1
		;;
	modules)
		run_module_tests || overall_failed=1
		;;
	all | *)
		run_cli_tests || overall_failed=1
		echo ""
		run_module_tests || overall_failed=1
		;;
	esac

	echo ""
	if [[ $overall_failed -eq 0 ]]; then
		echo -e "${GREEN}All tests passed!${NC}"
		exit 0
	else
		echo -e "${RED}Some tests failed!${NC}"
		exit 1
	fi
}

main "$@"
