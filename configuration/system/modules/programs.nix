# programs.nix
#
# Purpose: Configure system-level programs and gaming support
#
# This module:
# - Enables Fish shell at system level
# - Configures Steam with gamescope session on x86_64
# - Enables GameMode for gaming performance on x86_64
{ pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isx86_64;
in
{
  programs = {
    fish.enable = true;
    gamemode.enable = isx86_64;
    steam = {
      dedicatedServer.openFirewall = true;
      enable = isx86_64;
      gamescopeSession.enable = isx86_64;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };
}
