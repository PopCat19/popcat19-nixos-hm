{ pkgs, lib, ... }:
{
  # Optimized power management for ThinkPad T480 on AC power
  # Focus on performance when plugged in, balanced when on battery

  # Disable conflicting power management services
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = lib.mkForce false;
  # Configure auto-cpufreq for dynamic CPU scaling
  environment.etc."auto-cpufreq.conf".text = ''
    [settings]
    battery:
      governor: schedutil
      turbo: never
    
    charger:
      governor: performance
      turbo: always
  '';
  
  systemd.services.auto-cpufreq = {
    description = "auto-cpufreq daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.auto-cpufreq}/bin/auto-cpufreq --daemon --quiet";
      Restart = "always";
    };
  };

  # Systemd logind configuration for lid switch handling
  services.logind.settings = {
    Login = {
      # Lid switch handling
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
      
      # Ignore lid switch when inhibited (e.g., by media players)
      LidSwitchIgnoreInhibited = true;
      
      # Holdoff timeout for lid events
      HoldoffTimeoutSec = "5s";
    };
  };

  # Add CPU frequency monitoring tools
  environment.systemPackages = with pkgs; [
    auto-cpufreq
    cpufrequtils
    lm_sensors
    powertop
  ];

  # Let auto-cpufreq handle CPU frequency scaling dynamically

  # Kernel parameters for Intel iGPU suspend/resume stability
  boot.kernelParams = [
    "i915.enable_psr=0"
    "i915.fastboot=1"
    "i915.enable_dc=0"
  ];
  
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