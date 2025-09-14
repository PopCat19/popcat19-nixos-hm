{pkgs, ...}: {
  # Surface-specific hardware settings
  hardware = {
    # Enable firmware updates and include wifi firmware
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
        mesa
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
        intel-compute-runtime
        intel-ocl
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
        vpl-gpu-rt
        libGL
        libGLU
        freeglut
        glxinfo
        libva
        libva-utils
        vdpauinfo
      ];

      # 32-bit support for Intel graphics
      extraPackages32 = with pkgs.pkgsi686Linux; [
        mesa
        intel-vaapi-driver
        intel-media-driver
        libGL
        libGLU
        vulkan-loader
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

  # USER GROUPS FOR HARDWARE ACCESS
  # User groups moved to system_modules/users.nix (configured via user-config.nix)

  # SURFACE-SPECIFIC PACKAGES
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

  # SURFACE POWER MANAGEMENT
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # SURFACE NETWORKING (hardware-level WiFi tweaks)
  networking.wireless.iwd.enable = false;
  # Let NetworkManager handle WiFi
  networking.wireless.enable = false;

  # INTEL GRAPHICS ENVIRONMENT VARIABLES (session-level)
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    MESA_LOADER_DRIVER_OVERRIDE = "iris";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
    OCL_ICD_VENDORS = "/run/opengl-driver/etc/OpenCL/vendors";
  };
}
