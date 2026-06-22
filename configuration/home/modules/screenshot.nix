# screenshot.nix
#
# Purpose: Screenshot capture using grimblast and fuzzel menu
#
# This module:
# - Installs grimblast for Wayland screenshot capture
# - Creates fish wrapper with fuzzel mode selection and hyprshade bypass
{ pkgs, ... }:

{
  home.file."Pictures/Screenshots/.keep".text = "";

  home.file.".local/bin/screenshot" = {
    source = ./screenshot.fish;
    executable = true;
  };

  home.packages = with pkgs; [
    grimblast
    libnotify
  ];
}
