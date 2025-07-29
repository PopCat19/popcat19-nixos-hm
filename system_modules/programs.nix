{ ... }:

{
  # **SYSTEM PROGRAMS CONFIGURATION**
  # Defines system-level programs and their settings.
  # Note: Fish and Starship are configured in home_modules for user-specific settings.
  
  programs = {
    # **SHELL CONFIGURATION**
    # Enable fish system-wide but configure it in home_modules
    fish.enable = true;
    
    # **GAMING PROGRAMS**
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