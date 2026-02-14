# git.nix
#
# Purpose: Configure Git version control settings
#
# This module:
# - Enables Git functionality
# - Sets user identity from configuration
# - Applies additional Git configuration
{ userConfig, ... }:
{
  programs.git = {
    enable = true;
    inherit (userConfig.git) userName userEmail extraConfig;
  };
}
