# terminal.nix
#
# Purpose: Terminal and core shell tools
#
# This module:
# - Provides terminal emulator and launcher
# - Provides shell enhancements and utilities
{ pkgs, ... }:
with pkgs;
[
  eza
  fuzzel
  kitty
  micro
  nur.repos.charmbracelet.crush
  starship
  wl-clipboard
]
