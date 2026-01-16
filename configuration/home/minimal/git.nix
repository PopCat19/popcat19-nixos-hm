# Git Configuration Module
#
# Purpose: Configure Git version control settings
# Dependencies: None
# Related: None
#
# This module:
# - Enables Git functionality
# - Sets user identity from configuration
# - Applies additional Git configuration
{userConfig, ...}: {
  programs.git = {
    enable = true;
    settings =
      {
        user = {
          name = userConfig.git.userName;
          email = userConfig.git.userEmail;
        };
      }
      // userConfig.git.extraConfig;
  };
}
