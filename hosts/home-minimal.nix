# Minimal Home Manager Template
# This is a template for Home Manager configuration to be used with the minimal.nix system template.
#
# USAGE:
# 1. Copy this file to your-host-directory/home.nix
# 2. Customize the imports based on your needs
# 3. Update the hostname reference in the system configuration
#
# This template includes the most commonly used home modules.
# Uncomment or add modules as needed for your specific host.

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
  # Architecture helpers
  isX86_64 = system == "x86_64-linux";
  isAarch64 = system == "aarch64-linux";
in

{
  # ============================================================================
  # BASIC HOME CONFIGURATION
  # ============================================================================

  # Basic user information (automatically set from userConfig)
  home.username = userConfig.user.username;
  home.homeDirectory = userConfig.directories.home;

  # TODO: Set the appropriate Home Manager state version
  home.stateVersion = "24.05";

  # ============================================================================
  # HOME MODULE IMPORTS
  # ============================================================================

  imports = [
    # ==========================================================================
    # ESSENTIAL MODULES (recommended for all hosts)
    # ==========================================================================

    # Environment and basic configuration
    ../../home_modules/environment.nix
    ../../home_modules/home-files.nix

    # Shell and terminal
    ../../home_modules/fish.nix
    ../../home_modules/starship.nix
    ../../home_modules/kitty.nix

    # Editor
    ../../home_modules/micro.nix

    # ==========================================================================
    # DESKTOP ENVIRONMENT MODULES (uncomment if this host has a GUI)
    # ==========================================================================

    # Desktop theming and appearance
    # ../../home_modules/theme.nix
    # ../../home_modules/desktop-theme.nix
    # ../../home_modules/qt-gtk-config.nix

    # Desktop applications
    # ../../home_modules/dolphin.nix
    # ../../home_modules/fuzzel-config.nix
    # ../../home_modules/zen-browser.nix

    # Window manager (Hyprland)
    # ./hypr_config/hyprland.nix
    # ./hypr_config/hyprpanel.nix

    # ==========================================================================
    # OPTIONAL MODULES (uncomment as needed)
    # ==========================================================================

    # Development tools
    # ../../home_modules/development.nix

    # Gaming (x86_64 only)
    # ../../home_modules/gaming.nix
    # ../../home_modules/mangohud.nix

    # Streaming and creative tools
    # ../../home_modules/stream.nix

    # Android development
    # ../../home_modules/android-tools.nix

    # Input method
    # ../../home_modules/fcitx5.nix

    # Services and daemons
    # ../../home_modules/services.nix
    # ../../home_modules/systemd-services.nix

    # Screenshot tools
    # ../../home_modules/screenshot.nix

    # Synchronization
    # ../../syncthing_config/home.nix

    # Alternative shells/widgets
    # ../../quickshell_config/quickshell.nix

    # ==========================================================================
    # HOST-SPECIFIC MODULES (create these as needed)
    # ==========================================================================

    # Add any host-specific home modules here
    # ./home_modules/custom-config.nix
  ];

  # ============================================================================
  # PACKAGES
  # ============================================================================

  # Use the centralized packages list (recommended)
  # This includes all the common packages defined in home_modules/packages.nix
  home.packages = import ../../home_modules/packages.nix {
    inherit pkgs inputs system userConfig;
  };

  # ============================================================================
  # OPTIONAL HOST-SPECIFIC OVERRIDES
  # Uncomment and customize as needed for this specific host
  # ============================================================================

  # Example: Add host-specific packages
  # home.packages = (import ../../home_modules/packages.nix {
  #   inherit pkgs inputs system userConfig;
  # }) ++ (with pkgs; [
  #   # Add any additional packages specific to this host
  #   some-package
  # ]);

  # Example: Host-specific program configurations
  # programs.git = {
  #   enable = true;
  #   userName = userConfig.user.fullName;
  #   userEmail = userConfig.user.email;
  # };

  # Example: Host-specific environment variables
  # home.sessionVariables = {
  #   # Add any host-specific environment variables
  # };

  # Example: Host-specific file configurations
  # home.file = {
  #   # Add any host-specific dotfiles or configurations
  # };
}