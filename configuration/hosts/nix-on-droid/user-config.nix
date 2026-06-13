# user-config.nix
#
# Purpose: User configuration for nix-on-droid (Android)
{ lib, ... }:
import ../../shared {
  inherit lib;
  host = {
    system = "aarch64-linux";
    hostname = "nix-on-droid";
    username = "nix-on-droid";
    profile = "nix-on-droid";

    user = {
      fullName = "PopCat19";
      email = "atsuo11111@gmail.com";
      shell = "fish";
      extraGroups = [ ];
    };

    directories.home = "/data/data/com.termux.nix/files/home";

    defaultApps = { };

    agents = {
      enable = false;
    };

    gaming = {
      enable = false;
      enableROCm = false;
    };
  };
}
