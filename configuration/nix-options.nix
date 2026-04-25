# nix-options.nix
#
# Purpose: Centralized Nix configuration options
#
# This module:
# - Defines Nix experimental features
# - Sets up garbage collection
# - Configures trusted users
#
# Warning: Nix reads config from multiple sources. If the daemon
# reports fewer experimental-features than defined here, check for
# a root-level override at /root/.config/nix/nix.conf. The daemon
# runs as root and that file takes precedence over /etc/nix/nix.conf.
# Use tools/debug-nix-config.sh to diagnose.
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
  };

  nix.gc = {
    automatic = true;
    dates = "03:00";
    options = "--delete-older-than 3d";
  };

  nixpkgs.config.allowUnfree = true;
}
