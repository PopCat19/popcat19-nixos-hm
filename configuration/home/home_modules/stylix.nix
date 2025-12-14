# Stylix Theme Module
#
# Purpose: Configure theming using Stylix framework with Rose Pine color scheme
# Dependencies: stylix
# Related: theme.nix (deprecated)
#
# This module:
# - Sets up Rose Pine color scheme via Stylix
# - Configures fonts: Rounded Mplus 1c Medium + FiraCode Nerd Font
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

  # Font configuration
  stylix.fonts.sansSerif = {
    package = pkgs.google-fonts;
    name = "Rounded Mplus 1c Medium";
  };
  
  stylix.fonts.monospace = {
    package = pkgs.nerd-fonts.fira-code;
    name = "FiraCode Nerd Font";
  };
  
  # Font sizes for specific contexts
  stylix.fonts.sizes = {
    applications = 10;  # For applications like fuzzel
    terminal = 10;      # For terminal applications like kitty
    popups = 10;        # For popup dialogs
    desktop = 10;       # For desktop applications
  };

  # Enable theming targets for comprehensive coverage
  stylix.targets.hyprland.enable = true;
  stylix.targets.gtk.enable = true;

  # Cursor theme configuration
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.rose-pine-hyprcursor;
    name = "rose-pine-hyprcursor";
    size = 24;
  };

  # Icon theme configuration using stylix native option
  stylix.icons = {
    enable = true;
    package = pkgs.papirus-icon-theme;
    dark = "Papirus-Dark";
  };

  # Enable Qt theming target for comprehensive Qt/KDE integration
  stylix.targets.qt.enable = true;
  
  # Disable KDE target for Hyprland compatibility (creates conflicting configs)
  stylix.targets.kde.enable = false;

  # Session variables for Qt compatibility
  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";  # Force qt6ct over default qt5ct
    GDK_BACKEND = "wayland,x11,*";
    QT_QUICK_CONTROLS_STYLE = "org.kde.desktop";  # Better fallback for QML apps
  };

  # Package overrides to ensure we have the fonts, icons, and Qt tools we want
  home.packages = with pkgs; [
    google-fonts
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    papirus-icon-theme
    # Qt styling tools for platform theme support
    kdePackages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
  ];
}