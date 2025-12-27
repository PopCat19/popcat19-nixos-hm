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
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-gtk
      ];
      # Fix: Tell XDG to use Hyprland for things it supports (screenshare),
      # and fall back to GTK for things it doesn't (file picker).
      config = {
        common = {
          default = [ "gtk" ];
        };
        hyprland = {
          default = [ "hyprland" "gtk" ];
        };
      };
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