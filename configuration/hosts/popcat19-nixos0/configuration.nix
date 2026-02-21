# configuration.nix
#
# Purpose: Main NixOS configuration for the nixos0 host
#
# This module:
# - Imports hardware configuration and profile preset
# - Applies host-specific packages and settings
{
  pkgs,
  userConfig,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    ../../system/modules/sunshine.nix
  ];

  networking.hostName = userConfig.hostname;

  environment.systemPackages = with pkgs; [
    alsa-utils
    opentabletdriver
    pavucontrol
  ];
}
