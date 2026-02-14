# users.nix
#
# Purpose: Minimal user configuration
#
# This module:
# - Creates the main user account
# - Sets up basic user groups
{ lib, userConfig, ... }:
{
  users.users.${userConfig.username} = {
    isNormalUser = true;
    extraGroups = lib.mkDefault [ "wheel" ];
  };

  # Enable sudo for wheel group
  security.sudo.enable = lib.mkDefault true;
}
