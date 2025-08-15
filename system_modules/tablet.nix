{ pkgs, ... }:

{
  # Tablet configuration
  hardware.opentabletdriver = {
  enable = true;
  daemon.enable = true;
  package = pkgs.opentabletdriver;
  };

  # Udev rules for tablet
  services.udev.extraRules = ''
    # Gaomon S620
    SUBSYSTEM=="usb", ATTRS{idVendor}=="256c", ATTRS{idProduct}=="006d", MODE="0666", GROUP="users"
  '';
}