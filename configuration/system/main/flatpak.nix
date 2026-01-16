# Flatpak Configuration Module
#
# Purpose: Enable Flatpak for application sandboxing
# Dependencies: None
# Related: services.nix
#
# This module:
# - Enables Flatpak service
# - Provides sandboxed application support
{...}: {
  services.flatpak.enable = true;
}
