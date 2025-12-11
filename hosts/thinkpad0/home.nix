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
    ../../main-configuration/home-configuration.nix
    ./hypr_config/hyprpanel.nix
  ];
}
