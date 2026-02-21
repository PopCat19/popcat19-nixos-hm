# discover.sh
#
# Purpose: Filesystem scanner for discovering profiles, modules, and imports
#
# This module:
# - Discovers system and home modules from filesystem
# - Parses Nix import arrays from profile files
# - Resolves profile inheritance chains
# - Classifies modules by their relationship to a profile

# shellcheck shell=bash

# Source shared utilities
# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# -----------------------------------------------------------------------------
# Module Discovery
# -----------------------------------------------------------------------------

discover_system_modules() {
	# List all system module paths (individual .nix files, not barrel)
	# Returns: Array of module names (one per line)
	#
	# Output format: module name without .nix extension
	# Example: audio, display, fish, fonts, etc.
	local modules=()

	if [[ ! -d "$SYSTEM_MODULES_DIR" ]]; then
		print_warning "System modules directory not found: $SYSTEM_MODULES_DIR"
		return 1
	fi

	# Find all .nix files except default.nix (barrel file)
	while IFS= read -r -d '' file; do
		local name
		name=$(basename "$file" .nix)
		# Skip barrel files and non-module scripts
		if [[ "$name" != "default" && ! "$name" =~ \.sh$ ]]; then
			modules+=("$name")
		fi
	done < <(find "$SYSTEM_MODULES_DIR" -maxdepth 1 -name "*.nix" -type f -print0 2>/dev/null)

	# Sort and output
	printf '%s\n' "${modules[@]}" | sort
}

discover_home_modules() {
	# List all individual home module paths (not the barrel default.nix)
	# Returns: Array of module names (one per line)
	#
	# Output format: module name without .nix extension
	# Example: git, kitty, micro, etc.
	local modules=()

	if [[ ! -d "$HOME_MODULES_DIR" ]]; then
		print_warning "Home modules directory not found: $HOME_MODULES_DIR"
		return 1
	fi

	# Find all .nix files except default.nix (barrel file)
	while IFS= read -r -d '' file; do
		local name
		name=$(basename "$file" .nix)
		if [[ "$name" != "default" ]]; then
			modules+=("$name")
		fi
	done < <(find "$HOME_MODULES_DIR" -maxdepth 1 -name "*.nix" -type f -print0 2>/dev/null)

	# Sort and output
	printf '%s\n' "${modules[@]}" | sort
}

# -----------------------------------------------------------------------------
# Profile Discovery
# -----------------------------------------------------------------------------

list_profiles() {
	# Scan profiles directory and list all available profiles
	# Returns: Array of profile names (one per line)
	#
	# Output format: profile name without .nix extension
	# Example: default, laptop, minimal, surface
	local profiles=()

	if [[ ! -d "$PROFILES_DIR" ]]; then
		print_warning "Profiles directory not found: $PROFILES_DIR"
		return 1
	fi

	while IFS= read -r -d '' file; do
		local name
		name=$(basename "$file" .nix)
		profiles+=("$name")
	done < <(find "$PROFILES_DIR" -maxdepth 1 -name "*.nix" -type f -print0 2>/dev/null)

	# Sort and output (default first, then alphabetical)
	local default_profile=""
	local other_profiles=()

	for profile in "${profiles[@]}"; do
		if [[ "$profile" == "default" ]]; then
			default_profile="$profile"
		else
			other_profiles+=("$profile")
		fi
	done

	if [[ -n "$default_profile" ]]; then
		echo "$default_profile"
	fi
	printf '%s\n' "${other_profiles[@]}" | sort
}

