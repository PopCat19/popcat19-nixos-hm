# configuration.nix
#
# Purpose: Base NixOS configuration entry point
#
# This module:
# - Imports boot-critical modules
# - Imports centralized nix configuration
# - Injects userConfig and selectedProfile for all imported modules
{
  lib,
  userConfig,
  selectedProfile ? null,
  ...
}:
{
  imports = [
    # Boot-critical files from ./system/
    ./system/boot.nix
    ./system/core-packages.nix
    ./system/environment.nix
    ./system/localization.nix
    ./system/users.nix

    # Additional system modules from ../system/modules/
    ../system/modules/audio.nix
    ../system/modules/display.nix
    ../system/modules/fish.nix
    ../system/modules/fonts.nix
    ../system/modules/gnome-keyring.nix
    ../system/modules/hardware.nix
    ../system/modules/networking.nix
    ../system/modules/noctalia.nix
    ../system/modules/packages.nix
    ../system/modules/proxy.nix
    ../system/modules/services.nix
    ../system/modules/ssh.nix
    ../system/modules/tablet.nix
    ../system/modules/virtualisation.nix

    # Centralized nix configuration
    ../nix-options.nix
  ];

  _module.args = {
    inherit userConfig;
  }
  // lib.optionalAttrs (selectedProfile != null) {
    inherit selectedProfile;
  };
}
