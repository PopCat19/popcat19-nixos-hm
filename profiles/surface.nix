# surface.nix
#
# Purpose: Configuration preset for Microsoft Surface devices
#
# This profile:
# - Imports the default profile as base
# - Includes Surface-specific thermal management
# - Enables Surface hardware support (libwacom-surface, surface-control)
# - Applies clear-bdprochot fix for thermal issues
{ userConfig, ... }:
let
  stateVersion = import ../configuration/stateversion.nix;
in
{
  imports = [
    ./default.nix
  ];

  boot = {
    kernelModules = [
      "coretemp"
      "intel_powerclamp"
      "intel_rapl_common"
      "intel_rapl_msr"
      "intel_soc_dts_iosf"
      "intel_soc_dts_thermal"
      "msr"
      "processor_thermal_device"
      "processor_thermal_device_pci"
      "processor_thermal_mbox"
      "processor_thermal_rapl"
      "processor_thermal_rfim"
    ];

    kernelParams = [
      "intel_iommu=on"
      "intel_pstate=active"
      "iommu=pt"
      "nvme_core.default_ps_max_latency_us=2500"
      "processor.max_cstate=2"
      "thermal.governor=step_wise"
      "thermal.polling_delay=1000"
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
  };

  hardware = {
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

    cpu.intel.updateMicrocode = true;

    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    sensor.iio.enable = true;
  };

  powerManagement = {
    cpuFreqGovernor = "schedutil";
    enable = true;
    powertop.enable = true;
  };

  services = {
    thermald.enable = true;

    udev.extraRules = ''
      SUBSYSTEM=="thermal", MODE="0664", GROUP="users"
      SUBSYSTEM=="powercap", MODE="0664", GROUP="users"
      KERNEL=="coretemp.*", MODE="0664", GROUP="users"
    '';
  };

  system.stateVersion = stateVersion.system;

  home-manager = {
    users.${userConfig.username} = {
      home.stateVersion = stateVersion.home;
    };
  };
}
