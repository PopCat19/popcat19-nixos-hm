#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-info.fish
# Show detailed system information

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-utils.fish"

nixos-info $argv