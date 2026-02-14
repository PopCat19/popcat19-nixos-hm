# Laptop Profile Preset
#
# Purpose: Configuration preset for laptop devices with power management needs
# Dependencies: profiles/default/configuration.nix
# Related: hosts/thinkpad0/configuration.nix
#
# This preset:
# - Imports the default profile as base
# - Enables power management optimizations
# - Configures ZRAM swap for memory efficiency
# - Enables proxy support for mobile networking
{ inputs, ... }:
{
  imports = [
    ../default/configuration.nix
  ];

  # ZRAM swap for improved memory management on laptops
  zramSwap = {
    enable = true;
    memoryPercent = 100; # Compress up to 100% of RAM size
  };

  # Laptop power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # Intel graphics kernel parameters for laptops
  boot.kernelParams = [
    "i915.enable_guc=2"
  ];
}
