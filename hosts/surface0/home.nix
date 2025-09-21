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
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  imports = [
    ./hypr_config/hyprland.nix
    ./hypr_config/hyprpanel.nix
  ] ++ (import ../../home_modules/default.nix { });

  # Use the centralized packages list from home_modules/packages.nix.
  # This is the canonical source; per-host package overrides can still be
  # implemented here if necessary.
  home.packages = import ../../home_modules/packages.nix {inherit pkgs inputs system userConfig;};
}
