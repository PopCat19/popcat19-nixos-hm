# communication.nix
#
# Purpose: Communication and security packages
#
# This module:
# - Provides Discord client (vesktop)
# - Provides password manager (keepassxc)
{ pkgs, ... }:
with pkgs;
[
  keepassxc
  vesktop
]
