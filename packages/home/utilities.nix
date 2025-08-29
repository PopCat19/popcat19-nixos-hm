# Utility packages

{ pkgs, ... }:

with pkgs;
[
  # Audio & Hardware Control
  pavucontrol
  playerctl

  # File Sharing
  localsend
  zrok
]