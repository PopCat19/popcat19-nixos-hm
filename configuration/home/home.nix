# home.nix
#
# Purpose: Home Manager configuration for user-facing applications
#
# This module:
# - Imports all home modules
# - Configures user applications and services
# - Sets up desktop environment and themes
{
  pkgs,
  inputs,
  userConfig,
  hostPlatform,
  ...
}:
{
  # Basic home configuration
  home.username = userConfig.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05";

  imports = [
    ./hyprland/hyprland.nix
    ./modules/stylix.nix
    ./modules/fonts.nix
    ./noctalia/noctalia.nix
    ./modules/zed.nix
    ./modules/vscodium.nix
    ./modules/screenshot.nix
    ./modules/zen-browser.nix
    ./modules/generative.nix
    ./modules/ollama.nix
    ./modules/environment.nix
    ./modules/services.nix
    ./modules/home-files.nix
    ./modules/systemd-services.nix
    ./modules/kde-apps.nix
    ./modules/qt-gtk-config.nix
    ./modules/fuzzel-config.nix
    ./modules/kitty.nix

    ./modules/vesktop.nix
    ./modules/starship.nix
    ./modules/micro.nix
    ./modules/fcitx5.nix
    ./modules/mangohud.nix
    ./modules/privacy.nix
    ./modules/obs.nix
    ./modules/syncthing.nix
    ./modules/audio-control.nix
    ./modules/vicinae.nix
  ];

  # Use the centralized packages list from modules/packages.nix
  home.packages = import ./modules/packages.nix {
    inherit
      pkgs
      inputs
      hostPlatform
      userConfig
      ;
  };

  # Link existing wallpaper directory for Noctalia
  home.file = {
    ".wallpaper" = {
      source = ./wallpaper;
      recursive = true;
    };
  };
}
