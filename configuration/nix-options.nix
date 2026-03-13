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
      "ca-derivations"
      "pipe-operators"
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
      "https://cache.nixos.org"
      "https://popcat19-shared.cachix.org"
      "https://shimboot-systemd-nixos.cachix.org"
      "https://hyprland.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "popcat19-shared.cachix.org-1:qqle0Ek1MtOHDkqu2srjAnbjwl41fRUP8pLd9ZDsMEQ="
      "shimboot-systemd-nixos.cachix.org-1:vCWmEtJq7hA2UOLN0s3njnGs9/EuX06kD7qOJMo2kAA="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "03:00";
    options = "--delete-older-than 3d";
  };

  nixpkgs.config.allowUnfree = true;
}
