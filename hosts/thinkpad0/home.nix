# Host-specific home configuration for thinkpad0
#
# Purpose: Home Manager configuration for the thinkpad0 host
# Dependencies: configuration/home/home.nix
# Related: hosts/thinkpad0/user-config.nix
#
# This module:
# - Sets up basic home configuration from userConfig
# - Imports the central home configuration
# - Adds host-specific monitor configuration
{ userConfig, ... }:
{
  # Basic home configuration
  home.username = userConfig.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Import the central home configuration
  imports = [
    ../../configuration/home/home.nix
  ];

  # Host-specific monitor configuration (overrides central config)
  home.file.".config/hypr/monitors.conf".source = ./hypr_config/monitors.conf;
}
