# Utility packages
{pkgs, ...}:
with pkgs; [
  # Audio & Hardware Control
  pavucontrol
  playerctl

  # File Sharing
  localsend
  zrok

  # System Utilities
  appstream
  jq
  tree
  appimage-run
  zenity
  alejandra
  statix
  deadnix

  # Gaming
  lutris
  # bottles
  osu-lazer-bin
  winboat

  # Shimboot Project Tools
  pv
  parted
  squashfsTools
  nixos-install-tools
  nixos-generators
  sshpass
  coreutils-full
  file
]
