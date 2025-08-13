{ pkgs, ... }:

{
  # **BOOT & KERNEL CONFIGURATION**
  # Defines boot loader, kernel, and filesystem support settings.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ];
    # Let nixos-hardware common module provide the patched linux-surface kernel
    # kernelPackages = pkgs.linuxPackages_latest;  # Removed to avoid conflict with nixos-hardware
    # i2c-dev module removed for Surface
    kernelModules = [ ];
  };
}