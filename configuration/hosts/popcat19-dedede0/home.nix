# home.nix
#
# Purpose: Home Manager configuration for the dedede0 host (shimboot)
{ userConfig, ... }:
let
  stateVersion = import ../../stateversion.nix;
in
{
  home.username = userConfig.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = stateVersion.home;

  imports = [
    ../../home/modules
  ];
}
