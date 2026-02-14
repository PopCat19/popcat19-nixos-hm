# configuration.nix
#
# Purpose: Main NixOS configuration for the surface0 host
#
# This module:
# - Imports hardware configuration and profile preset
# - Applies host-specific modules and packages
{ pkgs, userConfig, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}/configuration.nix
    ./system_modules/boot.nix
    ./system_modules/clear-bdprochot.nix
    ./system_modules/hardware.nix
    ./system_modules/thermal-config.nix
  ];

  networking.hostName = userConfig.hostname;

  environment.systemPackages = with pkgs; [
    acpi
    alsa-utils
    brightnessctl
    ddcutil
    dmidecode
    fwupd
    i2c-tools
    iw
    libwacom-surface
    lm_sensors
    powertop
    pulseaudio
    surface-control
    v4l-utils
    wirelesstools
    wpa_supplicant
  ];
}
