# host.sh
#
# Purpose: Host configuration and profile assignment management
#
# This module:
# - Manages host profile assignments in user-config.nix
# - Provides interactive host management interface
# - Rewrites profile settings with validation
# - Displays host configuration summaries

# shellcheck shell=bash

# Source shared utilities and discovery functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
# shellcheck source=discover.sh
source "$SCRIPT_DIR/discover.sh"

# -----------------------------------------------------------------------------
# Host Profile Rewriting
# -----------------------------------------------------------------------------

rewrite_host_profile() {
	# Update the profile field in a host's user-config.nix
	# Args: $1 - host name
	#       $2 - new profile name
	# Returns: 0 on success, 1 on failure
	#
	# Creates backup, validates with nix-instantiate, then replaces
	local host="$1"
	local profile="$2"
	local host_config
	host_config=$(get_host_config_file "$host")

	if [[ ! -f "$host_config" ]]; then
		print_error "Host config not found: $host_config"
		return 1
	fi

	# Validate profile exists
	if ! profile_exists "$profile"; then
		print_error "Profile not found: $profile"
		return 1
	fi

	local tmp="${host_config}.tmp"
	local bak="${host_config}.bak"

	# Create backup
	cp "$host_config" "$bak"

	# Update profile line
	sed "s/profile = \"[^\"]*\";/profile = \"$profile\";/" "$host_config" >"$tmp"

	# Validate the result
	if nix-instantiate --parse "$tmp" >/dev/null 2>&1; then
		mv "$tmp" "$host_config"
		rm "$bak"
		print_success "Set $host profile to $profile"
		return 0
	else
		mv "$bak" "$host_config"
		rm -f "$tmp"
		print_error "Failed to update host profile: invalid Nix syntax"
		return 1
	fi
}

# -----------------------------------------------------------------------------
# Host Details Display
# -----------------------------------------------------------------------------

show_host_details() {
	# Display detailed information about a host configuration
	# Args: $1 - host name
	local host="$1"
	local host_dir="$HOSTS_DIR/$host"

	if [[ ! -d "$host_dir" ]]; then
		print_error "Host not found: $host"
		return 1
	fi

	local config_file
	config_file=$(get_host_config_file "$host")

	echo -e "${BLUE}Host:${NC} $host"
	echo -e "${BLUE}Directory:${NC} $host_dir"
	echo ""

	# Show current profile
	local current_profile
	current_profile=$(get_host_profile "$host")
	if [[ -n "$current_profile" ]]; then
		echo -e "${BLUE}Profile:${NC} $current_profile"
	else
		echo -e "${YELLOW}Profile:${NC} (not set)"
	fi
	echo ""

	# Show config file contents summary
	if [[ -f "$config_file" ]]; then
		echo -e "${BLUE}Config file:${NC} $config_file"

		# Extract key settings from user-config.nix
		local username
		username=$(grep -m1 'username = "' "$config_file" 2>/dev/null | sed 's/.*username = "\([^"]*\)".*/\1/')
		if [[ -n "$username" ]]; then
			echo -e "${BLUE}Username:${NC} $username"
		fi

		local hostname
		hostname=$(grep -m1 'hostname = "' "$config_file" 2>/dev/null | sed 's/.*hostname = "\([^"]*\)".*/\1/')
		if [[ -n "$hostname" ]]; then
			echo -e "${BLUE}Hostname:${NC} $hostname"
		fi
	fi

	# List host-specific files
	echo ""
	echo -e "${BLUE}Host files:${NC}"
	local files=()
	while IFS= read -r -d '' file; do
		files+=("$(basename "$file")")
	done < <(find "$host_dir" -maxdepth 2 -type f -name "*.nix" -print0 2>/dev/null)

	for file in "${files[@]}"; do
		echo "  • $file"
	done
}

# -----------------------------------------------------------------------------
# Interactive Host Management
# -----------------------------------------------------------------------------

