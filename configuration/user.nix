# user.nix
#
# Purpose: User configuration for home-manager
#
# This module:
# - Defines user-specific home-manager configuration
# - Imports home modules
# - Sets up user packages
{
  pkgs,
  inputs,
  userConfig,
  ...
}:
{
  home.username = userConfig.username;
  home.homeDirectory = userConfig.directories.home;

  imports = [
    ./home/modules
  ];

  home.packages = import ./home/home_packages.nix {
    inherit pkgs inputs userConfig;
  };
}
