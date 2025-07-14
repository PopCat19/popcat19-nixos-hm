#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-upgrade.fish
# Update flake inputs, then rebuild

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-workflows.fish"

nixos-upgrade $argv