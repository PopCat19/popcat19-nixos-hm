# Mobile Power Management Configuration
#
# Purpose: Provide optimized power management for mobile systems with auto-cpufreq
# Dependencies: auto-cpufreq, upower
# Related: system_modules/power-management.nix
#
# This module:
# - Enables auto-cpufreq with optimized settings for battery and AC power
# - Configures upower for battery management on mobile devices
# - Provides power management tools for mobile systems
# - Designed specifically for laptop and mobile device power optimization
{
  pkgs,
  lib,
  ...
}: {
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