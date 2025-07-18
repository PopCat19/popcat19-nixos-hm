#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-status.fish
# Show comprehensive NixOS system status

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-workflows.fish"

nixos-status $argv