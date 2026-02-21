# tablet.nix
#
# Purpose: Configure OpenTabletDriver for graphics tablet support
#
# This module:
# - Enables OpenTabletDriver daemon and service
# - Configures udev rules for tablet device access
# - Configures tablet input support
_: {
  hardware.opentabletdriver = {
    daemon.enable = true;
    enable = true;
  };

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="b33f", ATTRS{idProduct}=="c4k3", TAG+="uaccess", TAG+="udev-acl"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="b33f", ATTRS{idProduct}=="c4k3", TAG+="uaccess", TAG+="udev-acl"
  '';
}
