# Boot Configuration Module
#
# Purpose: Manage bootloader configuration and kernel settings.
# Dependencies: systemd-boot, nixpkgs
# Related: hardware.nix
#
# This module:
# - Configures systemd-boot as the bootloader
# - Sets up EFI boot variables
# - Enables support for NTFS filesystems
# - Configures zen kernel for optimal performance
{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "i2c-dev" ];
    blacklistedKernelModules = [ "snd_seq_dummy" ];
  };
}
