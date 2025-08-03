{ ... }:

{
  # **HARDWARE CONFIGURATION**
  # Defines hardware-specific settings and drivers.
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    opentabletdriver.enable = true;
    # i2c configuration removed for Surface
  };

  # **UDEV RULES**
  # Custom udev rules for hardware devices.
  services.udev.extraRules = ''
    # i2c devices removed for Surface
    # Allwinner FEL
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a" , ATTRS{idProduct}=="efe8", MODE="0666", GROUP="users"
    # Game controllers for Sunshine
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0664"
    KERNEL=="js*"     , SUBSYSTEM=="input", GROUP="input", MODE="0664"
  '';
}