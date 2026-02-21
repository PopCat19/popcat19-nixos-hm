# build.sh
#
# Purpose: NixOS rebuild wrapper with profile context
#
# This module:
# - Wraps nixos-rebuild with profile-aware operations
# - Provides interactive build menu with gum
# - Validates build prerequisites before execution
# - Reports build success/failure with appropriate messages

# shellcheck shell=bash

# Source shared utilities and discovery functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
# shellcheck source=discover.sh
source "$SCRIPT_DIR/discover.sh"

# -----------------------------------------------------------------------------
# Build Validation
# -----------------------------------------------------------------------------

check_nix_available() {
	# Verify Nix is installed and available
	# Returns: 0 if available, 1 if not
	if ! command -v nix &>/dev/null; then
		print_error "Nix is not installed or not in PATH"
		echo "Install from: https://nixos.org/download" >&2
		return 1
	fi
	return 0
}

check_nixos_environment() {
	# Verify running in NixOS environment for nixos-rebuild
	# Returns: 0 if in NixOS, 1 if not
	if [[ ! -f /etc/NIXOS ]]; then
		print_error "Not running in NixOS environment"
		echo "nixos-rebuild requires NixOS" >&2
		return 1
	fi
	return 0
}

check_uncommitted_changes() {
	# Warn about uncommitted changes before build
	# Returns: 0 always (just a warning)
	if git rev-parse --is-inside-work-tree &>/dev/null; then
		if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
			print_warning "You have uncommitted changes"
			echo "Consider committing before building for reproducibility" >&2
		fi
	fi
	return 0
}

# -----------------------------------------------------------------------------
# Build Operations
# -----------------------------------------------------------------------------

stage_for_flake() {
	# Stage files for flake visibility
	# Nix flakes read from git tree, not working directory
	# Returns: 0 on success
	git add --intent-to-add . 2>/dev/null || true
	git add . 2>/dev/null || true
	return 0
}

cmd_build() {
	# Execute nixos-rebuild with specified action
	# Args: $1 - action (test, switch, build, dry-run, dry-build)
	#       $2 - host (optional, defaults to current host)
	# Returns: 0 on success, 1 on failure
	local action="${1:-test}"
	local host="${2:-}"

	# Validate action
	case "$action" in
	test | switch | build | dry-run | dry-build) ;;
	*)
		print_error "Invalid build action: $action"
		echo "Valid actions: test, switch, build, dry-run, dry-build" >&2
		return 1
		;;
	esac

	# Check prerequisites
	if ! check_nix_available; then
		return 1
	fi

	if ! check_nixos_environment; then
		return 1
	fi

	# Warn about uncommitted changes
	check_uncommitted_changes

	# Stage files for flake
	stage_for_flake

	# Build the command
	local build_cmd
	if [[ -n "$host" ]]; then
		build_cmd="sudo nixos-rebuild $action --flake .#$host"
	else
		build_cmd="sudo nixos-rebuild $action --flake ."
	fi

	# Execute with gum spin
	print_info "Building with action: $action"
	if [[ -n "$host" ]]; then
		print_info "Target host: $host"
	fi

	if gum spin --spinner dot --title "Building ($action)..." -- sh -c "$build_cmd 2>&1"; then
		print_success "Build completed: $action"
		return 0
	else
		print_error "Build failed: $action"
		return 1
	fi
}

# -----------------------------------------------------------------------------
# Interactive Build Menu
# -----------------------------------------------------------------------------

cmd_build_interactive() {
	# Interactive build menu with host selection
	# Returns: 0 on success, 1 on failure
	clear
	gum style --foreground 212 --bold "Build NixOS Configuration"
	echo ""

	# Check prerequisites
	if ! check_nix_available; then
		return 1
	fi

	if ! check_nixos_environment; then
		return 1
	fi

	# Get available hosts
	local hosts=()
	mapfile -t hosts < <(list_hosts)

	local selected_host=""

	# Ask which host to build for if multiple available
	if [[ ${#hosts[@]} -gt 1 ]]; then
		selected_host=$(gum choose "${hosts[@]}" "Current host" --header "Select host to build:" --height 15)

		if [[ -z "$selected_host" ]]; then
			return 0
		fi

		if [[ "$selected_host" == "Current host" ]]; then
			selected_host=""
		fi
	elif [[ ${#hosts[@]} -eq 1 ]]; then
		if gum confirm "Build for host: ${hosts[0]}?"; then
			selected_host="${hosts[0]}"
		else
			selected_host=""
		fi
	fi

	# Show current profile for selected host
	if [[ -n "$selected_host" ]]; then
		local current_profile
		current_profile=$(get_host_profile "$selected_host")
		if [[ -n "$current_profile" ]]; then
			gum style --foreground 146 "Current profile: $current_profile"
		fi
	else
		gum style --foreground 240 "Building for current host"
	fi
	echo ""

	# Build action menu
	local actions=(
		"Test build (apply without boot entry)"
		"Switch (apply and set as boot default)"
		"Dry run (show what would change)"
		"Build only (build without applying)"
		"Dry build (build without applying, show derivation)"
		"Cancel"
	)

	local action_choice
	action_choice=$(gum choose "${actions[@]}" --header "Select build action:" --height 8)

	if [[ -z "$action_choice" || "$action_choice" == "Cancel" ]]; then
		gum style --foreground 240 "Build cancelled"
		return 0
	fi

	# Map choice to action
	local action=""
	case "$action_choice" in
	"Test build (apply without boot entry)")
		action="test"
		;;
	"Switch (apply and set as boot default)")
		action="switch"
		;;
	"Dry run (show what would change)")
		action="dry-run"
		;;
	"Build only (build without applying)")
		action="build"
		;;
	"Dry build (build without applying, show derivation)")
		action="dry-build"
		;;
	esac

	# Execute build
	cmd_build "$action" "$selected_host"
}

# -----------------------------------------------------------------------------
# CLI Entry Point
# -----------------------------------------------------------------------------

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	case "${1:-}" in
	test | switch | build | dry-run | dry-build)
		cmd_build "$@"
		;;
	*)
		cmd_build_interactive
		;;
	esac
fi
