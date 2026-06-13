# klipper.nix
#
# Purpose: Configuration preset for the Klipper Pi 4B — headless 3D printer appliance
#
# This profile:
# - Imports Pi 4 base (U-Boot, vendor kernel, firmware, udev groups, config.txt)
# - Imports users.nix for user/sudo base (augmented below)
# - Enables Klipper + Moonraker + Mainsail on port 80
# - Configures mutable printer.cfg
# - Enables SPI for ADXL345 input shaper calibration
# - Sets up WiFi via NetworkManager with credentials from userConfig
#
# Note: Uses nixos-raspberrypi's own nixpkgs (25.11) via nixosSystem.

{
  lib,
  pkgs,
  userConfig,
  config,
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
    ../base/system/localization.nix
    ../base/system/users.nix
    ../system/modules/klipper/printer.nix
  ];

  # ------------------------------------------------------------------
  # User — users.nix provides isNormalUser + group + mkDefault wheel.
  # mkForce ensures this definition wins, adding klipper+moonraker.
  # ------------------------------------------------------------------
  users.users.${userConfig.username} = {
    initialPassword = "popcat19";
    extraGroups = lib.mkForce [
      "wheel"
      "klipper"
      "moonraker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGiKOcLWZpZToQ3rlBy439vkBMfT+E/JuK1BywvsgiqT popcat19@popcat19-nixos0"
    ];
  };

  # ------------------------------------------------------------------
  # sudo — wheel group gets full NOPASSWD (concatenates with users.nix
  # rules — NixOS lists merge across modules)
  # ------------------------------------------------------------------
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "ALL";
          options = [
            "NOPASSWD"
            "SETENV"
          ];
        }
      ];
    }
  ];

  # ------------------------------------------------------------------
  # SPI — needed for ADXL345 input shaper calibration
  # ------------------------------------------------------------------
  hardware.raspberry-pi.config.all.base-dt-params.spi = {
    enable = true;
    value = "on";
  };

  # ------------------------------------------------------------------
  # WiFi — NetworkManager with preconfigured connection
  # ------------------------------------------------------------------
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  environment.etc."NetworkManager/system-connections/Beave_Net_IoT.nmconnection" = {
    source = nmConnection;
    mode = "0600";
  };

  hardware.enableRedistributableFirmware = true;

  # ------------------------------------------------------------------
  # SSH — OpenSSH server
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
  # Filesystem stub — for evaluation; sd-image module provides real one
  # ------------------------------------------------------------------
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  system.stateVersion = lib.mkDefault "25.05";
}
