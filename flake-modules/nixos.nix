# nixos.nix
#
# Purpose: NixOS configuration module for flake-parts
#
# This module:
# - Auto-discovers hosts from the configuration/hosts/ directory
# - Builds nixosConfigurations for each host using lib/mk-host.nix
# - Adds manual entry for popcat19-klipper0 using nixos-raspberrypi.lib.nixosSystem
#   + manual sd-image module (avoids nixosInstaller's global desktop overlays
#   which pull ffmpeg-rpi/vlc/libcamera -> matplotlib/scipy -> QEMU crash)
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

  # Pi uses nixos-raspberrypi's lib.nixosSystem + manual sd-image module.
  # We avoid lib.nixosInstaller because it injects global desktop overlays
  # (ffmpeg-rpi -> matplotlib -> QEMU aarch64 import-check crash).
  klipperUserConfig = import (hostsDir + "/popcat19-klipper0/user-config.nix");
  rpi-lib = inputs.nixos-raspberrypi.lib;
  rpi-sd-image = inputs.nixos-raspberrypi.nixosModules.sd-image;
in
{
  flake.nixosConfigurations = autoHosts // {
    popcat19-klipper0 = rpi-lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        userConfig = klipperUserConfig;
      };
      modules = [
        rpi-sd-image
        (hostsDir + "/popcat19-klipper0/configuration.nix")
      ];
    };
  };
}
