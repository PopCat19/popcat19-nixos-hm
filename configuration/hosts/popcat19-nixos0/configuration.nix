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
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    ../../system/modules/sunshine.nix
    ../../system/modules/agenix.nix
    ../../system/modules/searxng.nix
    ../../system/modules/perplexica.nix
    ../../system/modules/penpot.nix
  ];

  services.searxng-local.enable = true;
  services.perplexica.enable = true;
  services.penpot.enable = true;

  services.sillytavern = {
    enable = true;
    port = 8000;
    listen = true;
    configFile = "${pkgs.writeText "sillytavern-config.yaml" ''
      dataRoot: ./data
      basicAuthMode: true
      basicAuthUser:
        username: popcat19
        password: REDACTED
      enableCorsProxy: true
      whitelistDockerHosts: true
      enableForwardedWhitelist: true
    ''}";
  };

  systemd.services.zrok-share-sillytavern = {
    description = "Zrok reserved share tunnel for SillyTavern";
    after = [ "network-online.target" "sillytavern.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.zrok}/bin/zrok share reserved 5f5icptoebhm";
      Restart = "on-failure";
      RestartSec = "10";
      User = "popcat19";
      Group = "users";
    };
  };

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
