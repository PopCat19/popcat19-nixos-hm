# Boot Configuration Module
#
# Purpose: Manage bootloader configuration and kernel settings.
# Dependencies: systemd-boot, nixpkgs, nix-cachyos-kernel
# Related: hardware.nix
#
# This module:
# - Configures systemd-boot as the bootloader
# - Sets up EFI boot variables
# - Enables support for NTFS filesystems
# - Configures CachyOS LTO kernel for optimal performance
{
  pkgs,
  inputs,
  ...
}: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    supportedFilesystems = ["ntfs"];
    kernelPackages = inputs.nix-cachyos-kernel.legacyPackages.x86_64-linux.linuxPackages-cachyos-latest-lto-x86_64-v3;
    kernelModules = ["i2c-dev"];
    blacklistedKernelModules = ["snd_seq_dummy"];
  };
}
