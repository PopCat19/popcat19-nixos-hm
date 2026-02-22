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
    ../noctalia/noctalia.nix
    ./zed.nix
    ./vscodium.nix
    ./screenshot.nix
    ./zen-browser.nix
    ./generative.nix
    ./ollama.nix
    ./environment.nix
    ./services.nix
    ./home-files.nix
    ./systemd-services.nix
    ./kde-apps.nix
    ./qt-gtk-config.nix
    ./fuzzel-config.nix
    ./kitty.nix
    ./vesktop.nix
    ./starship.nix
    ./micro.nix
    ./nvim.nix
    ./tmux.nix
    ./fcitx5.nix
    ./mangohud.nix
    ./privacy.nix
    ./obs.nix
    ./syncthing.nix
    ./audio-control.nix
    ./vicinae.nix
    ./git.nix
    ./home.nix
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
