# Global Power Management Configuration (Desktop Systems)
#
# Purpose: Provide basic power management for desktop systems with CPU frequency scaling
# Dependencies: None
# Related: system_modules/mobile-pm.nix
#
# This module:
# - Enables CPU frequency scaling with userspace governor
# - Provides consistent power management behavior across desktop systems
# - Designed for desktop systems without auto-cpufreq
# - Note: Mobile systems should use system_modules/mobile-pm.nix for upower and auto-cpufreq
{
  pkgs,
  lib,
  ...
}: {
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "userspace";
  };

  # Note: upower is configured in system_modules/mobile-pm.nix for mobile systems
}
