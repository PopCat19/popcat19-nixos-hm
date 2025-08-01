# NixOS0 configuration for distributed builds
# This file defines the configuration for the nixos0 build machine

{ pkgs, inputs, lib, ... }:

let
  # Import nixos0-specific user configuration
  nixos0UserConfig = import ./user-config.nix;
in

{
  ################################
  # IMPORTS / STATE VERSION
  ################################
  imports = [
    # Hardware configuration for nixos0
    ./hardware-configuration.nix
    
    # Backup system (creates configuration.nix.bak with system_modules inlined)
    ../../backup-config.nix
    
    # External configurations
    ../../syncthing_config/system.nix
    
    # System modules (shared with main configuration)
    ./boot.nix  # nixos0-specific boot configuration
    ./hardware.nix  # nixos0-specific hardware configuration
    ../../system_modules/networking.nix
    ../../system_modules/localization.nix
    ../../system_modules/services.nix
    ../../system_modules/display.nix
    ../../system_modules/audio.nix
    ../../system_modules/users.nix
    ./virtualisation.nix  # nixos0-specific virtualization
    ../../system_modules/programs.nix
    ../../system_modules/environment.nix
    ../../system_modules/core-packages.nix
    ./packages.nix  # nixos0-specific packages configuration
    ../../system_modules/fonts.nix
    ./distributed-builds-server.nix  # Server-side distributed builds config
    
    # Home Manager module
    inputs.home-manager.nixosModules.home-manager
  ];

  # **USER CONFIGURATION**
  # Make the nixos0 user configuration available to system modules
  _module.args.userConfig = nixos0UserConfig;
  
  # **HOME MANAGER CONFIGURATION**
  # Manages user-specific configurations via Home Manager.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      userConfig = nixos0UserConfig;
      system = "x86_64-linux";
    };
    users.${nixos0UserConfig.user.username} = import ./home-packages.nix;
    backupFileExtension = "bak2"; # Custom backup file extension.
  };

  # nixos0-specific settings
  networking.hostName = "popcat19-nixos0";

  # WARNING: DO NOT CHANGE AFTER INITIAL INSTALL.
  system.stateVersion = "25.05";
}