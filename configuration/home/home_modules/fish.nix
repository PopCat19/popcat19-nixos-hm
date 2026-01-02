# Fish Shell Configuration Module
#
# Purpose: Configure Fish shell with custom functions
# Dependencies: fish-functions.nix
# Related: None
#
# This module:
# - Enables Fish shell functionality
# - Imports custom fish functions and abbreviations
# - Defers theming to Stylix
{...}: {
  programs.fish.enable = true;

  imports = [./fish-functions.nix];
}
