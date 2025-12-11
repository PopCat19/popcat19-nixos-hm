# Hardware tools and utilities
{pkgs, ...}:
with pkgs; [
  i2c-tools
  ddcutil
  usbutils
  util-linux
  e2fsprogs
  eza
  brightnessctl
]
