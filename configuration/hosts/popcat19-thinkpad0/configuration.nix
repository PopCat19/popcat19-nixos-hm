# configuration.nix
#
# Purpose: Main NixOS configuration for the thinkpad0 host
#
# This module:
# - Imports hardware configuration and profile preset
# - Applies host-specific modules and settings
{ pkgs, lib, userConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    ./modules/hardware.nix
    ./modules/zram.nix
    ../../system/modules/sunshine.nix
  ];

  networking.hostName = userConfig.hostname;

  services.displayManager.autoLogin.enable = lib.mkForce false;

  environment.systemPackages = with pkgs; [
    bleachbit
    moonlight-qt
  ];
}
