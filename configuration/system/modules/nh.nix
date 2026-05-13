# nh.nix
#
# Purpose: Configure nh (nix-community/nh) as the Nix CLI helper
#
# This module:
# - Installs nh package and sets NH_FLAKE env var
# - Replaces nix.gc with nh clean systemd timer
# - Enables build-tree visualization and change diffs
{ userConfig, ... }:
{
  programs.nh = {
    enable = true;
    flake = userConfig.env.NIXOS_CONFIG_DIR;

    clean = {
      enable = true;
      extraArgs = "--keep-since 3d --keep 5";
    };
  };
}
