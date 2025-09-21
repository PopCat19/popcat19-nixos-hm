{
  pkgs,
  inputs,
  lib,
  ...
}: let
  thinkpadUserConfig = import ../../user-config.nix {hostname = "popcat19-thinkpad0";};
in {
  imports = [
    ./hardware-configuration.nix
    ../../syncthing_config/system.nix
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
    ../../system_modules/privacy.nix
    ../../system_modules/gnome-keyring.nix
    ../../system_modules/vpn.nix
    inputs.home-manager.nixosModules.home-manager
  ];

  networking.hostName = "popcat19-thinkpad0";


  system.stateVersion = "25.05";
}
