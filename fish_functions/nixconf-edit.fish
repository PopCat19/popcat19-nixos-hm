# ~/nixos-config/fish_functions/nixconf-edit.fish
# NixOS configuration file editors
# Simple, focused functions for editing configuration files

# Load core dependencies
set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-env-core.fish"

function nixconf-edit -d "📝 Edit NixOS configuration.nix"
    if contains -- --help $argv; or contains -- help $argv
        _nixconf_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    set -l config_file "$NIXOS_CONFIG_DIR/configuration.nix"
    if not test -f "$config_file"
        echo "❌ Configuration file not found: $config_file"
        return 1
    end

    echo "📝 Editing: $(basename $config_file)"
    $EDITOR "$config_file" $argv
end

function homeconf-edit -d "📝 Edit Home Manager home.nix"
    if contains -- --help $argv; or contains -- help $argv
        _homeconf_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    set -l config_file "$NIXOS_CONFIG_DIR/home.nix"
    if not test -f "$config_file"
        echo "❌ Configuration file not found: $config_file"
        return 1
    end

    echo "📝 Editing: $(basename $config_file)"
    $EDITOR "$config_file" $argv
end

function flake-edit -d "📝 Edit flake.nix"
    if contains -- --help $argv; or contains -- help $argv
        _flake_help
        return 0
    end

    if not nixos_validate_env
        return 1
    end

    set -l config_file "$NIXOS_CONFIG_DIR/flake.nix"
    if not test -f "$config_file"
        echo "❌ Flake file not found: $config_file"
        return 1
    end

    echo "📝 Editing: $(basename $config_file)"
    $EDITOR "$config_file" $argv
end

function nixconf-list -d "📋 List available configuration files"
    if not nixos_validate_env
        return 1
    end

    nixos_list_configs
end

# Help functions
function _nixconf_help
    echo "📝 nixconf-edit - Edit NixOS system configuration"
    echo ""
    echo "Usage:"
    echo "  nixconf-edit [editor-options]"
    echo "  nixconf-edit --help"
    echo ""
    echo "Edits: \$NIXOS_CONFIG_DIR/configuration.nix"
    echo ""
    echo "Related commands:"
    echo "  homeconf-edit    Edit home.nix"
    echo "  flake-edit       Edit flake.nix"
    echo "  nixconf-list     List config files"
end

function _homeconf_help
    echo "📝 homeconf-edit - Edit Home Manager configuration"
    echo ""
    echo "Usage:"
    echo "  homeconf-edit [editor-options]"
    echo "  homeconf-edit --help"
    echo ""
    echo "Edits: \$NIXOS_CONFIG_DIR/home.nix"
    echo ""
    echo "Related commands:"
    echo "  nixconf-edit     Edit configuration.nix"
    echo "  flake-edit       Edit flake.nix"
    echo "  nixconf-list     List config files"
end

function _flake_help
    echo "📝 flake-edit - Edit Nix flake configuration"
    echo ""
    echo "Usage:"
    echo "  flake-edit [editor-options]"
    echo "  flake-edit --help"
    echo ""
    echo "Edits: \$NIXOS_CONFIG_DIR/flake.nix"
    echo ""
    echo "Related commands:"
    echo "  nixconf-edit     Edit configuration.nix"
    echo "  homeconf-edit    Edit home.nix"
    echo "  flake-update     Update flake inputs"
end
