# System Configuration Module
#
# Purpose: Core NixOS configuration for nixos-config base system
# Dependencies: All base system_modules, user-config.nix
# Related: configuration/home/home.nix, configuration/system/system-extended.nix, user-config.nix
#
# This module:
# - Imports all base system modules
# - Configures Nix settings and binary caches
# - Enables core system functionality
# - Sets system state version
{lib, ...}: let
  userConfig = import ../../configuration/user-config.nix {};
in {
  imports = [
    ./system_modules/environment.nix
    ./system_modules/fish.nix
    ./system_modules/boot.nix
    ./system_modules/networking.nix
    ./system_modules/ssh.nix
    ./system_modules/hardware.nix
    ./system_modules/packages.nix
    ./system_modules/core-packages.nix
    ./system_modules/localization.nix
    ./system_modules/users.nix
    ./system_modules/services.nix
    ./system_modules/display.nix
    ./system_modules/noctalia.nix
    ./system_modules/audio.nix
    ./system_modules/virtualisation.nix
    ./system_modules/fonts.nix
    ./system_modules/gnome-keyring.nix
  ];

  _module.args.userConfig = userConfig;

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

    trusted-users = ["root" "${userConfig.user.username}"];

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
