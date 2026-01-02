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
{inputs, ...}: {
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  # Enable Noctalia systemd service with proper autostart (this or hm only)
  # services.noctalia-shell = {
  #   enable = true;
  # };
}
