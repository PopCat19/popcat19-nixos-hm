# hardware.nix
#
# Purpose: Configure hardware support for Bluetooth and I2C
#
# This module:
# - Enables Bluetooth with auto-power-on
# - Configures I2C access for user group
_: {
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    i2c = {
      enable = true;
      group = "i2c";
    };
  };

  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
  '';
}
