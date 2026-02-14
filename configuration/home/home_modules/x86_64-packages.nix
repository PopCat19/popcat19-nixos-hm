# x86_64-packages.nix
#
# Purpose: Define x86_64-specific home manager packages
#
# This module:
# - Provides system monitoring with ROCm support
# - Includes hardware control tools
{ pkgs, ... }:
with pkgs;
[
  btop-rocm
  ddcui
  openrgb-with-all-plugins
]
