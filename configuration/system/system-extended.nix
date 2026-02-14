# system-extended.nix
#
# Purpose: Extended system configuration combining base and additional user modules
#
# This module:
# - Imports base system configuration as foundation
# - Adds user-specific system modules
# - Provides extension point for additional modules
{ ... }:
{
  imports = [
    ./configuration.nix
    ./modules/programs.nix
    ./modules/power-management.nix
    ./modules/vpn.nix
    ./modules/syncthing.nix
    ./modules/dconf.nix
    ./modules/openrgb.nix
    ./modules/stylix-lightdm.nix
  ];
}
