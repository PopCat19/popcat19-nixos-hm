# home.nix
#
# Purpose: Home Manager configuration for the thinkpad0 host
#
# This module:
# - Sets up home configuration from userConfig
# - Imports central home configuration
# - Applies host-specific monitor settings
{ userConfig, ... }:
let
  stateVersion = import ../../configuration/stateversion.nix;
in
{
  home.username = userConfig.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = stateVersion.home;

  imports = [
    ../../configuration/home/modules
  ];

  home.file.".config/hypr/monitors.conf".source = ./hyprland/monitors.conf;
}
