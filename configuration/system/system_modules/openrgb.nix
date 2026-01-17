# OpenRGB Configuration Module
#
# Purpose: Enable OpenRGB service for RGB lighting control across multiple hardware devices
# Dependencies: pkgs.openrgb, pkgs.openrgb-with-all-plugins (optional)
# Related: configuration/system/hardware.nix, configuration/home/home.nix
#
# This module:
# - Enables OpenRGB systemd service for system-wide RGB control
# - Configures automatic SMBus/I2C module loading for device detection
# - Provides OpenRGB server with customizable port options
# - Supports AMD motherboard RGB control and plugin extensions
{ pkgs, ... }:
{
  # Enable OpenRGB hardware service
  services.hardware.openrgb = {
    enable = true;

    # Configure motherboard support (AMD in this case)
    motherboard = "amd";
  };

  # Enable I2C/SMBus modules for proper device detection
  boot.kernelModules = [
    "i2c-dev"
    "i2c-i801"
    "i2c-piix4"
  ];

  # Add OpenRGB to system packages
  environment.systemPackages = with pkgs; [
    openrgb-with-all-plugins
  ];
}
