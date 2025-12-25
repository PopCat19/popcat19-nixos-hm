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
    inputs.stylix.homeModules.stylix
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
  stylix.targets.kitty.enable = true;
  stylix.targets.gtk.enable = true;
  stylix.targets.qt.enable = true;
  stylix.targets.zen-browser.enable = true;
  stylix.targets.zen-browser.profileNames = ["default"];
  stylix.targets.vesktop.enable = true;
  stylix.targets.fcitx5.enable = true;
  stylix.targets.fish.enable = true;
  stylix.targets.starship.enable = true;
  stylix.targets.tmux.enable = true;
  stylix.targets.font-packages.enable = true;
  stylix.targets.fuzzel.enable = true;
  stylix.targets.btop.enable = true;
  stylix.targets.mangohud.enable = true;
  stylix.targets.micro.enable = true;
  stylix.targets.mpv.enable = true;
  stylix.targets.neovim.enable = true;
  stylix.targets.vim.enable = true;
  stylix.targets.nixos-icons.enable = true;
  stylix.targets.noctalia-shell.enable = true;
  stylix.targets.opencode.enable = true;
  stylix.targets.vscode.enable = true;
  stylix.targets.zed.enable = true;


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
  ];

  # Create kdeglobals configuration file for KDE icon theme
  home.file.".config/kdeglobals".text = ''
    [Icons]
    Theme=Papirus-Dark
  '';
}