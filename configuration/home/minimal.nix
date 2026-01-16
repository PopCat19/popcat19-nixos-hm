# Minimal Home Configuration
#
# Purpose: Essential user configuration for basic system usage
# Dependencies: All minimal modules
# Related: main.nix, extras.nix
#
# This module:
# - Imports all minimal home modules
# - Provides basic user environment
{
  pkgs,
  inputs,
  userConfig,
  hostPlatform,
  ...
}: {
  imports = [
    ./minimal/environment.nix
    ./minimal/fonts.nix
    ./minimal/home-files.nix
    ./minimal/services.nix
    ./minimal/systemd-services.nix
    ./minimal/starship.nix
    ./minimal/micro.nix
    ./minimal/git.nix
  ];
}