cmd_host_assignments() {
	# View and change host profile assignments
	clear
	gum style --foreground 212 --bold "Host Assignments"
	echo ""

	# Get all hosts
	local hosts=()
	mapfile -t hosts < <(list_hosts)

	if [[ ${#hosts[@]} -eq 0 ]]; then
		gum style --foreground 240 "No hosts found in $HOSTS_DIR"
		return 0
	fi

	# Show current assignments
	gum style --foreground 146 "Current assignments:"
	echo ""
	for host in "${hosts[@]}"; do
		local profile
		profile=$(get_host_profile "$host")
		if [[ -n "$profile" ]]; then
			echo "  $host → $profile"
		else
			echo "  $host → (not set)"
		fi
	done

	echo ""
	local action
	action=$(gum choose "Change assignment" "View host details" "Back" --header "What would you like to do?" --height 6)

	case "$action" in
	"Change assignment")
		# Select host
		local selected_host
		selected_host=$(gum choose "${hosts[@]}" --header "Select a host:" --height 15)

		if [[ -z "$selected_host" ]]; then
			return 0
		fi

		# Select profile
		local profiles=()
		mapfile -t profiles < <(list_profiles)

		if [[ ${#profiles[@]} -eq 0 ]]; then
			print_error "No profiles available"
			return 1
		fi

		local selected_profile
		selected_profile=$(gum choose "${profiles[@]}" --header "Select profile for $selected_host:" --height 15)

		if [[ -z "$selected_profile" ]]; then
			return 0
		fi

		# Update the host config
		rewrite_host_profile "$selected_host" "$selected_profile"
		;;
	"View host details")
		# Select host
		local selected_host
		selected_host=$(gum choose "${hosts[@]}" --header "Select a host to view:" --height 15)

		if [[ -z "$selected_host" ]]; then
			return 0
		fi

		clear
		show_host_details "$selected_host"
		;;
	"Back")
		return 0
		;;
	esac
}

cmd_hosts_interactive() {
	# Full interactive host management menu
	# Returns: 0 on success, 1 on failure
	clear
	gum style --foreground 212 --bold "Host Management"
	echo ""

	# Get all hosts
	local hosts=()
	mapfile -t hosts < <(list_hosts)

	if [[ ${#hosts[@]} -eq 0 ]]; then
		gum style --foreground 240 "No hosts found in $HOSTS_DIR"
		return 0
	fi

	# Show summary
	gum style --foreground 146 "Discovered ${#hosts[@]} host(s):"
	echo ""
	for host in "${hosts[@]}"; do
		local profile
		profile=$(get_host_profile "$host")
		if [[ -n "$profile" ]]; then
			echo "  $host → $profile"
		else
			echo "  $host → (not set)"
		fi
	done

	echo ""
	local action
	action=$(gum choose "View all hosts and profiles" "Change host profile" "View host details" "Back" --header "Select action:" --height 7)

	case "$action" in
	"View all hosts and profiles")
		clear
		gum style --foreground 212 --bold "All Hosts and Profiles"
		echo ""
		for host in "${hosts[@]}"; do
			show_host_details "$host"
			echo ""
		done
		;;
	"Change host profile")
		# Select host
		local selected_host
		selected_host=$(gum choose "${hosts[@]}" --header "Select a host:" --height 15)

		if [[ -z "$selected_host" ]]; then
			return 0
		fi

		# Select profile
		local profiles=()
		mapfile -t profiles < <(list_profiles)

		if [[ ${#profiles[@]} -eq 0 ]]; then
			print_error "No profiles available"
			return 1
		fi

		local selected_profile
		selected_profile=$(gum choose "${profiles[@]}" --header "Select profile for $selected_host:" --height 15)

		if [[ -z "$selected_profile" ]]; then
			return 0
		fi

		# Update the host config
		rewrite_host_profile "$selected_host" "$selected_profile"
		;;
	"View host details")
		# Select host
		local selected_host
		selected_host=$(gum choose "${hosts[@]}" --header "Select a host to view:" --height 15)

		if [[ -z "$selected_host" ]]; then
			return 0
		fi

		clear
		show_host_details "$selected_host"
		;;
	"Back")
		return 0
		;;
	esac
}

# -----------------------------------------------------------------------------
# CLI Entry Point
# -----------------------------------------------------------------------------

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	case "${1:-}" in
	show)
		show_host_details "${2:-}"
		;;
	set-profile)
		if [[ -z "${2:-}" || -z "${3:-}" ]]; then
			echo "Usage: $0 set-profile <host> <profile>"
			exit 1
		fi
		rewrite_host_profile "$2" "$3"
		;;
	list)
		list_hosts
		;;
	*)
		cmd_hosts_interactive
		;;
	esac
fi
