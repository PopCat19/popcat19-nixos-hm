# Home Manager Package Configuration
# This file contains all user packages for the home configuration
# Imported by home.nix

{
  pkgs,
  inputs,
  system,
}:

with pkgs;
[
  # Terminal & Core Tools
  kitty
  fuzzel
  micro
  eza
  starship
  wl-clipboard
  
  # Browsers
  inputs.zen-browser.packages."${system}".default
  firefox
  
  # File Manager
  kdePackages.dolphin
  
  # Media
  mpv
  audacious
  audacious-plugins
  
  # Hyprland Essentials
  hyprpanel
  hyprshade
  hyprpolkitagent
  hyprutils
  quickshell
  
  # Communication
  vesktop
  keepassxc
  
  # System Monitoring
  btop-rocm
  fastfetch
  
  # File Sharing
  localsend
  zrok
  
  # Notifications
  dunst
  libnotify
  zenity
  
  # Development Editors
  zed-editor_git
  vscodium
  
  # Nix Development
  nil
  nixd
]
