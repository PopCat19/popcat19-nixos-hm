# surface.nix
#
# Purpose: Configuration preset for Microsoft Surface devices
#
# This profile:
# - Imports the default profile as base
# - Surface-specific hardware configuration is handled by host modules
# - Host should import surface-specific modules (thermal, hardware, etc.)
let
  stateVersion = import ../stateversion.nix;
in
{
  imports = [
    ./default.nix
  ];

  system.stateVersion = stateVersion.system;
}
