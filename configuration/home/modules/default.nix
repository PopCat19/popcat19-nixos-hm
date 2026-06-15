# default.nix
#
# Purpose: Import all home modules for Home Manager configuration
#
# This module:
# - Aggregates all home modules for easy importing
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
  imports = [
    ../hyprland/hyprland.nix
    ./stylix.nix
    ./fonts.nix
    ./bash.nix
    ./starship.nix
    ../noctalia/noctalia.nix
    ./zed.nix
    ./zathura.nix
    ./vscodium.nix
    ./screenshot.nix
    ./zen-browser.nix
    ./generative.nix
    ./environment.nix
    ./services.nix
    ./home-files.nix
    ./systemd-services.nix
    ./dolphin.nix
    ./kde.nix
    ./qt-gtk-config.nix
    ./fuzzel-config.nix
    ./kitty.nix
    ./nixcord.nix
    ./starship.nix
    ./micro.nix
    ./helix.nix
    ./broot.nix
    ./lazygit.nix
    ./tmux.nix
    ./fcitx5.nix
    ./glance.nix
    ./mangohud.nix
    ./playwright.nix
    ./privacy.nix
    ./obs.nix
    ./syncthing.nix
    ./audio-control.nix
    ./git.nix
    ./home.nix
    ./openrgb-leds.nix
    ./wallpaper-sync.nix
  ];

  # Use the centralized packages list from packages.nix
  home.packages = import ./packages.nix {
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
      source = ../wallpaper;
      recursive = true;
    };
  };
}
