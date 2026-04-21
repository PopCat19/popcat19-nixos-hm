# dconf.nix
#
# Purpose: Enable dconf for GTK/Qt settings and desktop configuration
#
# This module:
# - Enables dconf at system level for desktop settings
# - Provides dconf functionality for home-manager modules
# - Supports GTK theme and font configuration
_: {
  programs.dconf.enable = true;
}
