# home-files.nix
#
# Purpose: Manage home directory file symlinks and configuration
#
# This module:
# - Links Hyprland configuration files
# - Copies wallpaper directory for Noctalia
# - Configures NPM global prefix
{ config, ... }:
{
  home.file.".config/hypr" = {
    source = ../hypr_config;
    recursive = true;
  };

  home.file."wallpaper" = {
    source = ../wallpaper;
    recursive = true;
  };

  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';
}
