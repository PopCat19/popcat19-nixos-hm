# nixos.nix
#
# Purpose: NixOS configuration module for flake-parts
#
# This module:
# - Auto-discovers hosts from the configuration/hosts/ directory
# - Builds nixosConfigurations for each host
# - Uses shared lib helpers for configuration
{ inputs, ... }:
let
  lib = import ../lib { lib = inputs.nixpkgs.lib; inherit inputs; };
  hostsDir = ../configuration/hosts;
  hostEntries = builtins.readDir hostsDir;
  hostDirs = inputs.nixpkgs.lib.filterAttrs (_: type: type == "directory") hostEntries;
in
{
  flake.nixosConfigurations = builtins.mapAttrs lib.mkHost.mkHostConfiguration hostDirs;
}
