# Extended System Configuration Module
#
# Purpose: Extended system configuration combining base and additional user modules
# Dependencies: configuration/system, user system modules
# Related: configuration/system/configuration.nix, flake.nix
#
# This module:
# - Imports base system configuration as foundation
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
    ./configuration.nix
    ./system_modules/programs.nix
    ./system_modules/power-management.nix
    ./system_modules/vpn.nix
    ./system_modules/syncthing.nix
    ./system_modules/dconf.nix
  ];
}