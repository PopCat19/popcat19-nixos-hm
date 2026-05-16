# boot.nix
#
# Purpose: Manage bootloader configuration and kernel settings
#
# This module:
# - Configures systemd-boot as the bootloader
# - Sets up EFI boot variables
# - Enables NTFS filesystem support
# - Configures XanMod kernel for performance
{ pkgs, ... }:
{
  boot = {
    blacklistedKernelModules = [ "snd_seq_dummy" ];
    kernelModules = [ "i2c-dev" "ntsync" ];
    kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
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
