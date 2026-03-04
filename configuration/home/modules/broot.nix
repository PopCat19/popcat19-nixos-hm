# broot.nix
#
# Purpose: Configure Broot file manager with home-manager
#
# This module:
# - Enables Broot via home-manager
_: {
  programs.broot = {
    enable = true;
  };
}
