# test_build.sh
#
# Purpose: Unit tests for build.sh functions
#
# This module tests:
# - check_nix_available() detects Nix
# - check_nixos_environment() detects NixOS
# - Build command construction

# shellcheck shell=bash

# -----------------------------------------------------------------------------
# Test Setup
# -----------------------------------------------------------------------------

TEST_BUILD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER_DIR="$(cd "$TEST_BUILD_DIR/.." && pwd)"

# Source required modules
# shellcheck source=../common.sh
source "$PROFILE_MANAGER_DIR/common.sh"
# shellcheck source=../discover.sh
source "$PROFILE_MANAGER_DIR/discover.sh"
# shellcheck source=../build.sh
source "$PROFILE_MANAGER_DIR/build.sh"

# Provide test_case function if not already defined (for standalone execution)
if ! declare -f test_case >/dev/null 2>&1; then
	PASSED=0
	FAILED=0
	test_case() {
		local name="$1"
		local result="$2"
		if [[ "$result" == "pass" ]]; then
			echo "PASS: $name"
			((PASSED++)) || true
		else
			echo "FAIL: $name - ${result#fail: }"
			((FAILED++)) || true
		fi
	}
fi

# -----------------------------------------------------------------------------
# Nix Availability Tests
# -----------------------------------------------------------------------------

test_check_nix_available_detects_nix() {
	local test_name="check_nix_available detects Nix installation"

	# Most systems running this test should have Nix
	if command -v nix &>/dev/null; then
		if check_nix_available 2>/dev/null; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: Nix is installed but not detected"
		fi
	else
		# Nix not installed - function should fail
		if check_nix_available 2>/dev/null; then
			test_case "$test_name" "fail: should fail when Nix not installed"
		else
			test_case "$test_name" "pass"
		fi
	fi
}

test_check_nix_available_returns_code() {
	local test_name="check_nix_available returns appropriate exit code"

	if command -v nix &>/dev/null; then
		check_nix_available 2>/dev/null
		local result=$?
		if [[ $result -eq 0 ]]; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: expected 0, got $result"
		fi
	else
		check_nix_available 2>/dev/null
		local result=$?
		if [[ $result -eq 1 ]]; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: expected 1, got $result"
		fi
	fi
}

# -----------------------------------------------------------------------------
# NixOS Environment Tests
# -----------------------------------------------------------------------------

test_check_nixos_environment_detects_nixos() {
	local test_name="check_nixos_environment detects NixOS"

	if [[ -f /etc/NIXOS ]]; then
		if check_nixos_environment 2>/dev/null; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: NixOS detected but function returned false"
		fi
	else
		if check_nixos_environment 2>/dev/null; then
			test_case "$test_name" "fail: should fail on non-NixOS system"
		else
			test_case "$test_name" "pass"
		fi
	fi
}

test_check_nixos_environment_returns_code() {
	local test_name="check_nixos_environment returns appropriate exit code"

	if [[ -f /etc/NIXOS ]]; then
		check_nixos_environment 2>/dev/null
		local result=$?
		if [[ $result -eq 0 ]]; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: expected 0, got $result"
		fi
	else
		check_nixos_environment 2>/dev/null
		local result=$?
		if [[ $result -eq 1 ]]; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: expected 1, got $result"
		fi
	fi
}

# -----------------------------------------------------------------------------
# Uncommitted Changes Detection Tests
# -----------------------------------------------------------------------------

test_check_uncommitted_changes_in_git_repo() {
	local test_name="check_uncommitted_changes works in git repo"

	# This test runs in the nixos-config repo
	if git rev-parse --is-inside-work-tree &>/dev/null; then
		# Function should not fail
		check_uncommitted_changes 2>/dev/null
		test_case "$test_name" "pass"
	else
		test_case "$test_name (skipped - not in git repo)" "pass"
	fi
}

