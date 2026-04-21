# hardware-configuration.nix
#
# Purpose: Minimal hardware configuration for shimboot dedede board
{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
