#!/usr/bin/env bash
# profile-manager.sh
#
# Purpose: Root entry point for profile management CLI and TUI
#
# This script:
# - Dispatches CLI commands for profile operations
# - Launches TUI mode when invoked without arguments or with 'tui'
# - Provides help and usage information
#
# Usage:
#   ./profile-manager.sh [COMMAND] [OPTIONS]
#
# Commands:
#   list                    List all available profiles
#   show <profile>          Show profile details and imports
#   create <profile>        Create a new profile from template
#   delete <profile>        Delete a profile (with confirmation)
#   set-host <host> <profile>  Set profile for a host
#   get-host <host>         Get current profile for a host
#   tui                     Launch interactive TUI mode
#   help                    Show this help message

set -Eeuo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER_DIR="$SCRIPT_DIR/tools/profile-manager"

# Source shared utilities
# shellcheck source=tools/profile-manager/common.sh
source "$PROFILE_MANAGER_DIR/common.sh"

# Source discovery functions
# shellcheck source=tools/profile-manager/discover.sh
source "$PROFILE_MANAGER_DIR/discover.sh"

# Source edit functions
# shellcheck source=tools/profile-manager/edit.sh
source "$PROFILE_MANAGER_DIR/edit.sh"

# Source diff functions
# shellcheck source=tools/profile-manager/diff.sh
source "$PROFILE_MANAGER_DIR/diff.sh"

# Source host management functions
# shellcheck source=tools/profile-manager/host.sh
source "$PROFILE_MANAGER_DIR/host.sh"

# Source build functions
# shellcheck source=tools/profile-manager/build.sh
source "$PROFILE_MANAGER_DIR/build.sh"

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------

show_help() {
	cat <<EOF
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Commands:
  list                    List all available profiles
  show <profile>          Show profile details and imports
  create <profile>        Create a new profile from template
  delete <profile>        Delete a profile (with confirmation)
  edit <profile>          Edit profile modules interactively
  set-host <host> <profile>  Set profile for a host
  get-host <host>         Get current profile for a host
  hosts                   Manage host configurations
  build [action] [host]   Build NixOS configuration (test|switch|dry-run|build)
  diff                    Show git diff for profile changes
  status                  Show profile manager status
  tui                     Launch interactive TUI mode
  help                    Show this help message

Build actions:
  test      Apply configuration without creating boot entry
  switch    Apply configuration and set as boot default
  dry-run   Show what would change without applying
  build     Build without applying
  dry-build Build and show derivation without applying

Examples:
  $(basename "$0") list
  $(basename "$0") show default
  $(basename "$0") create gaming
  $(basename "$0") edit laptop
  $(basename "$0") delete minimal
  $(basename "$0") set-host nixos0 default
  $(basename "$0") get-host nixos0
  $(basename "$0") hosts
  $(basename "$0") build test nixos0
  $(basename "$0") build switch
  $(basename "$0") diff
  $(basename "$0") tui

Profile location: configuration/profiles/
Host location: configuration/hosts/
EOF
}

# -----------------------------------------------------------------------------
# CLI Commands
# -----------------------------------------------------------------------------

cmd_list() {
	# List all available profiles with descriptions
	echo -e "${BLUE}Available profiles:${NC}"
	echo ""

	if [[ ! -d "$PROFILES_DIR" ]]; then
		print_error "Profiles directory not found: $PROFILES_DIR"
		exit 1
	fi

	local count=0
	while IFS= read -r profile_name; do
		if [[ -n "$profile_name" ]]; then
			local profile_file
			profile_file=$(get_profile_file "$profile_name")
			local purpose
			purpose=$(grep -m1 "^# Purpose:" "$profile_file" 2>/dev/null | sed 's/^# Purpose: //' || echo "No description")
			echo -e "  ${CYAN}$profile_name${NC}"
			echo "    $purpose"
			echo ""
			((count++)) || true
		fi
	done < <(list_profiles)

	if [[ $count -eq 0 ]]; then
		print_warning "No profiles found in $PROFILES_DIR"
	else
		echo -e "Total: ${GREEN}$count${NC} profile(s)"
	fi
}

