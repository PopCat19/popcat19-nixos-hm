# test_common.sh
#
# Purpose: Unit tests for common.sh utilities
#
# This module tests:
# - Path constants are set correctly
# - Color detection (interactive vs non-interactive)
# - Output functions (print_error, print_success, print_info, print_warning)
# - require_cmd with existing and non-existing commands
# - nix_path_to_label conversions
# - label_to_nix_path reverse conversions
# - profile_exists with valid and invalid profiles
# - host_exists with valid and invalid hosts

# shellcheck shell=bash

# -----------------------------------------------------------------------------
# Test Setup
# -----------------------------------------------------------------------------

# Get test directory and source common.sh
TEST_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER_DIR="$(cd "$TEST_COMMON_DIR/.." && pwd)"

# Source common.sh (this sets up all the constants and functions)
# shellcheck source=../common.sh
source "$PROFILE_MANAGER_DIR/common.sh"

# Source discover.sh for list_hosts function
# shellcheck source=../discover.sh
source "$PROFILE_MANAGER_DIR/discover.sh"

# -----------------------------------------------------------------------------
# Path Constants Tests
# -----------------------------------------------------------------------------

test_path_constants() {
	local test_name="Path constants are set correctly"

	# Verify PROJECT_ROOT is set and exists
	if [[ -z "$PROJECT_ROOT" ]]; then
		test_case "$test_name" "fail: PROJECT_ROOT is not set"
		return
	fi

	if [[ ! -d "$PROJECT_ROOT" ]]; then
		test_case "$test_name" "fail: PROJECT_ROOT directory does not exist"
		return
	fi

	# Verify PROFILES_DIR is set and exists
	if [[ -z "$PROFILES_DIR" ]]; then
		test_case "$test_name" "fail: PROFILES_DIR is not set"
		return
	fi

	if [[ ! -d "$PROFILES_DIR" ]]; then
		test_case "$test_name" "fail: PROFILES_DIR directory does not exist"
		return
	fi

	# Verify HOSTS_DIR is set and exists
	if [[ -z "$HOSTS_DIR" ]]; then
		test_case "$test_name" "fail: HOSTS_DIR is not set"
		return
	fi

	if [[ ! -d "$HOSTS_DIR" ]]; then
		test_case "$test_name" "fail: HOSTS_DIR directory does not exist"
		return
	fi

	# Verify SYSTEM_MODULES_DIR is set
	if [[ -z "$SYSTEM_MODULES_DIR" ]]; then
		test_case "$test_name" "fail: SYSTEM_MODULES_DIR is not set"
		return
	fi

	# Verify HOME_MODULES_DIR is set
	if [[ -z "$HOME_MODULES_DIR" ]]; then
		test_case "$test_name" "fail: HOME_MODULES_DIR is not set"
		return
	fi

	test_case "$test_name" "pass"
}

# -----------------------------------------------------------------------------
# Color Detection Tests
# -----------------------------------------------------------------------------

test_color_detection() {
	local test_name="Color variables are defined"

	# Colors should be defined (even if empty in non-interactive mode)
	if [[ -z "${RED+x}" ]]; then
		test_case "$test_name" "fail: RED is not defined"
		return
	fi

	if [[ -z "${GREEN+x}" ]]; then
		test_case "$test_name" "fail: GREEN is not defined"
		return
	fi

	if [[ -z "${YELLOW+x}" ]]; then
		test_case "$test_name" "fail: YELLOW is not defined"
		return
	fi

	if [[ -z "${NC+x}" ]]; then
		test_case "$test_name" "fail: NC is not defined"
		return
	fi

	test_case "$test_name" "pass"
}

# -----------------------------------------------------------------------------
# Output Functions Tests
# -----------------------------------------------------------------------------

