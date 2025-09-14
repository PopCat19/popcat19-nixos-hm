{
  config,
  pkgs,
  lib,
  ...
}: {
  # **BOOT & KERNEL CONFIGURATION**
  # Defines boot loader, kernel, and filesystem support settings for Surface.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["ntfs"];

    # Let nixos-hardware common module provide the patched linux-surface kernel
    # kernelPackages = pkgs.linuxPackages_latest;  # Removed to avoid conflict with nixos-hardware

    # Surface-specific kernel modules
    kernelModules = [
      # Core Surface modules
      "surface_aggregator"
      "surface_aggregator_registry"
      "surface_aggregator_hub"
      "surface_hid_core"
      "surface_hid"

      # Surface ACPI drivers
      "surface_acpi_notify"
      "surface_platform_profile"
      "surface_gpe"

      # Surface input drivers (touch and pen)
      "surface_kbd"
      "surface_hotplug"
      "8250_dw"
      "pinctrl_tigerlake"
      "intel_lpss"
      "intel_lpss_acpi"

      # Surface camera drivers
      "ipu3_cio2"
      "ipu3_imgu"
      "ov5693"
      "ov8865"

      # Surface audio drivers
      "snd_soc_skl"
      "snd_soc_skl_hda_dsp_generic"
      "snd_hda_codec_realtek"
      "snd_soc_rt5682_i2c"
      "snd_soc_max98357a"

      # Surface thermal management
      "intel_rapl_msr"
      "intel_rapl_common"
      "intel_powerclamp"
      "coretemp"

      # Surface power management
      "intel_pstate"
      "processor_thermal_device"
      "intel_soc_dts_iosf"

      # WiFi and networking modules
      "mwifiex"
      "mwifiex_pcie"
      "cfg80211"
      "mac80211"

      # MSR module for BD-PROCHOT clearing
      "msr"

      # Backlight support modules
      "intel_backlight"
      "video"

      # I2C userspace access for DDC/CI
      "i2c-dev"
    ];

    # Surface-specific kernel parameters
    kernelParams = [
      "mem_sleep_default=deep"
      "surface_aggregator.dyndbg=+p"
      "surface_serial_hub.dyndbg=+pfl"
      "i915.enable_psr=0"
      "i915.enable_fbc=1"
      "i915.fastboot=1"
      "i915.enable_guc=2"
      "i915.enable_dc=0"
      "i915.disable_power_well=0"
      "intel_pstate=active"
      "intel_pstate=hwp_only"
      "processor.max_cstate=8"
      "intel_idle.max_cstate=8"
      "snd_hda_intel.dmic_detect=0"
      "mwifiex_pcie.disable_msi=1"
      "mwifiex_pcie.reg_alpha2=US"
      "cfg80211.ieee80211_regdom=US"
      "acpi_osi=Linux"
      "acpi_backlight=video"
      "video.brightness_switch_enabled=0"
      "iwlwifi.power_save=0"
      "iwlwifi.uapsd_disable=1"
      "mitigations=off"
      "nowatchdog"
      "quiet"
      "loglevel=3"
    ];

    # Additional module packages for Surface hardware (kept empty placeholder to allow overrides)
    extraModulePackages = with pkgs; [
      # Surface-specific drivers that may not be in mainline kernel
    ];

    # Blacklist problematic modules that might interfere with mwifiex
    blacklistedKernelModules = [
      "ideapad_laptop" # Can interfere with WiFi on some devices
    ];
  };
}
