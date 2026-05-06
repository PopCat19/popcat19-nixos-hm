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
    KERNEL=="hidraw*", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006d", TAG+="uaccess", TAG+="udev-acl"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006d", TAG+="uaccess", TAG+="udev-acl"

    # Tag OTD virtual devices as tablets for Wayland compositor tablet-v2 protocol
    SUBSYSTEM=="input", ENV{DEVNAME}=="/dev/input/event*", \
      ATTRS{name}=="OpenTabletDriver Virtual Tablet", \
      ENV{ID_INPUT_TABLET}="1"
    SUBSYSTEM=="input", ENV{DEVNAME}=="/dev/input/event*", \
      ATTRS{name}=="OpenTabletDriver Virtual Artist Tablet", \
      ENV{ID_INPUT_TABLET}="1"
  '';
}
