# helix.nix
#
# Purpose: Configure Helix editor with home-manager and stylix theming
#
# This module:
# - Enables Helix via home-manager
# - Configures basic editor settings
_: {
  programs.helix = {
    enable = true;
    settings = {
      editor = {
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        selection-mode = "replace";
      };
    };
  };
}
