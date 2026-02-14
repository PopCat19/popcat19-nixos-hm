# configuration.nix
#
# Purpose: Configuration preset for laptop devices with power management needs
#
# This module:
# - Imports the default profile as base
# - Enables power management optimizations
# - Configures ZRAM swap for memory efficiency
# - Enables proxy support for mobile networking
{ ... }:
{
  imports = [
    ../default/configuration.nix
  ];

  boot.kernelParams = [
    "i915.enable_guc=2"
  ];

  powerManagement = {
    cpuFreqGovernor = "schedutil";
    enable = true;
    powertop.enable = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };
}
