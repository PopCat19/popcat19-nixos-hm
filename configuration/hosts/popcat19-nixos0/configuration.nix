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
let
  sillytavernPassword = builtins.getEnv "SILLYTAVERN_PASSWORD";

  sillytavernConfig = pkgs.writeText "sillytavern-config.yaml" ''
    dataRoot: ./data
    basicAuthMode: true
    basicAuthUser:
      username: popcat19
      password: ${sillytavernPassword}
    enableCorsProxy: true
    whitelistMode: false
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    ../../system/modules/sunshine.nix
    ../../system/modules/agenix.nix
    ../../system/modules/searxng.nix
    ../../system/modules/perplexica.nix
    ../../system/modules/penpot.nix
    ../../services/zrok
  ];

  services.searxng-local.enable = true;
  services.perplexica.enable = true;
  services.penpot.enable = true;
  services.open-webui = {
    enable = true;
    port = 3000;
  };

  services.sillytavern = {
    enable = true;
    port = 8000;
    listen = true;
  };

  # Override upstream tmpfiles symlink (L+) with writable copy (C)
  # The upstream module links config into the Nix store (read-only), causing EROFS
  systemd.tmpfiles.settings.sillytavern."/var/lib/SillyTavern/config.yaml" = lib.mkForce {
    "C" = {
      mode = "0600";
      argument = "${sillytavernConfig}";
      user = "sillytavern";
      group = "sillytavern";
    };
  };

  # Replace upstream's read-only symlink with a writable copy on first boot
  systemd.services.sillytavern.preStart = ''
    if [ -L /var/lib/SillyTavern/config.yaml ]; then
      rm -f /var/lib/SillyTavern/config.yaml
      cp -f ${sillytavernConfig} /var/lib/SillyTavern/config.yaml
      chown sillytavern:sillytavern /var/lib/SillyTavern/config.yaml
      chmod 600 /var/lib/SillyTavern/config.yaml
    fi
  '';

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
