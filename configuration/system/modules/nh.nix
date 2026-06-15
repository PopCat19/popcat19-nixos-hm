# nh.nix
#
# Purpose: Configure nh (nix-community/nh) as the Nix CLI helper
#
# This module:
# - Installs nh package and sets NH_FLAKE env var
# - Replaces nix.gc with nh clean systemd timer
# - Enables build-tree visualization and change diffs
# - (nh NOPASSWD sudo rule is in users.nix to avoid %wheel override)
{ lib, userConfig, ... }:
{
  programs.nh = {
    enable = true;
    flake = lib.mkForce userConfig.env.NIXOS_CONFIG_DIR;

    clean = {
      enable = true;
      extraArgs = lib.mkForce "--keep-since 3d --keep 5";
    };
  };
}
