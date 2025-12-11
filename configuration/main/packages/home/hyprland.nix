# Hyprland window manager essentials
{pkgs, ...}:
with pkgs; [
  hyprpanel
  hyprshade
  hyprpolkitagent
  hyprutils

  # Screen locker
  hyprlock

  # Screenshot and input tools
  hyprpicker
  hyprpaper
]