cmd_show() {
	# Show detailed information about a profile
	# Args: $1 - profile name
	local profile="$1"

	if [[ -z "$profile" ]]; then
		print_error "Profile name required"
		echo "Usage: $(basename "$0") show <profile>"
		exit 1
	fi

	if ! profile_exists "$profile"; then
		print_error "Profile not found: $profile"
		echo ""
		echo "Available profiles:"
		while IFS= read -r name; do
			[[ -n "$name" ]] && echo "  - $name"
		done < <(list_profiles)
		echo ""
		echo "Run '$(basename "$0") show <profile>' to see profile details"
		exit 1
	fi

	local profile_file
	profile_file=$(get_profile_file "$profile")

	echo -e "${BLUE}Profile:${NC} $profile"
	echo -e "${BLUE}File:${NC} $profile_file"
	echo ""

	# Extract purpose from header
	local purpose
	purpose=$(grep -m1 "^# Purpose:" "$profile_file" 2>/dev/null | sed 's/^# Purpose: //')
	if [[ -n "$purpose" ]]; then
		echo -e "${BLUE}Purpose:${NC} $purpose"
	fi

	# Extract bullet points from header
	echo -e "${BLUE}Features:${NC}"
	while IFS= read -r line; do
		if [[ "$line" =~ ^#\ -\ (.+)$ ]]; then
			echo "  - ${BASH_REMATCH[1]}"
		fi
	done <"$profile_file"
	echo ""

	# Show inheritance chain
	local chain=()
	mapfile -t chain < <(resolve_inheritance_chain "$profile")
	if [[ ${#chain[@]} -gt 1 ]]; then
		echo -e "${BLUE}Inheritance Chain:${NC}"
		local chain_str=""
		for ((i = 0; i < ${#chain[@]}; i++)); do
			if [[ $i -eq 0 ]]; then
				chain_str="${chain[$i]}"
			else
				chain_str="$chain_str → ${chain[$i]}"
			fi
		done
		echo "  $chain_str"
		echo ""
	fi

	# Show imports
	echo -e "${BLUE}Imports:${NC}"
	local imports
	imports=$(parse_profile_imports "$profile_file")
	if [[ -n "$imports" ]]; then
		while IFS= read -r import_path; do
			if [[ -n "$import_path" ]]; then
				local label
				label=$(nix_path_to_label "$import_path")
				echo "  $import_path  ($label)"
			fi
		done <<<"$imports"
	else
		print_warning "No imports found"
	fi
}

cmd_create() {
	# Create a new profile from template
	# Args: $1 - profile name
	local profile="$1"

	if [[ -z "$profile" ]]; then
		print_error "Profile name required"
		echo "Usage: $(basename "$0") create <profile>"
		exit 1
	fi

	if profile_exists "$profile"; then
		print_error "Profile already exists: $profile"
		exit 1
	fi

	# Validate profile name (alphanumeric, hyphens, underscores)
	if [[ ! "$profile" =~ ^[a-zA-Z0-9_-]+$ ]]; then
		print_error "Invalid profile name. Use only letters, numbers, hyphens, and underscores."
		exit 1
	fi

	local profile_file
	profile_file=$(get_profile_file "$profile")

	# Create profile from template
	cat >"$profile_file" <<EOF
# $profile.nix
#
# Purpose: Custom profile configuration
#
# This profile:
# - Add feature descriptions here
# - Customize imports as needed
{ inputs, userConfig, ... }:
let
  stateVersion = import ../stateversion.nix;
in
{
  imports = [
    # Base profile or modules
    # ../base/configuration.nix
  ];

  system.stateVersion = stateVersion.system;
}
EOF

	print_success "Created profile: $profile"
	echo "File: $profile_file"
	echo ""
	print_info "Edit the file to customize imports and configuration"
}

cmd_delete() {
	# Delete a profile with confirmation
	# Args: $1 - profile name
	local profile="$1"

	if [[ -z "$profile" ]]; then
		print_error "Profile name required"
		echo "Usage: $(basename "$0") delete <profile>"
		exit 1
	fi

	if ! profile_exists "$profile"; then
		print_error "Profile not found: $profile"
		exit 1
	fi

	# Prevent deleting certain profiles
	if [[ "$profile" == "default" ]]; then
		print_error "Cannot delete the 'default' profile"
		echo "Reason: It is the base profile for other profiles."
		echo "Suggestion: Create a new profile instead with: $(basename "$0") create <name>"
		exit 1
	fi

	local profile_file
	profile_file=$(get_profile_file "$profile")

	echo -e "${YELLOW}Warning:${NC} This will delete the profile: $profile"
	echo "File: $profile_file"
	echo ""
	read -r -p "Are you sure? (y/N): " confirmation

	if [[ "$confirmation" =~ ^[Yy]$ ]]; then
		rm "$profile_file"
		print_success "Deleted profile: $profile"
	else
		print_info "Operation cancelled"
	fi
}

cmd_set_host() {
	# Set the profile for a host
	# Args: $1 - host name
	#       $2 - profile name
	local host="$1"
	local profile="$2"

	if [[ -z "$host" || -z "$profile" ]]; then
		print_error "Host and profile names required"
		echo "Usage: $(basename "$0") set-host <host> <profile>"
		exit 1
	fi

	if ! host_exists "$host"; then
		print_error "Host not found: $host"
		echo ""
		echo "Available hosts:"
		while IFS= read -r name; do
			[[ -n "$name" ]] && echo "  - $name"
		done < <(list_hosts)
		echo ""
		echo "Run '$(basename "$0") hosts' to manage host configurations"
		exit 1
	fi

	if ! profile_exists "$profile"; then
		print_error "Profile not found: $profile"
		echo ""
		echo "Available profiles:"
		while IFS= read -r name; do
			[[ -n "$name" ]] && echo "  - $name"
		done < <(list_profiles)
		echo ""
		echo "Run '$(basename "$0") list' to see all profiles"
		exit 1
	fi

	local config_file
	config_file=$(get_host_config_file "$host")

	if [[ ! -f "$config_file" ]]; then
		print_error "Host config file not found: $config_file"
		exit 1
	fi

	# Update the profile line in user-config.nix
	if grep -q 'profile = "' "$config_file"; then
		sed -i "s/profile = \"[^\"]*\";/profile = \"$profile\";/" "$config_file"
		print_success "Set profile '$profile' for host '$host'"
	else
		print_error "Could not find profile setting in $config_file"
		exit 1
	fi
}

cmd_get_host() {
	# Get the current profile for a host
	# Args: $1 - host name
	local host="$1"

	if [[ -z "$host" ]]; then
		print_error "Host name required"
		echo "Usage: $(basename "$0") get-host <host>"
		exit 1
	fi

	if ! host_exists "$host"; then
		print_error "Host not found: $host"
		echo ""
		echo "Available hosts:"
		while IFS= read -r name; do
			[[ -n "$name" ]] && echo "  - $name"
		done < <(list_hosts)
		echo ""
		echo "Run '$(basename "$0") hosts' to manage host configurations"
		exit 1
	fi

	local config_file
	config_file=$(get_host_config_file "$host")

	if [[ ! -f "$config_file" ]]; then
		print_error "Host config file not found: $config_file"
		exit 1
	fi

	local current_profile
	current_profile=$(grep -m1 'profile = "' "$config_file" | sed 's/.*profile = "\([^"]*\)".*/\1/')

	if [[ -n "$current_profile" ]]; then
		echo -e "${BLUE}Host:${NC} $host"
		echo -e "${BLUE}Profile:${NC} $current_profile"
	else
		print_warning "No profile setting found in $config_file"
	fi
}

cmd_tui() {
	# Launch the TUI mode
	# Check for gum availability
	if ! command -v gum &>/dev/null; then
		print_error "gum is required for TUI mode"
		echo "Install with: nix-shell -p gum" >&2
		echo "Or run: nix-shell -p gum --run './profile-manager.sh tui'" >&2
		exit 1
	fi

	# Source and run TUI
	# shellcheck source=tools/profile-manager/tui.sh
	source "$PROFILE_MANAGER_DIR/tui.sh"
	run_tui
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

main() {
	local command="${1:-help}"
	shift || true

	case "$command" in
	list)
		cmd_list
		;;
	show)
		cmd_show "$@"
		;;
	create)
		cmd_create "$@"
		;;
	delete)
		cmd_delete "$@"
		;;
	edit)
		cmd_edit_modules_for "$@"
		;;
	set-host)
		cmd_set_host "$@"
		;;
	get-host)
		cmd_get_host "$@"
		;;
	hosts)
		cmd_hosts_interactive
		;;
	build)
		if [[ -z "${1:-}" ]]; then
			cmd_build_interactive
		else
			cmd_build "$@"
		fi
		;;
	diff)
		cmd_diff
		;;
	status)
		cmd_status
		;;
	tui)
		cmd_tui
		;;
	help | --help | -h)
		show_help
		;;
	"")
		# No argument - launch TUI
		cmd_tui
		;;
	*)
		print_error "Unknown command: $command"
		echo ""
		show_help
		exit 1
		;;
	esac
}

main "$@"
