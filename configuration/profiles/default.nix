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
    # Base configuration (minimal bootable)
    ../base/configuration.nix

    # System modules previously in base
    ../system/modules/boot.nix
    ../system/modules/audio.nix
    ../system/modules/zrythm.nix
    ../system/modules/display.nix
    ../system/modules/fish.nix
    ../system/modules/fonts.nix
    ../system/modules/gnome-keyring.nix
    ../system/modules/hardware.nix
    ../system/modules/hyprland.nix
    ../system/modules/networking.nix
    ../system/modules/noctalia.nix
    ../system/packages.nix
    ../system/modules/services.nix
    ../system/modules/ssh.nix
    ../system/modules/tablet.nix
    ../system/modules/virtualisation.nix
    ../system/modules/xdg.nix

    # Additional profile modules
    ../system/modules/programs.nix
    ../system/modules/users.nix
    ../system/modules/environment.nix
    ../system/modules/power-management.nix
    ../system/modules/vpn.nix
    ../system/modules/syncthing.nix
    ../system/modules/dconf.nix
    ../system/modules/openrgb.nix
    ../system/modules/stylix-lightdm.nix
    ../system/modules/apollo.nix

    # Centralized nix configuration
    ../nix-options.nix
  ];

  system.stateVersion = stateVersion.system;

  home-manager.users.${userConfig.username} = {
    imports = [ ../home/modules ];
  };
}
