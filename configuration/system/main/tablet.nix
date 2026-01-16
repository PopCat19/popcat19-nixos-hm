# Tablet Configuration Module
#
# Purpose: Configure OpenTabletDriver for graphics tablet support
# Dependencies: opentabletdriver | None
# Related: hardware.nix, display.nix
#
# This module:
# - Enables OpenTabletDriver daemon and service
# - Configures tablet input support
_: {
  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };
}
