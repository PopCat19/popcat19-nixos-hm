# configuration.nix
#
# Purpose: Core NixOS configuration for nixos-config base system
#
# This module:
# - Imports all base system modules
# - Configures Nix settings and binary caches
# - Enables core system functionality
# - Sets system state version
# - Injects userConfig and selectedProfile for all imported modules
{
  lib,
  userConfig,
  selectedProfile,
  ...
}:
let
  stateVersion = import ../stateversion.nix;
in
{
  imports = [
    # Boot-critical files from ./system/
    ./system/boot.nix
    ./system/core-packages.nix
    ./system/environment.nix
    ./system/localization.nix
    ./system/users.nix

    # Additional system modules from ../system/modules/
    ../system/modules/audio.nix
    ../system/modules/display.nix
    ../system/modules/fish.nix
    ../system/modules/fonts.nix
    ../system/modules/gnome-keyring.nix
    ../system/modules/hardware.nix
    ../system/modules/networking.nix
    ../system/modules/noctalia.nix
    ../system/modules/packages.nix
    ../system/modules/proxy.nix
    ../system/modules/services.nix
    ../system/modules/ssh.nix
    ../system/modules/tablet.nix
    ../system/modules/virtualisation.nix
  ];

  _module.args = {
    inherit userConfig selectedProfile;
  };

  nix.gc = {
    automatic = true;
    dates = "03:00";
    options = "--delete-older-than 3d";
  };

  nix.settings = {
    accept-flake-config = true;
    auto-optimise-store = true;
    cores = 0;
    download-buffer-size = 67108864;
    experimental-features = [
      "nix-command"
      "flakes"
      "fetch-tree"
      "impure-derivations"
    ];
    max-jobs = "auto";
    min-free = 0;

    substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
      "https://shimboot-systemd-nixos.cachix.org"
      "https://vicinae.cachix.org"
    ];

    trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "shimboot-systemd-nixos.cachix.org-1:vCWmEtJq7hA2UOLN0s3njnGs9/EuX06kD7qOJMo2kAA="
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];

    trusted-users = [
      "root"
      "${userConfig.user.username}"
    ];
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  system.stateVersion = lib.mkDefault stateVersion.system;
}
