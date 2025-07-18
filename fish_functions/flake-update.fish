# ~/nixos-config/fish_functions/flake-update.fish
# Streamlined flake input management
# Handles updating, backup, and restoration of flake inputs

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-env-core.fish"
source "$script_dir/nixos-git-core.fish"

function flake-update -d "🔄 Update Nix flake inputs with backup and validation"
    # Parse arguments
    set -l show_help false
    set -l recreate_lock false
    set -l specific_inputs

    for arg in $argv
        switch $arg
            case -h --help help
                set show_help true
            case --recreate-lock-file
                set recreate_lock true
            case '*'
                # Assume it's a specific input name
                set -a specific_inputs $arg
        end
    end

    if test "$show_help" = true
        _flake_update_help
        return 0
    end

    # Validate environment
    if not nixos_validate_env
        return 1
    end

    # Check for flake.nix
    if not test -f "$NIXOS_CONFIG_DIR/flake.nix"
        echo "❌ flake.nix not found in $NIXOS_CONFIG_DIR"
        echo "💡 This command requires a flake-based configuration"
        return 1
    end

    echo "🔄 Updating flake inputs..."

    # Backup current lock file
    nixos_backup_lock

    # Perform update
    pushd "$NIXOS_CONFIG_DIR" >/dev/null

    set -l update_cmd "nix flake update"

    # Add specific inputs if provided
    if test (count $specific_inputs) -gt 0
        for input in $specific_inputs
            set update_cmd "$update_cmd $input"
        end
        echo "🎯 Updating specific inputs: $specific_inputs"
    else
        echo "📦 Updating all inputs..."
    end

    # Add recreate flag if requested
    if test "$recreate_lock" = true
        set update_cmd "$update_cmd --recreate-lock-file"
        echo "🔄 Recreating lock file..."
    end

    # Execute update
    if eval $update_cmd
        echo "✅ Flake inputs updated successfully"

        # Show changes if git is available
        if nixos_git_check
            echo "📊 Changes made:"
            if test -f "flake.lock.bak"
                git diff --no-index flake.lock.bak flake.lock 2>/dev/null || echo "  (Use git diff to see detailed changes)"
            end
        end

        popd >/dev/null
        return 0
    else
        echo "❌ Flake update failed"

        # Restore backup on failure
        echo "🔄 Restoring backup..."
        if nixos_restore_lock
            echo "✅ Backup restored"
        end

        popd >/dev/null
        return 1
    end
end

function flake-lock-clean -d "🧹 Clean up backup lock files"
    if not nixos_validate_env
        return 1
    end

    set -l backup_files "$NIXOS_CONFIG_DIR/flake.lock.bak"

    if test -f "$backup_files"
        rm "$backup_files"
        echo "🧹 Cleaned up backup files"
    else
        echo "ℹ️  No backup files to clean"
    end
end

function flake-rollback -d "🔄 Rollback flake.lock to backup"
    if not nixos_validate_env
        return 1
    end

    if nixos_restore_lock
        echo "✅ Flake rolled back to backup"
        echo "💡 Test with: nixos-apply-config -d"
    else
        echo "❌ No backup available to rollback to"
        return 1
    end
end

function _flake_update_help
    echo "🔄 flake-update - Nix Flake Input Manager"
    echo ""
    echo "Usage:"
    echo "  flake-update [inputs...] [options]"
    echo ""
    echo "Options:"
    echo "  --recreate-lock-file    Recreate entire lock file"
    echo "  -h, --help             Show this help"
    echo ""
    echo "Examples:"
    echo "  flake-update                    # Update all inputs"
    echo "  flake-update nixpkgs           # Update only nixpkgs"
    echo "  flake-update nixpkgs home-manager  # Update specific inputs"
    echo "  flake-update --recreate-lock-file   # Recreate lock file"
    echo ""
    echo "Related commands:"
    echo "  flake-rollback      Restore from backup"
    echo "  flake-lock-clean    Clean backup files"
    echo ""
    echo "Workflow:"
    echo "  1. Backup current flake.lock"
    echo "  2. Update inputs"
    echo "  3. Show changes made"
    echo "  4. Restore backup on failure"
    echo ""
    echo "💡 Always test updates with 'nixos-apply-config -d' before committing"
end
