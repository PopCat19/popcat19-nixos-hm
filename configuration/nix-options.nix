# nix-options.nix
#
# Purpose: Centralized Nix configuration options
#
# This module:
# - Defines Nix experimental features
# - Configures binary caches and trusted keys
# - Sets up garbage collection
{ userConfig, ... }:
{
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
}
