# gui.nix
#
# Purpose: GUI applications and launcher tools
#
# This module:
# - Provides application launcher
# - Provides Qt theming and applications
# - Provides learning and drawing applications
{ pkgs, ... }:
with pkgs;
[
  anki
  drawpile
  fuzzel
  kdePackages.filelight
  kdePackages.qtstyleplugin-kvantum
]
