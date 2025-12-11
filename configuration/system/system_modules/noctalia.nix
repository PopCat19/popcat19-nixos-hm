# Noctalia Shell Configuration Module
#
# Purpose: Enable Noctalia shell globally for Wayland systems with bar and launcher functionality
# Dependencies: inputs.noctalia (flake input), wayland, nixpkgs-unstable
# Related: system_modules/display.nix, system_modules/networking.nix
#
# This module:
# - Imports and enables the Noctalia NixOS module
# - Enables the Noctalia systemd service for automatic startup
# - Ensures required system dependencies are available
# - Provides global configuration for all Wayland systems
# - Note: Does not configure power-profiles-daemon or tuned as requested
{
  pkgs,
  lib,
  inputs,
  ...
}: {
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  # Enable Noctalia systemd service with proper autostart
  services.noctalia-shell = {
    enable = true;
    # Use graphical-session.target for proper autostart with Wayland compositors
    target = "graphical-session.target";
  };

  # Ensure systemd user services are enabled
  systemd.user.services.noctalia-shell = {
    # Add service override for better startup behavior
    serviceConfig = {
      # Restart on failure to ensure it starts reliably
      Restart = "on-failure";
      RestartSec = 5;
      # Ensure it waits for display server
      After = [ "graphical-session.target" "wayland-session.target" ];
      # Add wayland dependency
      Wants = [ "graphical-session.target" ];
    };
  };

  # Ensure required system packages are available
  environment.systemPackages = with pkgs; [
    # Noctalia is provided by the flake input, but ensure basic Wayland support
    wayland
    wayland-protocols
    wlroots
  ];

  # Optional: Set default environment variables for better Noctalia compatibility
  environment.sessionVariables = {
    # Ensure Wayland applications use native protocols
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    # Help Noctalia detect the correct display server
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
  };
}