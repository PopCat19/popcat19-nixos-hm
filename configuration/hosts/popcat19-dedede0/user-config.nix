# user-config.nix
#
# Purpose: Host-specific overrides for dedede0 (shimboot)
{ lib, ... }:
import ../../shared {
  inherit lib;
  host = {
    system = "x86_64-linux";
    hostname = "popcat19-dedede0";
    username = "nixos-user";
    profile = "shimboot";
    board = "dedede";

    timezone = "America/New_York";
    locale = "en_US.UTF-8";

    host = {
      board = "dedede";
    };

    user = {
      fullName = "PopCat19";
      email = "atsuo11111@gmail.com";
      shell = "fish";
      extraGroups = [
        "audio"
        "docker"
        "i2c"
        "input"
        "libvirtd"
        "networkmanager"
        "video"
        "wheel"
      ];
    };

    agents = {
      enable = true;
      pi = true;
    };
  };
}
