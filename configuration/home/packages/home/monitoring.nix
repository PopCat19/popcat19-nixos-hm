# monitoring.nix
#
# Purpose: System monitoring packages
#
# This module:
# - Provides system information tools
{ pkgs, ... }:
with pkgs;
[
  fastfetch
]
