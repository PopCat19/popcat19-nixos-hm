# Hyprland window manager essentials

{ pkgs, ... }:

with pkgs;
[
  hyprpanel
  hyprshade
  hyprpolkitagent
  hyprutils

  # Screenshot and input tools
  grim
  slurp
  wtype
  hyprpicker
]