# klipper.nix
#
# Purpose: Configuration preset for the Klipper Pi 4B — headless 3D printer appliance
#
# This profile:
# - Imports the base boot-critical configuration
# - Imports the canonical users module (groups, sudo)
# - Imports the Klipper printer stack module
# - Enables SPI for ADXL345 input shaper calibration
# - Configures NetworkManager for WiFi
# - Sets up basic services and packages for the Pi
{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../base/system/localization.nix
    ../system/modules/users.nix
    ../system/modules/fish-functions.nix
    ../system/modules/syncthing.nix
    ../system/modules/klipper
  ];

  # SPI — needed for ADXL345 input shaper calibration
  hardware.raspberry-pi.config.all.base-dt-params.spi = {
    enable = true;
    value = "on";
  };

  # Use generational bootloader — supports nixos-rebuild switch without
  # corrupting firmware partition (unlike U-Boot, which rewrites on every switch).
  # nixos-raspberrypi recommends this for new installations (github:nvmd/nixos-raspberrypi#60).
  boot.loader.raspberry-pi.bootloader = "kernel";

  # systemd initrd is required for kernel cmdline fsck flags to take effect
  # (fsck.repair=yes, fsck.mode=force). Without this, unclean shutdowns
  # leave /nix/store mounted read-only, corrupting the nix DB.
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [
    "fsck.mode=force"
    "fsck.repair=yes"
  ];

  # WiFi — NetworkManager (PSK is injected from agenix by the klipper module)
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  hardware.enableRedistributableFirmware = true;

  # SSH — OpenSSH server
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = lib.mkDefault "yes";
    };
  };

  # Packages — git, system utilities
  environment.sessionVariables = {
    NIXOS_CONFIG_DIR = "/home/popcat19/popcat19-nixos-hm";
  };

  environment.systemPackages = with pkgs; [
    curl
    eza
    git
    micro
    starship
    vim
    wget
  ];

  # Fish is used as the interactive shell for the primary user
  programs.fish.enable = true;

  # Nix — flakes enabled, auto GC every week.
  # keep-derivations + keep-outputs prevent GC from deleting the
  # nixos-rebuild wrapper's embedded nix binary (avoids sqlite SIGABRT).
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    keep-derivations = true;
    keep-outputs = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  # Journald — keep logs small on 32GB SD
  services.journald.extraConfig = ''
    MaxRetentionSec=7day
    SystemMaxUse=200M
    SystemKeepFree=100M
    Compress=yes
  '';

  system.stateVersion = lib.mkDefault "25.05";
}
