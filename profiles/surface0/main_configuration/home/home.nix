# surface0 Profile Home Configuration
#
# Purpose: Home Manager configuration for the surface0 profile
# Dependencies: configuration/home/home.nix, user-config.nix
# Related: profiles/surface0/main_configuration/configuration.nix
#
# This module:
# - Imports shared home modules from configuration/home/
# - Configures user-specific settings
# - Sets up profile-specific monitor configuration
{ userConfig, ... }:
{
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Import the central home configuration
  imports = [
    ../../../../configuration/home/home.nix
  ];

  # Profile-specific monitor configuration (overrides central config)
  home.file.".config/hypr/monitors.conf".source = ./hypr_config/monitors.conf;
}
