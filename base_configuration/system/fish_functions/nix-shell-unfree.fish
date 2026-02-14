#!/usr/bin/env fish

# Nix Shell Unfree Function
#
# Purpose: Enable Nix shell with unfree and insecure packages
# Dependencies: nix-shell, NIXPKGS_ALLOW_UNFREE, NIXPKGS_ALLOW_INSECURE
# Related: fish.nix, nixos-rebuild-basic.fish
#
# This function:
# - Sets environment variables for unfree/insecure packages
# - Runs nix-shell with packages if provided
# - Shows informational message when used interactively

function nix-shell-unfree
    set -lx NIXPKGS_ALLOW_UNFREE 1
    set -lx NIXPKGS_ALLOW_INSECURE 1
    if test (count $argv) -gt 0
        nix-shell $argv
    else
        echo "NIXPKGS_ALLOW_UNFREE and NIXPKGS_ALLOW_INSECURE are now set for this session."
        echo "You can now run nix-shell with packages that require these flags."
    end
end
