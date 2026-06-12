# nixos.nix
#
# Purpose: NixOS configuration module for flake-parts
#
# This module:
# - Auto-discovers hosts from the configuration/hosts/ directory
# - Builds nixosConfigurations for each host using lib/mk-host.nix
# - Adds manual entry for popcat19-klipper0 using nixos-raspberrypi.lib.nixosSystem
#   (must use vendor nixpkgs 25.11 for Pi kernel+firmware compatibility)
{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  customLib = import ../lib {
    inherit lib inputs;
  };
  hostsDir = ../configuration/hosts;
  hostEntries = builtins.readDir hostsDir;
  hostDirs = lib.filterAttrs (
    name: type: type == "directory" && name != "nix-on-droid" && name != "popcat19-klipper0"
  ) hostEntries;
  hostPaths = lib.mapAttrs (name: _: hostsDir + "/${name}") hostDirs;

  # Auto-discovered x86 hosts (uses flake's nixpkgs-unstable)
  autoHosts = lib.mapAttrs customLib.mkHost.mkHostConfiguration hostPaths;

  # Manual: popcat19-klipper0 uses nixos-raspberrypi.lib.nixosSystem
  # with its own nixpkgs (25.11) for vendor kernel+firmware compatibility.
  klipperUserConfig = import (hostsDir + "/popcat19-klipper0/user-config.nix");
  rpi-lib = inputs.nixos-raspberrypi.lib;
in
{
  flake.nixosConfigurations = autoHosts // {
    popcat19-klipper0 = rpi-lib.nixosSystem {
      # specialArgs pass inputs + userConfig eagerly to all modules,
      # avoiding _module.args infinite recursion on imports
      specialArgs = {
        inherit inputs;
        userConfig = klipperUserConfig;
      };
      modules = [
        (hostsDir + "/popcat19-klipper0/configuration.nix")
      ];
    };
  };
}
