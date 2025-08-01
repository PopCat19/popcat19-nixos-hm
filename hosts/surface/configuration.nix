# Surface-specific NixOS configuration
# This file defines the configuration for the Surface device

{ pkgs, inputs, lib, ... }:

let
  # Import surface-specific user configuration
  surfaceUserConfig = import ./user-config.nix;
in

{
  ################################
  # IMPORTS / STATE VERSION
  ################################
  imports = [
    # Hardware configuration for Surface
    ./hardware-configuration.nix
    
    # Comprehensive Surface hardware drivers and configuration
    ./surface-hardware.nix
    
    # Surface-specific systemd service
    ./clear-bdprochot.nix
    
    # Surface thermal management configuration
    ./thermal-config.nix
    
    # Backup system (creates configuration.nix.bak with system_modules inlined)
    ../../backup-config.nix
    
    # External configurations
    ../../syncthing_config/system.nix
    
    # System modules (shared with main configuration)
    ./boot.nix  # Surface-specific boot configuration
    ./hardware.nix  # Surface-specific hardware configuration
    ../../system_modules/networking.nix
    ../../system_modules/localization.nix
    ../../system_modules/services.nix
    ../../system_modules/display.nix
    ../../system_modules/audio.nix
    ../../system_modules/users.nix
    ./virtualisation.nix  # Surface-specific virtualization (no QEMU/KVM)
    ../../system_modules/programs.nix
    ../../system_modules/environment.nix
    ../../system_modules/core-packages.nix
    ./packages.nix  # Surface-specific packages configuration
    ../../system_modules/fonts.nix
    ../../system_modules/distributed-builds.nix  # Distributed builds configuration
    
    # Home Manager module
    inputs.home-manager.nixosModules.home-manager
  ];

# **USER CONFIGURATION**
  # Make the surface user configuration available to system modules
  _module.args.userConfig = surfaceUserConfig;
  # **HOME MANAGER CONFIGURATION**
  # Manages user-specific configurations via Home Manager.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      userConfig = surfaceUserConfig;
      system = "x86_64-linux";
    };
    users.${surfaceUserConfig.user.username} = import ./home-packages.nix;
    backupFileExtension = "bak2"; # Custom backup file extension.
  };

  # Surface-specific settings
  networking.hostName = "popcat19-surface0";

  # WARNING: DO NOT CHANGE AFTER INITIAL INSTALL.
  system.stateVersion = "25.05";
}