# user-config.nix
#
# Purpose: Host-specific overrides for nixos0
{ lib, ... }:
import ../../shared {
  inherit lib;
  host = {
    system = "x86_64-linux";
    hostname = "popcat19-nixos0";
    profile = "default";

    gaming = {
      enable = true;
      enableROCm = true;
    };

    agents = {
      enable = true;
      forgecode = true;
      kilocode-cli = true;
      omp = true;
      opencode = true;
      pi = true;
      reasonix = true;
    };

    zrok = {
      enable = true;
    };

    sillytavern = {
      enable = true;
    };
  };
}
