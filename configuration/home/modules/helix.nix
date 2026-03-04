# helix.nix
#
# Purpose: Configure Helix editor with stylix theming
#
# This module:
# - Enables helix editor via home-manager
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
        edit = {
          use-commit-timestamps = true;
        };
        indent = {
          unit = "2tabs";
        };
      };
    };
  };
}
