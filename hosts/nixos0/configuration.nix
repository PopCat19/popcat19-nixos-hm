# NixOS Configuration for nixos0
{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../configuration/system/extras.nix
    inputs.jovian.nixosModules.default
  ];

  networking.hostName = "popcat19-nixos0";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    opentabletdriver
  ];
}
