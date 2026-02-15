# configuration.nix
#
# Purpose: Main NixOS configuration for the nixos0 host
#
# This module:
# - Imports hardware configuration and profile preset
# - Applies host-specific packages and settings
{
  pkgs,
  inputs,
  userConfig,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    inputs.jovian.nixosModules.default
  ];

  networking.hostName = userConfig.hostname;

  environment.systemPackages = with pkgs; [
    alsa-utils
    opentabletdriver
    pavucontrol
  ];
}
