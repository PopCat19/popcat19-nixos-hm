# zathura.nix
#
# Purpose: Configure Zathura PDF viewer with home-manager
#
# This module:
# - Enables Zathura via home-manager
_: {
  programs.zathura = {
    enable = true;
  };
}
