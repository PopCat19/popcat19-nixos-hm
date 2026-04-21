# users.nix
#
# Purpose: User and sudo configuration
#
# This module:
# - Creates the main user account
# - Sets up basic user groups
# - Configures passwordless sudo for nixos-rebuild (LLM automation)
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
            command = "/run/wrappers/bin/nixos-rebuild";
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
