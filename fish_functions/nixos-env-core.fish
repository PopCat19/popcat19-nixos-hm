#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-env-core.fish
# Environment and configuration discovery utilities for NixOS management
# This module provides core environment validation and configuration file discovery

# nixos_validate_env: Validate required environment variables for NixOS operations
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

# nixos_find_config: Find the primary configuration file based on priority
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

# nixos_list_configs: List all available configuration files with primary indicator
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