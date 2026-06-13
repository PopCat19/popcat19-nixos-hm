# home.nix
#
# Purpose: Home Manager configuration for the aarch640 stub host
{ lib, userConfig, ... }:
let
  stateVersion = import ../../stateversion.nix;
in
{
  home.username = userConfig.username;
  home.homeDirectory = lib.mkForce userConfig.directories.home;
  home.stateVersion = stateVersion.home;

  imports = [
    ../../home/modules
  ];
}
