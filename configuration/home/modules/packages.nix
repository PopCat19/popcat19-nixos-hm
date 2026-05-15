# packages.nix
#
# Purpose: Re-exports consolidated home packages
#
# This module:
# - Imports the consolidated packages.nix with inputs and hostPlatform
{
  pkgs,
  inputs,
  userConfig,
  hostPlatform,
  ...
}:
import ../packages.nix {
  inherit
    pkgs
    inputs
    userConfig
    hostPlatform
    ;
}
