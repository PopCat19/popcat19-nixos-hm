# programs.nix
#
# Purpose: Configure system-level programs and gaming support
#
# This module:
# - Enables Fish shell at system level
# - Configures Steam with gamescope session
# - Enables GameMode for gaming performance
_: {
  programs = {
    fish.enable = true;
    gamemode.enable = true;
    steam = {
      dedicatedServer.openFirewall = true;
      enable = true;
      gamescopeSession.enable = true;
      localNetworkGameTransfers.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };
}
