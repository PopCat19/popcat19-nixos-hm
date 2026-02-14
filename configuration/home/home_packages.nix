# home_packages.nix
#
# Purpose: Consolidated Home Manager package list
#
# This module:
# - Provides all user-space packages
# - Includes x86_64-specific packages when applicable
{ pkgs, ... }:
with pkgs;
let
  x86_64Packages = if pkgs.stdenv.isx86_64 then [
    btop-rocm
    ddcui
    openrgb-with-all-plugins
  ] else [];
in
# Browsers
[
  firefox
]
# Communication
++ [
  keepassxc
  vesktop
]
# Hyprland
++ [
  hyprlock
  hyprpolkitagent
  hyprshade
  hyprutils
]
# Media
++ [
  audacious
  audacious-plugins
  audacity
  carla
  furnace
  helio-workstation
  kdePackages.gwenview
  lmms
  mangayomi
  mpv
  pear-desktop
  pureref
  qbittorrent
  qtractor
  vital
]
# Terminal
++ [
  eza
  fuzzel
  kitty
  micro
  nur.repos.charmbracelet.crush
  starship
  wl-clipboard
]
# Development
++ [
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
]
# Editors
++ [
  vscodium
  zed-editor
]
# Monitoring
++ [
  fastfetch
]
# Utilities
++ [
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
# Hardware tools
++ [
  brightnessctl
  ddcutil
  e2fsprogs
  eza
  i2c-tools
  usbutils
  util-linux
]
# x86_64-specific
++ x86_64Packages
