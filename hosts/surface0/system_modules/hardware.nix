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
  # services.udev.extraRules = '''';
}