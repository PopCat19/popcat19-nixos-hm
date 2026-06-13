# user-config.nix
#
# Purpose: Host-specific overrides for aarch640 (generic aarch64 stub)
{ lib, ... }:
import ../../shared {
  inherit lib;
  host = {
    system = "aarch64-linux";
    hostname = "popcat19-aarch640";
    profile = "default";

    gaming = {
      enable = false;
      enableROCm = false;
    };
  };
}
