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
let
  inherit (pkgs.stdenv.hostPlatform) isx86_64;
in
{
  boot = {
    blacklistedKernelModules = [ "snd_seq_dummy" ];
    kernelModules = [
      "i2c-dev"
      "ntsync"
    ];
    # XanMod kernel (>= 7.0.10 includes MT7922 Bluetooth fix). x86_64 only.
    kernelPackages = pkgs.lib.mkIf isx86_64 pkgs.linuxPackages_xanmod_latest;
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
