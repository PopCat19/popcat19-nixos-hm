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
    kernelModules = [
      "i2c-dev"
      "ntsync"
    ];
    # CachyOS kernel with BORE scheduler (v3 optimized)
    # Replaces xanmod — MT7922 Bluetooth fix landed in 7.0.10
    kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;
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
