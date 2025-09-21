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
  ] ++ (import ../../system_modules/default.nix { });

  networking.hostName = "popcat19-thinkpad0";


  system.stateVersion = "25.05";
}
