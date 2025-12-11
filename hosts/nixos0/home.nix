# Home Manager configuration for nixos0
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
}: {
  imports = [
    ../../configuration/home/home.nix
  ];
}
