# Microsoft Surface Hardware Configuration
# Comprehensive driver suite for Surface devices including ACPI, touch, pen, camera, audio, thermal, and power management

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # Import nixos-hardware Surface modules for comprehensive hardware support
    inputs.nixos-hardware.nixosModules.microsoft-surface-common
  ];

  # **SURFACE-SPECIFIC KERNEL CONFIGURATION**
  # Use linux-surface patched kernel from nixos-hardware for best Surface hardware support
  # The nixos-hardware common module provides the patched kernel automatically
  boot = {
    # Let nixos-hardware common module provide the patched linux-surface kernel
    # kernelPackages = lib.mkForce pkgs.linuxPackages_latest;  # Disabled to use linux-surface patches
    
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
    ];
    
    # Surface-specific kernel parameters
    kernelParams = [
      # Modern Standby support - required for proper S0ix sleep states
      "mem_sleep_default=deep"
      
      # Enable Surface aggregator bus
      "surface_aggregator.dyndbg=+p"
      
      # Improve touch responsiveness and graphics performance
      "i915.enable_psr=0"
      "i915.enable_fbc=1"
      "i915.fastboot=1"
      "i915.enable_guc=2"
      
      # Power management optimizations - use intel_pstate for better performance
      "intel_pstate=active"
      "intel_pstate=hwp_only"
      
      # Allow deeper C-states for better power efficiency when idle
      "processor.max_cstate=8"
      "intel_idle.max_cstate=8"
      
      # Audio improvements
      "snd_hda_intel.dmic_detect=0"
      
      # WiFi driver optimizations for mwifiex
      "mwifiex_pcie.disable_msi=1"
      "mwifiex_pcie.reg_alpha2=US"
      "cfg80211.ieee80211_regdom=US"
      
      # ACPI and backlight optimizations - try different backlight methods
      "acpi_osi=Linux"
      "acpi_backlight=video"
      "video.brightness_switch_enabled=0"
      
      # Additional WiFi stability parameters
      "iwlwifi.power_save=0"
      "iwlwifi.uapsd_disable=1"
      
      # Performance optimizations
      "mitigations=off"
      "nowatchdog"
      "quiet"
      "loglevel=3"
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
    
    # IIO sensor support for accelerometer/gyroscope
    sensor.iio.enable = true;
    
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
        # Intel Mesa drivers for optimal graphics performance
        mesa
        
        # Intel graphics drivers
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        intel-compute-runtime
        
        # Additional Intel graphics packages
        vpl-gpu-rt # QSV on 11th gen or newer
        # intel-media-sdk # Removed due to security vulnerabilities
      ];
      
      # 32-bit support for Intel graphics
      extraPackages32 = with pkgs.pkgsi686Linux; [
        mesa
        intel-vaapi-driver
        intel-media-driver
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

  # **USER GROUPS FOR HARDWARE ACCESS**
  # Add user to video group for brightness control and surface-control for performance modes
  users.users = {
    popcat19 = {
      extraGroups = [ "video" "surface-control" ];
    };
  };

  # **SURFACE-SPECIFIC SERVICES**
  services = {
    # Thermal management is now handled by thermal-config.nix
    # thermald.enable = true;  # Moved to thermal-config.nix with custom configuration
    
    # Intel Precise Touch & Stylus Daemon for Surface touch and pen support
    # Enable IPTS for most Surface devices (except Surface Go and Surface Laptop 3 AMD)
    iptsd.enable = lib.mkDefault true;
    
    # Power management - using auto-cpufreq instead of power-profiles-daemon
    power-profiles-daemon.enable = false;
    
    # Auto CPU frequency scaling - optimized for Surface performance
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "schedutil";
          turbo = "auto";
          scaling_min_freq = 400000;
          scaling_max_freq = 4200000;
        };
        charger = {
          governor = "performance";
          turbo = "auto";
          scaling_min_freq = 800000;
          scaling_max_freq = 4200000;
        };
      };
    };
    
    # TLP power management - disabled by default for Surface devices
    # as recommended by nixos-hardware to avoid conflicts with auto-cpufreq
    tlp.enable = false;
    
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
      
      # Brightness control permissions
      SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
      SUBSYSTEM=="backlight", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"
      SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/leds/%k/brightness"
      SUBSYSTEM=="leds", ACTION=="add", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
      
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
    surface-control   # Surface hardware control utilities for performance modes
    
    # Hardware monitoring and control
    lm_sensors
    brightnessctl  # Brightness control utility
    
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
    cpuFreqGovernor = "schedutil";  # Better than ondemand for modern CPUs
    scsiLinkPolicy = "med_power_with_dipm";
  };

  # **SURFACE NETWORKING**
  # WiFi optimizations for mwifiex driver - disable iwd to avoid conflicts with NetworkManager
  networking.wireless.iwd.enable = false;
  
  # WiFi firmware and driver optimizations
  networking.wireless.enable = false; # Let NetworkManager handle WiFi

  # **INTEL GRAPHICS ENVIRONMENT VARIABLES**
  # Set environment variables for Intel graphics drivers
  environment.sessionVariables = {
    # Use Intel HD Media Driver for VAAPI
    LIBVA_DRIVER_NAME = "iHD";
    
    # Enable Intel GPU debugging if needed
    # INTEL_DEBUG = "all";
    
    # Set DRI_PRIME for hybrid graphics if needed
    # DRI_PRIME = "1";
  };

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