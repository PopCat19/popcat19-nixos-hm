# Rose Pine Theme with Stylix
#
# Purpose: Configure system theming using Stylix with Rose Pine color scheme
# Dependencies: stylix
# Related: None
#
# This module:
# - Enables Stylix theming framework
# - Applies Rose Pine Base16 color scheme
# - Configures wallpaper and fonts
# - Automatically applies theming to GTK, Qt, terminals, and other applications
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;
    
    # Enable all Stylix targets to use Rose Pine theming
    targets = {
      hyprland.enable = true;
      kitty.enable = true;
      fuzzel.enable = true;
      micro.enable = true;
      starship.enable = true;
      zen-browser.enable = true;
      zen-browser.profileNames = [ "default" ];
    };
    
    # Use Rose Pine Base16 color scheme from themes directory
    base16Scheme = ../themes/rose-pine.yaml;
    
    # Generate a wallpaper based on Rose Pine colors
    image = let
      # Extract base color from Rose Pine scheme
      baseColor = "191724"; # Rose Pine base color
    in
      pkgs.runCommand "rose-pine-wallpaper.png" { } ''
        ${lib.getExe pkgs.imagemagick} -size 1920x1080 xc:"#${baseColor}" $out
      '';
    
    # Configure fonts
    fonts = {
      sansSerif = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
    };
    
    # Set theme polarity to dark (Rose Pine is primarily dark)
    polarity = "dark";
  };

  # Additional system-specific theming that Stylix doesn't cover
  home.sessionVariables = {
    # Force dark theme preference
    GTK_THEME = "rose-pine-gtk-theme";
    
    # Qt styling
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORM = "wayland;xcb";
    
    # Wayland display server preference
    GDK_BACKEND = "wayland,x11,*";
  };

  # Keep essential packages for compatibility
  home.packages = with pkgs; [
    # Rose Pine cursor theme (for applications that don't use Stylix)
    inputs.rose-pine-hyprcursor.packages.${system}.default
    
    # Additional Rose Pine GTK theme (backup/compatibility)
    rose-pine-gtk-theme-full
    
    # Keep Kvantum for Qt applications
    kdePackages.qtstyleplugin-kvantum
    rose-pine-kvantum
    
    # Icon theme
    papirus-icon-theme
    
    # Keep some legacy theming tools for manual adjustments if needed
    nwg-look
  ];
}