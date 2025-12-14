# Stylix Theme Module
#
# Purpose: Configure theming using Stylix framework with Rose Pine color scheme
# Dependencies: stylix
# Related: theme.nix (deprecated)
#
# This module:
# - Sets up Rose Pine color scheme via Stylix
# - Configures fonts: Rounded Mplus 1c Medium + JetBrainsMono Nerd Font
# - Manages GTK, Qt, and desktop environment theming
# - Provides comprehensive theming across all applications
{
  lib,
  pkgs,
  config,
  inputs,
  userConfig,
  ...
}: {
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  # Enable Stylix
  stylix.enable = true;

  # Use Rose Pine Base16 scheme from base16-schemes package
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

  # Font configuration - let stylix handle packages automatically
  # Manual font packages removed to avoid conflicts

  # Enable theming targets for comprehensive coverage
  stylix.targets.hyprland.enable = true;
  stylix.targets.gtk.enable = true;

  # Session variables for Qt compatibility (let stylix handle GTK automatically)
  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11,*";
    QT_QUICK_CONTROLS_STYLE = "Kvantum";
    QT_QUICK_CONTROLS_MATERIAL_THEME = "Dark";
    # GTK_THEME removed - let stylix handle GTK theming automatically
  };

  # Package overrides to ensure we have the fonts we want
  home.packages = with pkgs; [
    google-fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];
}