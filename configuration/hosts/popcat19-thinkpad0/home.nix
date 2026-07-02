# home.nix
#
# Purpose: Home Manager configuration for the thinkpad0 host
#
# This module:
# - Sets up home configuration from userConfig
# - Imports central home configuration
# - Applies host-specific monitor settings
{ lib, userConfig, ... }:
let
  stateVersion = import ../../stateversion.nix;
in
{
  home.username = userConfig.username;
  home.homeDirectory = lib.mkForce userConfig.directories.home;
  home.stateVersion = stateVersion.home;

  imports = [
    ../../home/modules
  ];

  home.file.".config/hypr/monitors.conf".source = ./hyprland/monitors.conf;

  # Toggle Super+C for hjkl mouse emulation. Requires services.kanataUdev.enable
  # in configuration.nix so /dev/uinput is accessible to the user service.
  programs.kanata.enable = true;
}
