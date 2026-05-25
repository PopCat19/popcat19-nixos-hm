# configuration.nix
#
# Purpose: Main NixOS configuration for the nixos0 host
#
# This module:
# - Imports hardware configuration and profile preset
# - Applies host-specific packages and settings
{
  config,
  pkgs,
  userConfig,
  lib,
  ...
}:
let
  # Template written at build time; password injected at runtime from agenix
  sillytavernConfigTemplate = pkgs.writeText "sillytavern-config-template.yaml" ''
    dataRoot: ./data
    basicAuthMode: true
    basicAuthUser:
      username: popcat19
      password: __PASSWORD_PLACEHOLDER__
    enableCorsProxy: true
    whitelistMode: false
  '';
  cfg = config.services.sillytavern;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/${userConfig.profile}.nix
    ../../system/modules/sunshine.nix
    ../../system/modules/agenix.nix
    ../../system/modules/searxng.nix
    ../../system/modules/firecrawl.nix
    ../../services/zrok
  ];

  services.searxng-local.enable = true;
  services.firecrawl.enable = true;
  services.sillytavern = {
    enable = true;
    port = 8000;
    listen = true;
  };

  # Remove the upstream tmpfiles entry for config.yaml — preStart handles it
  systemd.tmpfiles.settings.sillytavern."/var/lib/SillyTavern/config.yaml" = lib.mkForce { };

  # Fix: upstream generates --listen=1 which yargs parses as false for boolean flags.
  # Also add --basicAuthMode so auth is explicitly enabled regardless of config state.
  systemd.services.sillytavern.serviceConfig.ExecStart =
    lib.mkForce "${lib.getExe pkgs.sillytavern} --port=${toString cfg.port} --listen --basicAuthMode";

  # Silence console.debug() spam — SillyTavern dumps full system prompts
  # on every chat request via console.debug, generating ~36K log lines/hour
  systemd.services.sillytavern.environment.NODE_OPTIONS =
    "--require ${pkgs.writeText "st-no-debug.cjs" "console.debug = () => {};"}";

  # Generate config.yaml at runtime. Replaces the upstream read-only symlink.
  # Password uses agenix secret if available, else falls back to template default.
  systemd.services.sillytavern.preStart = ''
    SECRET="${
      lib.optionalString (
        config.age.secrets ? sillytavern-password
      ) config.age.secrets.sillytavern-password.path
    }"
    if [ -n "$SECRET" ] && [ -f "$SECRET" ]; then
      PASSWORD=$(cat "$SECRET")
    else
      PASSWORD=REDACTED
    fi
    sed "s/__PASSWORD_PLACEHOLDER__/$PASSWORD/g" \
      ${sillytavernConfigTemplate} \
      > /var/lib/SillyTavern/config.yaml
    chown sillytavern:sillytavern /var/lib/SillyTavern/config.yaml
    chmod 600 /var/lib/SillyTavern/config.yaml
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
    cachix
    moonlight-qt
    opentabletdriver
    pavucontrol
  ];
}
