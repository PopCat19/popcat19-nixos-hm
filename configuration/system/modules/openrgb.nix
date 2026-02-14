# openrgb.nix
#
# Purpose: Enable OpenRGB service for RGB lighting control
#
# This module:
# - Enables OpenRGB systemd service for system-wide RGB control
# - Configures automatic SMBus/I2C module loading
# - Provides OpenRGB with all plugins
{ pkgs, ... }:
{
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
}
