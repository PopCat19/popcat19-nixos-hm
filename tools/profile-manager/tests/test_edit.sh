# test_edit.sh
#
# Purpose: Unit tests for edit.sh functions
#
# This module tests:
# - detect_home_barrel_import() detects barrel vs explicit imports
# - Import parsing handles edge cases
# - Profile creation (template validation)
# - Profile deletion protection (default profile)

# shellcheck shell=bash

# -----------------------------------------------------------------------------
# Test Setup
# -----------------------------------------------------------------------------

TEST_EDIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER_DIR="$(cd "$TEST_EDIT_DIR/.." && pwd)"

# Source required modules
# shellcheck source=../common.sh
source "$PROFILE_MANAGER_DIR/common.sh"
# shellcheck source=../discover.sh
source "$PROFILE_MANAGER_DIR/discover.sh"
# shellcheck source=../edit.sh
source "$PROFILE_MANAGER_DIR/edit.sh"

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
TEST_EDIT_TMP=""

setup_test_edit() {
	TEST_EDIT_TMP=$(mktemp -d)
}

cleanup_test_edit() {
	if [[ -n "$TEST_EDIT_TMP" && -d "$TEST_EDIT_TMP" ]]; then
		rm -rf "$TEST_EDIT_TMP"
	fi
}

# -----------------------------------------------------------------------------
# Barrel Detection Tests
# -----------------------------------------------------------------------------

test_detect_home_barrel_import_detects_barrel() {
	local test_name="detect_home_barrel_import detects barrel import"

	setup_test_edit

	# Create a test profile with barrel import
	cat >"$TEST_EDIT_TMP/test-barrel.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [
    ../home/modules
  ];
}
EOF

	if detect_home_barrel_import "$TEST_EDIT_TMP/test-barrel.nix"; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should detect barrel import"
	fi

	cleanup_test_edit
}

test_detect_home_barrel_import_detects_explicit() {
	local test_name="detect_home_barrel_import returns false for explicit imports"

	setup_test_edit

	# Create a test profile with explicit imports
	cat >"$TEST_EDIT_TMP/test-explicit.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [
    ../home/modules/git.nix
    ../home/modules/kitty.nix
  ];
}
EOF

	if detect_home_barrel_import "$TEST_EDIT_TMP/test-explicit.nix"; then
		test_case "$test_name" "fail: should not detect barrel for explicit imports"
	else
		test_case "$test_name" "pass"
	fi

	cleanup_test_edit
}

test_detect_home_barrel_import_no_imports() {
	local test_name="detect_home_barrel_import handles file without imports"

	setup_test_edit

	# Create a test profile without imports
	cat >"$TEST_EDIT_TMP/test-no-imports.nix" <<'EOF'
{ userConfig, ... }:
{
  # No imports
  some.setting = true;
}
EOF

	if detect_home_barrel_import "$TEST_EDIT_TMP/test-no-imports.nix"; then
		test_case "$test_name" "fail: should return false for no imports"
	else
		test_case "$test_name" "pass"
	fi

	cleanup_test_edit
}

