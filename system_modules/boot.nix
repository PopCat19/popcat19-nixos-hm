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
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "i2c-dev" ];
  };
}