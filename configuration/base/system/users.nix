# users.nix
#
# Purpose: User and sudo configuration
#
# This module:
# - Creates the main user account
# - Sets up basic user groups
# - Configures passwordless sudo for nixos-rebuild, nix-env, and systemd-run (LLM automation + remote deploy)
{ lib, userConfig, ... }:
{
  users.users.${userConfig.username} = {
    isNormalUser = true;
    extraGroups = lib.mkDefault [ "wheel" ];
  };

  security.sudo = {
    enable = lib.mkDefault true;
    extraRules = [
      {
        users = [ userConfig.username ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nixos-rebuild";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl set-environment *";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl unset-environment *";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl restart nix-daemon";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-env";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
          {
            command = "/run/current-system/sw/bin/systemd-run";
            options = [
              "NOPASSWD"
              "SETENV"
            ];
          }
        ];
      }
    ];
  };
}
