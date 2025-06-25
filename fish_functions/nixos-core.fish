# ~/nixos-config/fish_functions/nixos-core.fish
# Core utilities for NixOS configuration management
# Provides foundational functions used by other NixOS tools

# Environment validation
function nixos_validate_env -d "Validate required environment variables"
    set -l missing_vars

    if test -z "$NIXOS_CONFIG_DIR"
        set -a missing_vars "NIXOS_CONFIG_DIR"
    end

    if test -z "$NIXOS_FLAKE_HOSTNAME"
        set -a missing_vars "NIXOS_FLAKE_HOSTNAME"
    end

    if test (count $missing_vars) -gt 0
        echo "❌ Missing required environment variables:"
        for var in $missing_vars
            echo "  $var"
        end
        echo ""
        echo "💡 Set these variables in your shell configuration:"
        echo "  export NIXOS_CONFIG_DIR=\"/path/to/nixos-config\""
        echo "  export NIXOS_FLAKE_HOSTNAME=\"your-hostname\""
        return 1
    end

    if not test -d "$NIXOS_CONFIG_DIR"
        echo "❌ NIXOS_CONFIG_DIR does not exist: $NIXOS_CONFIG_DIR"
        return 1
    end

    return 0
end

# Configuration file discovery
function nixos_find_config -d "Find primary configuration file"
    # Priority: home-packages.nix > home-*.nix > home.nix > configuration.nix
    for pattern in "$NIXOS_CONFIG_DIR/home-packages.nix" \
                   "$NIXOS_CONFIG_DIR/home-*.nix" \
                   "$NIXOS_CONFIG_DIR/home.nix" \
                   "$NIXOS_CONFIG_DIR/configuration.nix"
        for file in $pattern
            if test -f "$file"
                echo "$file"
                return 0
            end
        end
    end
    return 1
end

function nixos_list_configs -d "List all available configuration files"
    echo "Available configuration files:"
    set -l primary (nixos_find_config)

    for file in "$NIXOS_CONFIG_DIR"/*.nix
        if test -f "$file"
            set -l basename (basename "$file")
            if test "$file" = "$primary"
                echo "  $basename (primary)"
            else
                echo "  $basename"
            end
        end
    end
end

# Git operations
function nixos_git_check -d "Check if config directory is a git repository"
    if not nixos_validate_env
        return 1
    end

    pushd "$NIXOS_CONFIG_DIR" >/dev/null
    set -l result (git rev-parse --is-inside-work-tree 2>/dev/null)
    popd >/dev/null

    test "$result" = "true"
end

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

    if git push origin 2>/dev/null
        echo "✅ Pushed to remote"
        popd >/dev/null
        return 0
    else
        echo "⚠️  Failed to push to remote"
        popd >/dev/null
        return 1
    end
end

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

# System operations
function nixos_test_config -d "Test configuration with dry-run"
    if not nixos_validate_env
        return 1
    end

    echo "🔍 Testing configuration..."
    pushd "$NIXOS_CONFIG_DIR" >/dev/null

    if sudo nixos-rebuild dry-run --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME" >/dev/null 2>&1
        echo "✅ Configuration test passed"
        popd >/dev/null
        return 0
    else
        echo "❌ Configuration test failed"
        popd >/dev/null
        return 1
    end
end

function nixos_current_generation -d "Get current generation number"
    nixos-rebuild list-generations | grep -E '\s+True\s*$' | awk '{print $1}'
end

function nixos_rebuild -d "Rebuild and switch system configuration"
    if not nixos_validate_env
        return 1
    end

    echo "🚀 Rebuilding NixOS configuration..."
    pushd "$NIXOS_CONFIG_DIR" >/dev/null

    set -l current_gen (nixos_current_generation)
    echo "📦 Current generation: $current_gen"

    if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME" $argv
        set -l new_gen (nixos_current_generation)
        echo "✅ NixOS rebuild successful! Generation: $new_gen"
        popd >/dev/null
        return 0
    else
        echo "❌ NixOS rebuild failed"
        echo "💡 System remains on generation $current_gen"
        echo "🔄 To rollback: sudo nixos-rebuild switch --rollback"
        popd >/dev/null
        return 1
    end
end

# Utility functions
function nixos_backup_lock -d "Backup flake.lock file"
    if test -f "$NIXOS_CONFIG_DIR/flake.lock"
        cp "$NIXOS_CONFIG_DIR/flake.lock" "$NIXOS_CONFIG_DIR/flake.lock.bak"
        echo "💾 Backed up flake.lock"
        return 0
    else
        echo "ℹ️  No flake.lock to backup"
        return 1
    end
end

function nixos_restore_lock -d "Restore flake.lock from backup"
    if test -f "$NIXOS_CONFIG_DIR/flake.lock.bak"
        mv "$NIXOS_CONFIG_DIR/flake.lock.bak" "$NIXOS_CONFIG_DIR/flake.lock"
        echo "🔄 Restored flake.lock from backup"
        return 0
    else
        echo "❌ No backup found"
        return 1
    end
end

function nixos_show_summary -d "Show system summary"
    if not nixos_validate_env
        return 1
    end

    echo "🖥️  NixOS System Summary"
    echo "  Config: $NIXOS_CONFIG_DIR"
    echo "  Host: $NIXOS_FLAKE_HOSTNAME"
    echo "  Generation: $(nixos_current_generation)"

    set -l primary_config (nixos_find_config)
    if test -n "$primary_config"
        echo "  Primary config: $(basename $primary_config)"
    end

    nixos_git_status
end