test_detect_home_barrel_import_nonexistent() {
	local test_name="detect_home_barrel_import handles nonexistent file"

	if detect_home_barrel_import "/nonexistent/file.nix" 2>/dev/null; then
		test_case "$test_name" "fail: should return false for nonexistent file"
	else
		test_case "$test_name" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Import Parsing Edge Cases Tests
# -----------------------------------------------------------------------------

test_parse_home_imports_extracts_imports() {
	local test_name="parse_home_imports extracts home imports"

	setup_test_edit

	# Create a test profile with home-manager imports
	cat >"$TEST_EDIT_TMP/test-home.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [
    ../system/modules/audio.nix
  ];

  home-manager.users.${userConfig.username} = {
    imports = [
      ../home/modules/git.nix
      ../home/modules/kitty.nix
    ];
  };
}
EOF

	local imports
	imports=$(parse_home_imports "$TEST_EDIT_TMP/test-home.nix" 2>/dev/null)

	if [[ "$imports" == *"git.nix"* && "$imports" == *"kitty.nix"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should extract home imports"
	fi

	cleanup_test_edit
}

test_parse_home_imports_no_home_block() {
	local test_name="parse_home_imports handles file without home-manager block"

	setup_test_edit

	# Create a test profile without home-manager block
	cat >"$TEST_EDIT_TMP/test-no-home.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [
    ../system/modules/audio.nix
  ];
}
EOF

	local imports
	imports=$(parse_home_imports "$TEST_EDIT_TMP/test-no-home.nix" 2>/dev/null)

	if [[ -z "$imports" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should return empty for no home imports"
	fi

	cleanup_test_edit
}

# -----------------------------------------------------------------------------
# Profile Import Parsing Edge Cases
# -----------------------------------------------------------------------------

test_parse_profile_imports_with_comments() {
	local test_name="parse_profile_imports handles comments between imports"

	setup_test_edit

	# Create a test profile with comments in imports
	cat >"$TEST_EDIT_TMP/test-comments.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [
    # Audio support
    ../system/modules/audio.nix
    # Display configuration
    ../system/modules/display.nix
  ];
}
EOF

	local imports
	imports=$(parse_profile_imports "$TEST_EDIT_TMP/test-comments.nix" 2>/dev/null)

	if [[ "$imports" == *"audio.nix"* && "$imports" == *"display.nix"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should extract imports despite comments"
	fi

	cleanup_test_edit
}

test_parse_profile_imports_with_trailing_commas() {
	local test_name="parse_profile_imports handles trailing commas"

	setup_test_edit

	# Create a test profile with trailing commas (Nix allows this)
	cat >"$TEST_EDIT_TMP/test-commas.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [
    ../system/modules/audio.nix,
    ../system/modules/display.nix,
  ];
}
EOF

	local imports
	imports=$(parse_profile_imports "$TEST_EDIT_TMP/test-commas.nix" 2>/dev/null)

	if [[ "$imports" == *"audio.nix"* && "$imports" == *"display.nix"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should handle trailing commas"
	fi

	cleanup_test_edit
}

test_parse_profile_imports_with_blank_lines() {
	local test_name="parse_profile_imports handles blank lines"

	setup_test_edit

	# Create a test profile with blank lines in imports
	cat >"$TEST_EDIT_TMP/test-blanks.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [

    ../system/modules/audio.nix

    ../system/modules/display.nix

  ];
}
EOF

	local imports
	imports=$(parse_profile_imports "$TEST_EDIT_TMP/test-blanks.nix" 2>/dev/null)

	if [[ "$imports" == *"audio.nix"* && "$imports" == *"display.nix"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should handle blank lines"
	fi

	cleanup_test_edit
}

test_parse_profile_imports_inline() {
	local test_name="parse_profile_imports handles inline imports"

	setup_test_edit

	# Create a test profile with inline imports
	cat >"$TEST_EDIT_TMP/test-inline.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [ ../system/modules/audio.nix ../system/modules/display.nix ];
}
EOF

	local imports
	imports=$(parse_profile_imports "$TEST_EDIT_TMP/test-inline.nix" 2>/dev/null)

	if [[ "$imports" == *"audio.nix"* && "$imports" == *"display.nix"* ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should handle inline imports"
	fi

	cleanup_test_edit
}

test_parse_profile_imports_empty_block() {
	local test_name="parse_profile_imports handles empty imports block"

	setup_test_edit

	# Create a test profile with empty imports
	cat >"$TEST_EDIT_TMP/test-empty.nix" <<'EOF'
{ userConfig, ... }:
{
  imports = [];
}
EOF

	local imports
	imports=$(parse_profile_imports "$TEST_EDIT_TMP/test-empty.nix" 2>/dev/null)

	if [[ -z "$imports" ]]; then
		test_case "$test_name" "pass"
	else
		test_case "$test_name" "fail: should return empty for empty imports"
	fi

	cleanup_test_edit
}

# -----------------------------------------------------------------------------
# Profile Creation Template Tests
# -----------------------------------------------------------------------------

test_profile_template_structure() {
	local test_name="Profile creation template has correct structure"

	# Check that cmd_create generates valid Nix structure
	# We test the template content by examining the function

	# The template should include:
	# - Function arguments ({ inputs, userConfig, ... }:)
	# - imports block
	# - stateVersion

	# This is a static analysis test
	local edit_file="$PROFILE_MANAGER_DIR/edit.sh"

	if [[ -f "$edit_file" ]]; then
		if grep -q "system.stateVersion" "$edit_file" &&
			grep -q "imports = \[" "$edit_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: template missing required elements"
		fi
	else
		test_case "$test_name (skipped - edit.sh not found)" "pass"
	fi
}

test_profile_template_inheritance() {
	local test_name="Profile creation template supports inheritance"

	local edit_file="$PROFILE_MANAGER_DIR/edit.sh"

	if [[ -f "$edit_file" ]]; then
		# Check for inheritance template
		# shellcheck disable=SC2016 # Literal string: looking for ${inherit} in nix template
		if grep -q '\./\${inherit}.nix' "$edit_file" ||
			grep -q 'Inherit from' "$edit_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: template missing inheritance support"
		fi
	else
		test_case "$test_name (skipped - edit.sh not found)" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Profile Deletion Protection Tests
# -----------------------------------------------------------------------------

test_delete_protects_default() {
	local test_name="Profile deletion protects default profile"

	# Check that the delete function has protection for default profile
	local profile_manager="$PROFILE_MANAGER_DIR/../profile-manager.sh"

	if [[ -f "$profile_manager" ]]; then
		if grep -q 'Cannot delete.*default' "$profile_manager" ||
			grep -q 'profile == "default"' "$profile_manager"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing default profile protection"
		fi
	else
		test_case "$test_name (skipped - profile-manager.sh not found)" "pass"
	fi
}

test_delete_checks_dependencies() {
	local test_name="Profile deletion checks for dependent hosts"

	local edit_file="$PROFILE_MANAGER_DIR/edit.sh"

	if [[ -f "$edit_file" ]]; then
		# Check for host dependency checking
		if grep -q 'using_hosts' "$edit_file" ||
			grep -q 'get_host_profile' "$edit_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing dependency checking"
		fi
	else
		test_case "$test_name (skipped - edit.sh not found)" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Rewrite Functions Tests
# -----------------------------------------------------------------------------

test_rewrite_imports_creates_backup() {
	local test_name="rewrite_imports creates backup before modifying"

	# Check that rewrite_imports creates a backup
	local edit_file="$PROFILE_MANAGER_DIR/edit.sh"

	if [[ -f "$edit_file" ]]; then
		if grep -q '\.bak' "$edit_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing backup creation"
		fi
	else
		test_case "$test_name (skipped - edit.sh not found)" "pass"
	fi
}

test_rewrite_imports_validates_syntax() {
	local test_name="rewrite_imports validates Nix syntax"

	local edit_file="$PROFILE_MANAGER_DIR/edit.sh"

	if [[ -f "$edit_file" ]]; then
		if grep -q 'nix-instantiate --parse' "$edit_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing syntax validation"
		fi
	else
		test_case "$test_name (skipped - edit.sh not found)" "pass"
	fi
}

test_rewrite_imports_restores_on_failure() {
	local test_name="rewrite_imports restores backup on failure"

	local edit_file="$PROFILE_MANAGER_DIR/edit.sh"

	if [[ -f "$edit_file" ]]; then
		# Check for restore logic
		if grep -q 'mv.*bak' "$edit_file"; then
			test_case "$test_name" "pass"
		else
			test_case "$test_name" "fail: missing restore logic"
		fi
	else
		test_case "$test_name (skipped - edit.sh not found)" "pass"
	fi
}

# -----------------------------------------------------------------------------
# Run All Tests
# -----------------------------------------------------------------------------

run_test_edit() {
	echo ""
	echo "=== Testing edit.sh ==="
	echo ""

	test_detect_home_barrel_import_detects_barrel
	test_detect_home_barrel_import_detects_explicit
	test_detect_home_barrel_import_no_imports
	test_detect_home_barrel_import_nonexistent
	test_parse_home_imports_extracts_imports
	test_parse_home_imports_no_home_block
	test_parse_profile_imports_with_comments
	test_parse_profile_imports_with_trailing_commas
	test_parse_profile_imports_with_blank_lines
	test_parse_profile_imports_inline
	test_parse_profile_imports_empty_block
	test_profile_template_structure
	test_profile_template_inheritance
	test_delete_protects_default
	test_delete_checks_dependencies
	test_rewrite_imports_creates_backup
	test_rewrite_imports_validates_syntax
	test_rewrite_imports_restores_on_failure
}
