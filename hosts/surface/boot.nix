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
    kernelPackages = pkgs.linuxPackages_latest;
    # i2c-dev module removed for Surface
    kernelModules = [ ];
  };
}