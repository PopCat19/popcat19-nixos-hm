#!/usr/bin/env fish
# ~/nixos-config/fish_functions/nixos-quick-commit.fish
# Quick rebuild and commit with message

set -l script_dir (dirname (status --current-filename))
source "$script_dir/nixos-workflows.fish"

nixos-quick-commit $argv