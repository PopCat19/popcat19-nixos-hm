# Microsoft Surface Hardware Configuration
# Comprehensive driver suite for Surface devices including ACPI, touch, pen, camera, audio, thermal, and power management

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Import nixos-hardware Surface modules for comprehensive hardware support
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
  ];

  # **SURFACE-SPECIFIC KERNEL CONFIGURATION**
  # Use latest kernel for best Surface hardware support
  boot = {
    # Latest kernel packages for Surface compatibility
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    
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
    ];
    
    # Surface-specific kernel parameters
    kernelParams = [
      # Enable Surface aggregator bus
      "surface_aggregator.dyndbg=+p"
      
      # Improve touch responsiveness
      "i915.enable_psr=0"
      "i915.enable_fbc=0"
      
      # Power management optimizations
      "intel_pstate=active"
      "processor.max_cstate=1"
      
      # Audio improvements
      "snd_hda_intel.dmic_detect=0"
      
      # Thermal management
      "intel_idle.max_cstate=2"
      
      # WiFi driver optimizations for mwifiex
      "mwifiex_pcie.disable_msi=1"
      "mwifiex_pcie.reg_alpha2=US"
      "cfg80211.ieee80211_regdom=US"
      
      # Reduce DPTF power management errors
      "acpi_osi=Linux"
      "acpi_backlight=vendor"
      "intel_pstate=disable"
      "processor.ignore_ppc=1"
      
      # Additional WiFi stability parameters
      "iwlwifi.power_save=0"
      "iwlwifi.uapsd_disable=1"
    ];
    
    # Additional module packages for Surface hardware
    extraModulePackages = with config.boot.kernelPackages; [
      # Surface-specific drivers that may not be in mainline kernel
    ];
    
    # Blacklist problematic modules that might interfere with mwifiex
    blacklistedKernelModules = [
      "ideapad_laptop"  # Can interfere with WiFi on some devices
    ];
  };

  # **SURFACE HARDWARE CONFIGURATION**
  hardware = {
    # Enable firmware updates
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    
    # CPU microcode updates
    cpu.intel.updateMicrocode = true;
    
    # Additional firmware for WiFi and other hardware
    firmware = with pkgs; [
      linux-firmware
      wireless-regdb
    ];
    
    # Graphics configuration for Surface
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        # Intel graphics drivers
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        intel-compute-runtime
      ];
    };
    
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
    
    # Surface pen and touch input
    opentabletdriver.enable = true;
  };

  # **SURFACE-SPECIFIC SERVICES**
  services = {
    # Thermal management daemon
    thermald.enable = true;
    
    # Power management - using auto-cpufreq instead of power-profiles-daemon
    power-profiles-daemon.enable = false;
    
    # Auto CPU frequency scaling
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          turbo = "never";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
    
    # TLP power management (alternative to auto-cpufreq, choose one)
    # tlp = {
    #   enable = true;
    #   settings = {
    #     CPU_SCALING_GOVERNOR_ON_AC = "performance";
    #     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    #     CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    #     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    #   };
    # };
    
    # Firmware update service
    fwupd.enable = true;
    
    # udev rules for Surface hardware
    udev.extraRules = ''
      # Surface touch and pen devices
      SUBSYSTEM=="input", ATTRS{name}=="*Surface*", MODE="0664", GROUP="input"
      
      # Surface camera devices
      SUBSYSTEM=="video4linux", ATTRS{name}=="*Surface*", MODE="0664", GROUP="video"
      
      # Surface aggregator devices
      SUBSYSTEM=="surface_aggregator", MODE="0664", GROUP="users"
      
      # Surface battery and power devices
      SUBSYSTEM=="power_supply", ATTRS{name}=="*Surface*", MODE="0664", GROUP="users"
      
      # WiFi power management and stability rules
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlp*", RUN+="${pkgs.iw}/bin/iw dev $name set power_save off"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x11ab", ATTR{device}=="0x2b38", ATTR{power/control}="on"
      
      # Disable USB autosuspend for WiFi devices to prevent disconnections
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="11ab", ATTRS{idProduct}=="2b38", ATTR{power/autosuspend}="-1"
    '';
    
  };

  # **SURFACE-SPECIFIC PACKAGES**
  environment.systemPackages = with pkgs; [
    # Surface-specific utilities
    libwacom-surface  # Wacom drivers for Surface pen
    
    # Hardware monitoring and control
    lm_sensors
    
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
  ];

  # **SURFACE POWER MANAGEMENT**
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # **SURFACE NETWORKING**
  # WiFi optimizations for mwifiex driver - disable iwd to avoid conflicts with NetworkManager
  networking.wireless.iwd.enable = false;
  
  # WiFi firmware and driver optimizations
  networking.wireless.enable = false; # Let NetworkManager handle WiFi

  # **SURFACE DISPLAY CONFIGURATION**
  # High DPI display support
  services.xserver = {
    dpi = 200;  # Adjust based on your Surface model
  };

  # **SURFACE AUDIO CONFIGURATION**
  # Enhanced audio support for Surface devices
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # **SURFACE SECURITY**
  # TPM and secure boot support
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  # **ADDITIONAL SYSTEMD SERVICES**
  # WiFi stability services
  systemd.services.wifi-powersave-off = {
    description = "Turn off WiFi power saving";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'for i in /sys/class/net/wlp*; do [ -e $i/device/power/control ] && echo on > $i/device/power/control; done'";
    };
  };
}