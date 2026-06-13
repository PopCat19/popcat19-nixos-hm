# openrgb.nix
#
# Purpose: Enable OpenRGB service for RGB lighting control
#
# This module:
# - Enables OpenRGB systemd service for system-wide RGB control
# - Configures automatic SMBus/I2C module loading
# - Provides OpenRGB with all plugins
# - x86_64 only: SMBus/I2C RGB controllers are PC hardware
{ pkgs, lib, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isx86_64;
in
{
  config = lib.mkIf isx86_64 {
    boot.kernelModules = [
      "i2c-dev"
      "i2c-i801"
      "i2c-piix4"
    ];

    environment.systemPackages = with pkgs; [
      openrgb-with-all-plugins
    ];

    services.hardware.openrgb = {
      enable = true;
      motherboard = "amd";
    };
  };
}
