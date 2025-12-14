{...}: {
  # Hardware configuration
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

  # Udev rules
  services.udev.extraRules = ''
    KERNEL=="i2c-[0-9]*"             , GROUP="i2c",   MODE="0660"
  '';
}
