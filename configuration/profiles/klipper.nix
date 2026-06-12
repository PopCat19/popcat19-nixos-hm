# klipper.nix
#
# Purpose: Configuration preset for the Klipper Pi 4B — headless 3D printer appliance
#
# This profile:
# - Imports nixos-raspberrypi Pi 4 base (U-Boot, vendor kernel, firmware, udev groups, config.txt)
# - Enables Klipper + Moonraker + Mainsail on port 80
# - Configures mutable printer.cfg with syncthing group sharing
# - Enables SPI for ADXL345 input shaper calibration
# - Sets up WiFi via NetworkManager with credentials from userConfig
# - Minimal services: SSH, journald, dbus, nix GC
#
# Note: Uses nixos-raspberrypi's own nixpkgs (25.11) via nixosSystem,
# not the flake's unstable nixpkgs. This ensures tested kernel+firmware compat.
{
  lib,
  pkgs,
  userConfig,
  ...
}:
let
  inherit (userConfig.wifi) ssid psk;
  nmConnection = pkgs.writeText "Beave_Net_IoT.nmconnection" ''
    [connection]
    id=Beave_Net_IoT
    uuid=0278899c-f325-4669-ad07-06abc09f893d
    type=wifi

    [wifi]
    mode=infrastructure
    ssid=${ssid}

    [wifi-security]
    key-mgmt=wpa-psk
    psk=${psk}

    [ipv4]
    method=auto

    [ipv6]
    addr-gen-mode=default
    method=auto

    [proxy]
  '';
in
{
  imports = [
    # Portable modules from the flake
    ../base/system/localization.nix
    ../base/system/users.nix

    # Klipper ecosystem
    ../system/modules/klipper/printer.nix
  ];

  # ------------------------------------------------------------------
  # SPI — needed for ADXL345 input shaper calibration
  # nixos-raspberrypi config.txt module provides this; just enable the
  # dtparam that's commented out by default in configtxt.nix
  # ------------------------------------------------------------------
  hardware.raspberry-pi.config.all.base-dt-params.spi = {
    enable = true;
    value = "on";
  };

  # ------------------------------------------------------------------
  # WiFi — NetworkManager with preconfigured connection
  # PSK ends up in /nix/store via the writeText above. Same tradeoff
  # as every NixOS headless Pi setup — the Pi is on home LAN and
  # SSH keys gate actual access, so cleartext PSK in store is fine.
  # ------------------------------------------------------------------
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  # Pre-provision the NM connection file so the Pi connects on first boot
  environment.etc."NetworkManager/system-connections/Beave_Net_IoT.nmconnection" = {
    source = nmConnection;
    mode = "0600";
  };

  # Enable non-free firmware (required for Broadcom WiFi on Pi)
  hardware.enableRedistributableFirmware = true;

  # ------------------------------------------------------------------
  # SSH — OpenSSH server, password + key auth
  # ------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "yes";
    };
  };

  # ------------------------------------------------------------------
  # Packages — fish shell, git, system utilities
  # ------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    curl
    fish
    git
    micro
    vim
    wget
  ];

  # ------------------------------------------------------------------
  # Nix — flakes enabled, auto GC every week
  # ------------------------------------------------------------------
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "${userConfig.username}"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  # ------------------------------------------------------------------
  # Journald — keep logs small on 32GB SD
  # ------------------------------------------------------------------
  services.journald.extraConfig = ''
    MaxRetentionSec=7day
    SystemMaxUse=200M
    SystemKeepFree=100M
    Compress=yes
  '';

  # ------------------------------------------------------------------
  # System
  # ------------------------------------------------------------------

  # Minimal filesystem definition for evaluation — the actual SD image
  # is built via nixos-raspberrypi's sd-image module at deploy time.
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  # ------------------------------------------------------------------
  # System
  # ------------------------------------------------------------------
  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ userConfig.username ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
        ];
      }
    ];
  };

  system.stateVersion = lib.mkDefault "25.05";
}
