# Home Manager configuration for surface0
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
  # Host-specific package list is provided by hosts/surface0/home_modules/packages.nix
  hostPackages = import ./home_modules/packages.nix { inherit pkgs inputs system userConfig; };
in
{
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

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
    ../../home_modules/development.nix
    ../../home_modules/android-tools.nix
    ../../home_modules/shimboot-project.nix
    ../../home_modules/desktop-theme.nix
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

  # Use host-local package list so surface-specific overrides are possible
  home.packages = hostPackages;
}