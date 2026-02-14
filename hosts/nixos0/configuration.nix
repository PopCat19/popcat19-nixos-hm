# NixOS Configuration for nixos0
#
# Purpose: Main configuration for the nixos0 host
# Dependencies: hardware-configuration.nix, profile preset
# Related: hosts/nixos0/user-config.nix
#
# This module:
# - Imports hardware configuration
# - Imports the profile preset specified in user-config.nix
# - Adds host-specific overrides and packages
{ pkgs, inputs, userConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}/configuration.nix
    inputs.jovian.nixosModules.default
  ];

  networking.hostName = userConfig.hostname;

  proxy.enable = false;

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    opentabletdriver
  ];
}
