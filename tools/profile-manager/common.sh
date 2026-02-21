# common.sh
#
# Purpose: Shared utilities and constants for profile manager modules
#
# This module:
# - Defines path constants for project directories
# - Provides color output helpers with non-interactive detection
# - Supplies path conversion utilities for Nix imports
# - Validates required command availability

# shellcheck shell=bash

# -----------------------------------------------------------------------------
# Path Constants
# -----------------------------------------------------------------------------

# Determine project root relative to this script's location
PROFILE_MANAGER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$PROFILE_MANAGER_DIR/../.." && pwd)"

# Directory paths
PROFILES_DIR="$PROJECT_ROOT/configuration/profiles"
HOSTS_DIR="$PROJECT_ROOT/configuration/hosts"
# shellcheck disable=SC2034 # Used by discover.sh
SYSTEM_MODULES_DIR="$PROJECT_ROOT/configuration/system/modules"
# shellcheck disable=SC2034 # Used by discover.sh
HOME_MODULES_DIR="$PROJECT_ROOT/configuration/home/modules"

# -----------------------------------------------------------------------------
# Color Definitions
# -----------------------------------------------------------------------------

# Detect non-interactive mode and disable colors accordingly
if [[ -t 1 ]]; then
	RED='\033[0;31m'
	GREEN='\033[0;32m'
	YELLOW='\033[0;33m'
	# shellcheck disable=SC2034 # Used by profile-manager.sh
	BLUE='\033[0;34m'
	CYAN='\033[0;36m'
	# shellcheck disable=SC2034 # Reserved for future use
	BOLD='\033[1m'
	NC='\033[0m' # No Color
else
	RED=''
	GREEN=''
	YELLOW=''
	# shellcheck disable=SC2034 # Used by profile-manager.sh
	BLUE=''
	CYAN=''
	# shellcheck disable=SC2034 # Reserved for future use
	BOLD=''
	NC=''
fi

# -----------------------------------------------------------------------------
# Output Functions
# -----------------------------------------------------------------------------

print_error() {
	# Print error message to stderr
	# Args: $1 - message text
	echo -e "${RED}Error:${NC} $1" >&2
}

print_success() {
	# Print success message to stdout
	# Args: $1 - message text
	echo -e "${GREEN}Success:${NC} $1"
}

print_info() {
	# Print informational message to stdout
	# Args: $1 - message text
	echo -e "${CYAN}Info:${NC} $1"
}

print_warning() {
	# Print warning message to stdout
	# Args: $1 - message text
	echo -e "${YELLOW}Warning:${NC} $1"
}

# -----------------------------------------------------------------------------
# Command Validation
# -----------------------------------------------------------------------------

require_cmd() {
	# Check if a required command is available
	# Args: $1 - command name
	# Returns: 0 if available, exits with 1 if not
	local cmd="$1"
	if ! command -v "$cmd" &>/dev/null; then
		print_error "Required command not found: $cmd"
		return 1
	fi
	return 0
}

# -----------------------------------------------------------------------------
# Path Conversion Utilities
# -----------------------------------------------------------------------------

nix_path_to_label() {
	# Convert a Nix import path to a human-readable label
	# Args: $1 - Nix path (e.g., "../system/modules/audio.nix")
	# Returns: Label string (e.g., "system/audio")
	#
	# Examples:
	#   ../system/modules/audio.nix -> system/audio
	#   ../home/modules/git.nix     -> home/git
	#   ../base/configuration.nix   -> base/configuration
	#   ./default.nix               -> profile/default
	local nix_path="$1"
	local label=""

	# Remove leading ../ or ./
	local clean_path="${nix_path#\.\./}"
	clean_path="${clean_path#\./}"

	# Handle system/modules path
	if [[ "$clean_path" == "system/modules/"* ]]; then
		label="${clean_path#system/modules/}"
		label="system/${label%.nix}"
	# Handle home/modules path
	elif [[ "$clean_path" == "home/modules/"* ]]; then
		label="${clean_path#home/modules/}"
		label="home/${label%.nix}"
	# Handle base path
	elif [[ "$clean_path" == "base/"* ]]; then
		label="${clean_path#base/}"
		label="base/${label%.nix}"
	# Handle profile imports (./default.nix)
	elif [[ "$clean_path" == "default.nix" ]]; then
		label="profile/default"
	# Handle nix-options.nix
	elif [[ "$clean_path" == "nix-options.nix" ]]; then
		label="nix-options"
	# Handle stateversion.nix
	elif [[ "$clean_path" == "stateversion.nix" ]]; then
		label="stateversion"
	# Fallback: just remove .nix extension
	else
		label="${clean_path%.nix}"
	fi

	echo "$label"
}

label_to_nix_path() {
	# Convert a human-readable label back to a Nix import path
	# Args: $1 - Label (e.g., "system/audio")
	#       $2 - Context directory for relative path (optional, defaults to profiles dir)
	# Returns: Nix path (e.g., "../system/modules/audio.nix")
	#
	# Examples:
	#   system/audio -> ../system/modules/audio.nix
	#   home/git     -> ../home/modules/git.nix
	#   base/configuration -> ../base/configuration.nix
	local label="$1"
	local prefix="../"

	# Parse label parts
	local category="${label%%/*}"
	local name="${label#*/}"

	case "$category" in
	system)
		echo "${prefix}system/modules/${name}.nix"
		;;
	home)
		echo "${prefix}home/modules/${name}.nix"
		;;
	base)
		echo "${prefix}base/${name}.nix"
		;;
	profile)
		# Profile reference (e.g., profile/default -> ./default.nix)
		echo "./${name}.nix"
		;;
	nix-options)
		echo "${prefix}nix-options.nix"
		;;
	stateversion)
		echo "${prefix}stateversion.nix"
		;;
	*)
		# Unknown category, return as-is with .nix extension
		echo "${prefix}${label}.nix"
		;;
	esac
}

# -----------------------------------------------------------------------------
# Profile Utilities
# -----------------------------------------------------------------------------

get_profile_file() {
	# Get the full path to a profile file
	# Args: $1 - profile name
	# Returns: Absolute path to profile .nix file
	local profile="$1"
	echo "$PROFILES_DIR/${profile}.nix"
}

profile_exists() {
	# Check if a profile exists
	# Args: $1 - profile name
	# Returns: 0 if exists, 1 if not
	local profile="$1"
	[[ -f "$(get_profile_file "$profile")" ]]
}

get_host_config_file() {
	# Get the path to a host's user-config.nix
	# Args: $1 - host name
	# Returns: Path to user-config.nix
	local host="$1"
	echo "$HOSTS_DIR/$host/user-config.nix"
}

host_exists() {
	# Check if a host directory exists
	# Args: $1 - host name
	# Returns: 0 if exists, 1 if not
	local host="$1"
	[[ -d "$HOSTS_DIR/$host" ]]
}
