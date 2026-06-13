# user-config.nix
#
# Purpose: Host-specific overrides for aarch640 (generic aarch64 stub)
let
  base = import ../../user-config.nix;
in
base
// {
  system = "aarch64-linux";
  hostname = "popcat19-aarch640";
  profile = "default";

  # Disable x86_64-only features on the generic aarch64 stub
  gaming = {
    enable = false;
    enableROCm = false;
  };

  agents = {
    enable = false;
  };
}
