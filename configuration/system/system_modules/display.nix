# display.nix
#
# Purpose: Orchestrate display system configuration through separated modules
#
# This module:
# - Imports greeter configuration (SDDM)
# - Imports window manager configuration (Hyprland)
# - Imports XDG portal configuration
{ ... }:
{
  imports = [
    ./greeter.nix
    ./hyprland.nix
    ./xdg.nix
  ];
}
