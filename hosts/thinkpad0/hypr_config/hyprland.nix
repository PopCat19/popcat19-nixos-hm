# thinkpad0-specific Hyprland Configuration Module (copied from nixos0)
{
  config,
  pkgs,
  lib,
  ...
}: let
  wallpaper = import ../../../hypr_config/wallpaper.nix {inherit lib pkgs;};
in {
  imports = [
    # Import all shared Hyprland configuration modules from the main config
    ../../../hypr_config/modules/colors.nix
    ../../../hypr_config/modules/environment.nix
    ../../../hypr_config/modules/autostart.nix
    ../../../hypr_config/modules/general.nix
    ../../../hypr_config/modules/animations.nix
    ../../../hypr_config/modules/keybinds.nix
    ../../../hypr_config/modules/window-rules.nix
  ];

  # Enable Hyprland window manager
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    # Additional settings that need to be at the top level
    settings = {
      # Configuration imports (thinkpad0-specific files)
      source = [
        # host-specific monitor configuration
        "~/.config/hypr/monitors.conf"
        "~/.config/hypr/userprefs.conf"
      ];
    };
  };

  # Ensure Hyprland config directory exists and copy host-specific files
  home.file = {
    # Copy the host-specific monitors.conf file
    ".config/hypr/monitors.conf".source = ./monitors.conf;
    ".config/hypr/userprefs.conf".source = ../../../hypr_config/userprefs.conf;

    # Copy shared shaders directory
    ".config/hypr/shaders" = {
      source = ../../../hypr_config/shaders;
      recursive = true;
    };
  };
}
