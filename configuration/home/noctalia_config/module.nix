# Noctalia Configuration Module
#
# Purpose: Main module for Noctalia configuration
# Dependencies: inputs.noctalia (flake input), home-manager
# Related: home_modules/noctalia.nix
#
# This module:
# - Imports Noctalia home manager module
# - Applies user's personalized settings
# - Configures systemd service for autostart
# - Integrates with the centralized configuration
{
  lib,
  pkgs,
  config,
  system,
  inputs,
  userConfig,
  ...
}: let
  inherit (import ./settings.nix {inherit pkgs config;}) settings;
  username = userConfig.user.username;
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;
    # Enable systemd service through home manager
    systemd.enable = true;

    settings = settings;
  };
}
