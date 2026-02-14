# home.nix
#
# Purpose: Home Manager configuration for the nixos0 host
#
# This module:
# - Sets up home configuration from userConfig
# - Imports central home configuration
# - Applies host-specific monitor settings
{ userConfig, ... }:
{
  home.username = userConfig.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  imports = [
    ../../configuration/home/home.nix
  ];

  home.file.".config/hypr/monitors.conf".source = ./hyprland/monitors.conf;
}
