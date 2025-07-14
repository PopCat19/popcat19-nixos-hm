#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-system-core.fish
# System operations module for NixOS configuration management
# Provides core system-level operations for NixOS rebuilds and testing

# Ensure required environment is loaded
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-env-core.fish"

# nixos_current_generation: Get the current NixOS generation number
function nixos_current_generation -d "Get current generation number"
    nixos-rebuild list-generations | grep -E '\s+True\s*$' | awk '{print $1}'
end

# nixos_test_config: Test configuration with dry-run
function nixos_test_config -d "Test configuration with dry-run"
    if not nixos_validate_env
        return 1
    end

    pushd "$NIXOS_CONFIG_DIR" >/dev/null

    sudo nixos-rebuild dry-run --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME"
    set -l rebuild_status $status
    popd >/dev/null
    return $rebuild_status
end

# nixos_rebuild: Execute nixos-rebuild with specified command
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