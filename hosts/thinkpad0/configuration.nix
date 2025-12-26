# NixOS Configuration for thinkpad0
{
  pkgs,
  inputs,
  lib,
  userConfig,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration/system/configuration.nix
    ../../configuration/system/system-extended.nix
    ./system_modules/hardware.nix
    ./system_modules/zram.nix
  ];

  networking.hostName = "popcat19-thinkpad0";

  # Disable autologin for thinkpad0 (override from display module)
  services.displayManager.autoLogin.enable = lib.mkForce false;
}
