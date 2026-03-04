# vivid.nix
#
# Purpose: Configure Vivid with home-manager
#
# This module:
# - Enables Vivid via home-manager
_: {
  programs.vivid = {
    enable = true;
  };
}
