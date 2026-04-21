#!/usr/bin/env bash
# runner.sh
#
# Purpose: Test runner for profile manager modules
#
# This script:
# - Sources all test files
# - Runs tests in sequence
# - Reports pass/fail with colors
# - Exits with appropriate code
#
# Usage:
#   ./runner.sh              # Run all tests
#   ./runner.sh common       # Run only common.sh tests
#   ./runner.sh discover     # Run only discover.sh tests
#   ./runner.sh edit         # Run only edit.sh tests
#   ./runner.sh host         # Run only host.sh tests
#   ./runner.sh build        # Run only build.sh tests

set -Ee

# Disable pipefail to avoid SIGPIPE issues
set +o pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

# Use TESTS_DIR instead of SCRIPT_DIR to avoid conflicts with sourced modules
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC2034 # Used by test files that source this runner
PROFILE_MANAGER_DIR="$(cd "$TESTS_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PROFILE_MANAGER_DIR/../.." && pwd)"

# -----------------------------------------------------------------------------
# Color Definitions
# -----------------------------------------------------------------------------

# Detect non-interactive mode and disable colors accordingly
if [[ -t 1 ]]; then
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[0;33m'
	BLUE='\033[0;34m'
	NC='\033[0m' # No Color
else
	RED=''
	GREEN=''
	# shellcheck disable=SC2034 # Color defined for consistency, may be used in future
	YELLOW=''
	BLUE=''
	NC=''
fi

# -----------------------------------------------------------------------------
# Test Counters
# -----------------------------------------------------------------------------

PASSED=0
FAILED=0

# -----------------------------------------------------------------------------
# Test Case Reporter
# -----------------------------------------------------------------------------

# shellcheck disable=SC2329 # Function is exported and called from test files
test_case() {
	# Report test case result
	# Args: $1 - test name
	#       $2 - result ("pass" or "fail: reason")
	local name="$1"
	local result="$2"

	if [[ "$result" == "pass" ]]; then
		echo -e "${GREEN}PASS${NC}: $name"
		((PASSED++)) || true
	else
		echo -e "${RED}FAIL${NC}: $name - ${result#fail: }"
		((FAILED++)) || true
	fi
}

# Export test_case function for use in test files
export -f test_case

# -----------------------------------------------------------------------------
# Test File Loader
# -----------------------------------------------------------------------------

run_test_file() {
	# Source and run a test file
	# Args: $1 - test file path
	#       $2 - run function name
	local test_file="$1"
	local run_func="$2"

	if [[ -f "$test_file" ]]; then
		# shellcheck source=/dev/null
		source "$test_file"
		"$run_func"
	else
		echo -e "${RED}Error:${NC} Test file not found: $test_file"
		((FAILED++)) || true
	fi
}

# -----------------------------------------------------------------------------
# Main Test Runner
# -----------------------------------------------------------------------------

run_all_tests() {
	echo ""
	echo -e "${BLUE}========================================${NC}"
	echo -e "${BLUE}   Profile Manager Test Suite${NC}"
	echo -e "${BLUE}========================================${NC}"

	# Run common.sh tests
	run_test_file "$TESTS_DIR/test-common.sh" run_test_common

	# Run discover.sh tests
	run_test_file "$TESTS_DIR/test-discover.sh" run_test_discover

	# Run edit.sh tests
	run_test_file "$TESTS_DIR/test-edit.sh" run_test_edit

	# Run host.sh tests
	run_test_file "$TESTS_DIR/test-host.sh" run_test_host

	# Run build.sh tests
	run_test_file "$TESTS_DIR/test-build.sh" run_test_build

	# Print summary
	print_summary
}

run_specific_tests() {
	local module="$1"

	echo ""
	echo -e "${BLUE}========================================${NC}"
	echo -e "${BLUE}   Profile Manager Test Suite${NC}"
	echo -e "${BLUE}   Module: $module${NC}"
	echo -e "${BLUE}========================================${NC}"

	case "$module" in
	common)
		run_test_file "$TESTS_DIR/test-common.sh" run_test_common
		;;
	discover)
		run_test_file "$TESTS_DIR/test-discover.sh" run_test_discover
		;;
	edit)
		run_test_file "$TESTS_DIR/test-edit.sh" run_test_edit
		;;
	host)
		run_test_file "$TESTS_DIR/test-host.sh" run_test_host
		;;
	build)
		run_test_file "$TESTS_DIR/test-build.sh" run_test_build
		;;
	*)
		echo -e "${RED}Error:${NC} Unknown test module: $module"
		echo "Valid modules: common, discover, edit, host, build"
		exit 1
		;;
	esac

	# Print summary
	print_summary
}

print_summary() {
	echo ""
	echo -e "${BLUE}========================================${NC}"
	echo -e "${BLUE}   Test Summary${NC}"
	echo -e "${BLUE}========================================${NC}"
	echo ""
	echo -e "  ${GREEN}Passed:${NC} $PASSED"
	echo -e "  ${RED}Failed:${NC} $FAILED"
	echo ""

	if [[ $FAILED -gt 0 ]]; then
		echo -e "${RED}Some tests failed!${NC}"
		exit 1
	else
		echo -e "${GREEN}All tests passed!${NC}"
		exit 0
	fi
}

# -----------------------------------------------------------------------------
# Entry Point
# -----------------------------------------------------------------------------

main() {
	local module="${1:-all}"

	if [[ "$module" == "all" ]]; then
		run_all_tests
	else
		run_specific_tests "$module"
	fi
}

main "$@"
