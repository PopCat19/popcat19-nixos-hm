# Home Manager Package Configuration for Surface
# This file contains all user packages for the Surface home configuration
# Imported by home.nix for Surface

{
  pkgs,
  config,
  system,
  lib,
  inputs,
  userConfig,
  ...
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
    # ddcui removed for Surface - no DDC support needed
    pkgs.openrgb-with-all-plugins
    pkgs.brightnessctl  # Brightness control for Surface display
  ] else [
    # ARM64 alternatives or empty list
    pkgs.brightnessctl  # Brightness control for Surface display
  ];
  
  # Package list
  packageList = with pkgs; [
    # Terminal & Core Tools (universal)
    kitty
    fuzzel
    micro
    eza
    starship
    wl-clipboard
    
    # Browsers (check availability per architecture)
    firefox
  ] ++ [
    
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
  ];

in
{
  # **BASIC HOME CONFIGURATION**
  # Sets up basic user home directory parameters.
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;
  home.stateVersion = "24.05"; # Home Manager state version.

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎨 THEME CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # All theme-related configurations are imported from home-theme.nix
  # This includes GTK, Qt, cursors, fonts, and all theming components

  imports = [
    # Theme and UI configurations
    ../../home_modules/theme.nix
    ../../home_modules/screenshot.nix
    ../../home_modules/mangohud.nix
    ../../home_modules/zen-browser.nix
    ./hypr_config/hyprland.nix
    ./hypr_config/hyprpanel-home.nix

    # Core system modules
    ../../home_modules/environment.nix
    ../../home_modules/services.nix
    ../../home_modules/home-files.nix
    ../../home_modules/systemd-services.nix

    # Application and feature modules
    ../../home_modules/gaming.nix
    ../../home_modules/development.nix
    ../../home_modules/android-tools.nix
    ../../home_modules/shimboot-project.nix
    ../../home_modules/desktop-theme.nix
    ../../home_modules/kde.nix
    ../../home_modules/qt-gtk-config.nix
    ../../home_modules/fuzzel-config.nix
    ../../home_modules/kitty.nix
    ../../home_modules/fish.nix
    ../../home_modules/starship.nix
    ../../home_modules/micro.nix
    ../../home_modules/fcitx5.nix
    ../../home_modules/rose-pine-checker.nix
    ../../quickshell_config/quickshell.nix
    ../../syncthing_config/home.nix
  ];

  # **INSTALLED PACKAGES**
  # Surface-specific packages without ddcui
  home.packages = packageList;
}