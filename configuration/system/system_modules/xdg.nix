# xdg.nix
#
# Purpose: Configure XDG desktop portals and MIME type handling
#
# This module:
# - Enables XDG MIME type support
# - Configures XDG desktop portals with Hyprland support
# - Integrates Hyprland-specific portal implementation
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.flatpak
    pkgs.xdg-desktop-portal
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-hyprland
  ];

  xdg = {
    mime.enable = true;
    portal = {
      config = {
        common = {
          default = [ "gtk" ];
        };
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
        };
      };
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
  };
}
