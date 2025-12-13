# DConf Configuration Module
#
# Purpose: Enable dconf for GTK/Qt settings and desktop configuration
# Dependencies: None
# Related: display.nix, theme.nix, fonts.nix
#
# This module:
# - Enables dconf at system level for desktop settings
# - Provides dconf functionality for home-manager modules
# - Supports GTK theme and font configuration
{
  pkgs,
  ...
}: {
  programs.dconf.enable = true;
}