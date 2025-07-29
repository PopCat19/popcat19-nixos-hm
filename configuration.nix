# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

{
  ################################
  # IMPORTS / STATE VERSION
  ################################
  imports = [
    # Hardware configuration (kept in root as requested)
    ./hardware-configuration.nix
    
    # External configurations
    ./syncthing_config/system.nix
    
    # System modules
    ./system_modules/boot.nix
    ./system_modules/hardware.nix
    ./system_modules/networking.nix
    ./system_modules/localization.nix
    ./system_modules/services.nix
    ./system_modules/display.nix
    ./system_modules/audio.nix
    ./system_modules/users.nix
    ./system_modules/virtualisation.nix
    ./system_modules/programs.nix
    ./system_modules/environment.nix
    ./system_modules/fonts.nix
  ];

  # WARNING: DO NOT CHANGE AFTER INITIAL INSTALL.
  system.stateVersion = "24.11";
}
