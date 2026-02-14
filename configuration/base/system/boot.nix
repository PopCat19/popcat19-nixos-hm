# boot.nix
#
# Purpose: Minimal bootloader configuration
#
# This module:
# - Configures systemd-boot
# - Sets up EFI boot variables
{ lib, ... }:
{
  boot.loader = {
    efi.canTouchEfiVariables = lib.mkDefault true;
    systemd-boot = {
      configurationLimit = lib.mkDefault 5;
      enable = lib.mkDefault true;
    };
    timeout = lib.mkDefault 3;
  };
}
