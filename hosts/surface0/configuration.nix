# NixOS Configuration for surface0
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
    ./system_modules/clear-bdprochot.nix
    ./system_modules/thermal-config.nix
    ./system_modules/boot.nix
    ./system_modules/hardware.nix
    ./home.nix
  ];

  networking.hostName = "popcat19-surface0";
}
