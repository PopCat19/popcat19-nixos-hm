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
    ../../configuration/base/configuration.nix
    ../../configuration/main/configuration.nix
    inputs.jovian.nixosModules.default
  ];

  networking.hostName = "popcat19-nixos0";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    zluda
    alsa-utils
    pavucontrol
  ];
}
