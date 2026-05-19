# default.nix
#
# Purpose: nix-on-droid configuration for Android
#
# This module:
# - Imports the nix-on-droid profile
{ ... }:
{
  imports = [
    ../../profiles/nix-on-droid.nix
  ];
}
