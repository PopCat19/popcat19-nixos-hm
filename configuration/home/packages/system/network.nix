# network.nix
#
# Purpose: Network tools
#
# This module:
# - Provides WireGuard VPN utilities
{ pkgs, ... }:
with pkgs;
[
  wireguard-tools
]
