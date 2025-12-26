# Waydroid Android Emulation Module
#
# Purpose: Configure Waydroid for running Android applications on Linux (disabled by default)
# Dependencies: waydroid
# Related: None
#
# This module:
# - Disables Waydroid for Android app emulation by default
# - Can be enabled per-host if needed
# - Maintains networking support for waydroid0 interface
{
  pkgs,
  userConfig,
  ...
}: let
  # Architecture detection
  system = userConfig.host.system;
  isX86_64 = system == "x86_64-linux";
in {
  # Waydroid (Android emulation) - disabled by default
  # To enable Waydroid on specific hosts, add:
  # virtualisation.waydroid.enable = true;
  virtualisation.waydroid.enable = false;
}
