# Global Power Management Configuration
#
# Purpose: Provide unified power management across nixos0 and thinkpad0 (excluding surface0)
# Dependencies: auto-cpufreq, upower
# Related: thinkpad0/system_modules/power-management.nix
#
# This module:
# - Enables CPU frequency scaling with userspace governor
# - Configures upower for battery management
# - Sets up auto-cpufreq with optimized settings for battery and AC power
# - Provides consistent power management behavior across desktop systems

{pkgs, lib, ...}: {
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
        };
        charger = {
          governor = lib.mkDefault "schedutil";
          turbo = lib.mkDefault "auto";
        };
      };
    };
  };

  # Add power management tools
  environment.systemPackages = with pkgs; [
    auto-cpufreq
    upower
    cpufrequtils
  ];
}