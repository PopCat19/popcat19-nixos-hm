# user-config.nix
#
# Purpose: Host-specific overrides for thinkpad0
{ lib, ... }:
import ../../shared {
  inherit lib;
  host = {
    system = "x86_64-linux";
    hostname = "popcat19-thinkpad0";
    profile = "laptop";

    agents = {
      enable = true;
      pi = true;
    };
  };
}
