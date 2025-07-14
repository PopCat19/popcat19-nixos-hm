#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-backup.fish
# Backup current configuration

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-utils.fish"

nixos-backup $argv