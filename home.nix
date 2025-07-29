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
    ./home_modules/theme.nix
    ./home_modules/screenshot.nix
    ./home_modules/mangohud.nix
    ./hypr_config/hyprpanel.nix

    # Core system modules
    ./home_modules/environment.nix
    ./home_modules/services.nix
    ./home_modules/git.nix
    ./home_modules/home-files.nix
    ./home_modules/systemd-services.nix

    # Application and feature modules
    ./home_modules/gaming.nix
    ./home_modules/development.nix
    ./home_modules/android-tools.nix
    ./home_modules/shimboot-project.nix
    ./home_modules/desktop-theme.nix
    ./home_modules/kde.nix
    ./home_modules/qt-gtk-config.nix
    ./home_modules/fuzzel-config.nix
    ./home_modules/kitty.nix
    ./home_modules/fish.nix
    ./home_modules/starship.nix
    ./home_modules/micro.nix
    ./home_modules/fcitx5.nix
    ./home_modules/rose-pine-checker.nix
    ./quickshell_config/quickshell.nix
    ./syncthing_config/home.nix
  ];

  # **INSTALLED PACKAGES**
  # All user packages are imported from home_modules/packages.nix for better organization
  home.packages = import ./home_modules/packages.nix { inherit pkgs inputs system; };
}
