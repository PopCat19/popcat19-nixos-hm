# user-config.nix
#
# Purpose: Host-specific overrides for nixos0
let
  base = import ../../user-config.nix;
in
base
// {
  system = "x86_64-linux";
  hostname = "popcat19-nixos0";
  profile = "default";

  gaming = {
    enable = true;
    enableROCm = true;
  };

  agents = {
    enable = true;
    opencode = true;
    pi = true;
  };

  zrok = {
    enable = true;
  };
}
