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

  # Try base16Scheme instead
  stylix.base16Scheme = {
    base00 = "#191724";  # base
    base01 = "#1f1d2e";  # surface
    base02 = "#26233a";  # overlay
    base03 = "#6e6a86";  # muted
    base04 = "#908caa";  # subtle
    base05 = "#e0def4";  # text
    base06 = "#524f67";  # highlightHigh
    base07 = "#524f67";  # highlightHigh
    base08 = "#eb6f92";  # love
    base09 = "#f6c177";  # gold
    base0A = "#ebbcba";  # rose
    base0B = "#31748f";  # pine
    base0C = "#9ccfd8";  # foam
    base0D = "#c4a7e7";  # iris
    base0E = "#c4a7e7";  # iris
    base0F = "#eb6f92";  # love
  };

  # Font configuration - let stylix handle packages automatically
  # Manual font packages removed to avoid conflicts

  # Enable Hyprland theming target
  stylix.targets.hyprland.enable = true;

  # Session variables for Qt and GTK compatibility
  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM = "wayland;xcb";
    GTK_THEME = "Rose-Pine-Main-BL";
    GDK_BACKEND = "wayland,x11,*";
    QT_QUICK_CONTROLS_STYLE = "Kvantum";
    QT_QUICK_CONTROLS_MATERIAL_THEME = "Dark";
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