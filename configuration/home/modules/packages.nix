# packages.nix
#
# Purpose: Re-exports consolidated home packages
#
# This module:
# - Imports the consolidated packages.nix
{ pkgs, ... }: import ../packages.nix { inherit pkgs; }
