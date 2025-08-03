{ pkgs, inputs, lib, ... }:

let
  surfaceUserConfig = import ../../user-config.nix { hostname = "popcat19-surface0"; };
in

{
  imports = [
    ./hardware-configuration.nix
    ./surface-hardware.nix
    ./clear-bdprochot.nix
    ./thermal-config.nix
    ../../syncthing_config/system.nix
    ./boot.nix
    ./hardware.nix
    ../../system_modules/networking.nix
    ../../system_modules/localization.nix
    ../../system_modules/services.nix
    ../../system_modules/display.nix
    ../../system_modules/audio.nix
    ../../system_modules/users.nix
    ./virtualisation.nix
    ../../system_modules/programs.nix
    ../../system_modules/environment.nix
    ../../system_modules/core-packages.nix
    ./packages.nix
    ../../system_modules/fonts.nix
    ../../system_modules/ssh.nix
    ../../system_modules/distributed-builds.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  _module.args.userConfig = surfaceUserConfig;
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      userConfig = surfaceUserConfig;
      system = "x86_64-linux";
    };
    users.${surfaceUserConfig.user.username} = import ./home-packages.nix;
    backupFileExtension = "bak2";
  };

  networking.hostName = "popcat19-surface0";

  system.stateVersion = "25.05";
}