# packages.nix
#
# Purpose: Re-exports consolidated home packages
#
# This module:
# - Imports the consolidated packages.nix with inputs and hostPlatform
{
  pkgs,
  inputs,
  hostPlatform,
  ...
}:
import ../packages.nix { inherit pkgs inputs hostPlatform; }
