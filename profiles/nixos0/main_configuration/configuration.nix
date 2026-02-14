# nixos0 Profile System Configuration
#
# Purpose: Main NixOS configuration entry point for the nixos0 profile
# Dependencies: base_configuration/configuration.nix, hardware-configuration.nix
# Related: profiles/nixos0/user-config.nix, profiles/nixos0/main_configuration/home/home.nix
#
# This module:
# - Imports hardware configuration and base system modules
# - Configures profile-specific system settings
# - Sets hostname for this profile
{ pkgs, inputs, ... }:
{
  imports = [
    # Hardware configuration at profile root
    ../hardware-configuration.nix

    # Base configuration (shared)
    ../../../base_configuration/configuration.nix
    ../../../configuration/system/system-extended.nix

    # External modules
    inputs.jovian.nixosModules.default
  ];

  networking.hostName = "popcat19-nixos0";

  proxy.enable = false;

  # Profile-specific packages
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    opentabletdriver
  ];
}
