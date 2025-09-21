# Home Manager configuration for thinkpad0 (copied from nixos0)
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
}: {
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Imports (aggregated shared modules + host-local hypr configs)
  imports = [
    ./hypr_config/hyprland.nix
    ./hypr_config/hyprpanel.nix
  ] ++ (import ../../home_modules/default.nix { });

  # Use the centralized packages list from home_modules/packages.nix.
  # This is the canonical source; per-host package overrides can still be
  # implemented here if necessary.
  home.packages = import ../../home_modules/packages.nix {inherit pkgs inputs system userConfig;};
}
