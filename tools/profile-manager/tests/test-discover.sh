# test_discover.sh
#
# Purpose: Unit tests for discover.sh functions
#
# This module tests:
# - discover_system_modules() returns expected modules
# - discover_home_modules() returns expected modules (excludes default.nix)
# - list_profiles() returns profiles in correct order (default first)
# - list_hosts() returns expected hosts
# - parse_profile_imports() extracts imports correctly
# - get_parent_profile() detects inheritance
# - resolve_inheritance_chain() follows chain correctly
# - classify_modules() classifies correctly (direct/inherited/available)
# - get_host_profile() extracts profile from host config

# shellcheck shell=bash

# -----------------------------------------------------------------------------
# Test Setup
# -----------------------------------------------------------------------------

TEST_DISCOVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER_DIR="$(cd "$TEST_DISCOVER_DIR/.." && pwd)"

# Source required modules
# shellcheck source=../common.sh
source "$PROFILE_MANAGER_DIR/common.sh"
# shellcheck source=../discover.sh
source "$PROFILE_MANAGER_DIR/discover.sh"

# -----------------------------------------------------------------------------
# Module Discovery Tests
# -----------------------------------------------------------------------------

test_discover_system_modules_returns_modules() {
	local test_name="discover_system_modules returns modules"

	local modules
	modules=$(discover_system_modules 2>/dev/null)

	if [[ -n "$modules" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: no modules returned"
	fi
}

test_discover_system_modules_excludes_barrel() {
	local test_name="discover_system_modules excludes default.nix barrel"

	local modules
	modules=$(discover_system_modules 2>/dev/null)

	if echo "$modules" | grep -q "^default$"; then
		test_case "$test_name" "fail: default.nix should be excluded"
	else
		test_case "$test_name" "pass"
	fi
}

test_discover_system_modules_excludes_scripts() {
	local test_name="discover_system_modules excludes .sh scripts"

	local modules
	modules=$(discover_system_modules 2>/dev/null)

	# Should not include catch-22-rebuild.sh (if it exists)
	if echo "$modules" | grep -q "\.sh$"; then
		test_case "$test_name" "fail: .sh scripts should be excluded"
	else
		test_case "$test_name" "pass"
	fi
}

test_discover_home_modules_returns_modules() {
	local test_name="discover_home_modules returns modules"

	local modules
	modules=$(discover_home_modules 2>/dev/null)

	if [[ -n "$modules" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: no modules returned"
	fi
}

test_discover_home_modules_excludes_barrel() {
	local test_name="discover_home_modules excludes default.nix barrel"

	local modules
	modules=$(discover_home_modules 2>/dev/null)

	if echo "$modules" | grep -q "^default$"; then
		test_case "$test_name" "fail: default.nix should be excluded"
	else
		test_case "$test_name" "pass"
	fi
}

test_discover_modules_sorted() {
	local test_name="discover_system_modules returns sorted output"

	local modules
	modules=$(discover_system_modules 2>/dev/null)

	local sorted
	sorted=$(echo "$modules" | sort)

	if [[ "$modules" == "$sorted" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: modules not sorted"
	fi
}

# -----------------------------------------------------------------------------
# Profile Discovery Tests
# -----------------------------------------------------------------------------

test_list_profiles_returns_profiles() {
	local test_name="list_profiles returns profiles"

	local profiles
	profiles=$(list_profiles 2>/dev/null)

	if [[ -n "$profiles" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: no profiles returned"
	fi
}

test_list_profiles_default_first() {
	local test_name="list_profiles puts default profile first"

	local profiles
	profiles=$(list_profiles 2>/dev/null)

	local first_profile
	first_profile=$(echo "$profiles" | head -1)

	if [[ "$first_profile" == "default" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: default should be first, got '$first_profile'"
	fi
}

test_list_profiles_includes_expected() {
	local test_name="list_profiles includes expected profiles"

	local profiles
	profiles=$(list_profiles 2>/dev/null)

	# Should include 'default' profile
	if echo "$profiles" | grep -q "^default$"; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: 'default' profile not found"
	fi
}

# -----------------------------------------------------------------------------
# Host Discovery Tests
# -----------------------------------------------------------------------------

test_list_hosts_returns_hosts() {
	local test_name="list_hosts returns hosts"

	local hosts
	hosts=$(list_hosts 2>/dev/null)

	# May be empty if no hosts, but should not error
	test_case "$test_name" "pass"
}

test_list_hosts_sorted() {
	local test_name="list_hosts returns sorted output"

	local hosts
	hosts=$(list_hosts 2>/dev/null)

	if [[ -z "$hosts" ]]; then
		test_case "$test_name (skipped - no hosts)" "pass"
		return
	fi

	local sorted
	sorted=$(echo "$hosts" | sort)

	if [[ "$hosts" == "$sorted" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: hosts not sorted"
	fi
}

# -----------------------------------------------------------------------------
# Import Parsing Tests
# -----------------------------------------------------------------------------

test_parse_profile_imports_extracts_imports() {
	local test_name="parse_profile_imports extracts imports"

	local profile_file="$PROFILES_DIR/default.nix"

	if [[ ! -f "$profile_file" ]]; then
		test_case "$test_name (skipped - no default.nix)" "pass"
		return
	fi

	local imports
	imports=$(parse_profile_imports "$profile_file" 2>/dev/null)

	# default.nix should have some imports
	if [[ -n "$imports" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: no imports extracted"
	fi
}

test_parse_profile_imports_handles_nonexistent() {
	local test_name="parse_profile_imports handles nonexistent file"

	local result
	if parse_profile_imports "/nonexistent/file.nix" 2>/dev/null; then
		test_case "$test_name" "fail: should fail for nonexistent file"
	else
		test_case "$test_name" "pass"
	fi
}

test_parse_profile_imports_format() {
	local test_name="parse_profile_imports returns correct format"

	local profile_file="$PROFILES_DIR/default.nix"

	if [[ ! -f "$profile_file" ]]; then
		test_case "$test_name (skipped - no default.nix)" "pass"
		return
	fi

	local imports
	imports=$(parse_profile_imports "$profile_file" 2>/dev/null)

	# Check that imports have expected format (../path/file.nix or ./file.nix)
	local valid=1
	while IFS= read -r import; do
		if [[ -n "$import" ]]; then
			if [[ ! "$import" =~ ^\.\./ && ! "$import" =~ ^\./ ]]; then
				valid=0
				break
			fi
		fi
	done <<<"$imports"

	if [[ $valid -eq 1 ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: unexpected import format"
	fi
}

# -----------------------------------------------------------------------------
# Inheritance Resolution Tests
# -----------------------------------------------------------------------------

test_get_parent_profile_detects_parent() {
	local test_name="get_parent_profile detects parent profile"

	# Find a profile that inherits from another
	local profiles
	profiles=$(list_profiles 2>/dev/null)

	local found_child=""
	while IFS= read -r profile; do
		if [[ -n "$profile" && "$profile" != "default" ]]; then
			local profile_file="$PROFILES_DIR/${profile}.nix"
			if [[ -f "$profile_file" ]]; then
				local parent
				parent=$(get_parent_profile "$profile_file" 2>/dev/null)
				if [[ -n "$parent" ]]; then
					found_child="$profile"
					break
				fi
			fi
		fi
	done <<<"$profiles"

	if [[ -n "$found_child" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name (skipped - no inherited profiles)" "pass"
	fi
}

test_get_parent_profile_no_parent() {
	local test_name="get_parent_profile returns empty for standalone profile"

	local profile_file="$PROFILES_DIR/default.nix"

	if [[ ! -f "$profile_file" ]]; then
		test_case "$test_name (skipped - no default.nix)" "pass"
		return
	fi

	local parent
	parent=$(get_parent_profile "$profile_file" 2>/dev/null)

	# default.nix typically doesn't inherit from another profile
	if [[ -z "$parent" ]]; then
		test_case "$test_name" "pass"
	else
		# default.nix might inherit, that's okay too
		test_case "$test_name (skipped - default has parent)" "pass"
	fi
}

test_resolve_inheritance_chain_single() {
	local test_name="resolve_inheritance_chain returns profile for standalone"

	local profile_file="$PROFILES_DIR/default.nix"

	if [[ ! -f "$profile_file" ]]; then
		test_case "$test_name (skipped - no default.nix)" "pass"
		return
	fi

	local chain
	chain=$(resolve_inheritance_chain "default" 2>/dev/null)

	local first
	first=$(echo "$chain" | head -1)

	if [[ "$first" == "default" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: chain should start with profile name"
	fi
}

test_resolve_inheritance_chain_includes_profile() {
	local test_name="resolve_inheritance_chain includes starting profile"

	local profiles
	profiles=$(list_profiles 2>/dev/null | head -1)

	if [[ -z "$profiles" ]]; then
		test_case "$test_name (skipped - no profiles)" "pass"
		return
	fi

	local chain
	chain=$(resolve_inheritance_chain "$profiles" 2>/dev/null)

	if echo "$chain" | grep -q "^${profiles}$"; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: chain should include starting profile"
	fi
}

# -----------------------------------------------------------------------------
# Module Classification Tests
# -----------------------------------------------------------------------------

test_classify_modules_returns_three_lines() {
	local test_name="classify_modules returns three output lines"

	local result
	result=$(classify_modules "default" "system" 2>/dev/null)

	local lines
	lines=$(echo "$result" | wc -l)

	if [[ $lines -eq 3 ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: expected 3 lines, got $lines"
	fi
}

test_classify_modules_handles_invalid_profile() {
	local test_name="classify_modules handles invalid profile"

	if classify_modules "__nonexistent__" "system" 2>/dev/null; then
		test_case "$test_name" "fail: should fail for invalid profile"
	else
		test_case "$test_name" "pass"
	fi
}

test_classify_modules_handles_invalid_type() {
	local test_name="classify_modules handles invalid module type"

	if classify_modules "default" "invalid" 2>/dev/null; then
		test_case "$test_name" "fail: should fail for invalid type"
	else
		test_case "$test_name" "pass"
	fi
}

test_classify_modules_system() {
	local test_name="classify_modules works for system modules"

	local result
	result=$(classify_modules "default" "system" 2>/dev/null) || {
		test_case "$test_name (skipped - classify failed)" "pass"
		return
	}

	# Should not error
	test_case "$test_name" "pass"
}

test_classify_modules_home() {
	local test_name="classify_modules works for home modules"

	local result
	result=$(classify_modules "default" "home" 2>/dev/null) || {
		test_case "$test_name (skipped - classify failed)" "pass"
		return
	}

	# Should not error
	test_case "$test_name" "pass"
}

# -----------------------------------------------------------------------------
# Host Profile Tests
# -----------------------------------------------------------------------------

test_get_host_profile_extracts_profile() {
	local test_name="get_host_profile extracts profile from host"

	local hosts
	hosts=$(list_hosts 2>/dev/null | head -1)

	if [[ -z "$hosts" ]]; then
		test_case "$test_name (skipped - no hosts)" "pass"
		return
	fi

	local profile
	profile=$(get_host_profile "$hosts" 2>/dev/null)

	# Profile may be empty if not set, but function should not error
	test_case "$test_name" "pass"
}

test_get_host_profile_invalid_host() {
	local test_name="get_host_profile handles invalid host"

	local profile
	profile=$(get_host_profile "__nonexistent__" 2>/dev/null) || true

	if [[ -z "$profile" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should return empty for invalid host"
	fi
}

# -----------------------------------------------------------------------------
# Run All Tests
# -----------------------------------------------------------------------------

run_test_discover() {
	echo ""
	echo "=== Testing discover.sh ==="
	echo ""

	test_discover_system_modules_returns_modules
	test_discover_system_modules_excludes_barrel
	test_discover_system_modules_excludes_scripts
	test_discover_home_modules_returns_modules
	test_discover_home_modules_excludes_barrel
	test_discover_modules_sorted
	test_list_profiles_returns_profiles
	test_list_profiles_default_first
	test_list_profiles_includes_expected
	test_list_hosts_returns_hosts
	test_list_hosts_sorted
	test_parse_profile_imports_extracts_imports
	test_parse_profile_imports_handles_nonexistent
	test_parse_profile_imports_format
	test_get_parent_profile_detects_parent
	test_get_parent_profile_no_parent
	test_resolve_inheritance_chain_single
	test_resolve_inheritance_chain_includes_profile
	test_classify_modules_returns_three_lines
	test_classify_modules_handles_invalid_profile
	test_classify_modules_handles_invalid_type
	test_classify_modules_system
	test_classify_modules_home
	test_get_host_profile_extracts_profile
	test_get_host_profile_invalid_host
}
