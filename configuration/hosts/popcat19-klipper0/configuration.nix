# configuration.nix
#
# Purpose: Main NixOS configuration for the Klipper Pi 4B host
#
# This module:
# - Imports Pi 4 hardware base (U-Boot, vendor kernel, firmware) from nixos-raspberrypi
# - Imports the klipper profile (Klipper + Moonraker + Mainsail + services)
#
# inputs, userConfig, and nixos-raspberrypi are passed via specialArgs
# from flake-modules/nixos.nix to avoid _module.args infinite recursion.
{ inputs, userConfig, ... }:
{
  imports = [
    # Pi 4 hardware: U-Boot, vendor kernel, firmware, config.txt, udev
    # (gpio, i2c, spi groups already created by nixos-raspberrypi)
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
    ../../profiles/klipper.nix
  ];

  networking.hostName = userConfig.hostname;
}
