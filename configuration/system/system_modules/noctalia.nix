# noctalia.nix
#
# Purpose: Enable Noctalia shell globally for Wayland systems
#
# This module:
# - Imports and enables the Noctalia NixOS module
# - Provides global configuration for all Wayland systems
{ inputs, ... }:
{
  imports = [
    inputs.noctalia.nixosModules.default
  ];
}
