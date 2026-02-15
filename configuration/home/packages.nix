# packages.nix
#
# Purpose: Consolidated Home Manager package list
#
# This module:
# - Provides all user-space packages
# - Includes x86_64-specific packages when applicable
{ pkgs, ... }:
let
  x86_64Packages = pkgs.lib.optionals pkgs.stdenv.isx86_64 [
    pkgs.btop-rocm
    pkgs.ddcui
    pkgs.openrgb-with-all-plugins
  ];
in
with pkgs;
[
  # Audio
  audacious
  audacious-plugins
  audacity
  furnace
  lmms
  mpv
  pavucontrol
  playerctl

  # Communication
  keepassxc
  vesktop

  # Desktop
  brightnessctl
  fuzzel
  hyprlock
  hyprpolkitagent
  hyprshade
  hyprutils

  # Development
  alejandra
  android-tools
  black
  bun
  clang-tools
  deadnix
  fd
  fish-lsp
  git-lfs
  glslang
  hyprlang
  hyprls
  jdk
  lazygit
  nil
  nixd
  nixfmt
  nixfmt-tree
  nodejs_latest
  prettierd
  python3
  ripgrep
  rustup
  shellcheck
  shfmt
  statix
  yamllint
  yarn-berry

  # Editors
  vscodium
  zed-editor

  # Files
  e2fsprogs
  eza
  file
  parted
  squashfsTools
  tree

  # Gaming
  lutris
  osu-lazer-bin

  # Graphics
  kdePackages.gwenview
  pureref

  # Networking
  localsend
  pear-desktop
  qbittorrent
  sshpass
  zrok

  # System
  appimage-run
  appstream
  coreutils-full
  ddcutil
  i2c-tools
  jq
  nixos-generators
  nixos-install-tools
  pv
  scrcpy
  usbutils
  util-linux
  zenity

  # Terminal
  fastfetch
  gum
  kitty
  micro
  starship
  wl-clipboard
]
++ x86_64Packages
