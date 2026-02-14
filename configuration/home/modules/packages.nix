# packages.nix
#
# Purpose: Re-exports consolidated home packages
#
# This module:
# - Imports the consolidated home_packages.nix
{ pkgs, ... }:
import ../home_packages.nix { inherit pkgs; }
