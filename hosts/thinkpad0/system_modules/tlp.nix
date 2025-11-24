# TLP Battery Calibration Module
#
# Purpose: Configure TLP for ThinkPad battery calibration and power management
# Dependencies: tlp, powertop
# Related: system_modules/mobile-pm.nix
#
# This module:
# - Enables TLP with ThinkPad-optimized settings
# - Configures battery calibration thresholds
# - Provides advanced power management for battery health
# - Temporarily replaces auto-cpufreq for calibration period
{
  pkgs,
  lib,
  ...
}: {
  # Disable auto-cpufreq while using TLP for calibration
  services.auto-cpufreq.enable = lib.mkForce false;

  # Enable TLP with ThinkPad-specific configuration
  services.tlp = {
    enable = true;
    
    settings = {
      # General power management
      TLP_ENABLE = 1;
      TLP_PERSISTENT_DEFAULT = 1;
      
      # Battery calibration thresholds (ThinkPad specific)
      # Charge to 80% when plugged in, start charging at 40%
      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
      
      # If second battery exists (rare on ThinkPads)
      START_CHARGE_THRESH_BAT1 = 40;
      STOP_CHARGE_THRESH_BAT1 = 80;
      
      # Power management settings
      DISK_IDLE_SECS_ON_AC = 20;
      DISK_IDLE_SECS_ON_BAT = 10;
      
      MAX_LOST_WORK_SECS_ON_AC = 15;
      MAX_LOST_WORK_SECS_ON_BAT = 60;
      
      # CPU settings
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
      
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;
      
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      
      # Energy performance hints
      ENERGY_PERF_POLICY_ON_AC = "performance";
      ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      
      # ThinkPad specific settings
      THINKPAD_BAT_ENABLED = 1;
      
      # Radio device management
      RESTORE_DEVICE_STATE_ON_STARTUP = 1;
      
      # USB autosuspend
      USB_AUTOSUSPEND = 1;
      USB_BLACKLIST_BTUSB = 0;
      USB_BLACKLIST_PHONE = 0;
      USB_BLACKLIST_PRINTER = 1;
      USB_BLACKLIST_WWAN = 0;
      
      # PCIe active state power management
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersave";
      
      # Radeon power profile
      RADEON_POWER_PROFILE_ON_AC = "high";
      RADEON_POWER_PROFILE_ON_BAT = "low";
      
      # WiFi power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      
      # Wake-on-LAN
      WOL_DISABLE = "Y";
      
      # Audio power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      
      # Runtime Power Management
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      
      # Backlight control
      BRIGHTNESS_START = 50;
      BRIGHTNESS_STEP = 1;
      BRIGHTNESS_MIN = 1;
      BRIGHTNESS_MAX = 100;
    };
  };

  # Add TLP and battery monitoring tools
  environment.systemPackages = with pkgs; [
    tlp
    powertop
    acpi
  ];

  # Enable TLP service
  systemd.services.tlp = {
    description = "TLP power management";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.tlp}/bin/tlp start";
      ExecStop = "${pkgs.tlp}/bin/tlp stop";
      Restart = "on-failure";
    };
  };
}