# Home Manager configuration for nixos0
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
}:

let
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
in
{
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  # Imports (shared home modules + host-local hypr configs)
  imports = [
    ../../home_modules/theme.nix
    ../../home_modules/screenshot.nix
    ../../home_modules/mangohud.nix
    ../../home_modules/zen-browser.nix
    ./hypr_config/hyprland.nix
    ./hypr_config/hyprpanel.nix

    ../../home_modules/environment.nix
    ../../home_modules/services.nix
    ../../home_modules/home-files.nix
    ../../home_modules/systemd-services.nix

    ../../home_modules/gaming.nix
    ../../home_modules/stream.nix
    ../../home_modules/development.nix
    ../../home_modules/android-tools.nix
    ../../home_modules/shimboot-project.nix
    ../../home_modules/dolphin.nix
    ../../home_modules/qt-gtk-config.nix
    ../../home_modules/fuzzel-config.nix
    ../../home_modules/kitty.nix
    ../../home_modules/fish.nix
    ../../home_modules/starship.nix
    ../../home_modules/micro.nix
    ../../home_modules/fcitx5.nix
    ../../quickshell_config/quickshell.nix
    ../../syncthing_config/home.nix
  ];

  # Use the centralized packages list from home_modules/packages.nix.
  # This is the canonical source; per-host package overrides can still be
  # implemented here if necessary.
  home.packages = import ../../home_modules/packages.nix { inherit pkgs inputs system userConfig; };
}