# configuration.nix
#
# Purpose: Main NixOS configuration for the Klipper Pi 4B host
#
# This module:
# - Imports Pi 4 hardware base (U-Boot, vendor kernel, firmware) from nixos-raspberrypi
# - Imports the klipper profile (Klipper + Moonraker + Mainsail + base services)
# - Defines host-specific filesystem, hostname, and SSH authorized keys
{
  inputs,
  userConfig,
  ...
}:
{
  imports = [
    # Pi 4 hardware: U-Boot, vendor kernel, firmware, config.txt, udev
    # (gpio, i2c, spi groups already created by nixos-raspberrypi)
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-4.base
    ../../profiles/klipper.nix
  ];

  networking.hostName = userConfig.hostname;

  # Filesystem stub: sd-image module provides the real one at build time
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  # SSH access for the primary user
  users.users.${userConfig.username} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiKOcLWZpZToQ3rlBy439vkBMfT+E/JuK1BywvsgiqT popcat19@popcat19-nixos0"
    ];
  };
}
