# helix.nix
#
# Purpose: Configure Helix editor with home-manager and stylix theming
#
# This module:
# - Enables Helix via home-manager
_: {
  programs.helix = {
    enable = true;
  };
}
