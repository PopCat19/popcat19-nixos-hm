# user-config.nix
#
# Purpose: Host-specific configuration for the Klipper Pi 4B
{ lib, ... }:
import ../../shared {
  inherit lib;
  host = {
    system = "aarch64-linux";
    hostname = "klipper";
    profile = "klipper";

    user = {
      fullName = "PopCat19";
      email = "atsuo11111@gmail.com";
      shell = "fish";
      extraGroups = [
        "wheel"
        "klipper"
        "moonraker"
        "networkmanager"
      ];
    };

    defaultApps = { };

    agents = {
      enable = false;
    };

    gaming = {
      enable = false;
      enableROCm = false;
    };

    klipper = {
      enable = true;
      wifi = {
        ssid = "Beave_Net_IoT";
      };
    };
  };
}
