{ pkgs, lib, ... }:
{
  # Optimized power management for ThinkPad T480 on AC power
  # Focus on performance when plugged in, balanced when on battery

  # Disable conflicting power management services
  services.power-profiles-daemon.enable = false;
  
  # Configure TLP for optimal AC performance
  services.tlp = {
    enable = true;
    settings = {
      # CPU governor settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
      
      # CPU frequency limits (i5-8350U: 1.7GHz base, 3.6GHz boost)
      CPU_MIN_PERF_ON_AC = "0";
      CPU_MAX_PERF_ON_AC = "100";
      CPU_MIN_PERF_ON_BAT = "0";
      CPU_MAX_PERF_ON_BAT = "50";
      
      # Intel P-state control
      CPU_BOOST_ON_AC = "1";
      CPU_BOOST_ON_BAT = "0";
      
      # Energy performance preference
      ENERGY_PERF_POLICY_ON_AC = "performance";
      ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      
      # CPU idle states
      CPU_IDLE_STOP_CSTATE_ON_AC = "1";
      CPU_IDLE_STOP_CSTATE_ON_BAT = "1";
      
      # PCIe ASPM
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersave";
      
      # Radio power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      
      # Disable wake-on-lan
      WOL_DISABLE = "Y";
      
      # Audio power saving
      SOUND_POWER_SAVE_ON_AC = "0";
      SOUND_POWER_SAVE_ON_BAT = "1";
      
      # Runtime Power Management
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      
      # USB autosuspend
      USB_AUTOSUSPEND = "1";
      
      # Restore device state on startup
      RESTORE_DEVICE_STATE_ON_STARTUP = "1";
      
      # Disk power management
      DISK_IDLE_SECS_ON_AC = "0";
      DISK_IDLE_SECS_ON_BAT = "10";
      
      # SATA link power management
      SATA_LINKPWR_ON_AC = "max_performance";
      SATA_LINKPWR_ON_BAT = "min_power";
      
      # RAID controller power management
      RAID_CONTROLLER_POWER = "auto";
    };
  };

  # Add CPU frequency monitoring tools
  environment.systemPackages = with pkgs; [
    cpufrequtils
    lm_sensors
    powertop
  ];

  # Enable CPU frequency scaling
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  
  # Enable thermald for thermal management
  services.thermald.enable = true;
  
  # Load necessary kernel modules for ThinkPad
  boot.kernelModules = [
    "thinkpad_acpi"
    "thinkpad_hwmon"
    "coretemp"
    "intel_rapl_common"
  ];

  # ThinkPad specific settings
  boot.extraModprobeConfig = ''
    # Enable ThinkPad ACPI features
    options thinkpad_acpi fan_control=1
    options thinkpad_acpi experimental=1
  '';

  # Udev rules for ThinkPad devices
  services.udev.extraRules = ''
    # ThinkPad battery and power devices
    SUBSYSTEM=="power_supply", ATTRS{name}=="*BAT*", MODE="0664", GROUP="users"
    
    # ThinkPad fan control
    SUBSYSTEM=="hwmon", ATTRS{name}=="thinkpad", MODE="0664", GROUP="users"
  '';

}