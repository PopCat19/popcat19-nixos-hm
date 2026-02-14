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
  stateVersion = import ../configuration/stateversion.nix;
in
{
  imports = [
    ../base_configuration/configuration.nix
    ../configuration/system/modules/programs.nix
    ../configuration/system/modules/power-management.nix
    ../configuration/system/modules/vpn.nix
    ../configuration/system/modules/syncthing.nix
    ../configuration/system/modules/dconf.nix
    ../configuration/system/modules/openrgb.nix
    ../configuration/system/modules/stylix-lightdm.nix
  ];

  system.stateVersion = stateVersion.system;

  home-manager = {
    users.${userConfig.username} = {
      home.stateVersion = stateVersion.home;
      imports = [ ../configuration/home/modules ];
    };
  };
}
