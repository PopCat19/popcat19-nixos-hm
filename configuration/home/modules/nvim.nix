# nvim.nix
#
# Purpose: Configure Neovim editor
#
# This module:
# - Enables Neovim with default settings
# - Intentionally minimal for learning
_: {
  programs.neovim.enable = true;
}
