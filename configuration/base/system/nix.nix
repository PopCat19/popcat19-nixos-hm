# nix.nix
#
# Purpose: Minimal Nix configuration for flakes
#
# This module:
# - Enables flakes and nix-command
# - Configures basic Nix settings
{ lib, userConfig, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "${userConfig.username}"
    ];
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
