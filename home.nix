# ~/nixos-config/home.nix
{
  pkgs,
  config,
  system,
  lib,
  inputs,
  ...
}:

{
  # **BASIC HOME CONFIGURATION**
  # Sets up basic user home directory parameters.
  home.username = "popcat19";
  home.homeDirectory = "/home/popcat19";
  home.stateVersion = "24.05"; # Home Manager state version.

  # ═══════════════════════════════════════════════════════════════════════════════
  # 🎨 THEME CONFIGURATION
  # ═══════════════════════════════════════════════════════════════════════════════
  # All theme-related configurations are imported from home-theme.nix
  # This includes GTK, Qt, cursors, fonts, and all theming components

  imports = [
    # Theme and UI configurations
    ./home-theme.nix
    ./home-screenshot.nix
    ./home-mangohud.nix
    # ./home-hyprpanel.nix  # Temporarily disabled due to Home Manager module issues

    # Core system modules
    ./modules/environment.nix
    ./modules/services.nix
    ./modules/git.nix
    ./modules/home-files.nix
    ./modules/systemd-services.nix

    # Application and feature modules
    ./modules/gaming.nix
    ./modules/development.nix
    ./modules/android-tools.nix
    ./modules/shimboot-project.nix
    ./modules/desktop-theme.nix
    ./modules/kde.nix
    ./modules/qt-gtk-config.nix
    ./modules/fuzzel-config.nix
    ./modules/kitty.nix
    ./modules/fish.nix
    ./modules/starship.nix
    ./modules/micro.nix
    ./modules/fcitx5.nix
    ./modules/rose-pine-checker.nix
    ./syncthing_config/home.nix
  ];

  # **INSTALLED PACKAGES**
  # All user packages are imported from home-packages.nix for better organization
  home.packages = import ./home-packages.nix { inherit pkgs inputs system; };
}
