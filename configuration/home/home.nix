# Home Configuration Module
#
# Purpose: Home Manager configuration for user-facing applications
# Dependencies: All home_modules, user-config.nix
# Related: configuration/system/configuration.nix, configuration/system/system-extended.nix
#
# This module:
# - Imports all home modules
# - Configures user applications and services
# - Sets up desktop environment and themes
{
  config,
  pkgs,
  lib,
  inputs,
  userConfig,
  hostPlatform,
  ...
}: {
  # Basic home configuration
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  imports = [
    ./hypr_config/hyprland.nix
    ./home_modules/stylix.nix
    ./home_modules/fonts.nix
    ./home_modules/noctalia.nix
    ./home_modules/screenshot.nix
    ./home_modules/zen-browser.nix
    ./home_modules/generative.nix
    ./home_modules/ollama.nix
    ./home_modules/environment.nix
    ./home_modules/services.nix
    ./home_modules/home-files.nix
    ./home_modules/systemd-services.nix
    ./home_modules/kde-apps.nix
    ./home_modules/qt-gtk-config.nix
    ./home_modules/fuzzel-config.nix
    ./home_modules/kitty.nix
    ./home_modules/fish.nix
    ./home_modules/starship.nix
    ./home_modules/micro.nix
    ./home_modules/fcitx5.nix
    ./home_modules/mangohud.nix
    ./home_modules/privacy.nix
    ./home_modules/obs.nix
    ./home_modules/syncthing.nix
    ./home_modules/audio-control.nix
  ];

  # Use the centralized packages list from home_modules/packages.nix
  home.packages = import ./home_modules/packages.nix {inherit pkgs inputs hostPlatform userConfig;};

  # Link existing wallpaper directory for Noctalia
  home.file = {
    ".wallpaper" = {
      source = ./wallpaper;
      recursive = true;
    };
  };
}