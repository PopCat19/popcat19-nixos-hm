# packages.nix
#
# Purpose: Re-exports consolidated system packages
#
# This module:
# - Imports the consolidated system_packages.nix
{
  pkgs,
  inputs,
  ...
}:
import ../../home/system_packages.nix { inherit pkgs inputs; }
