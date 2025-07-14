#!/usr/bin/env fish
# ~/nixos-config/fish_functions/home-edit-rebuild.fish
# Edit home.nix, then rebuild

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-workflows.fish"

home-edit-rebuild $argv