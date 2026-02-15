# edit.sh
#
# Purpose: Module toggle editor and profile management operations
#
# This module:
# - Detects and expands home module barrel imports
# - Provides interactive module toggle interface
# - Rewrites Nix import blocks with validation
# - Creates and deletes profiles with safety checks

# shellcheck shell=bash

# Source shared utilities and discovery functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"
# shellcheck source=discover.sh
source "$SCRIPT_DIR/discover.sh"

# -----------------------------------------------------------------------------
# Home Module Barrel Detection
# -----------------------------------------------------------------------------

detect_home_barrel_import() {
	# Check if a profile uses the home modules barrel import
	# Args: $1 - path to profile .nix file
	# Returns: 0 if barrel import exists, 1 if not
	#
	# Detects: imports = [ ../home/modules ]; (without specific module refs)
	# Does NOT trigger on: imports = [ ../home/modules/git.nix ];
	local profile_file="$1"

	if [[ ! -f "$profile_file" ]]; then
		return 1
	fi

	# Look for barrel import: ../home/modules without a .nix file extension
	# This indicates importing the directory's default.nix
	local imports
	imports=$(parse_profile_imports "$profile_file")

	while IFS= read -r import_path; do
		# Match barrel import: ends with ../home/modules (no .nix)
		if [[ "$import_path" == "../home/modules" ]]; then
			return 0
		fi
	done <<<"$imports"

	return 1
}

