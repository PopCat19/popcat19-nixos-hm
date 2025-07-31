# Surface-specific NixOS configuration
# This file defines the configuration for the Surface device

{ pkgs, inputs, ... }:

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
    
    # Surface-specific systemd service
    ./clear-bdprochot.nix
    
    # Backup system (creates configuration.nix.bak with system_modules inlined)
    ../../backup-config.nix
    
    # External configurations
    ../../syncthing_config/system.nix
    
    # System modules (shared with main configuration)
    ../../system_modules/boot.nix
    ../../system_modules/hardware.nix
    ../../system_modules/networking.nix
    ../../system_modules/localization.nix
    ../../system_modules/services.nix
    ../../system_modules/display.nix
    ../../system_modules/audio.nix
    ../../system_modules/users.nix
    ../../system_modules/virtualisation.nix
    ../../system_modules/programs.nix
    ../../system_modules/environment.nix
    ../../system_modules/core-packages.nix
    ../../system_modules/packages.nix
    ../../system_modules/fonts.nix
    
    # Home Manager module
    inputs.home-manager.nixosModules.home-manager
  ];

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
    users.${surfaceUserConfig.user.username} = import ../../home.nix;
    backupFileExtension = "bak2"; # Custom backup file extension.
  };

  # Use latest kernel for Surface compatibility
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Surface-specific settings
  networking.hostName = "surface-nixos";

  # WARNING: DO NOT CHANGE AFTER INITIAL INSTALL.
  system.stateVersion = "25.05";
}