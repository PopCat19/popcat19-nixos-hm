# configuration.nix
#
# Purpose: Core NixOS configuration for nixos-config base system
#
# This module:
# - Imports all base system modules
# - Configures Nix settings and binary caches
# - Enables core system functionality
# - Sets system state version
{ userConfig, ... }:
{
  imports = [
    ./modules/environment.nix
    ./modules/fish.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/proxy.nix
    ./modules/ssh.nix
    ./modules/hardware.nix
    ./modules/tablet.nix
    ./modules/packages.nix
    ./modules/core-packages.nix
    ./modules/localization.nix
    ./modules/users.nix
    ./modules/services.nix
    ./modules/display.nix
    ./modules/noctalia.nix
    ./modules/audio.nix
    ./modules/virtualisation.nix
    ./modules/fonts.nix
    ./modules/gnome-keyring.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
      "fetch-tree"
      "impure-derivations"
    ];
    accept-flake-config = true;
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    min-free = 0;
    download-buffer-size = 67108864;

    trusted-users = [
      "root"
      "${userConfig.username}"
    ];

    substituters = [
      "https://vicinae.cachix.org"
      "https://shimboot-systemd-nixos.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
    ];

    trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "shimboot-systemd-nixos.cachix.org-1:vCWmEtJq7hA2UOLN0s3njnGs9/EuX06kD7qOJMo2kAA="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "03:00";
    options = "--delete-older-than 3d";
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
