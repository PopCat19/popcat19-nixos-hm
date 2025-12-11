# Home Manager configuration for surface0
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
