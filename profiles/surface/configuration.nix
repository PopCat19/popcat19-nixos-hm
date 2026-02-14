# Surface Profile Preset
#
# Purpose: Configuration preset for Microsoft Surface devices
# Dependencies: profiles/default/configuration.nix, Surface-specific modules
# Related: hosts/surface0/configuration.nix
#
# This preset:
# - Imports the default profile as base
# - Includes Surface-specific thermal management
# - Enables Surface hardware support (libwacom-surface, surface-control)
# - Applies clear-bdprochot fix for thermal issues
{ inputs, ... }:
{
  imports = [
    ../default/configuration.nix
  ];

  # Surface-specific thermal configuration
  services = {
    # Enable thermald with custom configuration for Surface devices
    thermald.enable = true;
  };

  # Enable IIO sensors for accelerometer/gyroscope
  hardware.sensor.iio.enable = true;

  # Surface-specific kernel modules for thermal management
  boot.kernelModules = [
    "intel_rapl_msr"
    "intel_rapl_common"
    "intel_powerclamp"
    "coretemp"
    "processor_thermal_device"
    "processor_thermal_device_pci"
    "processor_thermal_rfim"
    "processor_thermal_mbox"
    "processor_thermal_rapl"
    "intel_soc_dts_iosf"
    "intel_soc_dts_thermal"
    "msr"
  ];

  # Surface-specific kernel parameters
  boot.kernelParams = [
    "intel_pstate=active"
    "thermal.governor=step_wise"
    "thermal.polling_delay=1000"
    "processor.max_cstate=2"
    "intel_iommu=on"
    "iommu=pt"
    "nvme_core.default_ps_max_latency_us=2500"
  ];

  # Surface power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # Surface hardware configuration
  hardware = {
    # Enable all firmware for Surface devices
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    # Intel CPU microcode updates
    cpu.intel.updateMicrocode = true;

    # Bluetooth configuration
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

  # Surface-specific environment variables for Intel graphics
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
  };

  # Thermal monitoring udev rules
  services.udev.extraRules = ''
    SUBSYSTEM=="thermal", MODE="0664", GROUP="users"
    SUBSYSTEM=="powercap", MODE="0664", GROUP="users"
    KERNEL=="coretemp.*", MODE="0664", GROUP="users"
  '';
}
