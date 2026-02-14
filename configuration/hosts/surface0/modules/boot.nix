# boot.nix
#
# Purpose: Boot loader and kernel configuration for Surface hardware
#
# This module:
# - Configures systemd-boot and kernel modules
# - Applies Surface-specific kernel parameters
_: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    supportedFilesystems = [ "ntfs" ];

    kernelModules = [
      "8250_dw"
      "cfg80211"
      "coretemp"
      "i2c-dev"
      "intel_backlight"
      "intel_lpss"
      "intel_lpss_acpi"
      "intel_powerclamp"
      "intel_pstate"
      "intel_rapl_common"
      "intel_rapl_msr"
      "ipu3_cio2"
      "ipu3_imgu"
      "mac80211"
      "msr"
      "mwifiex"
      "mwifiex_pcie"
      "ov5693"
      "ov8865"
      "pinctrl_tigerlake"
      "processor_thermal_device"
      "snd_hda_codec_realtek"
      "snd_soc_max98357a"
      "snd_soc_rt5682_i2c"
      "snd_soc_skl"
      "snd_soc_skl_hda_dsp_generic"
      "surface_acpi_notify"
      "surface_aggregator"
      "surface_aggregator_hub"
      "surface_aggregator_registry"
      "surface_gpe"
      "surface_hid"
      "surface_hid_core"
      "surface_hotplug"
      "surface_kbd"
      "surface_platform_profile"
      "video"
    ];

    kernelParams = [
      "acpi_backlight=video"
      "acpi_osi=Linux"
      "cfg80211.ieee80211_regdom=US"
      "i915.enable_dc=0"
      "i915.enable_fbc=1"
      "i915.enable_guc=2"
      "i915.enable_psr=0"
      "i915.fastboot=1"
      "intel_idle.max_cstate=8"
      "intel_pstate=active"
      "intel_pstate=hwp_only"
      "iwlwifi.power_save=0"
      "iwlwifi.uapsd_disable=1"
      "loglevel=3"
      "mem_sleep_default=deep"
      "mitigations=off"
      "mwifiex_pcie.disable_msi=1"
      "mwifiex_pcie.reg_alpha2=US"
      "nowatchdog"
      "processor.max_cstate=8"
      "quiet"
      "snd_hda_intel.dmic_detect=0"
      "surface_aggregator.dyndbg=+p"
      "surface_serial_hub.dyndbg=+pfl"
      "video.brightness_switch_enabled=0"
    ];

    extraModulePackages = [ ];

    blacklistedKernelModules = [
      "ideapad_laptop"
    ];
  };
}
