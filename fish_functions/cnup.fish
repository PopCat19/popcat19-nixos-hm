#!/usr/bin/env fish

# Cnup Function
#
# Purpose: Comprehensive NixOS configuration linting and formatting
# Dependencies: statix, deadnix, nixfmt, nix flake check
# Related: fish.nix, nixos-rebuild-basic.fish
#
# This function:
# - Runs statix to fix security issues and bad practices
# - Removes dead nix code with deadnix
# - Formats code with nixfmt (RFC-style)
# - Validates flake configuration
# - Automatically uses nix-shell if tools are not available

function cnup
    begin
        if test -d .git
            git add --intent-to-add . 2>/dev/null; or true
        end
        set -l use_nix_shell false
        for cmd in statix deadnix nixfmt
            if not command -q $cmd
                set use_nix_shell true
                break
            end
        end
        if test $use_nix_shell = true
            nix-shell -p 'statix deadnix nixfmt' --run 'statix fix . && deadnix -e . && nixfmt . && nix flake check --impure --accept-flake-config --verbose'
        else
            statix fix . && deadnix -e . && nixfmt . && nix flake check --impure --accept-flake-config --verbose
        end
    end
end
