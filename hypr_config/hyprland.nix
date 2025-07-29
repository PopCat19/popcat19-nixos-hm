# Main Hyprland Configuration Module
# ==================================
# This module imports all Hyprland configuration sub-modules
# and enables the Hyprland window manager through Home Manager

{ config, pkgs, ... }:

{
  imports = [
    # Import all Hyprland configuration modules
    ./hypr_modules/colors.nix
    ./hypr_modules/environment.nix
    ./hypr_modules/autostart.nix
    ./hypr_modules/general.nix
    ./hypr_modules/animations.nix
    ./hypr_modules/keybinds.nix
    ./hypr_modules/window-rules.nix
  ];

  # Enable Hyprland window manager
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    
    # Additional settings that need to be at the top level
    settings = {
      # Configuration imports (these files are not modularized as requested)
      source = [
        "~/.config/hypr/monitors.conf"
        "~/.config/hypr/userprefs.conf"
      ];
    };
  };

  # Ensure Hyprland config directory exists and copy static files
  home.file = {
    # Copy the existing monitors.conf and userprefs.conf files
    ".config/hypr/monitors.conf".source = ./monitors.conf;
    ".config/hypr/userprefs.conf".source = ./userprefs.conf;
    
    # Copy hyprpaper.conf (not modularized as requested)
    ".config/hypr/hyprpaper.conf".source = ./hyprpaper.conf;
    
    # Copy shaders directory
    ".config/hypr/shaders" = {
      source = ./shaders;
      recursive = true;
    };
  };
}