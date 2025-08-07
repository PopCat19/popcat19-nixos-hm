{ pkgs, inputs, lib, ... }:

let
  nixos0UserConfig = import ../../user-config.nix { hostname = "popcat19-nixos0"; };
in

{
  imports = [
    ./hardware-configuration.nix
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
    ../../system_modules/packages.nix
    ./system-packages.nix
    ../../system_modules/fonts.nix
    ../../system_modules/ssh.nix
    ./distributed-builds-server.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  _module.args.userConfig = nixos0UserConfig;
  
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      userConfig = nixos0UserConfig;
      system = "x86_64-linux";
    };
    users.${nixos0UserConfig.user.username} = import ../../home.nix;
    backupFileExtension = "bak2";
  };

  networking.hostName = "popcat19-nixos0";
  
  nix.extraOptions = ''
    experimental-features = fetch-tree flakes nix-command impure-derivations ca-derivations
  '';
  
  system.stateVersion = "25.05";
}