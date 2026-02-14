# NixOS Configuration for thinkpad0
#
# Purpose: Main configuration for the thinkpad0 host
# Dependencies: hardware-configuration.nix, profile preset
# Related: hosts/thinkpad0/user-config.nix
#
# This module:
# - Imports hardware configuration
# - Imports the profile preset specified in user-config.nix
# - Adds host-specific overrides and modules
{ lib, pkgs, inputs, userConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}/configuration.nix
    ./system_modules/hardware.nix
  ];

  networking.hostName = userConfig.hostname;

  proxy.enable = true;

  # Disable autologin for thinkpad0 (override from display module)
  services.displayManager.autoLogin.enable = lib.mkForce false;
}
