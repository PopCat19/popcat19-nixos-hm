# Minimal NixOS Host Template
# This is a template configuration for creating new NixOS machine configurations.
# Copy this file to create a new host configuration and customize the placeholders below.
#
# USAGE:
# 1. Copy this file to hosts/your-hostname.nix
# 2. Replace all placeholder values (marked with TODO)
# 3. Add hardware-configuration.nix import if needed (not included in template)
# 4. Create corresponding home.nix file (see template below)
# 5. Add the new host to flake.nix nixosConfigurations
# 6. Run: nixos-rebuild dry-run --flake .#your-hostname
{
  pkgs,
  inputs,
  lib,
  ...
}: let
  # TODO: Replace with your hostname (should match flake.nix entry)
  hostname = "your-hostname-here";
  userConfig = import ../user-config.nix {inherit hostname;};
in {
  # ============================================================================
  # ESSENTIAL SYSTEM MODULES
  # These are the core modules that most NixOS systems will need
  # ============================================================================

  imports = [
    # TODO: Add hardware-configuration.nix when you generate it for this host
    # ./hardware-configuration.nix

    # Full system modules for selective import
    ../system_modules/core_modules/boot.nix
    ../system_modules/core_modules/hardware.nix
    ../system_modules/core_modules/networking.nix
    ../system_modules/core_modules/users.nix
    ../system_modules/localization.nix
    ../system_modules/services.nix
    ../system_modules/display.nix
    ../system_modules/audio.nix
    ../system_modules/virtualisation.nix
    ../system_modules/programs.nix
    ../system_modules/environment.nix
    ../system_modules/core-packages.nix
    ../system_modules/packages.nix
    ../system_modules/fonts.nix
    ../system_modules/tablet.nix
    ../system_modules/openrgb.nix
    ../system_modules/privacy.nix
    ../system_modules/gnome-keyring.nix
    ../system_modules/vpn.nix
    # ../syncthing_config/system.nix  # Uncomment if needed

    # Host-specific modules (create these as needed)
    # ./system_modules/custom-hardware.nix
    # ./system_modules/custom-services.nix

    # Home Manager
    inputs.home-manager.nixosModules.home-manager
  ];

  # ============================================================================
  # USER CONFIGURATION
  # ============================================================================

  # Pass userConfig to all modules
  _module.args.userConfig = userConfig;

  # ============================================================================
  # HOME MANAGER CONFIGURATION
  # ============================================================================

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      inherit userConfig;
      # TODO: Set the correct system architecture for this host
      system = "x86_64-linux";
    };
    # TODO: Create and import your home.nix file (copy from home-minimal.nix)
    users.${userConfig.user.username} = import ./home.nix;
    backupFileExtension = "bak2";
  };

  # ============================================================================
  # HOST-SPECIFIC CONFIGURATION
  # ============================================================================

  # TODO: Set the hostname (should match the hostname in userConfig)
  networking.hostName = hostname;

  # TODO: Set the NixOS state version (use current stable release)
  system.stateVersion = "25.05";

  # ============================================================================
  # OPTIONAL HOST-SPECIFIC OVERRIDES
  # Uncomment and customize as needed for this specific host
  # ============================================================================

  # Example: Disable certain services on this host

  # Example: Add host-specific packages
  # environment.systemPackages = with pkgs; [
  #   # Add any host-specific packages here
  # ];

  # Example: Host-specific Nix settings
  # nix.extraOptions = ''
  #   experimental-features = fetch-tree flakes nix-command impure-derivations ca-derivations
  # '';

  # Example: Host-specific user configuration
  # users.users.${userConfig.user.username} = {
  #   openssh.authorizedKeys.keys = [
  #     # Add SSH keys specific to this host
  #   ];
  # };
}
