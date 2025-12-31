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
    userName = userConfig.git.userName;
    userEmail = userConfig.git.userEmail;
    extraConfig = userConfig.git.extraConfig;
  };
}
