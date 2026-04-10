# hardware.nix
#
# Purpose: Hardware configuration for Surface device
#
# This module:
# - Configures graphics, bluetooth, and firmware
# - Sets up power management and environment variables
{ pkgs, ... }:
{
  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    cpu.intel.updateMicrocode = true;

    sensor.iio.enable = true;

    firmware = with pkgs; [
      linux-firmware
      wireless-regdb
    ];

    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        freeglut
        intel-compute-runtime
        intel-media-driver
        intel-vaapi-driver
        libGL
        libGLU
        libva
        libva-utils
        libvdpau-va-gl
        mesa
        mesa-demos
        vdpauinfo
        vulkan-extension-layer
        vulkan-loader
        vulkan-validation-layers
        vpl-gpu-rt
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        intel-media-driver
        intel-vaapi-driver
        libGL
        libGLU
        mesa
        vulkan-loader
      ];
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };

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

  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "schedutil";
  };

  networking.wireless.iwd.enable = false;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
    OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
  };
}
