#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-rollback.fish
# Rollback to previous generation

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-workflows.fish"

nixos-rollback $argv