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
    ../../main-configuration/home-configuration.nix
    ../../hypr_config/hyprpanel-home.nix
  ];
}
