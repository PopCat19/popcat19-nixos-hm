# hyprland.nix
#
# Purpose: Hyprland window manager essentials
#
# This module:
# - Provides Hyprland utilities and agents
# - Provides screen locker configuration
{ pkgs, ... }:
with pkgs;
[
  hyprlock
  hyprpolkitagent
  hyprshade
  hyprutils
]
