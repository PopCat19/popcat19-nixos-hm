# Hyprland Window Manager
#
# Purpose: Configure Hyprland Wayland compositor with modular settings
# Dependencies: hyprland
# Related: userprefs.conf, wallpaper.nix, modules/*
#
# This module:
# - Enables Hyprland window manager
# - Imports modular configuration files
# - Sources user preferences and monitor configuration
# - Manages shader files and wallpaper directory
{pkgs, ...}: {
  imports = [
    ./modules/colors.nix
    ./modules/environment.nix
    ./modules/autostart.nix
    ./modules/general.nix
    ./modules/animations.nix
    ./modules/keybinds.nix
    ./modules/window-rules.nix
    ./modules/hyprlock.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    settings = {
      source = [
        "~/.config/hypr/monitors.conf"
        "~/.config/hypr/userprefs.conf"
      ];
    };
  };

  home.file = {
    ".config/hypr/userprefs.conf".source = ./userprefs.conf;
    ".config/hypr/shaders" = {
      source = ./shaders;
      recursive = true;
    };
  };
}
