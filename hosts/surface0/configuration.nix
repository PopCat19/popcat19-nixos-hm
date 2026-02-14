# NixOS Configuration for surface0
#
# Purpose: Main configuration for the surface0 host
# Dependencies: hardware-configuration.nix, profile preset
# Related: hosts/surface0/user-config.nix
#
# This module:
# - Imports hardware configuration
# - Imports the profile preset specified in user-config.nix
# - Adds host-specific overrides and modules
{ pkgs, inputs, userConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}/configuration.nix
    ./system_modules/clear-bdprochot.nix
    ./system_modules/thermal-config.nix
    ./system_modules/boot.nix
    ./system_modules/hardware.nix
  ];

  networking.hostName = userConfig.hostname;

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Surface-specific utilities
    libwacom-surface
    surface-control

    # Hardware monitoring and control
    lm_sensors
    brightnessctl

    # Power management utilities
    powertop
    acpi

    # Firmware and hardware tools
    fwupd
    dmidecode

    # Camera utilities
    v4l-utils

    # Audio utilities
    alsa-utils
    pulseaudio

    # WiFi utilities for debugging
    iw
    wpa_supplicant
    wirelesstools

    # DDC/CI and I2C tools for monitor control
    i2c-tools
    ddcutil
  ];
}
