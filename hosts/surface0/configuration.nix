{ pkgs, inputs, lib, ... }:

let
  surfaceUserConfig = import ../../user-config.nix { hostname = "popcat19-surface0"; };
in

{
  imports = [
    ./hardware-configuration.nix
    ./system_modules/surface-hardware.nix
    ./system_modules/clear-bdprochot.nix
    ./system_modules/thermal-config.nix
    ../../syncthing_config/system.nix
    ./system_modules/boot.nix
    ./system_modules/hardware.nix
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
    users.${surfaceUserConfig.user.username} = import ./home.nix;
    backupFileExtension = "bak2";
  };

  networking.hostName = "popcat19-surface0";

  system.stateVersion = "25.05";
  
  # Add nixos0's SSH public key to surface0's authorized_keys
  users.users.${surfaceUserConfig.user.username} = {
    openssh.authorizedKeys.keys = [
      # Default SSH key from system_modules/ssh.nix
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvtrt7vEbXSyP8xuOfsfNGgC99Y98s1fmBIp3eZP4zx popcat19@nixos"
      # nixos0's SSH public key for SSH access from nixos0 to surface0
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFvtrt7vEbXSyP8xuOfsfNGgC99Y98s1fmBIp3eZP4zx popcat19@nixos0"
    ];
  };
}
