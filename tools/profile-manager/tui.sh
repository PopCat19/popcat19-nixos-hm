#!/usr/bin/env bash
# tui.sh
#
# Purpose: Terminal UI for interactive profile management using gum
#
# This module:
# - Provides interactive menu for profile operations
# - Displays profile information with inheritance visualization
# - Offers user-friendly navigation via gum choose
# - Integrates edit and diff modules for full functionality

set -Eeuo pipefail

# Source shared utilities and discovery functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
# shellcheck source=discover.sh
source "$SCRIPT_DIR/discover.sh"
# shellcheck source=edit.sh
source "$SCRIPT_DIR/edit.sh"
# shellcheck source=diff.sh
source "$SCRIPT_DIR/diff.sh"
# shellcheck source=host.sh
source "$SCRIPT_DIR/host.sh"
# shellcheck source=build.sh
source "$SCRIPT_DIR/build.sh"

# -----------------------------------------------------------------------------
# Gum Runtime Check
# -----------------------------------------------------------------------------

check_gum() {
	# Verify gum is available for TUI operation
	if ! command -v gum &>/dev/null; then
		print_error "gum is required for TUI mode"
		echo "Install with: nix-shell -p gum" >&2
		echo "Or run: nix-shell -p gum --run './profile-manager.sh tui'" >&2
		exit 1
	fi
}

# -----------------------------------------------------------------------------
# Menu Display
# -----------------------------------------------------------------------------

show_header() {
	# Display the TUI header with project info
	clear
	gum style --border double --padding "1 2" --margin "0 0" \
		"$(gum style --foreground 212 --bold 'Profile Manager TUI')"
	echo ""
}

main_menu() {
	# Display main menu and handle selection loop
	local options=(
		"Browse profiles"
		"Edit profile modules"
		"Create new profile"
		"Delete profile"
		"Host assignments"
		"Build / rebuild"
		"Review changes"
		"Quit"
	)

	while true; do
		show_header

		local choice
		choice=$(gum choose "${options[@]}" --header "Select an action:" --height 10)

		case "$choice" in
		"Browse profiles")
			cmd_browse
			;;
		"Edit profile modules")
			cmd_edit_modules
			;;
		"Create new profile")
			cmd_create_profile
			;;
		"Delete profile")
			cmd_delete_profile
			;;
		"Host assignments")
			cmd_host_assignments
			;;
		"Build / rebuild")
			cmd_build
			;;
		"Review changes")
			cmd_review
			;;
		"Quit")
			echo ""
			gum style --foreground 240 "Goodbye!"
			exit 0
			;;
		esac

		# Pause before returning to menu (except for Quit)
		if [[ "$choice" != "Quit" ]]; then
			echo ""
			gum style --foreground 240 "Press Enter to continue..."
			read -r
		fi
	done
}

# -----------------------------------------------------------------------------
# Browse Command
# -----------------------------------------------------------------------------

cmd_browse() {
	# Show profile with inheritance display (direct vs inherited modules)
	show_header
	gum style --foreground 212 --bold "Browse Profiles"
	echo ""

	# Get list of profiles
	local profiles
	mapfile -t profiles < <(list_profiles)

	if [[ ${#profiles[@]} -eq 0 ]]; then
		gum style --foreground 214 "No profiles found in $PROFILES_DIR"
		return 1
	fi

	# Let user select a profile
	local selected_profile
	selected_profile=$(gum choose "${profiles[@]}" --header "Select a profile to view:" --height 15)

	if [[ -z "$selected_profile" ]]; then
		return 0
	fi

	# Show profile details
	show_profile_details "$selected_profile"
}

show_profile_details() {
	# Display detailed information about a profile
	# Args: $1 - profile name
	local profile="$1"
	local profile_file
	profile_file=$(get_profile_file "$profile")

	clear
	gum style --foreground 212 --bold "Profile: $profile"
	echo ""

	# Show file path
	gum style --foreground 240 "File: $profile_file"
	echo ""

	# Extract and show purpose from header
	local purpose
	purpose=$(grep -m1 "^# Purpose:" "$profile_file" 2>/dev/null | sed 's/^# Purpose: //')
	if [[ -n "$purpose" ]]; then
		gum style --foreground 214 "Purpose: $purpose"
		echo ""
	fi

	# Show inheritance chain
	local chain=()
	mapfile -t chain < <(resolve_inheritance_chain "$profile")

	if [[ ${#chain[@]} -gt 1 ]]; then
		gum style --foreground 146 --bold "Inheritance Chain:"
		local chain_str=""
		for ((i = 0; i < ${#chain[@]}; i++)); do
			if [[ $i -eq 0 ]]; then
				chain_str="${chain[$i]}"
			else
				chain_str="$chain_str → ${chain[$i]}"
			fi
		done
		gum style --foreground 146 "  $chain_str"
		echo ""
	fi

	# Classify and display system modules
	show_module_classification "$profile" "system"

	# Classify and display home modules
	show_module_classification "$profile" "home"
}

show_module_classification() {
	# Display modules classified as direct/inherited/available
	# Args: $1 - profile name
	#       $2 - module type ("system" or "home")
	local profile="$1"
	local module_type="$2"

	# Get classification
	local classification
	mapfile -t classification < <(classify_modules "$profile" "$module_type")

	local direct="${classification[0]}"
	local inherited="${classification[1]}"
	local available="${classification[2]}"

	# Header for module type
	gum style --foreground 212 --bold "${module_type^} Modules:"

	# Direct modules
	if [[ -n "$direct" ]]; then
		gum style --foreground 82 "  Direct (in this profile):"
		for module in $direct; do
			echo "    • $module"
		done
	else
		gum style --foreground 240 "  Direct: (none)"
	fi

	# Inherited modules
	if [[ -n "$inherited" ]]; then
		gum style --foreground 214 "  Inherited (from parent profiles):"
		for module in $inherited; do
			echo "    • $module"
		done
	else
		gum style --foreground 240 "  Inherited: (none)"
	fi

	# Available modules
	if [[ -n "$available" ]]; then
		gum style --foreground 240 "  Available (not in profile):"
		local avail_count=0
		for module in $available; do
			((avail_count++)) || true
		done
		echo "    ($avail_count modules available)"
	else
		gum style --foreground 240 "  Available: (none)"
	fi

	echo ""
}

# -----------------------------------------------------------------------------
# Command Wrappers
# -----------------------------------------------------------------------------

# Wrapper functions to match main_menu naming expectations

cmd_create_profile() {
	# Wrapper for cmd_create_interactive from edit.sh
	cmd_create_interactive
}

cmd_delete_profile() {
	# Wrapper for cmd_delete_interactive from edit.sh
	cmd_delete_interactive
}

cmd_build() {
	# Build / rebuild - delegates to build.sh
	cmd_build_interactive
}

# Note: cmd_edit_modules is defined in edit.sh
# Note: cmd_host_assignments is defined in host.sh
# Note: cmd_review is defined in diff.sh

# -----------------------------------------------------------------------------
# TUI Entry Point
# -----------------------------------------------------------------------------

run_tui() {
	# Main entry point for TUI mode
	check_gum
	main_menu
}

# Run TUI if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	run_tui
fi
