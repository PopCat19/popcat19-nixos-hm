# Waydroid Android Emulation Module
#
# Purpose: Enable Waydroid for running Android applications on Linux
# Dependencies: waydroid
# Related: None
#
# This module:
# - Enables Waydroid for Android app emulation
# - Provides basic Android app compatibility
# - Uses minimal system resources
{
  pkgs,
  userConfig,
  ...
}: let
  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";
in {
  # Waydroid (Android emulation)
  virtualisation.waydroid.enable = true;
}
