# hardware.nix
#
# Purpose: Hardware tools and utilities
#
# This module:
# - Provides display and USB management tools
# - Provides filesystem and brightness utilities
{ pkgs, ... }:
with pkgs;
[
  brightnessctl
  ddcutil
  e2fsprogs
  eza
  i2c-tools
  usbutils
  util-linux
]
