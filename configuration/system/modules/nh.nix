# nh.nix
#
# Purpose: Configure nh (nix-community/nh) as the Nix CLI helper
#
# This module:
# - Installs nh package and sets NH_FLAKE env var
# - Replaces nix.gc with nh clean systemd timer
# - Grants passwordless sudo for nh os subcommands
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

  security.sudo.extraRules = [
    {
      users = [ userConfig.username ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nh";
          options = [
            "SETENV"
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
}
