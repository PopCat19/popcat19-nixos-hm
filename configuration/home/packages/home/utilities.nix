# utilities.nix
#
# Purpose: System utilities and tools
#
# This module:
# - Provides audio control and file sharing tools
# - Provides Android device management
# - Provides gaming platforms
# - Provides Shimboot project tools
{ pkgs, ... }:
with pkgs;
[
  android-tools
  appimage-run
  appstream
  coreutils-full
  file
  jq
  localsend
  lutris
  nixos-generators
  nixos-install-tools
  osu-lazer-bin
  parted
  pavucontrol
  playerctl
  pv
  scrcpy
  squashfsTools
  sshpass
  tree
  winboat
  zenity
  zrok
]