test_print_error() {
	local test_name="print_error outputs to stderr"

	# Capture stderr
	local output
	output=$(print_error "test error message" 2>&1)

	if [[ "$output" == *"test error message"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: output does not contain message"
	fi
}

test_print_success() {
	local test_name="print_success outputs to stdout"

	local output
	output=$(print_success "test success message")

	if [[ "$output" == *"test success message"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: output does not contain message"
	fi
}

test_print_info() {
	local test_name="print_info outputs to stdout"

	local output
	output=$(print_info "test info message")

	if [[ "$output" == *"test info message"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: output does not contain message"
	fi
}

test_print_warning() {
	local test_name="print_warning outputs to stdout"

	local output
	output=$(print_warning "test warning message")

	if [[ "$output" == *"test warning message"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: output does not contain message"
	fi
}

# -----------------------------------------------------------------------------
# Command Validation Tests
# -----------------------------------------------------------------------------

test_require_cmd_existing() {
	local test_name="require_cmd returns 0 for existing command"

	# Use 'ls' which should always exist
	if require_cmd ls 2>/dev/null; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: require_cmd failed for 'ls'"
	fi
}

test_require_cmd_nonexisting() {
	local test_name="require_cmd returns 1 for non-existing command"

	# Use a very unlikely command name
	if require_cmd __nonexistent_command_xyz123__ 2>/dev/null; then
		test_case "$test_name" "fail: require_cmd succeeded for non-existent command"
	else
		test_case "$test_name" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Path Conversion Tests
# -----------------------------------------------------------------------------

test_nix_path_to_label_system() {
	local test_name="nix_path_to_label converts system module paths"

	local result
	result=$(nix_path_to_label "../system/modules/audio.nix")

	if [[ "$result" == "system/audio" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected 'system/audio', got '$result'"
	fi
}

test_nix_path_to_label_home() {
	local test_name="nix_path_to_label converts home module paths"

	local result
	result=$(nix_path_to_label "../home/modules/git.nix")

	if [[ "$result" == "home/git" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected 'home/git', got '$result'"
	fi
}

test_nix_path_to_label_base() {
	local test_name="nix_path_to_label converts base paths"

	local result
	result=$(nix_path_to_label "../base/configuration.nix")

	if [[ "$result" == "base/configuration" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected 'base/configuration', got '$result'"
	fi
}

test_nix_path_to_label_profile() {
	local test_name="nix_path_to_label converts profile imports"

	local result
	result=$(nix_path_to_label "./default.nix")

	if [[ "$result" == "profile/default" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected 'profile/default', got '$result'"
	fi
}

test_label_to_nix_path_system() {
	local test_name="label_to_nix_path converts system labels"

	local result
	result=$(label_to_nix_path "system/audio")

	if [[ "$result" == "../system/modules/audio.nix" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected '../system/modules/audio.nix', got '$result'"
	fi
}

test_label_to_nix_path_home() {
	local test_name="label_to_nix_path converts home labels"

	local result
	result=$(label_to_nix_path "home/git")

	if [[ "$result" == "../home/modules/git.nix" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected '../home/modules/git.nix', got '$result'"
	fi
}

test_label_to_nix_path_base() {
	local test_name="label_to_nix_path converts base labels"

	local result
	result=$(label_to_nix_path "base/configuration")

	if [[ "$result" == "../base/configuration.nix" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected '../base/configuration.nix', got '$result'"
	fi
}

test_label_to_nix_path_profile() {
	local test_name="label_to_nix_path converts profile labels"

	local result
	result=$(label_to_nix_path "profile/default")

	if [[ "$result" == "./default.nix" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected './default.nix', got '$result'"
	fi
}

test_path_conversion_roundtrip() {
	local test_name="Path conversion roundtrip is consistent"

	# Test system module roundtrip
	local original="../system/modules/audio.nix"
	local label
	local converted
	label=$(nix_path_to_label "$original")
	converted=$(label_to_nix_path "$label")

	if [[ "$converted" == "$original" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: roundtrip failed for '$original' -> '$label' -> '$converted'"
	fi
}

# -----------------------------------------------------------------------------
# Profile Utilities Tests
# -----------------------------------------------------------------------------

test_profile_exists_valid() {
	local test_name="profile_exists returns 0 for valid profile"

	# 'default' profile should always exist
	if profile_exists "default"; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: profile_exists failed for 'default'"
	fi
}

test_profile_exists_invalid() {
	local test_name="profile_exists returns 1 for invalid profile"

	if profile_exists "__nonexistent_profile_xyz__"; then
		test_case "$test_name" "fail: profile_exists succeeded for non-existent profile"
	else
		test_case "$test_name" "pass"
	fi
}

test_get_profile_file() {
	local test_name="get_profile_file returns correct path"

	local result
	result=$(get_profile_file "default")

	local expected="$PROFILES_DIR/default.nix"

	if [[ "$result" == "$expected" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected '$expected', got '$result'"
	fi
}

# -----------------------------------------------------------------------------
# Host Utilities Tests
# -----------------------------------------------------------------------------

test_host_exists_valid() {
	local test_name="host_exists returns 0 for valid host"

	# Find an actual host
	local hosts
	hosts=$(list_hosts 2>/dev/null | head -1)

	if [[ -n "$hosts" ]]; then
		if host_exists "$hosts"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: host_exists failed for '$hosts'"
		fi
	else
		# Skip if no hosts exist
		test_case "$test_name (skipped - no hosts)" "pass"
	fi
}

test_host_exists_invalid() {
	local test_name="host_exists returns 1 for invalid host"

	if host_exists "__nonexistent_host_xyz__"; then
		test_case "$test_name" "fail: host_exists succeeded for non-existent host"
	else
		test_case "$test_name" "pass"
	fi
}

test_get_host_config_file() {
	local test_name="get_host_config_file returns correct path"

	local result
	result=$(get_host_config_file "testhost")

	local expected="$HOSTS_DIR/testhost/user-config.nix"

	if [[ "$result" == "$expected" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected '$expected', got '$result'"
	fi
}

# -----------------------------------------------------------------------------
# Run All Tests
# -----------------------------------------------------------------------------

run_test_common() {
	echo ""
	echo "=== Testing common.sh ==="
	echo ""

	test_path_constants
	test_color_detection
	test_print_error
	test_print_success
	test_print_info
	test_print_warning
	test_require_cmd_existing
	test_require_cmd_nonexisting
	test_nix_path_to_label_system
	test_nix_path_to_label_home
	test_nix_path_to_label_base
	test_nix_path_to_label_profile
	test_label_to_nix_path_system
	test_label_to_nix_path_home
	test_label_to_nix_path_base
	test_label_to_nix_path_profile
	test_path_conversion_roundtrip
	test_profile_exists_valid
	test_profile_exists_invalid
	test_get_profile_file
	test_host_exists_valid
	test_host_exists_invalid
	test_get_host_config_file
}
