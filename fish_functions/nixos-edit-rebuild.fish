#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-edit-rebuild.fish
# Edit configuration.nix, then rebuild

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-workflows.fish"

nixos-edit-rebuild $argv