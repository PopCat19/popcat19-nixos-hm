# Utility packages
{pkgs, ...}:
with pkgs; [
  # Audio & Hardware Control
  pavucontrol
  playerctl
  openrgb

  # File Sharing
  localsend
  zrok

  # System Utilities
  appstream
  jq
  tree
  appimage-run
  zenity

  # Gaming
  # lutris # Temporarily disabled due to pyrate-limiter build failures
  osu-lazer-bin

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
