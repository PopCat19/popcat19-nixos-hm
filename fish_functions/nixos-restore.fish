#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-restore.fish
# Restore configuration from backup

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-utils.fish"

nixos-restore $argv