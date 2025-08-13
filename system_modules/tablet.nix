{ ... }:

{
  # Tablet configuration
  hardware.opentabletdriver.enable = true;

  # # Udev rules for tablet
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a" , ATTRS{idProduct}=="efe8", MODE="0666", GROUP="users"
  # '';
}