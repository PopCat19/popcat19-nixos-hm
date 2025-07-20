# ~/nixos-config/fish_functions/nixos-git-core.fish
# Core Git operations for NixOS configuration management
# Provides foundational Git utilities used by other NixOS tools

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-env-core.fish"

# nixos_git_check: Check if config directory is a git repository
function nixos_git_check -d "Check if config directory is a git repository"
    if not nixos_validate_env
        return 1
    end

    pushd "$NIXOS_CONFIG_DIR" >/dev/null
    set -l result (git rev-parse --is-inside-work-tree 2>/dev/null)
    popd >/dev/null

    test "$result" = "true"
end

# nixos_git_status: Show git status of config directory
function nixos_git_status -d "Show git status of config directory"
    if not nixos_git_check
        echo "⚠️  Not a git repository"
        return 1
    end

    pushd "$NIXOS_CONFIG_DIR" >/dev/null
    set -l status (git status --porcelain)
    if test -z "$status"
        echo "✅ No changes in git repository"
    else
        echo "📝 Git status:"
        git status --short
    end
    popd >/dev/null
end

# nixos_git_commit: Commit NixOS configuration changes
function nixos_git_commit -d "Commit changes with message"
    set -l commit_msg "$argv"

    if test -z "$commit_msg"
        echo "❌ No commit message provided"
        return 1
    end

    if not nixos_git_check
        echo "❌ Not a git repository"
        return 1
    end

    pushd "$NIXOS_CONFIG_DIR" >/dev/null

    # Add all changes
    git add .

    # Check if there are changes to commit
    if git diff --cached --quiet
        echo "ℹ️  No changes to commit"
        popd >/dev/null
        return 0
    end

    # Commit changes
    if git commit -m "$commit_msg"
        echo "✅ Changes committed: $commit_msg"
        popd >/dev/null
        return 0
    else
        echo "❌ Failed to commit changes"
        popd >/dev/null
        return 1
    end
end

# nixos_git_push: Push changes to remote
function nixos_git_push -d "Push changes to remote"
    if not nixos_git_check
        echo "❌ Not a git repository"
        return 1
    end

    pushd "$NIXOS_CONFIG_DIR" >/dev/null

    if not git remote | grep -q origin
        echo "ℹ️  No remote repository configured"
        popd >/dev/null
        return 0
    end

    # Handle refspec arguments - avoid empty string as refspec
    set -l push_args $argv
    
    set -l push_output
    if test (count $push_args) -eq 0
        set push_output (git push origin 2>&1)
    else
        set push_output (git push origin $push_args 2>&1)
    end
    set -l push_exit_code $status
    
    if test $push_exit_code -eq 0
        if test (count $argv) -gt 0
            echo "✅ Pushed to remote: $argv"
        else
            echo "✅ Pushed to remote"
        end
        popd >/dev/null
        return 0
    else
        if test (count $argv) -gt 0
            echo "⚠️  Failed to push to remote: $argv"
        else
            echo "⚠️  Failed to push to remote"
        end
        echo "💡 Error details: $push_output"
        popd >/dev/null
        return 1
    end
end

# nixos_git_pull: Pull changes from remote
function nixos_git_pull -d "Pull changes from remote"
    if not nixos_git_check
        echo "❌ Not a git repository"
        return 1
    end

    pushd "$NIXOS_CONFIG_DIR" >/dev/null

    if git pull $argv
        echo "✅ Pulled from remote"
        popd >/dev/null
        return 0
    else
        echo "❌ Failed to pull from remote"
        popd >/dev/null
        return 1
    end
end