# tablet.nix
#
# Purpose: Configure OpenTabletDriver for graphics tablet support
#
# This module:
# - Enables OpenTabletDriver daemon and service
# - Configures tablet input support
_: {
  hardware.opentabletdriver = {
    daemon.enable = true;
    enable = true;
  };
}
