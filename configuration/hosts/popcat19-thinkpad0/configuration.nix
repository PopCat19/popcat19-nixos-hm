# configuration.nix
#
# Purpose: Main NixOS configuration for the thinkpad0 host
#
# This module:
# - Imports hardware configuration and profile preset
# - Applies host-specific modules and settings
{ lib, userConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    ./modules/hardware.nix
  ];

  networking.hostName = userConfig.hostname;

  services.displayManager.autoLogin.enable = lib.mkForce false;
}
