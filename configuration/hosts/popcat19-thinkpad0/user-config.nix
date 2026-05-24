# user-config.nix
#
# Purpose: Host-specific overrides for thinkpad0
let
  base = import ../../user-config.nix;
in
base
// {
  system = "x86_64-linux";
  hostname = "popcat19-thinkpad0";
  profile = "laptop";

  piAgent = {
    enable = true;
  };
}
