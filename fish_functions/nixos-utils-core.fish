# ~/nixos-config/fish_functions/nixos-utils-core.fish
# Core utility functions for NixOS configuration management
# Provides backup/restore and summary display functionality

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-env-core.fish"
source "$script_dir/nixos-git-core.fish"

# nixos_backup_lock: Backup flake.lock file
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

# nixos_restore_lock: Restore flake.lock from backup
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

# nixos_show_summary: Display post-rebuild summary
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

    # Source git module for git status
    set -l script_dir (dirname (status --current-filename))
    source "$script_dir/nixos-git-core.fish"
    nixos_git_status
end