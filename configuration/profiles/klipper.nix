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
    ../system/modules/klipper
  ];

  # SPI — needed for ADXL345 input shaper calibration
  hardware.raspberry-pi.config.all.base-dt-params.spi = {
    enable = true;
    value = "on";
  };

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
  environment.systemPackages = with pkgs; [
    curl
    git
    micro
    vim
    wget
  ];

  # Fish is used as the interactive shell for the primary user
  programs.fish.enable = true;

  # Nix — flakes enabled, auto GC every week
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
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
