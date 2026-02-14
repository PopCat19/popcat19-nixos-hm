# surface0 Profile System Configuration
#
# Purpose: Main NixOS configuration entry point for the surface0 profile
# Dependencies: base_configuration/configuration.nix, hardware-configuration.nix
# Related: profiles/surface0/user-config.nix, profiles/surface0/main_configuration/home/home.nix
#
# This module:
# - Imports hardware configuration and base system modules
# - Imports Surface-specific system modules (thermal, boot, hardware)
# - Configures profile-specific system settings
# - Sets hostname for this profile
{ ... }:
{
  imports = [
    # Hardware configuration at profile root
    ../hardware-configuration.nix

    # Base configuration (shared)
    ../../../base_configuration/configuration.nix
    ../../../configuration/system/system-extended.nix

    # Profile-specific system modules
    ./system/system_modules/clear-bdprochot.nix
    ./system/system_modules/thermal-config.nix
    ./system/system_modules/boot.nix
    ./system/system_modules/hardware.nix
  ];

  networking.hostName = "popcat19-surface0";
}
