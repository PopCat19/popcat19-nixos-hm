# git.nix
#
# Purpose: Configure Git version control settings
#
# This module:
# - Enables Git functionality
# - Sets user identity from configuration
# - Explicitly sets signing format to silence deprecation warning
{ userConfig, ... }:
{
  programs.git = {
    enable = true;

    # Silence signing format deprecation warning (home.stateVersion < 25.05)
    signing.format = "openpgp";

    settings = {
      user = {
        name = userConfig.git.userName;
        email = userConfig.git.userEmail;
      };
    }
    // userConfig.git.extraConfig;
  };
}
