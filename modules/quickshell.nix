{ inputs, pkgs, ... }:

{
  # **QUICKSHELL CONFIGURATION**
  # Quickshell is a QtQuick-based desktop shell toolkit
  # Available from the quickshell flake input
  
  home.packages = [
    # Quickshell package from flake input
    inputs.quickshell.packages.${pkgs.system}.default
    
    # Additional Qt packages that may be useful for quickshell
    pkgs.qt6.qtsvg          # Support for SVG image loading
    pkgs.qt6.qtimageformats # Support for WEBP and other image formats
    pkgs.qt6.qtmultimedia   # Support for playing videos, audio, etc
    pkgs.qt6.qt5compat      # Extra visual effects, notably gaussian blur
  ];

  # **QUICKSHELL CONFIGURATION FILES**
  # Link the quickshell_config directory to ~/.config/quickshell
  home.file.".config/quickshell" = {
    source = ../quickshell_config;
    recursive = true;
  };
}