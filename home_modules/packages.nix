# Home Manager Package Configuration
# This file contains all user packages for the home configuration
# Imported by home.nix

{
  pkgs,
  inputs,
  system,
  userConfig,
}:

let
  # Architecture detection helpers
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
  
  # Helper function to conditionally include packages
  onlyX86_64 = packages: if isX86_64 then packages else [];
  onlyAarch64 = packages: if isAarch64 then packages else [];
  
  # Architecture-specific package selections
  systemMonitoring = if isX86_64 then [ pkgs.btop-rocm ] else [ pkgs.btop ];
  hardwareControl = if isX86_64 then [
    pkgs.ddcui
    pkgs.openrgb-with-all-plugins
  ] else [
    # ARM64 alternatives or empty list
  ];
  
in
with pkgs;
[
  # Terminal & Core Tools (universal)
  kitty
  fuzzel
  micro
  eza
  starship
  wl-clipboard
  
  # Browsers (check availability per architecture)
  firefox
] ++ (if inputs.zen-browser.packages ? "${system}" then [
  inputs.zen-browser.packages."${system}".default
] else []) ++ [
  
  # Media (universal)
  mpv
  audacious
  audacious-plugins
  
  # Hyprland Essentials (check ARM64 compatibility)
  hyprpanel
  hyprshade
  hyprpolkitagent
  hyprutils
  # quickshell - now provided by modules/quickshell.nix using flake input
  
  # Communication (universal)
  vesktop
  keepassxc
  
  # System Monitoring (architecture-specific)
] ++ systemMonitoring ++ [
  fastfetch
  
  # Audio & Hardware Control (architecture-specific)
  pavucontrol
  playerctl
] ++ hardwareControl ++ [
  glances
  
  # File Sharing (universal)
  localsend
  zrok
  
  # Notifications (universal)
  dunst
  libnotify
  zenity
  
  # Development Editors (universal)
  vscodium
  
  # Nix Development (universal)
  nil
  nixd
] ++
# Architecture-specific packages
onlyX86_64 [
  # x86_64-specific packages that may not be available on ARM64
] ++
onlyAarch64 [
  # ARM64-specific packages
]
