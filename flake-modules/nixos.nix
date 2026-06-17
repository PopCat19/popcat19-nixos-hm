# nixos.nix
#
# Purpose: NixOS configuration module for flake-parts
#
# This module:
# - Auto-discovers hosts from the configuration/hosts/ directory
# - Builds nixosConfigurations for each host using lib/mk-host.nix
{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  customLib = import ../lib {
    inherit lib inputs;
  };
  hostsDir = ../configuration/hosts;
  hostEntries = builtins.readDir hostsDir;
  hostDirs = lib.filterAttrs (name: type: type == "directory" && name != "nix-on-droid") hostEntries;
  hostPaths = lib.mapAttrs (name: _: hostsDir + "/${name}") hostDirs;
in
{
  flake.nixosConfigurations = lib.mapAttrs customLib.mkHost.mkHostConfiguration hostPaths;
}
