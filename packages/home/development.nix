# Development tools and language support

{ pkgs, ... }:

with pkgs;
[
  # Nix Development
  nil
  nixd
  nixfmt-rfc-style

  # Code Formatters
  black
  prettierd

  # Development Tools
  ripgrep
  fd
  lazygit
  git-lfs
  hyprls

  # Android Tools
  universal-android-debloater
  android-tools
  scrcpy
  sidequest

  # Programming Languages and Runtimes
  jdk
  nodejs_latest
  yarn-berry
  rustup
  python3

  # Hardware Development Tools
  sunxi-tools
  binwalk
  vboot_reference
]