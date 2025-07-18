#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-doctor.fish
# Diagnose common NixOS configuration issues

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-utils.fish"

nixos-doctor $argv