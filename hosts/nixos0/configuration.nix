# NixOS Configuration for nixos0
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
    inputs.jovian.nixosModules.default
  ];

  networking.hostName = "popcat19-nixos0";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    opentabletdriver
  ];

  # Hardware configuration
  hardware.opentabletdriver.enable = true;
}
