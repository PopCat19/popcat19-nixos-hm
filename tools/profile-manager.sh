#!/usr/bin/env bash
# profile-manager.sh
#
# Purpose: Manage NixOS configuration profiles and host assignments
#
# This script:
# - Lists and displays profile configurations
# - Creates and deletes custom profiles
# - Configures which profile a host uses
#
# Usage:
#   ./tools/profile-manager.sh [COMMAND] [OPTIONS]
#
# Commands:
#   list                    List all available profiles
#   show <profile>          Show profile details and imports
#   create <profile>        Create a new profile from template
#   delete <profile>        Delete a profile (with confirmation)
#   set-host <host> <profile>  Set profile for a host
#   get-host <host>         Get current profile for a host
#   help                    Show this help message
#
# Examples:
#   ./tools/profile-manager.sh list
#   ./tools/profile-manager.sh show default
#   ./tools/profile-manager.sh create gaming
#   ./tools/profile-manager.sh delete minimal
#   ./tools/profile-manager.sh set-host nixos0 default
#   ./tools/profile-manager.sh get-host nixos0
set -Eeuo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROFILES_DIR="$PROJECT_ROOT/configuration/profiles"
HOSTS_DIR="$PROJECT_ROOT/configuration/hosts"

# Colors (disabled for non-interactive use)
if [[ -t 1 ]]; then
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[0;33m'
	BLUE='\033[0;34m'
	CYAN='\033[0;36m'
	NC='\033[0m' # No Color
else
	RED=''
	GREEN=''
	YELLOW=''
	BLUE=''
	CYAN=''
	NC=''
fi

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

print_error() {
	echo -e "${RED}Error:${NC} $1" >&2
}

print_success() {
	echo -e "${GREEN}Success:${NC} $1"
}

print_info() {
	echo -e "${CYAN}Info:${NC} $1"
}

print_warning() {
	echo -e "${YELLOW}Warning:${NC} $1"
}

show_help() {
	cat <<EOF
Usage: $(basename "$0") [COMMAND] [OPTIONS]

Commands:
  list                    List all available profiles
  show <profile>          Show profile details and imports
  create <profile>        Create a new profile from template
  delete <profile>        Delete a profile (with confirmation)
  set-host <host> <profile>  Set profile for a host
  get-host <host>         Get current profile for a host
  help                    Show this help message

Examples:
  $(basename "$0") list
  $(basename "$0") show default
  $(basename "$0") create gaming
  $(basename "$0") delete minimal
  $(basename "$0") set-host popcat19-nixos0 default
  $(basename "$0") get-host popcat19-nixos0

Profile location: configuration/profiles/
Host location: configuration/hosts/
EOF
}

get_profile_file() {
	local profile="$1"
	echo "$PROFILES_DIR/${profile}.nix"
}

profile_exists() {
	local profile="$1"
	[[ -f "$(get_profile_file "$profile")" ]]
}

get_host_config_file() {
	local host="$1"
	echo "$HOSTS_DIR/$host/user-config.nix"
}

host_exists() {
	local host="$1"
	[[ -d "$HOSTS_DIR/$host" ]]
}

# -----------------------------------------------------------------------------
# Commands
# -----------------------------------------------------------------------------

cmd_list() {
	echo -e "${BLUE}Available profiles:${NC}"
	echo ""

	if [[ ! -d "$PROFILES_DIR" ]]; then
		print_error "Profiles directory not found: $PROFILES_DIR"
		exit 1
	fi

	local count=0
	for profile_file in "$PROFILES_DIR"/*.nix; do
		if [[ -f "$profile_file" ]]; then
			local name
			name=$(basename "$profile_file" .nix)
			local purpose
			purpose=$(grep -m1 "^# Purpose:" "$profile_file" 2>/dev/null | sed 's/^# Purpose: //' || echo "No description")
			echo -e "  ${CYAN}$name${NC}"
			echo "    $purpose"
			echo ""
			((count++)) || true
		fi
	done

	if [[ $count -eq 0 ]]; then
		print_warning "No profiles found in $PROFILES_DIR"
	else
		echo -e "Total: ${GREEN}$count${NC} profile(s)"
	fi
}

cmd_show() {
	local profile="$1"

	if [[ -z "$profile" ]]; then
		print_error "Profile name required"
		echo "Usage: $(basename "$0") show <profile>"
		exit 1
	fi

	if ! profile_exists "$profile"; then
		print_error "Profile not found: $profile"
		echo "Available profiles:"
		for f in "$PROFILES_DIR"/*.nix; do
			[[ -f "$f" ]] && echo "  - $(basename "$f" .nix)"
		done
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

	# Show imports
	echo -e "${BLUE}Imports:${NC}"
	grep -E '^\s+\.\./' "$profile_file" 2>/dev/null | sed 's/^[[:space:]]*//' | while read -r line; do
		echo "  $line"
	done || print_warning "No imports found"
}

cmd_create() {
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
		print_error "Cannot delete the default profile"
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
	local host="$1"
	local profile="$2"

	if [[ -z "$host" || -z "$profile" ]]; then
		print_error "Host and profile names required"
		echo "Usage: $(basename "$0") set-host <host> <profile>"
		exit 1
	fi

	if ! host_exists "$host"; then
		print_error "Host not found: $host"
		echo "Available hosts:"
		for d in "$HOSTS_DIR"/*/; do
			[[ -d "$d" ]] && echo "  - $(basename "$d")"
		done
		exit 1
	fi

	if ! profile_exists "$profile"; then
		print_error "Profile not found: $profile"
		echo "Available profiles:"
		for f in "$PROFILES_DIR"/*.nix; do
			[[ -f "$f" ]] && echo "  - $(basename "$f" .nix)"
		done
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
	local host="$1"

	if [[ -z "$host" ]]; then
		print_error "Host name required"
		echo "Usage: $(basename "$0") get-host <host>"
		exit 1
	fi

	if ! host_exists "$host"; then
		print_error "Host not found: $host"
		echo "Available hosts:"
		for d in "$HOSTS_DIR"/*/; do
			[[ -d "$d" ]] && echo "  - $(basename "$d")"
		done
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
	set-host)
		cmd_set_host "$@"
		;;
	get-host)
		cmd_get_host "$@"
		;;
	help | --help | -h)
		show_help
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