list_hosts() {
	# Scan hosts directory and list all available hosts
	# Returns: Array of host names (one per line)
	#
	# Output format: host directory name
	# Example: nixos0, surface-go
	local hosts=()

	if [[ ! -d "$HOSTS_DIR" ]]; then
		print_warning "Hosts directory not found: $HOSTS_DIR"
		return 1
	fi

	while IFS= read -r -d '' dir; do
		local name
		name=$(basename "$dir")
		hosts+=("$name")
	done < <(find "$HOSTS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

	# Sort and output
	printf '%s\n' "${hosts[@]}" | sort
}

# -----------------------------------------------------------------------------
# Import Parsing
# -----------------------------------------------------------------------------

parse_profile_imports() {
	# Extract imports array from a .nix file
	# Args: $1 - path to profile .nix file
	# Returns: Array of import paths (one per line)
	#
	# Parses the imports = [ ... ]; block
	# Handles edge cases:
	# - Comments between imports (lines starting with #)
	# - Trailing commas (Nix allows them)
	# - Blank lines in imports block
	# - Inline imports on same line as brackets
	# - Multiple imports on same line
	#
	# Example output: ../system/modules/audio.nix, ./default.nix
	local profile_file="$1"
	local in_imports=0
	local imports=()

	if [[ ! -f "$profile_file" ]]; then
		print_error "Profile file not found: $profile_file"
		return 1
	fi

	# Parse the imports array
	# Strategy: Find "imports = [" then collect paths until "]"
	while IFS= read -r line || [[ -n "$line" ]]; do
		# Check for start of imports array
		if [[ "$line" =~ ^[[:space:]]*imports[[:space:]]*=[[:space:]]*\[ ]]; then
			in_imports=1
			# Check if the line also contains paths (inline import)
			# Extract all paths from the line, not just the first
			while IFS= read -r path; do
				if [[ -n "$path" ]]; then
					imports+=("$path")
				fi
			done < <(echo "$line" | grep -oE '(\.\./|\./)[^[:space:];\]]+\.nix' 2>/dev/null)
			continue
		fi

		# Check for end of imports array
		if [[ $in_imports -eq 1 && "$line" =~ \][[:space:]]*\;?[[:space:]]*$ ]]; then
			# Check if there's a path before the closing bracket
			while IFS= read -r path; do
				if [[ -n "$path" ]]; then
					imports+=("$path")
				fi
			done < <(echo "$line" | grep -oE '(\.\./|\./)[^[:space:];\]]+\.nix' 2>/dev/null)
			break
		fi

		# Collect import paths while inside the array
		if [[ $in_imports -eq 1 ]]; then
			# Skip comment-only lines
			if [[ "$line" =~ ^[[:space:]]*# ]]; then
				continue
			fi

			# Skip blank lines
			if [[ "$line" =~ ^[[:space:]]*$ ]]; then
				continue
			fi

			# Match lines containing relative paths
			if [[ "$line" =~ \.\./ || "$line" =~ \./ ]]; then
				# Remove inline comments (everything after # not in a string)
				local clean_line="${line%%#*}"

				# Remove trailing commas and whitespace
				clean_line="${clean_line%,}"

				# Extract all paths from the line (handles multiple imports per line)
				while IFS= read -r path; do
					if [[ -n "$path" ]]; then
						# Remove trailing comma if present
						path="${path%,}"
						imports+=("$path")
					fi
				done < <(echo "$clean_line" | grep -oE '(\.\./|\./)[^[:space:];,]+\.nix' 2>/dev/null)
			fi
		fi
	done <"$profile_file"

	# Output imports
	printf '%s\n' "${imports[@]}"
}

# -----------------------------------------------------------------------------
# Inheritance Resolution
# -----------------------------------------------------------------------------

get_parent_profile() {
	# Detect if a profile imports another profile (e.g., ./default.nix)
	# Args: $1 - path to profile .nix file
	# Returns: Parent profile name or empty string if standalone
	#
	# Example: laptop.nix imports ./default.nix -> returns "default"
	local profile_file="$1"
	local parent=""

	if [[ ! -f "$profile_file" ]]; then
		return 1
	fi

	# Get imports and look for profile references
	local imports
	imports=$(parse_profile_imports "$profile_file")

	while IFS= read -r import_path; do
		# Check for relative profile import (./something.nix)
		if [[ "$import_path" =~ ^\./([^/]+)\.nix$ ]]; then
			parent="${BASH_REMATCH[1]}"
			break
		fi
	done <<<"$imports"

	echo "$parent"
}

resolve_inheritance_chain() {
	# Follow profile→parent imports recursively
	# Args: $1 - profile name
	# Returns: Inheritance chain from child to root (one per line)
	#
	# Example: surface -> default (surface inherits from default)
	# Output: surface, default
	local profile="$1"
	local chain=()
	local current="$profile"
	local max_depth=10 # Prevent infinite loops
	local depth=0

	while [[ -n "$current" && $depth -lt $max_depth ]]; do
		chain+=("$current")
		local profile_file
		profile_file=$(get_profile_file "$current")

		if [[ ! -f "$profile_file" ]]; then
			break
		fi

		local parent
		parent=$(get_parent_profile "$profile_file")

		if [[ -z "$parent" ]]; then
			break
		fi

		current="$parent"
		((depth++)) || true
	done

	# Output chain
	printf '%s\n' "${chain[@]}"
}

# -----------------------------------------------------------------------------
# Module Classification
# -----------------------------------------------------------------------------

classify_modules() {
	# Classify modules as direct, inherited, or available for a profile
	# Args: $1 - profile name
	#       $2 - module type: "system" or "home"
	# Returns: Three lines of space-separated module names
	#          Line 1: direct modules
	#          Line 2: inherited modules
	#          Line 3: available modules (not in profile)
	#
	# Example output for "laptop" with system modules:
	#   direct: (empty if laptop only imports default.nix)
	#   inherited: audio display fish fonts ... (from default.nix)
	#   available: (modules not in default or laptop)
	local profile="$1"
	local module_type="$2"
	local profile_file
	profile_file=$(get_profile_file "$profile")

	if [[ ! -f "$profile_file" ]]; then
		print_error "Profile not found: $profile"
		return 1
	fi

	# Get all available modules
	local all_modules=()
	if [[ "$module_type" == "system" ]]; then
		mapfile -t all_modules < <(discover_system_modules)
	elif [[ "$module_type" == "home" ]]; then
		mapfile -t all_modules < <(discover_home_modules)
	else
		print_error "Invalid module type: $module_type (expected 'system' or 'home')"
		return 1
	fi

	# Get inheritance chain
	local chain=()
	mapfile -t chain < <(resolve_inheritance_chain "$profile")

	# Collect all imports from the chain
	local all_imports=()
	for current_profile in "${chain[@]}"; do
		local current_file
		current_file=$(get_profile_file "$current_profile")
		local imports
		imports=$(parse_profile_imports "$current_file")

		while IFS= read -r import_path; do
			if [[ -n "$import_path" ]]; then
				all_imports+=("$import_path")
			fi
		done <<<"$imports"
	done

	# Convert imports to module labels and categorize
	local direct_modules=()
	local inherited_modules=()

	# Get direct imports (from the profile itself, not parents)
	local direct_imports
	direct_imports=$(parse_profile_imports "$profile_file")
	local direct_labels=()
	while IFS= read -r import_path; do
		if [[ -n "$import_path" ]]; then
			local label
			label=$(nix_path_to_label "$import_path")
			direct_labels+=("$label")
		fi
	done <<<"$direct_imports"

	# Get inherited imports (from parent profiles)
	local inherited_labels=()
	if [[ ${#chain[@]} -gt 1 ]]; then
		for ((i = 1; i < ${#chain[@]}; i++)); do
			local parent_profile="${chain[$i]}"
			local parent_file
			parent_file=$(get_profile_file "$parent_profile")
			local parent_imports
			parent_imports=$(parse_profile_imports "$parent_file")

			while IFS= read -r import_path; do
				if [[ -n "$import_path" ]]; then
					local label
					label=$(nix_path_to_label "$import_path")
					inherited_labels+=("$label")
				fi
			done <<<"$parent_imports"
		done
	fi

	# Filter by module type and categorize
	for module in "${all_modules[@]}"; do
		local label="${module_type}/${module}"
		local is_direct=0
		local is_inherited=0

		# Check if in direct
		for dl in "${direct_labels[@]}"; do
			if [[ "$dl" == "$label" ]]; then
				is_direct=1
				break
			fi
		done

		# Check if in inherited
		if [[ $is_direct -eq 0 ]]; then
			for il in "${inherited_labels[@]}"; do
				if [[ "$il" == "$label" ]]; then
					is_inherited=1
					break
				fi
			done
		fi

		if [[ $is_direct -eq 1 ]]; then
			direct_modules+=("$module")
		elif [[ $is_inherited -eq 1 ]]; then
			inherited_modules+=("$module")
		fi
	done

	# Calculate available modules (not in direct or inherited)
	local available_modules=()
	for module in "${all_modules[@]}"; do
		local found=0
		for dm in "${direct_modules[@]}"; do
			if [[ "$module" == "$dm" ]]; then
				found=1
				break
			fi
		done
		if [[ $found -eq 0 ]]; then
			for im in "${inherited_modules[@]}"; do
				if [[ "$module" == "$im" ]]; then
					found=1
					break
				fi
			done
		fi
		if [[ $found -eq 0 ]]; then
			available_modules+=("$module")
		fi
	done

	# Output: direct | inherited | available
	echo "${direct_modules[*]}"
	echo "${inherited_modules[*]}"
	echo "${available_modules[*]}"
}

# -----------------------------------------------------------------------------
# Host Profile Assignment
# -----------------------------------------------------------------------------

get_host_profile() {
	# Get the current profile assigned to a host
	# Args: $1 - host name
	# Returns: Profile name or empty string if not set
	local host="$1"
	local config_file
	config_file=$(get_host_config_file "$host")

	if [[ ! -f "$config_file" ]]; then
		return 1
	fi

	# Extract profile from user-config.nix
	local profile
	profile=$(grep -m1 'profile = "' "$config_file" 2>/dev/null | sed 's/.*profile = "\([^"]*\)".*/\1/')

	echo "$profile"
}
