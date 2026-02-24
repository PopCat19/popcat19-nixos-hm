# git.nix
#
# Purpose: Configure Git version control settings
#
# This module:
# - Enables Git functionality
# - Sets user identity from configuration
{ userConfig, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = userConfig.git.userName;
        email = userConfig.git.userEmail;
      };
    }
    // userConfig.git.extraConfig;
  };
}
