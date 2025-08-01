# Home Manager Package Configuration for NixOS0
# This file contains all user packages for the NixOS0 home configuration
# Imported by home.nix for NixOS0

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
    pkgs.openrgb-with-all-plugins
  ] else [
    # ARM64 alternatives or empty list
  ];
  
  # Package list - server/build machine focused
  packageList = with pkgs; [
    # Terminal & Core Tools (universal)
    kitty
    micro
    eza
    starship
    wl-clipboard
    
    # Browsers (minimal for server)
    firefox
    
    # System Monitoring (architecture-specific)
  ] ++ systemMonitoring ++ [
    fastfetch
    
    # Audio & Hardware Control (minimal for server)
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
    
    # Build server specific packages
    cachix
    nix-output-monitor
    nix-tree
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
    # Theme and UI configurations (minimal for server)
    ../../home_modules/theme.nix
    ../../home_modules/screenshot.nix

    # Core system modules
    ../../home_modules/environment.nix
    ../../home_modules/services.nix
    ../../home_modules/git.nix
    ../../home_modules/home-files.nix
    ../../home_modules/systemd-services.nix

    # Application and feature modules
    ../../home_modules/development.nix
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
    
    # Syncthing configuration
    ../../syncthing_config/home.nix
  ];

  # **INSTALLED PACKAGES**
  # NixOS0-specific packages for build server
  home.packages = packageList;
}