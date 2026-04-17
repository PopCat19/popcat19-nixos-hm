# screenshot.nix
#
# Purpose: Screenshot capture using hyprshot and fish wrapper
#
# This module:
# - Installs hyprshot for Wayland screenshot capture
# - Creates fish wrapper with window naming and hyprshade bypass
{ pkgs, ... }:

{
  home.file."Pictures/Screenshots/.keep".text = "";

  home.file.".local/bin/screenshot" = {
    source = ./screenshot.fish;
    executable = true;
  };

  home.packages = with pkgs; [
    hyprshot
    libnotify
    jq
  ];
}
