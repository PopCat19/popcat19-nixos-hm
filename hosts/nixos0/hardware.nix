{ ... }:

{
  # **HARDWARE CONFIGURATION**
  # Defines hardware-specific settings and drivers for nixos0.
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    opentabletdriver.enable = true;
    i2c.enable = true;
  };

  # **UDEV RULES**
  # Custom udev rules for hardware devices.
  services.udev.extraRules = ''
    # I2C devices
    KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
    # Allwinner FEL
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a" , ATTRS{idProduct}=="efe8", MODE="0666", GROUP="users"
    # Game controllers for Sunshine
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0664"
    KERNEL=="js*"     , SUBSYSTEM=="input", GROUP="input", MODE="0664"
  '';
}