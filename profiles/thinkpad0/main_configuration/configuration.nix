# thinkpad0 Profile System Configuration
#
# Purpose: Main NixOS configuration entry point for the thinkpad0 profile
# Dependencies: base_configuration/configuration.nix, hardware-configuration.nix
# Related: profiles/thinkpad0/user-config.nix, profiles/thinkpad0/main_configuration/home/home.nix
#
# This module:
# - Imports hardware configuration and base system modules
# - Imports ThinkPad-specific system modules (hardware, zram)
# - Configures profile-specific system settings
# - Sets hostname for this profile
{ lib, ... }:
{
  imports = [
    # Hardware configuration at profile root
    ../hardware-configuration.nix

    # Base configuration (shared)
    ../../../base_configuration/configuration.nix
    ../../../configuration/system/system-extended.nix

    # Profile-specific system modules
    ./system/system_modules/hardware.nix
    ./system/system_modules/zram.nix
  ];

  networking.hostName = "popcat19-thinkpad0";

  proxy.enable = true;

  # Disable autologin for thinkpad0 (override from display module)
  services.displayManager.autoLogin.enable = lib.mkForce false;
}
