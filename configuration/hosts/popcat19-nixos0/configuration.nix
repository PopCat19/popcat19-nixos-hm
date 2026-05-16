# configuration.nix
#
# Purpose: Main NixOS configuration for the nixos0 host
#
# This module:
# - Imports hardware configuration and profile preset
# - Applies host-specific packages and settings
{
  pkgs,
  userConfig,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    ../../system/modules/sunshine.nix
    ../../system/modules/agenix.nix
    ../../system/modules/searxng.nix
  ];

  services.searxng-local.enable = true;

  networking.hostName = userConfig.hostname;

  # Windows 11 dual boot (on /dev/sdb)
  # Requires one-time manual copy of Windows bootloader:
  #   sudo mkdir -p /boot/EFI/Microsoft/Boot
  #   sudo mount /dev/sdb1 /mnt
  #   sudo cp /mnt/EFI/Microsoft/Boot/bootmgfw.efi /boot/EFI/Microsoft/Boot/
  #   sudo umount /mnt
  boot.loader.systemd-boot.extraEntries = {
    "windows.conf" = ''
      title Windows 11
      efi /EFI/Microsoft/Boot/bootmgfw.efi
      sort-key o_windows
    '';
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    bleachbit
    moonlight-qt
    opentabletdriver
    pavucontrol
  ];
}
