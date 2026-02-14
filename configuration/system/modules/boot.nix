# boot.nix
#
# Purpose: Manage bootloader configuration and kernel settings
#
# This module:
# - Configures systemd-boot as the bootloader
# - Sets up EFI boot variables
# - Enables NTFS filesystem support
# - Configures zen kernel for performance
{ pkgs, ... }:
{
  boot = {
    blacklistedKernelModules = [ "snd_seq_dummy" ];
    kernelModules = [ "i2c-dev" ];
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        configurationLimit = 5;
        enable = true;
      };
      timeout = 3;
    };
    supportedFilesystems = [ "ntfs" ];
  };
}
