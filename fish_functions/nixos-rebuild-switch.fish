# ~/nixos-config/fish_functions/nixos-rebuild-switch.fish
# Streamlined NixOS rebuild and switch function
# Direct rebuild without additional workflow features

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-core.fish"

function nixos-rebuild-switch -d "🚀 Rebuild and switch NixOS system configuration"
    if contains -- --help $argv; or contains -- help $argv
        _nixos_rebuild_switch_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    echo "🚀 Rebuilding and switching NixOS configuration..."
    echo "  Config: $NIXOS_CONFIG_DIR"
    echo "  Target: $NIXOS_FLAKE_HOSTNAME"

    set -l current_gen (nixos_current_generation)
    echo "  Current generation: $current_gen"

    # Execute rebuild
    pushd "$NIXOS_CONFIG_DIR" >/dev/null

    if sudo nixos-rebuild switch --flake "$NIXOS_CONFIG_DIR#$NIXOS_FLAKE_HOSTNAME" $argv
        set -l new_gen (nixos_current_generation)
        echo "✅ NixOS rebuild successful!"
        echo "  New generation: $new_gen"
        popd >/dev/null
        return 0
    else
        echo "❌ NixOS rebuild failed"
        echo "  System remains on generation: $current_gen"
        echo "💡 To rollback manually: sudo nixos-rebuild switch --rollback"
        popd >/dev/null
        return 1
    end
end

function _nixos_rebuild_switch_help
    echo "🚀 nixos-rebuild-switch - Direct NixOS rebuild"
    echo ""
    echo "Usage:"
    echo "  nixos-rebuild-switch [nixos-rebuild-options]"
    echo "  nixos-rebuild-switch --help"
    echo ""
    echo "Description:"
    echo "  Direct interface to 'nixos-rebuild switch' using your flake configuration."
    echo "  This is a low-level function - consider using 'nixos-apply-config' for"
    echo "  a more complete workflow with git integration and testing."
    echo ""
    echo "Examples:"
    echo "  nixos-rebuild-switch                    # Basic rebuild"
    echo "  nixos-rebuild-switch --show-trace       # Rebuild with trace"
    echo "  nixos-rebuild-switch --fast             # Fast rebuild"
    echo ""
    echo "Related commands:"
    echo "  nixos-apply-config    Complete workflow with git integration"
    echo "  nixos-test-config     Test configuration without applying"
    echo "  nixos-rollback        Rollback to previous generation"
end
