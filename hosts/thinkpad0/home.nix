# Home Manager configuration for thinkpad0
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
    ../../configuration/main/home.nix
  ];
}
