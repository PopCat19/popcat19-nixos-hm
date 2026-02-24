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
    ../../profiles/${userConfig.profile}.nix
    ./modules/boot.nix
    ./modules/clear-bdprochot.nix
    ./modules/hardware.nix
    ./modules/thermal-config.nix
    ../../system/modules/sunshine.nix
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
    moonlight-qt
    powertop
    pulseaudio
    surface-control
    v4l-utils
    wirelesstools
    wpa_supplicant
  ];
}
