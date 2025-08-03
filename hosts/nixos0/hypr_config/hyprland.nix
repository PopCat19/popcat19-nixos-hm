# nixos0-specific Hyprland Configuration Module
# ==============================================
# This module imports all shared Hyprland configuration sub-modules
# but uses nixos0-specific configuration files for monitors and userprefs
# to provide desktop-optimized configuration

{ config, pkgs, lib, ... }:

{
  imports = [
    # Import all shared Hyprland configuration modules from the main config
    ../../../hypr_config/hypr_modules/colors.nix
    ../../../hypr_config/hypr_modules/environment.nix
    ../../../hypr_config/hypr_modules/autostart.nix
    ../../../hypr_config/hypr_modules/general.nix
    ../../../hypr_config/hypr_modules/animations.nix
    ../../../hypr_config/hypr_modules/keybinds.nix
    ../../../hypr_config/hypr_modules/window-rules.nix
  ];

  # Enable Hyprland window manager
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    
    # Additional settings that need to be at the top level
    settings = {
      # Configuration imports (nixos0-specific files)
      source = [
        # nixos0-specific monitor configuration for desktop dual-monitor setup
        "~/.config/hypr/monitors.conf"
        "~/.config/hypr/userprefs.conf"
      ];
    };
  };

  # Ensure Hyprland config directory exists and copy nixos0-specific files
  home.file = {
    # Copy the nixos0-specific monitors.conf file
    ".config/hypr/monitors.conf".source = ./monitors.conf;
    ".config/hypr/userprefs.conf".source = ../../../hypr_config/userprefs.conf;
    
    # Copy shared hyprpaper.conf (not device-specific)
    ".config/hypr/hyprpaper.conf".source = ../../../hypr_config/hyprpaper.conf;
    
    # Copy shared shaders directory
    ".config/hypr/shaders" = {
      source = ../../../hypr_config/shaders;
      recursive = true;
    };
  };
}