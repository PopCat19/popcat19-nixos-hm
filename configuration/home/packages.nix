# packages.nix
#
# Purpose: Consolidated Home Manager package list
#
# This module:
# - Provides all user-space packages
# - Includes x86_64-specific packages when applicable
{
  pkgs,
  inputs,
  userConfig,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isx86_64;

  # ROCm-aware: x86_64 AMD GPU hosts get btop-rocm; everything else gets btop
  btopPackage =
    if isx86_64 && (userConfig.gaming.enableROCm or false) then pkgs.btop-rocm else pkgs.btop;

  x86_64Packages = pkgs.lib.optionals isx86_64 [
    pkgs.appimage-run
    pkgs.ddcui
    pkgs.lutris
    pkgs.openrgb-with-all-plugins
    pkgs.osu-lazer-bin
    pkgs.pureref
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-stable
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
  ast-grep
  black
  bun
  clang-tools
  dbus.dev
  deadnix
  biome
  fd
  fish-lsp
  gcc
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
  pkg-config
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
  # lutris, osu-lazer-bin, and osu-stable are x86_64-only

  # Graphics
  friction-graphics
  kdePackages.gwenview
  # pureref is x86_64-only

  # Networking
  localsend
  pear-desktop
  qbittorrent
  sshpass
  zrok

  # System
  appstream
  coreutils-full
  ddcutil
  distrobox
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
  btopPackage
  fastfetch
  gum
  kitty
  micro
  starship
  wl-clipboard
]
++ x86_64Packages
