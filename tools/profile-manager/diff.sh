# diff.sh
#
# Purpose: Change preview and commit workflow for profile modifications
#
# This module:
# - Shows git diff for profile changes
# - Provides interactive commit workflow
# - Suggests commit message format per DEVELOPMENT.md

# shellcheck shell=bash

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$SCRIPT_DIR/common.sh"

# -----------------------------------------------------------------------------
# Change Preview
# -----------------------------------------------------------------------------

cmd_diff() {
	# Show git diff for profile changes
	# Args: $1 - optional path to limit diff scope
	clear
	gum style --foreground 212 --bold "Review Changes"
	echo ""

	# Check if we're in a git repository
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		print_error "Not in a git repository"
		return 1
	fi

	local scope="${1:-configuration/profiles}"

	# Check for changes
	local has_staged
	local has_unstaged
	has_staged=$(git diff --cached --quiet "$scope" 2>/dev/null && echo "0" || echo "1")
	has_unstaged=$(git diff --quiet "$scope" 2>/dev/null && echo "0" || echo "1")

	if [[ "$has_staged" == "0" && "$has_unstaged" == "0" ]]; then
		gum style --foreground 240 "No changes in $scope"
		return 0
	fi

	# Show diff stat first
	echo ""
	gum style --foreground 146 "Changed files:"
	git diff --stat "$scope" 2>/dev/null
	if [[ "$has_staged" == "1" ]]; then
		git diff --cached --stat "$scope" 2>/dev/null
	fi
	echo ""

	# Offer to show full diff
	if gum confirm "Show full diff?"; then
		echo ""
		gum style --foreground 146 "Full diff:"
		echo ""

		# Use gum pager for scrollable diff
		if [[ "$has_unstaged" == "1" ]]; then
			git diff "$scope" 2>/dev/null | gum pager
		fi
		if [[ "$has_staged" == "1" ]]; then
			echo ""
			gum style --foreground 82 "Staged changes:"
			git diff --cached "$scope" 2>/dev/null | gum pager
		fi
	fi
}

cmd_review() {
	# Full review workflow: diff, stage, commit
	clear
	gum style --foreground 212 --bold "Review & Commit"
	echo ""

	# Check if we're in a git repository
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		print_error "Not in a git repository"
		return 1
	fi

	# Check for any changes
	if git diff --quiet && git diff --cached --quiet; then
		gum style --foreground 240 "No changes to review"
		return 0
	fi

	# Show what changed
	echo ""
	gum style --foreground 146 "Current changes:"
	echo ""

	# Show unstaged changes
	if ! git diff --quiet; then
		gum style --foreground 214 "Unstaged changes:"
		git diff --stat
		echo ""
	fi

	# Show staged changes
	if ! git diff --cached --quiet; then
		gum style --foreground 82 "Staged changes:"
		git diff --cached --stat
		echo ""
	fi

	# Ask what to do
	local action
	action=$(gum choose "Show full diff" "Stage all changes" "Commit staged" "Discard unstaged" "Cancel" --header "What would you like to do?" --height 8)

	case "$action" in
	"Show full diff")
		git diff | gum pager
		if ! git diff --cached --quiet; then
			echo ""
			gum style --foreground 82 "Staged:"
			git diff --cached | gum pager
		fi
		;;
	"Stage all changes")
		git add configuration/profiles/
		print_success "Staged all profile changes"
		;;
	"Commit staged")
		cmd_commit
		;;
	"Discard unstaged")
		if gum confirm "Discard all unstaged changes?"; then
			git checkout -- configuration/profiles/
			print_success "Discarded unstaged changes"
		fi
		;;
	"Cancel")
		return 0
		;;
	esac
}

# -----------------------------------------------------------------------------
# Commit Workflow
# -----------------------------------------------------------------------------

