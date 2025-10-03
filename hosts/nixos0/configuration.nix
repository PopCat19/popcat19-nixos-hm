{
  pkgs,
  inputs,
  lib,
  ...
}: let
  nixos0UserConfig = import ../../user-config.nix {hostname = "popcat19-nixos0";};
in {
  imports = [
    ./hardware-configuration.nix
    ../../syncthing_config/system.nix
  ] ++ (import ../../system_modules/default.nix { });

  networking.hostName = "popcat19-nixos0";

  # Host-specific packages
  environment.systemPackages = with pkgs; [
    zluda
  ];

  system.stateVersion = "25.05";
}
