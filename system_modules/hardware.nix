{ ... }:

{
  # Hardware configuration
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    opentabletdriver.enable = true;
    i2c = {
      enable = true;
      group = "i2c";
    };
  };

  # Udev rules
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*"             , GROUP="i2c",   MODE="0660"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1f3a" , ATTRS{idProduct}=="efe8", MODE="0666", GROUP="users"
    KERNEL=="event*", SUBSYSTEM=="input", GROUP="input", MODE="0664"
    KERNEL=="js*"     , SUBSYSTEM=="input", GROUP="input", MODE="0664"
  '';
}