cmd_commit() {
	# Interactive commit workflow with message format guidance
	clear
	gum style --foreground 212 --bold "Commit Changes"
	echo ""

	# Check if we're in a git repository
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		print_error "Not in a git repository"
		return 1
	fi

	# Check for staged changes
	if git diff --cached --quiet; then
		print_warning "No staged changes to commit"

		# Offer to stage changes
		if ! git diff --quiet configuration/profiles/; then
			if gum confirm "Stage profile changes first?"; then
				git add configuration/profiles/
			else
				return 0
			fi
		else
			return 0
		fi
	fi

	# Show what will be committed
	echo ""
	gum style --foreground 146 "Will commit:"
	git diff --cached --stat
	echo ""

	# Detect scope from changed files
	local scope
	scope=$(detect_commit_scope)

	# Show commit message format guidance
	gum style --foreground 240 "Commit message format: <type>(scope): <verb> <summary>"
	echo ""
	gum style --foreground 240 "Types: feat fix refactor docs style test chore perf revert"
	echo ""

	# Suggest scope
	if [[ -n "$scope" ]]; then
		gum style --foreground 214 "Suggested scope: $scope"
		echo ""
	fi

	# Get commit type
	local commit_type
	commit_type=$(gum choose "feat" "fix" "refactor" "docs" "style" "test" "chore" "perf" "revert" --header "Select commit type:" --height 12)

	if [[ -z "$commit_type" ]]; then
		gum style --foreground 240 "Cancelled"
		return 0
	fi

	# Get or confirm scope
	local final_scope="$scope"
	if [[ -z "$final_scope" ]]; then
		final_scope=$(gum input --placeholder "Enter scope (e.g., profiles, system)")
	fi

	if [[ -z "$final_scope" ]]; then
		final_scope="profiles"
	fi

	# Get commit summary
	local summary
	summary=$(gum input --placeholder "Enter commit summary (imperative, lowercase, no period)")

	if [[ -z "$summary" ]]; then
		gum style --foreground 240 "Cancelled"
		return 0
	fi

	# Build commit message
	local commit_msg="${commit_type}(${final_scope}): ${summary}"

	# Show preview
	echo ""
	gum style --foreground 82 "Commit message:"
	echo "  $commit_msg"
	echo ""

	# Ask about validation
	local skip_check=""
	if gum confirm "Run nix-instantiate validation before commit?"; then
		if ! validate_nix_syntax; then
			print_error "Validation failed. Fix errors before committing."
			if gum confirm "Commit anyway with [skip-check]?"; then
				skip_check=" [skip-check]"
				commit_msg="${commit_msg}${skip_check}"
			else
				return 1
			fi
		fi
	else
		skip_check=" [untested]"
		commit_msg="${commit_msg}${skip_check}"
	fi

	# Final confirmation
	if gum confirm "Commit with this message?"; then
		git commit -m "$commit_msg"
		print_success "Committed: $commit_msg"

		# Show current status
		echo ""
		gum style --foreground 240 "Current branch: $(git branch --show-current)"
		gum style --foreground 240 "Last commit: $(git rev-parse --short HEAD)"
	else
		gum style --foreground 240 "Cancelled"
	fi
}

detect_commit_scope() {
	# Detect appropriate scope from staged changes
	# Returns: scope string (e.g., "profiles", "system", "home")
	local staged_files
	staged_files=$(git diff --cached --name-only 2>/dev/null)

	# Count file types
	local profile_count=0
	local system_count=0
	local home_count=0
	local host_count=0

	while IFS= read -r file; do
		if [[ "$file" == configuration/profiles/* ]]; then
			((profile_count++)) || true
		elif [[ "$file" == configuration/system/* ]]; then
			((system_count++)) || true
		elif [[ "$file" == configuration/home/* ]]; then
			((home_count++)) || true
		elif [[ "$file" == configuration/hosts/* ]]; then
			((host_count++)) || true
		fi
	done <<<"$staged_files"

	# Return most common scope
	if [[ $profile_count -ge $system_count && $profile_count -ge $home_count && $profile_count -ge $host_count ]]; then
		echo "profiles"
	elif [[ $system_count -ge $home_count && $system_count -ge $host_count ]]; then
		echo "system"
	elif [[ $home_count -ge $host_count ]]; then
		echo "home"
	elif [[ $host_count -gt 0 ]]; then
		echo "hosts"
	else
		echo "config"
	fi
}

validate_nix_syntax() {
	# Validate Nix syntax of staged files
	# Returns: 0 if all valid, 1 if any errors
	local staged_nix
	staged_nix=$(git diff --cached --name-only --diff-filter=ACM "*.nix" 2>/dev/null)

	if [[ -z "$staged_nix" ]]; then
		return 0
	fi

	print_info "Validating Nix syntax..."

	local has_error=0
	while IFS= read -r file; do
		if [[ -f "$file" ]]; then
			if ! nix-instantiate --parse "$file" >/dev/null 2>&1; then
				print_error "Syntax error in: $file"
				has_error=1
			fi
		fi
	done <<<"$staged_nix"

	if [[ $has_error -eq 0 ]]; then
		print_success "All Nix files have valid syntax"
	fi

	return $has_error
}

# -----------------------------------------------------------------------------
# Status Display
# -----------------------------------------------------------------------------

cmd_status() {
	# Show current git status for profile manager context
	clear
	gum style --foreground 212 --bold "Profile Manager Status"
	echo ""

	# Check if we're in a git repository
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		print_error "Not in a git repository"
		return 1
	fi

	# Show branch
	local current_branch
	current_branch=$(git branch --show-current 2>/dev/null || echo "detached")
	gum style --foreground 146 "Branch: $current_branch"
	echo ""

	# Show profile changes
	gum style --foreground 214 "Profile changes:"
	if git diff --quiet configuration/profiles/ 2>/dev/null && git diff --cached --quiet configuration/profiles/ 2>/dev/null; then
		gum style --foreground 240 "  No uncommitted changes"
	else
		git status --short configuration/profiles/ 2>/dev/null | head -20
	fi
	echo ""

	# Show host changes
	gum style --foreground 214 "Host changes:"
	if git diff --quiet configuration/hosts/ 2>/dev/null && git diff --cached --quiet configuration/hosts/ 2>/dev/null; then
		gum style --foreground 240 "  No uncommitted changes"
	else
		git status --short configuration/hosts/ 2>/dev/null | head -20
	fi
	echo ""

	# Show recent commits
	gum style --foreground 146 "Recent commits:"
	git log --oneline -5 2>/dev/null
}