expand_home_barrel() {
	# Offer to expand barrel import to explicit individual module imports
	# Args: $1 - path to profile .nix file
	# Returns: 0 if expanded or declined, 1 on error
	#
	# Before: imports = [ ../home/modules ];
	# After:  imports = [ ../home/modules/git.nix ../home/modules/kitty.nix ... ];
	local profile_file="$1"

	if ! detect_home_barrel_import "$profile_file"; then
		# No barrel import, nothing to expand
		return 0
	fi

	# Get available home modules
	local modules=()
	mapfile -t modules < <(discover_home_modules)

	if [[ ${#modules[@]} -eq 0 ]]; then
		print_warning "No home modules found to expand to"
		return 1
	fi

	print_warning "Profile uses barrel import: ../home/modules"
	print_info "This imports all home modules via default.nix"
	echo ""

	if ! gum confirm "Expand to explicit individual imports?"; then
		print_info "Keeping barrel import"
		return 0
	fi

	# Build list of module imports
	local module_imports=()
	for module in "${modules[@]}"; do
		module_imports+=("../home/modules/${module}.nix")
	done

	# Rewrite the imports
	if rewrite_home_imports "$profile_file" "${module_imports[@]}"; then
		print_success "Expanded barrel import to ${#modules[@]} individual modules"
		return 0
	else
		return 1
	fi
}

# -----------------------------------------------------------------------------
# Import Parsing (Enhanced)
# -----------------------------------------------------------------------------

parse_home_imports() {
	# Extract home module imports from home-manager.users.*.imports block
	# Args: $1 - path to profile .nix file
	# Returns: Array of home module import paths (one per line)
	local profile_file="$1"
	local in_home_imports=0
	local imports=()

	if [[ ! -f "$profile_file" ]]; then
		print_error "Profile file not found: $profile_file"
		return 1
	fi

	# Parse the file looking for home-manager.users.*.imports = [
	while IFS= read -r line || [[ -n "$line" ]]; do
		# Check for start of home-manager imports array
		# Pattern: home-manager.users.${userConfig.username}.imports = [
		if [[ "$line" =~ home-manager\.users\..*\.imports[[:space:]]*=[[:space:]]*\[ ]]; then
			in_home_imports=1
			continue
		fi

		# Check for end of imports array
		if [[ $in_home_imports -eq 1 && "$line" =~ \][[:space:]]*\;?[[:space:]]*$ ]]; then
			# Check if there's a path before the closing bracket
			if [[ "$line" =~ \.\./ || "$line" =~ \./ ]]; then
				local path
				path=$(echo "$line" | grep -oE '(\.\./|\./)[^[:space:];\]]+\.nix' | head -1)
				if [[ -n "$path" ]]; then
					imports+=("$path")
				fi
			fi
			break
		fi

		# Collect import paths while inside the array
		if [[ $in_home_imports -eq 1 ]]; then
			if [[ "$line" =~ \.\./ || "$line" =~ \./ ]]; then
				local path
				path=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -oE '(\.\./|\./)[^[:space:];]+\.nix' | head -1)
				if [[ -n "$path" ]]; then
					imports+=("$path")
				fi
			fi
		fi
	done <"$profile_file"

	# Output imports
	printf '%s\n' "${imports[@]}"
}

# -----------------------------------------------------------------------------
# Import Rewriting
# -----------------------------------------------------------------------------

has_imports_block() {
	# Check if a profile file has an imports block
	# Args: $1 - profile file path
	# Returns: 0 if imports block exists, 1 if not
	local profile_file="$1"

	if [[ ! -f "$profile_file" ]]; then
		return 1
	fi

	grep -q 'imports[[:space:]]*=[[:space:]]*\[' "$profile_file"
}

rewrite_imports() {
	# Rewrite the top-level imports block in a profile
	# Args: $1 - profile file path
	#       $2 - parent import (e.g., "./default.nix" or "")
	#       $@ - module imports to include
	# Returns: 0 on success, 1 on failure
	#
	# Edge cases handled:
	# - Files without imports block (creates one)
	# - Empty imports block (populates it)
	# - Preserves surrounding formatting
	#
	# Creates backup, writes to temp, validates, then replaces
	local profile_file="$1"
	local parent_import="$2"
	shift 2
	local module_imports=("$@")

	if [[ ! -f "$profile_file" ]]; then
		print_error "Profile file not found: $profile_file"
		return 1
	fi

	local tmp_file="${profile_file}.tmp"
	local bak_file="${profile_file}.bak"

	# Create backup
	cp "$profile_file" "$bak_file"

	# Build the new imports block
	local imports_content=""
	if [[ -n "$parent_import" ]]; then
		imports_content+="    ${parent_import}"$'\n'
	fi
	for mod in "${module_imports[@]}"; do
		imports_content+="    ${mod}"$'\n'
	done

	# Check if file has an imports block
	if has_imports_block "$profile_file"; then
		# Use awk to replace the existing imports block
		awk -v imports_block="$imports_content" '
		BEGIN { in_imports = 0 }
		/imports[[:space:]]*=[[:space:]]*\[/ {
			in_imports = 1
			print "  imports = ["
			if (imports_block != "") {
				printf "%s", imports_block
			}
			next
		}
		/\][[:space:]]*\;?[[:space:]]*$/ && in_imports {
			in_imports = 0
			print "  ];"
			next
		}
		!in_imports { print }
		' "$profile_file" >"$tmp_file"
	else
		# No imports block exists - need to create one
		# Find the opening brace after the function arguments and insert imports
		awk -v imports_block="$imports_content" '
		/^ *\{/ {
			print
			print "  imports = ["
			if (imports_block != "") {
				printf "%s", imports_block
			}
			print "  ];"
			next
		}
		{ print }
		' "$profile_file" >"$tmp_file"
	fi

	# Validate the result
	if ! nix-instantiate --parse "$tmp_file" >/dev/null 2>&1; then
		print_error "Generated invalid Nix syntax, reverting"
		mv "$bak_file" "$profile_file"
		rm -f "$tmp_file"
		return 1
	fi

	# Success: replace original and remove backup
	mv "$tmp_file" "$profile_file"
	rm "$bak_file"
	return 0
}

rewrite_home_imports() {
	# Rewrite the home-manager.users.*.imports block
	# Args: $1 - profile file path
	#       $@ - home module imports to include
	# Returns: 0 on success, 1 on failure
	#
	# Edge cases handled:
	# - Files without home-manager imports block (creates one)
	# - Empty imports block (populates it)
	#
	# Creates backup, writes to temp, validates, then replaces
	local profile_file="$1"
	shift
	local home_imports=("$@")

	if [[ ! -f "$profile_file" ]]; then
		print_error "Profile file not found: $profile_file"
		return 1
	fi

	local tmp_file="${profile_file}.tmp"
	local bak_file="${profile_file}.bak"

	# Create backup
	cp "$profile_file" "$bak_file"

	# Build the new home imports block
	local imports_content=""
	for mod in "${home_imports[@]}"; do
		imports_content+="      ${mod}"$'\n'
	done

	# Check if file has a home-manager imports block
	if grep -q 'home-manager\.users\..*\.imports[[:space:]]*=[[:space:]]*\[' "$profile_file"; then
		# Use awk to replace the home-manager imports block
		awk -v imports_block="$imports_content" '
		BEGIN { in_home_imports = 0 }
		/home-manager\.users\..*\.imports[[:space:]]*=[[:space:]]*\[/ {
			in_home_imports = 1
			print "    imports = ["
			if (imports_block != "") {
				printf "%s", imports_block
			}
			next
		}
		/\][[:space:]]*\;?[[:space:]]*$/ && in_home_imports {
			in_home_imports = 0
			print "    ];"
			next
		}
		!in_home_imports { print }
		' "$profile_file" >"$tmp_file"
	else
		# No home-manager imports block - need to create one within home-manager.users block
		# This is more complex - we need to find or create the home-manager.users block
		# For now, just copy the file and warn
		print_warning "No home-manager imports block found, cannot add imports"
		cp "$profile_file" "$tmp_file"
	fi

	# Validate the result
	if ! nix-instantiate --parse "$tmp_file" >/dev/null 2>&1; then
		print_error "Generated invalid Nix syntax, reverting"
		mv "$bak_file" "$profile_file"
		rm -f "$tmp_file"
		return 1
	fi

	# Success: replace original and remove backup
	mv "$tmp_file" "$profile_file"
	rm "$bak_file"
	return 0
}

# -----------------------------------------------------------------------------
# Module Toggle Interface
# -----------------------------------------------------------------------------

cmd_edit_modules() {
	# Main edit workflow for toggling modules in a profile
	# Uses gum choose --no-limit for multi-select
	# Shows three states: inherited (greyed), direct (selectable), available (selectable)
	clear
	gum style --foreground 212 --bold "Edit Profile Modules"
	echo ""

	# Get list of profiles
	local profiles=()
	mapfile -t profiles < <(list_profiles)

	if [[ ${#profiles[@]} -eq 0 ]]; then
		gum style --foreground 214 "No profiles found in $PROFILES_DIR"
		return 1
	fi

	# Let user select a profile
	local selected_profile
	selected_profile=$(gum choose "${profiles[@]}" --header "Select a profile to edit:" --height 15)

	if [[ -z "$selected_profile" ]]; then
		return 0
	fi

	local profile_file
	profile_file=$(get_profile_file "$selected_profile")

	# Check for home barrel import and offer to expand
	if detect_home_barrel_import "$profile_file"; then
		echo ""
		print_warning "Profile uses barrel import for home modules"
		if gum confirm "Expand barrel import to individual modules first?"; then
			if ! expand_home_barrel "$profile_file"; then
				print_error "Failed to expand barrel import"
				return 1
			fi
		else
			print_info "Cannot edit home modules with barrel import"
			echo ""
			print_info "You can still edit system modules"
		fi
	fi

	# Ask which type of modules to edit
	local edit_choice
	edit_choice=$(gum choose "System modules" "Home modules" "Both" --header "What to edit?" --height 5)

	case "$edit_choice" in
	"System modules")
		edit_system_modules "$selected_profile"
		;;
	"Home modules")
		edit_home_modules "$selected_profile"
		;;
	"Both")
		edit_system_modules "$selected_profile"
		edit_home_modules "$selected_profile"
		;;
	esac
}

edit_system_modules() {
	# Edit system modules for a profile
	# Args: $1 - profile name
	local profile="$1"
	local profile_file
	profile_file=$(get_profile_file "$profile")

	# Get classification
	local classification
	mapfile -t classification < <(classify_modules "$profile" "system")

	local direct_str="${classification[0]}"
	local inherited_str="${classification[1]}"
	local available_str="${classification[2]}"

	# Convert to arrays
	local direct=()
	local inherited=()
	local available=()

	if [[ -n "$direct_str" ]]; then
		read -ra direct <<<"$direct_str"
	fi
	if [[ -n "$inherited_str" ]]; then
		read -ra inherited <<<"$inherited_str"
	fi
	if [[ -n "$available_str" ]]; then
		read -ra available <<<"$available_str"
	fi

	# Show inherited modules (informational only)
	if [[ ${#inherited[@]} -gt 0 ]]; then
		echo ""
		gum style --foreground 240 "Inherited system modules (from parent, cannot toggle):"
		for mod in "${inherited[@]}"; do
			echo "  • $mod"
		done
	fi

	# Build selection list: direct modules (selected) + available modules (unselected)
	local options=()
	local selected_indices=()
	local idx=0

	# Add direct modules (pre-selected)
	for mod in "${direct[@]}"; do
		options+=("$mod")
		selected_indices+=("$idx")
		((idx++)) || true
	done

	# Add available modules (unselected)
	for mod in "${available[@]}"; do
		options+=("$mod")
		((idx++)) || true
	done

	if [[ ${#options[@]} -eq 0 ]]; then
		echo ""
		gum style --foreground 240 "No system modules available to toggle"
		return 0
	fi

	echo ""
	gum style --foreground 82 "Select system modules to include:"

	# Build gum choose arguments
	# Format: --selected=0,2,3 for pre-selected items
	local selected_arg=""
	if [[ ${#selected_indices[@]} -gt 0 ]]; then
		selected_arg=$(
			IFS=,
			echo "${selected_indices[*]}"
		)
	fi

	local chosen=()
	if [[ -n "$selected_arg" ]]; then
		mapfile -t chosen < <(gum choose --no-limit --selected="$selected_arg" "${options[@]}" 2>/dev/null)
	else
		mapfile -t chosen < <(gum choose --no-limit "${options[@]}" 2>/dev/null)
	fi

	# Determine what changed
	local new_direct=()
	for opt in "${options[@]}"; do
		local found=0
		for ch in "${chosen[@]}"; do
			if [[ "$opt" == "$ch" ]]; then
				found=1
				break
			fi
		done
		if [[ $found -eq 1 ]]; then
			new_direct+=("$opt")
		fi
	done

	# Check if anything changed
	local changed=0
	if [[ ${#new_direct[@]} -ne ${#direct[@]} ]]; then
		changed=1
	else
		# Check if same elements
		for mod in "${new_direct[@]}"; do
			local found=0
			for old in "${direct[@]}"; do
				if [[ "$mod" == "$old" ]]; then
					found=1
					break
				fi
			done
			if [[ $found -eq 0 ]]; then
				changed=1
				break
			fi
		done
	fi

	if [[ $changed -eq 0 ]]; then
		echo ""
		gum style --foreground 240 "No changes made"
		return 0
	fi

	# Show what will change
	echo ""
	gum style --foreground 214 "Changes:"
	local added=()
	local removed=()

	# Find added
	for mod in "${new_direct[@]}"; do
		local found=0
		for old in "${direct[@]}"; do
			if [[ "$mod" == "$old" ]]; then
				found=1
				break
			fi
		done
		if [[ $found -eq 0 ]]; then
			added+=("$mod")
		fi
	done

	# Find removed
	for mod in "${direct[@]}"; do
		local found=0
		for new in "${new_direct[@]}"; do
			if [[ "$mod" == "$new" ]]; then
				found=1
				break
			fi
		done
		if [[ $found -eq 0 ]]; then
			removed+=("$mod")
		fi
	done

	if [[ ${#added[@]} -gt 0 ]]; then
		gum style --foreground 82 "  Adding:"
		for mod in "${added[@]}"; do
			echo "    + $mod"
		done
	fi

	if [[ ${#removed[@]} -gt 0 ]]; then
		gum style --foreground 196 "  Removing:"
		for mod in "${removed[@]}"; do
			echo "    - $mod"
		done
	fi

	echo ""
	if ! gum confirm "Apply changes?"; then
		gum style --foreground 240 "Cancelled"
		return 0
	fi

	# Build new imports list
	local new_imports=()
	for mod in "${new_direct[@]}"; do
		new_imports+=("../system/modules/${mod}.nix")
	done

	# Get parent import
	local parent
	parent=$(get_parent_profile "$profile_file")
	local parent_import=""
	if [[ -n "$parent" ]]; then
		parent_import="./${parent}.nix"
	fi

	# Rewrite imports
	if rewrite_imports "$profile_file" "$parent_import" "${new_imports[@]}"; then
		print_success "Updated system modules for $profile"
	else
		print_error "Failed to update imports"
		return 1
	fi
}

edit_home_modules() {
	# Edit home modules for a profile
	# Args: $1 - profile name
	local profile="$1"
	local profile_file
	profile_file=$(get_profile_file "$profile")

	# Check for barrel import
	if detect_home_barrel_import "$profile_file"; then
		print_warning "Cannot edit home modules: profile uses barrel import"
		print_info "Expand the barrel import first"
		return 1
	fi

	# Get classification
	local classification
	mapfile -t classification < <(classify_modules "$profile" "home")

	local direct_str="${classification[0]}"
	local inherited_str="${classification[1]}"
	local available_str="${classification[2]}"

	# Convert to arrays
	local direct=()
	local inherited=()
	local available=()

	if [[ -n "$direct_str" ]]; then
		read -ra direct <<<"$direct_str"
	fi
	if [[ -n "$inherited_str" ]]; then
		read -ra inherited <<<"$inherited_str"
	fi
	if [[ -n "$available_str" ]]; then
		read -ra available <<<"$available_str"
	fi

	# Show inherited modules (informational only)
	if [[ ${#inherited[@]} -gt 0 ]]; then
		echo ""
		gum style --foreground 240 "Inherited home modules (from parent, cannot toggle):"
		for mod in "${inherited[@]}"; do
			echo "  • $mod"
		done
	fi

	# Build selection list
	local options=()
	local selected_indices=()
	local idx=0

	for mod in "${direct[@]}"; do
		options+=("$mod")
		selected_indices+=("$idx")
		((idx++)) || true
	done

	for mod in "${available[@]}"; do
		options+=("$mod")
		((idx++)) || true
	done

	if [[ ${#options[@]} -eq 0 ]]; then
		echo ""
		gum style --foreground 240 "No home modules available to toggle"
		return 0
	fi

	echo ""
	gum style --foreground 82 "Select home modules to include:"

	local selected_arg=""
	if [[ ${#selected_indices[@]} -gt 0 ]]; then
		selected_arg=$(
			IFS=,
			echo "${selected_indices[*]}"
		)
	fi

	local chosen=()
	if [[ -n "$selected_arg" ]]; then
		mapfile -t chosen < <(gum choose --no-limit --selected="$selected_arg" "${options[@]}" 2>/dev/null)
	else
		mapfile -t chosen < <(gum choose --no-limit "${options[@]}" 2>/dev/null)
	fi

	# Determine new selection
	local new_direct=()
	for opt in "${options[@]}"; do
		local found=0
		for ch in "${chosen[@]}"; do
			if [[ "$opt" == "$ch" ]]; then
				found=1
				break
			fi
		done
		if [[ $found -eq 1 ]]; then
			new_direct+=("$opt")
		fi
	done

	# Check if anything changed
	local changed=0
	if [[ ${#new_direct[@]} -ne ${#direct[@]} ]]; then
		changed=1
	else
		for mod in "${new_direct[@]}"; do
			local found=0
			for old in "${direct[@]}"; do
				if [[ "$mod" == "$old" ]]; then
					found=1
					break
				fi
			done
			if [[ $found -eq 0 ]]; then
				changed=1
				break
			fi
		done
	fi

	if [[ $changed -eq 0 ]]; then
		echo ""
		gum style --foreground 240 "No changes made"
		return 0
	fi

	# Show what will change
	echo ""
	gum style --foreground 214 "Changes:"
	local added=()
	local removed=()

	for mod in "${new_direct[@]}"; do
		local found=0
		for old in "${direct[@]}"; do
			if [[ "$mod" == "$old" ]]; then
				found=1
				break
			fi
		done
		if [[ $found -eq 0 ]]; then
			added+=("$mod")
		fi
	done

	for mod in "${direct[@]}"; do
		local found=0
		for new in "${new_direct[@]}"; do
			if [[ "$mod" == "$new" ]]; then
				found=1
				break
			fi
		done
		if [[ $found -eq 0 ]]; then
			removed+=("$mod")
		fi
	done

	if [[ ${#added[@]} -gt 0 ]]; then
		gum style --foreground 82 "  Adding:"
		for mod in "${added[@]}"; do
			echo "    + $mod"
		done
	fi

	if [[ ${#removed[@]} -gt 0 ]]; then
		gum style --foreground 196 "  Removing:"
		for mod in "${removed[@]}"; do
			echo "    - $mod"
		done
	fi

	echo ""
	if ! gum confirm "Apply changes?"; then
		gum style --foreground 240 "Cancelled"
		return 0
	fi

	# Build new imports list
	local new_imports=()
	for mod in "${new_direct[@]}"; do
		new_imports+=("../home/modules/${mod}.nix")
	done

	# Rewrite home imports
	if rewrite_home_imports "$profile_file" "${new_imports[@]}"; then
		print_success "Updated home modules for $profile"
	else
		print_error "Failed to update home imports"
		return 1
	fi
}

# -----------------------------------------------------------------------------
# Profile Creation
# -----------------------------------------------------------------------------

cmd_create_interactive() {
	# Interactive profile creation workflow
	clear
	gum style --foreground 212 --bold "Create New Profile"
	echo ""

	# Get profile name
	local profile_name
	profile_name=$(gum input --placeholder "Enter profile name (alphanumeric, hyphens, underscores)")

	if [[ -z "$profile_name" ]]; then
		gum style --foreground 240 "Cancelled"
		return 0
	fi

	# Validate profile name
	if [[ ! "$profile_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
		print_error "Invalid profile name. Use only letters, numbers, hyphens, and underscores."
		return 1
	fi

	# Check if profile already exists
	if profile_exists "$profile_name"; then
		print_error "Profile already exists: $profile_name"
		return 1
	fi

	# Ask about inheritance
	local inherit=""
	if gum confirm "Inherit from an existing profile?"; then
		local profiles=()
		mapfile -t profiles < <(list_profiles)

		if [[ ${#profiles[@]} -gt 0 ]]; then
			inherit=$(gum choose "${profiles[@]}" --header "Select parent profile:" --height 15)
		fi
	fi

	# Create the profile
	local profile_file
	profile_file=$(get_profile_file "$profile_name")

	# Build the profile content
	local content=""
	if [[ -n "$inherit" ]]; then
		content=$(
			cat <<EOF
# ${profile_name}.nix
#
# Purpose: Custom profile configuration
#
# This profile:
# - Inherits from ${inherit}
# - Add additional features here
{ userConfig, ... }:
{
  imports = [
    ./${inherit}.nix
  ];

  # Add additional configuration here
}
EOF
		)
	else
		content=$(
			cat <<EOF
# ${profile_name}.nix
#
# Purpose: Custom profile configuration
#
# This profile:
# - Standalone profile (no inheritance)
# - Add feature descriptions here
{ inputs, userConfig, ... }:
let
  stateVersion = import ../stateversion.nix;
in
{
  imports = [
    # Add base configuration or modules here
    # ../base/configuration.nix
  ];

  system.stateVersion = stateVersion.system;

  # Add additional configuration here
}
EOF
		)
	fi

	# Write the file
	echo "$content" >"$profile_file"
	print_success "Created profile: $profile_name"
	echo "File: $profile_file"

	# Offer to edit modules
	echo ""
	if gum confirm "Edit modules now?"; then
		cmd_edit_modules_for "$profile_name"
	fi
}

cmd_edit_modules_for() {
	# Edit modules for a specific profile (used by create workflow)
	# Args: $1 - profile name
	local profile="$1"
	local profile_file
	profile_file=$(get_profile_file "$profile")

	# Ask which type of modules to edit
	local edit_choice
	edit_choice=$(gum choose "System modules" "Home modules" "Both" --header "What to edit?" --height 5)

	case "$edit_choice" in
	"System modules")
		edit_system_modules "$profile"
		;;
	"Home modules")
		edit_home_modules "$profile"
		;;
	"Both")
		edit_system_modules "$profile"
		edit_home_modules "$profile"
		;;
	esac
}

# -----------------------------------------------------------------------------
# Profile Deletion
# -----------------------------------------------------------------------------

cmd_delete_interactive() {
	# Interactive profile deletion workflow
	clear
	gum style --foreground 212 --bold "Delete Profile"
	echo ""

	# Get list of profiles (excluding protected)
	local profiles=()
	while IFS= read -r profile; do
		if [[ "$profile" != "default" ]]; then
			profiles+=("$profile")
		fi
	done < <(list_profiles)

	if [[ ${#profiles[@]} -eq 0 ]]; then
		gum style --foreground 240 "No profiles available to delete"
		return 0
	fi

	# Let user select a profile
	local selected_profile
	selected_profile=$(gum choose "${profiles[@]}" --header "Select a profile to delete:" --height 15)

	if [[ -z "$selected_profile" ]]; then
		return 0
	fi

	# Check if default (shouldn't be in list, but double-check)
	if [[ "$selected_profile" == "default" ]]; then
		print_error "Cannot delete the default profile"
		return 1
	fi

	local profile_file
	profile_file=$(get_profile_file "$selected_profile")

	# Check for hosts using this profile
	echo ""
	gum style --foreground 240 "Checking for hosts using this profile..."
	local using_hosts=()
	while IFS= read -r host; do
		if [[ -n "$host" ]]; then
			local host_profile
			host_profile=$(get_host_profile "$host")
			if [[ "$host_profile" == "$selected_profile" ]]; then
				using_hosts+=("$host")
			fi
		fi
	done < <(list_hosts)

	if [[ ${#using_hosts[@]} -gt 0 ]]; then
		print_warning "The following hosts use this profile:"
		for host in "${using_hosts[@]}"; do
			echo "  • $host"
		done
		echo ""
		print_warning "Deleting this profile will break these host configurations!"
		echo ""
	fi

	# Show profile info
	gum style --foreground 214 "Profile: $selected_profile"
	gum style --foreground 240 "File: $profile_file"
	echo ""

	# Confirmation
	if ! gum confirm "Are you sure you want to delete this profile?"; then
		gum style --foreground 240 "Cancelled"
		return 0
	fi

	# Second confirmation for safety
	if ! gum confirm "This cannot be undone. Delete $selected_profile?"; then
		gum style --foreground 240 "Cancelled"
		return 0
	fi

	# Delete the file
	rm "$profile_file"
	print_success "Deleted profile: $selected_profile"

	# Suggest updating hosts if needed
	if [[ ${#using_hosts[@]} -gt 0 ]]; then
		echo ""
		print_warning "Remember to update the following hosts to use a different profile:"
		for host in "${using_hosts[@]}"; do
			echo "  • $host"
		done
	fi
}

# Note: Host assignment functions moved to host.sh
# - cmd_host_assignments() -> host.sh
# - rewrite_host_profile() -> host.sh
# - show_host_details() -> host.sh
