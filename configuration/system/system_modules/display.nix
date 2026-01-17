# Display Configuration Module
#
# Purpose: Orchestrate display system configuration through separated modules
# Dependencies: None (delegates to sub-modules)
# Related: greeter.nix, hyprland.nix, xdg.nix
#
# This module:
# - Imports and coordinates greeter configuration (SDDM)
# - Imports and coordinates window manager configuration (Hyprland)
# - Imports and coordinates XDG portal configuration
# - Maintains single entry point for display system setup
{ ... }:
{
  imports = [
    ./greeter.nix
    ./hyprland.nix
    ./xdg.nix
  ];
}
