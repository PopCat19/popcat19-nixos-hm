# packages.nix
#
# Purpose: Consolidated Home Manager package list
#
# This module:
# - Provides all user-space packages
# - Includes x86_64-specific packages when applicable
{ pkgs, inputs, hostPlatform, ... }:
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
  openutau
  pavucontrol
  playerctl
  voicevox
  zrythm

  # Communication
  keepassxc

  # Desktop
  brightnessctl
  cliphist
  fuzzel
  hyprlock
  hyprshade
  hyprutils

  # Development
  android-tools
  black
  bun
  clang-tools
  deadnix
  biome
  fd
  fish-lsp
  git-lfs
  glslang
  gopls
  hyprlang
  hyprls
  java-language-server
  jdk
  lazygit
  nil
  nixd
  nixfmt
  nixfmt-tree
  nodejs_22
  prettierd
  python3
  pyright
  ripgrep
  rustup
  shellcheck
  shfmt
  statix
  typescript-language-server
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
  ranger
  squashfsTools
  tree

  # Gaming
  inputs.nix-gaming.packages.${hostPlatform}.osu-stable
  lutris
  osu-lazer-bin

  # Graphics
  friction-graphics
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
