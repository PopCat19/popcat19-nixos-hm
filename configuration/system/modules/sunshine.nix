# sunshine.nix
#
# Purpose: Configure Sunshine game streaming server
#
# This module:
# - Enables Sunshine service for game/desktop streaming
# - Configures firewall ports for streaming
# - Sets up necessary permissions for capture
{ pkgs, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  # Ensure user has access to input devices for capture
  users.users.popcat19.extraGroups = [
    "input"
    "video"
  ];

  # Additional packages for Sunshine functionality
  environment.systemPackages = with pkgs; [
    sunshine
  ];
}
