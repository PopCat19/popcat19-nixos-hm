#!/usr/bin/env bash

# profile-manager-tui.sh
#
# Purpose: Interactive terminal UI for profile operations
#
# This module:
# - Provides menu-driven interface for managing host profiles
# - Wraps profile-manager.sh functionality for easier use
# - Supports creating, setting, and getting host profile assignments
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_MANAGER="$SCRIPT_DIR/profile-manager/profile-manager.sh"

# Colors
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

show_menu() {
	clear
	echo -e "${BLUE}=== Profile Manager TUI ===${NC}"
	echo ""
	echo "1) List profiles"
	echo "2) Show profile details"
	echo "3) Create new profile"
	echo "4) Delete profile"
	echo "5) Set host profile"
	echo "6) Get host profile"
	echo "q) Quit"
	echo ""
}

press_enter() {
	echo ""
	read -r -p "Press Enter to continue..."
}

main() {
	while true; do
		show_menu
		read -r -p "Select option: " choice
		case $choice in
		1)
			echo ""
			"$PROFILE_MANAGER" list
			press_enter
			;;
		2)
			echo ""
			read -r -p "Profile name: " profile
			"$PROFILE_MANAGER" show "$profile"
			press_enter
			;;
		3)
			echo ""
			read -r -p "New profile name: " profile
			"$PROFILE_MANAGER" create "$profile"
			press_enter
			;;
		4)
			echo ""
			read -r -p "Profile to delete: " profile
			"$PROFILE_MANAGER" delete "$profile"
			press_enter
			;;
		5)
			echo ""
			read -r -p "Host name: " host
			read -r -p "Profile name: " profile
			"$PROFILE_MANAGER" set-host "$host" "$profile"
			press_enter
			;;
		6)
			echo ""
			read -r -p "Host name: " host
			"$PROFILE_MANAGER" get-host "$host"
			press_enter
			;;
		q | Q)
			echo ""
			echo "Goodbye!"
			exit 0
			;;
		*)
			echo -e "${RED}Invalid option${NC}"
			sleep 1
			;;
		esac
	done
}

main "$@"
