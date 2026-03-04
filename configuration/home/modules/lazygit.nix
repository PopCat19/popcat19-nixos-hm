# lazygit.nix
#
# Purpose: Configure LazyGit with home-manager
#
# This module:
# - Enables LazyGit via home-manager
_: {
  programs.lazygit = {
    enable = true;
  };
}
