# user-config.nix
#
# Purpose: Host-specific overrides for surface0
let
  base = import ../../user-config.nix;
in
base
// {
  system = "x86_64-linux";
  hostname = "popcat19-surface0";
  profile = "surface";

  user = base.user // {
    extraGroups = base.user.extraGroups ++ [ "surface-control" ];
  };

  inherit (base) agents;
}
