# Base Configuration Module
#
# Purpose: Core NixOS configuration for nixos-config base system
#
# This module:
# - Imports all base system modules
# - Configures Nix settings and binary caches
# - Enables core system functionality
# - Sets system state version
# - Injects userConfig and selectedProfile for all imported modules
{ inputs, userConfig, selectedProfile, ... }:
{
  imports = [
    ../configuration/system/system_modules/environment.nix
    ../configuration/system/system_modules/fish.nix
    ../configuration/system/system_modules/boot.nix
    ../configuration/system/system_modules/networking.nix
    ../configuration/system/system_modules/proxy.nix
    ../configuration/system/system_modules/ssh.nix
    ../configuration/system/system_modules/hardware.nix
    ../configuration/system/system_modules/tablet.nix
    ../configuration/system/system_modules/packages.nix
    ../configuration/system/system_modules/core-packages.nix
    ../configuration/system/system_modules/localization.nix
    ../configuration/system/system_modules/users.nix
    ../configuration/system/system_modules/services.nix
    ../configuration/system/system_modules/display.nix
    ../configuration/system/system_modules/noctalia.nix
    ../configuration/system/system_modules/audio.nix
    ../configuration/system/system_modules/virtualisation.nix
    ../configuration/system/system_modules/fonts.nix
    ../configuration/system/system_modules/gnome-keyring.nix
  ];

  _module.args = {
    inherit userConfig selectedProfile;
  };

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
      "${userConfig.user.username}"
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
