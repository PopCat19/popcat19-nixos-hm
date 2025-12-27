# XDG Portal and MIME Configuration Module
#
# Purpose: Configure XDG desktop portals and MIME type handling
# Dependencies: xdg-desktop-portal-hyprland
# Related: greeter.nix, wm.nix
#
# This module:
# - Enables XDG MIME type support
# - Configures XDG desktop portals with Hyprland support
# - Integrates Hyprland-specific portal implementation
{
  pkgs,
  ...
}: {
  xdg = {
    mime.enable = true;
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };

  # Ensure flatpak package is installed
  environment.systemPackages = [
    pkgs.flatpak
    pkgs.xdg-desktop-portal
    pkgs.xdg-desktop-portal-hyprland
    pkgs.xdg-desktop-portal-gtk
  ];
}