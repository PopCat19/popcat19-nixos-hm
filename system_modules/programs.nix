{ ... }:

{
  # System programs configuration
  # Fish and Starship are configured in home_modules for user-specific settings.
  
  programs = {
    # Shell configuration
    fish.enable = true;
    
    # Gaming programs
    gamemode.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}