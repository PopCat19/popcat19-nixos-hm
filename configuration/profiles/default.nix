# default.nix
#
# Purpose: Default profile preset for desktop systems
#
# This profile:
# - Imports base system configuration
# - Configures standard desktop environment
# - Sets up home manager with default modules
{ userConfig, ... }:
let
  stateVersion = import ../stateversion.nix;
in
{
  imports = [
    ../base/configuration.nix
    ../system/modules/programs.nix
    ../system/modules/power-management.nix
    ../system/modules/vpn.nix
    ../system/modules/syncthing.nix
    ../system/modules/dconf.nix
    ../system/modules/openrgb.nix
    ../system/modules/stylix-lightdm.nix
  ];

  system.stateVersion = stateVersion.system;

  home-manager = {
    users.${userConfig.username} = {
      home.stateVersion = stateVersion.home;
      imports = [ ../home/modules ];
    };
  };
}
