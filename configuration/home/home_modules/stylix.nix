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

  # Use Rose Pine Base16 scheme from GitHub
  stylix.base16Scheme = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/edunfelt/base16-rose-pine-scheme/main/rose-pine.yaml";
    sha256 = "4d16e181b6355fd34a444028b46425f08c3cc220deb0b5a00c62341c1d388de3";
  };

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