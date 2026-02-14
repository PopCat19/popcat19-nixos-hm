# development.nix
#
# Purpose: System-level development tools
#
# This module:
# - Provides GitHub CLI and archive utilities
# - Provides Python pip package
{ pkgs, ... }:
with pkgs;
[
  gh
  python313Packages.pip
  unzip
]
