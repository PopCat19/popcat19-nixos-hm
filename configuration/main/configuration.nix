# Main Configuration Module
#
# Purpose: Main system configuration combining base and user modules
# Dependencies: configuration/base, user system modules
# Related: configuration/base/configuration.nix, flake.nix
#
# This module:
# - Imports base configuration as foundation
# - Adds user-specific system modules
# - Provides extension point for additional modules
{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  imports = [
    ../configuration/base/configuration.nix
    ./system_modules/programs.nix
    ./system_modules/power-management.nix
    ./system_modules/vpn.nix
    ./system_modules/syncthing.nix
  ];
}