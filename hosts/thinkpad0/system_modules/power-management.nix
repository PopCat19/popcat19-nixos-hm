{
  pkgs,
  lib,
  ...
}: {
  # Optimized power management for ThinkPad T480 on AC power
  # Focus on performance when plugged in, balanced when on battery

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
      CPU_MAX_PERF_ON_BAT = "100";

      # Energy performance preference
      ENERGY_PERF_POLICY_ON_AC = "performance";
      ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # PCIe ASPM
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "balance_power";
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
}
