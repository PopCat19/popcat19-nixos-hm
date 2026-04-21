# hyprland.nix
#
# Purpose: Configure Hyprland Wayland compositor with modular settings
#
# This module:
# - Enables Hyprland window manager
# - Imports modular configuration files
# - Sources user preferences and monitor configuration
{ pkgs, ... }:
{
  imports = [
    ./modules/animations.nix
    ./modules/autostart.nix
    ./modules/colors.nix
    ./modules/environment.nix
    ./modules/general.nix
    ./modules/hyprlock.nix
    ./modules/keybinds.nix
    ./modules/window-rules.nix
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
    ".config/hypr/scripts" = {
      source = ./scripts;
      recursive = true;
      executable = true;
    };
    ".config/hypr/shaders" = {
      source = ./shaders;
      recursive = true;
    };
  };
}
