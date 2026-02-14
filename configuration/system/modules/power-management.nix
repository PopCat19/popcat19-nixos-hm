# power-management.nix
#
# Purpose: Provide basic power management for desktop systems
#
# This module:
# - Enables CPU frequency scaling with userspace governor
# - Provides consistent power management behavior across desktop systems
{ lib, ... }:
{
  powerManagement = {
    cpuFreqGovernor = lib.mkDefault "userspace";
    enable = true;
  };
}