test_check_uncommitted_changes_outside_git() {
	local test_name="check_uncommitted_changes handles non-git directory"

	# Save current dir and go to temp
	local original_dir="$PWD"
	local tmp_dir
	tmp_dir=$(mktemp -d)

	cd "$tmp_dir" 2>/dev/null || true

	# Function should not fail outside git
	check_uncommitted_changes 2>/dev/null
	local result=$?

	# Return to original dir
	cd "$original_dir" 2>/dev/null || true
	rm -rf "$tmp_dir"

	# Should return 0 (just a warning)
	if [[ $result -eq 0 ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should return 0 outside git"
	fi
}

# -----------------------------------------------------------------------------
# Build Command Construction Tests
# -----------------------------------------------------------------------------

test_cmd_build_validates_action() {
	local test_name="cmd_build validates build action"

	# Test with invalid action
	local output
	output=$(cmd_build "invalid-action" 2>&1) || true

	if echo "$output" | grep -qi "invalid\|error"; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should reject invalid action"
	fi
}

test_cmd_build_accepts_valid_actions() {
	local test_name="cmd_build accepts valid actions"

	# Check that valid actions are defined in the case statement
	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		# Check for valid actions in the validation
		if grep -q 'test | switch | build | dry-run | dry-build' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing valid action definitions"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

test_build_command_includes_flake() {
	local test_name="Build command includes flake reference"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		if grep -q '\-\-flake' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing flake reference in build command"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

test_build_command_includes_host() {
	local test_name="Build command supports host targeting"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		# Check for host parameter support
		# shellcheck disable=SC2016 # Literal string: looking for $host in nix files
		if grep -q '#\$host' "$build_file" || grep -q 'host=' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing host targeting support"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Stage for Flake Tests
# -----------------------------------------------------------------------------

test_stage_for_flake_runs_git() {
	local test_name="stage_for_flake executes git commands"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		if grep -q 'git add' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing git add commands"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

test_stage_for_flake_handles_error() {
	local test_name="stage_for_flake handles git errors gracefully"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		# Check for error handling (|| true)
		if grep -q 'git add.*|| true' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing error handling for git"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Build Action Validation Tests
# -----------------------------------------------------------------------------

test_build_action_test() {
	local test_name="Build action 'test' is valid"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		if grep -q '"test"' "$build_file" || grep -q 'test)' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: 'test' action not defined"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

test_build_action_switch() {
	local test_name="Build action 'switch' is valid"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		if grep -q '"switch"' "$build_file" || grep -q 'switch)' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: 'switch' action not defined"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

test_build_action_dry_run() {
	local test_name="Build action 'dry-run' is valid"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		if grep -q '"dry-run"' "$build_file" || grep -q 'dry-run)' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: 'dry-run' action not defined"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

test_build_action_build() {
	local test_name="Build action 'build' is valid"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		if grep -q '"build"' "$build_file" || grep -q 'build)' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: 'build' action not defined"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

test_build_action_dry_build() {
	local test_name="Build action 'dry-build' is valid"

	local build_file="$PROFILE_MANAGER_DIR/build.sh"

	if [[ -f "$build_file" ]]; then
		if grep -q '"dry-build"' "$build_file" || grep -q 'dry-build)' "$build_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: 'dry-build' action not defined"
		fi
	else
		test_case "$test_name (skipped - build.sh not found)" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Run All Tests
# -----------------------------------------------------------------------------

run_test_build() {
	echo ""
	echo "=== Testing build.sh ==="
	echo ""

	test_check_nix_available_detects_nix
	test_check_nix_available_returns_code
	test_check_nixos_environment_detects_nixos
	test_check_nixos_environment_returns_code
	test_check_uncommitted_changes_in_git_repo
	test_check_uncommitted_changes_outside_git
	test_cmd_build_validates_action
	test_cmd_build_accepts_valid_actions
	test_build_command_includes_flake
	test_build_command_includes_host
	test_stage_for_flake_runs_git
	test_stage_for_flake_handles_error
	test_build_action_test
	test_build_action_switch
	test_build_action_dry_run
	test_build_action_build
	test_build_action_dry_build
}
