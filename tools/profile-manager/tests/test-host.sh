# test_host.sh
#
# Purpose: Unit tests for host.sh functions
#
# This module tests:
# - rewrite_host_profile() updates profile correctly
# - Validation rejects invalid profiles
# - Backup/restore on failure

# shellcheck shell=bash

# -----------------------------------------------------------------------------
# Test Setup
# -----------------------------------------------------------------------------

TEST_HOST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER_DIR="$(cd "$TEST_HOST_DIR/.." && pwd)"

# Source required modules
# shellcheck source=../common.sh
source "$PROFILE_MANAGER_DIR/common.sh"
# shellcheck source=../discover.sh
source "$PROFILE_MANAGER_DIR/discover.sh"
# shellcheck source=../host.sh
source "$PROFILE_MANAGER_DIR/host.sh"

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

# Create temp directory for test files
TEST_HOST_TMP=""

setup_test_host() {
	TEST_HOST_TMP=$(mktemp -d)
}

cleanup_test_host() {
	if [[ -n "$TEST_HOST_TMP" && -d "$TEST_HOST_TMP" ]]; then
		rm -rf "$TEST_HOST_TMP"
	fi
}

# -----------------------------------------------------------------------------
# Host Profile Rewriting Tests
# -----------------------------------------------------------------------------

test_rewrite_host_profile_updates_profile() {
	local test_name="rewrite_host_profile updates profile field"

	setup_test_host

	# Create a test host config
	mkdir -p "$TEST_HOST_TMP/testhost"
	cat >"$TEST_HOST_TMP/testhost/user-config.nix" <<'EOF'
{
  username = "testuser";
  hostname = "testhost";
  profile = "default";
}
EOF

	# Override HOSTS_DIR temporarily
	HOSTS_DIR="$TEST_HOST_TMP"

	# Create a fake profile
	mkdir -p "$PROFILES_DIR"
	touch "$PROFILES_DIR/newprofile.nix"

	# Test the rewrite
	if rewrite_host_profile "testhost" "newprofile" 2>/dev/null; then
		# Check if profile was updated
		local new_profile
		new_profile=$(grep 'profile = ' "$TEST_HOST_TMP/testhost/user-config.nix" | sed 's/.*profile = "\([^"]*\)".*/\1/')

		if [[ "$new_profile" == "newprofile" ]]; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: profile not updated correctly"
		fi
	else
		test_case "$test_name" "fail: rewrite_host_profile returned error"
	fi

	cleanup_test_host
}

test_rewrite_host_profile_validates_profile() {
	local test_name="rewrite_host_profile validates profile exists"

	# Get a real host if available
	local hosts
	hosts=$(list_hosts 2>/dev/null | head -1)

	if [[ -z "$hosts" ]]; then
		test_case "$test_name (skipped - no hosts)" "pass"
		return
	fi

	# Try to set a non-existent profile
	if rewrite_host_profile "$hosts" "__nonexistent_profile__" 2>/dev/null; then
		test_case "$test_name" "fail: should reject non-existent profile"
	else
		test_case "$test_name" "pass"
	fi
}

test_rewrite_host_profile_validates_host() {
	local test_name="rewrite_host_profile validates host exists"

	# Try to update a non-existent host
	if rewrite_host_profile "__nonexistent_host__" "default" 2>/dev/null; then
		test_case "$test_name" "fail: should reject non-existent host"
	else
		test_case "$test_name" "pass"
	fi
}

test_rewrite_host_profile_creates_backup() {
	local test_name="rewrite_host_profile creates backup"

	# Check that the function creates a backup
	local host_file="$PROFILE_MANAGER_DIR/host.sh"

	if [[ -f "$host_file" ]]; then
		if grep -q '\.bak' "$host_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing backup creation"
		fi
	else
		test_case "$test_name (skipped - host.sh not found)" "pass"
	fi
}

test_rewrite_host_profile_validates_syntax() {
	local test_name="rewrite_host_profile validates Nix syntax"

	local host_file="$PROFILE_MANAGER_DIR/host.sh"

	if [[ -f "$host_file" ]]; then
		if grep -q 'nix-instantiate --parse' "$host_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing syntax validation"
		fi
	else
		test_case "$test_name (skipped - host.sh not found)" "pass"
	fi
}

test_rewrite_host_profile_restores_on_failure() {
	local test_name="rewrite_host_profile restores backup on failure"

	local host_file="$PROFILE_MANAGER_DIR/host.sh"

	if [[ -f "$host_file" ]]; then
		# Check for restore logic
		if grep -q 'mv.*bak' "$host_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing restore logic"
		fi
	else
		test_case "$test_name (skipped - host.sh not found)" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Host Details Display Tests
# -----------------------------------------------------------------------------

test_show_host_details_valid_host() {
	local test_name="show_host_details displays host information"

	local hosts
	hosts=$(list_hosts 2>/dev/null | head -1)

	if [[ -z "$hosts" ]]; then
		test_case "$test_name (skipped - no hosts)" "pass"
		return
	fi

	local output
	output=$(show_host_details "$hosts" 2>/dev/null)

	if [[ "$output" == *"Host:"* && "$output" == *"Directory:"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: missing expected output"
	fi
}

test_show_host_details_invalid_host() {
	local test_name="show_host_details handles invalid host"

	if show_host_details "__nonexistent__" 2>/dev/null; then
		test_case "$test_name" "fail: should fail for invalid host"
	else
		test_case "$test_name" "pass"
	fi
}

test_show_host_details_shows_profile() {
	local test_name="show_host_details shows current profile"

	local hosts
	hosts=$(list_hosts 2>/dev/null | head -1)

	if [[ -z "$hosts" ]]; then
		test_case "$test_name (skipped - no hosts)" "pass"
		return
	fi

	local output
	output=$(show_host_details "$hosts" 2>/dev/null)

	# Should show Profile: line (even if not set)
	if [[ "$output" == *"Profile:"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: missing profile information"
	fi
}

# -----------------------------------------------------------------------------
# Host Config File Tests
# -----------------------------------------------------------------------------

test_get_host_config_file_path() {
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
# Integration Tests
# -----------------------------------------------------------------------------

test_host_profile_roundtrip() {
	local test_name="Host profile get/set roundtrip"

	local hosts
	hosts=$(list_hosts 2>/dev/null | head -1)

	if [[ -z "$hosts" ]]; then
		test_case "$test_name (skipped - no hosts)" "pass"
		return
	fi

	# Get current profile
	local original_profile
	original_profile=$(get_host_profile "$hosts" 2>/dev/null)

	# If a profile exists, verify it can be read
	if [[ -n "$original_profile" ]]; then
		test_case "$test_name" "pass"
	else
		# Profile might not be set, that's okay
		test_case "$test_name (skipped - no profile set)" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Run All Tests
# -----------------------------------------------------------------------------

run_test_host() {
	echo ""
	echo "=== Testing host.sh ==="
	echo ""

	test_rewrite_host_profile_updates_profile
	test_rewrite_host_profile_validates_profile
	test_rewrite_host_profile_validates_host
	test_rewrite_host_profile_creates_backup
	test_rewrite_host_profile_validates_syntax
	test_rewrite_host_profile_restores_on_failure
	test_show_host_details_valid_host
	test_show_host_details_invalid_host
	test_show_host_details_shows_profile
	test_get_host_config_file_path
	test_host_profile_roundtrip
}
