# user-config.nix
#
# Purpose: Host-specific overrides for surface0
{ lib, ... }:
import ../../shared {
  inherit lib;
  host = {
    system = "x86_64-linux";
    hostname = "popcat19-surface0";
    profile = "surface";

    user = {
      fullName = "PopCat19";
      email = "atsuo11111@gmail.com";
      shell = "fish";
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "networkmanager"
        "i2c"
        "input"
        "libvirtd"
        "docker"
        "surface-control"
      ];
    };
  };
}
