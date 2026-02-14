# boot.nix
#
# Purpose: Manage bootloader configuration and kernel settings
#
# This module:
# - Configures systemd-boot as the bootloader
# - Sets up EFI boot variables
# - Enables NTFS filesystem support
# - Configures zen kernel for performance
{ lib, pkgs, ... }:
{
  boot = {
    blacklistedKernelModules = lib.mkDefault [ "snd_seq_dummy" ];
    kernelModules = lib.mkDefault [ "i2c-dev" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;
    loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;
      systemd-boot = {
        configurationLimit = lib.mkDefault 5;
        enable = lib.mkDefault true;
      };
      timeout = lib.mkDefault 3;
    };
    supportedFilesystems = lib.mkDefault [ "ntfs" ];
  };
}
