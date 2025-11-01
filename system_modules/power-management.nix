# Global Power Management Configuration (Non-TLP)
#
# Purpose: Provide unified power management for desktop systems excluding TLP-based setups
# Dependencies: auto-cpufreq, upower
# Related: None - standalone global module
#
# This module:
# - Enables CPU frequency scaling with userspace governor
# - Configures upower for battery management
# - Sets up auto-cpufreq with optimized settings for battery and AC power
# - Provides consistent power management behavior across desktop systems
# - Designed for systems that should NOT use TLP
{
  pkgs,
  lib,
  ...
}: {
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "userspace";
  };

  services = {
    upower.enable = lib.mkDefault true;

    auto-cpufreq = {
      enable = lib.mkDefault true;
      settings = {
        battery = {
          governor = lib.mkDefault "schedutil";
          turbo = lib.mkDefault "auto";
          energy_performance_preference = lib.mkDefault "balance_power";
        };
        charger = {
          governor = lib.mkDefault "schedutil";
          turbo = lib.mkDefault "auto";
          energy_performance_preference = lib.mkDefault "performance";
        };
      };
    };
  };

  # Add power management tools
  environment.systemPackages = with pkgs; [
    auto-cpufreq
    cpufrequtils
  ];
}
