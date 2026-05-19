# nix-options.nix
#
# Purpose: Centralized Nix configuration options
#
# This module:
# - Defines Nix experimental features
# - Disables nix.gc (delegated to programs.nh.clean)
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

  # GC delegated to programs.nh.clean (see modules/nh.nix).
  # nix.gc and programs.nh.clean must not both be enabled.
  nix.gc.automatic = false;

  nixpkgs.config.allowUnfree = true;
}
