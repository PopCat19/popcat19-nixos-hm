#!/usr/bin/env fish

# Default Fish Functions Loader
#
# Purpose: Source all custom Fish function files
# Dependencies: All fish_functions/*.fish files
# Related: fish-functions.nix, fish.nix
#
# This file:
# - Sources all custom Fish function files from fish_functions directory
# - Provides single import point for fish-functions.nix
# - Automatically includes new function files

# Source individual fish function files
if test -f "${../../../fish_functions/nix-shell-unfree.fish}"
    source ${../../../fish_functions/nix-shell-unfree.fish}
end

if test -f "${../../../fish_functions/fish-greeting.fish}"
    source ${../../../fish_functions/fish-greeting.fish}
end

if test -f "${../../../fish_functions/list-fish-helpers.fish}"
    source ${../../../fish_functions/list-fish-helpers.fish}
end

if test -f "${../../../fish_functions/nixos-commit-rebuild-push.fish}"
    source ${../../../fish_functions/nixos-commit-rebuild-push.fish}
end

if test -f "${../../../fish_functions/nixos-rebuild-basic.fish}"
    source ${../../../fish_functions/nixos-rebuild-basic.fish}
end

if test -f "${../../../fish_functions/dev-to-main.fish}"
    source ${../../../fish_functions/dev-to-main.fish}
end

if test -f "${../../../fish_functions/nixos-flake-update.fish}"
    source ${../../../fish_functions/nixos-flake-update.fish}
end

if test -f "${../../../fish_functions/fix-fish-history.fish}"
    source ${../../../fish_functions/fix-fish-history.fish}
end

if test -f "${../../../fish_functions/cnup.fish}"
    source ${../../../fish_functions/cnup.fish}
end

if test -f "${../../../fish_functions/sillytavern.fish}"
    source ${../../../fish_functions/sillytavern.fish}
end

if test -f "${../../../fish_functions/show-shortcuts.fish}"
    source ${../../../fish_functions/show-shortcuts.fish}
end

if test -f "${../../../fish_functions/lsa.fish}"
    source ${../../../fish_functions/lsa.fish}
end
