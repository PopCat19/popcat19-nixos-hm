# x86_64-packages.nix
#
# Purpose: Define x86_64-specific system packages
#
# This module:
# - Provides AMD GPU acceleration packages
# - Includes Remote Desktop Protocol client
{ pkgs, ... }:
with pkgs;
[
  freerdp
  rocmPackages.rpp
]
