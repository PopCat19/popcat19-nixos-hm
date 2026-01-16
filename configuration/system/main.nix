# Main System Configuration
#
# Purpose: Userland with Wayland environment and essential daily tools
# Dependencies: minimal.nix, all main modules
# Related: minimal.nix, extras.nix
#
# This module:
# - Imports all main system modules
# - Provides Wayland environment and desktop functionality
{...}: {
  imports = [
    ./minimal.nix
    ./main/display.nix
    ./main/programs.nix
    ./main/power-management.nix
    ./main/syncthing.nix
    ./main/dconf.nix
    ./main/stylix-lightdm.nix
    ./main/wayland/hyprland.nix
    ./main/wayland/noctalia.nix
    ./main/flatpak.nix
  ];
}
