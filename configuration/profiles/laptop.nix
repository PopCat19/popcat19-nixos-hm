# laptop.nix
#
# Purpose: Configuration preset for laptop devices with power management needs
#
# This profile:
# - Imports the default profile as base
# - Enables power management optimizations
# - Configures ZRAM swap for memory efficiency
# - Enables proxy support for mobile networking
{ userConfig, ... }:
let
  stateVersion = import ../stateversion.nix;
in
{
  imports = [
    ./default.nix
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

  system.stateVersion = stateVersion.system;

  home-manager = {
    users.${userConfig.username} = {
      home.stateVersion = stateVersion.home;
    };
  };
}
