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
}: {
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
    # FULL HOME MODULES FOR SELECTIVE IMPORT
    # ==========================================================================

    # Theme and UI
    ../../home_modules/theme.nix
    ../../home_modules/fonts.nix
    ../../home_modules/screenshot.nix
    ../../home_modules/zen-browser.nix

    # Core system
    ../../home_modules/environment.nix
    ../../home_modules/services.nix
    ../../home_modules/home-files.nix
    ../../home_modules/systemd-services.nix

    # Application and feature modules
    ../../home_modules/kde-apps.nix
    ../../home_modules/qt-gtk-config.nix
    ../../home_modules/fuzzel-config.nix
    ../../home_modules/kitty.nix
    ../../home_modules/fish.nix
    ../../home_modules/starship.nix
    ../../home_modules/micro.nix
    ../../home_modules/fcitx5.nix
    ../../home_modules/mangohud.nix
    ../../home_modules/privacy.nix

    # Cross-repo home configs
    ../../quickshell_config/quickshell.nix
    ../../syncthing_config/home.nix

    # ==========================================================================
    # DESKTOP ENVIRONMENT MODULES (uncomment if this host has a GUI)
    # ==========================================================================

    # Window manager (Hyprland) - add host-specific paths as needed
    # ./hypr_config/hyprland.nix
    # ./hypr_config/hyprpanel.nix

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
