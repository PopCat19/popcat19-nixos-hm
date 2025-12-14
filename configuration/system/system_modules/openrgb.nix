# OpenRGB Configuration Module
#
# Purpose: Enable OpenRGB service for RGB lighting control across multiple hardware devices
# Dependencies: pkgs.openrgb, pkgs.openrgb-with-all-plugins (optional)
# Related: configuration/system/hardware.nix, configuration/home/home.nix
#
# This module:
# - Enables OpenRGB systemd service for system-wide RGB control
# - Configures automatic SMBus/I2C module loading for device detection
# - Provides OpenRGB server with customizable port and auto-start options
# - Supports AMD motherboard RGB control and plugin extensions
{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable OpenRGB hardware service
  services.hardware.openrgb = {
    enable = true;
    
    # Use the full-featured package with all plugins
    package = pkgs.openrgb-with-all-plugins;
    
    # Configure motherboard support (AMD in this case)
    motherboard = "amd";
    
    # Server configuration for network control
    server = {
      port = 6742;
      autoStart = true;
    };
  };

  # Enable I2C/SMBus modules for proper device detection
  boot.kernelModules = [
    "i2c-dev"
    "i2c-i801"
    "i2c-piix4"
  ];

  # Load kernel modules automatically at boot
  boot.extraModulePackages = with pkgs; [
    # These packages provide the kernel modules for I2C/SMBus support
  ];

  # Add OpenRGB to system packages
  environment.systemPackages = with pkgs; [
    openrgb-with-all-plugins
  ];

  # Optional: Add udev rules for device permissions (uncomment if needed)
  # services.udev.extraRules = ''
  #   # OpenRGB device access
  #   SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5720", GROUP="openrgb", MODE="0660"
  # '';
}