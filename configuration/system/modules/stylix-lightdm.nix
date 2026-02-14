# stylix-lightdm.nix
#
# Purpose: Configure LightDM theming using Stylix framework
#
# This module:
# - Imports Stylix NixOS module for LightDM theming
# - Enables LightDM theming with wallpaper support
{ inputs, ... }:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix.targets.lightdm.enable = true;
  stylix.targets.lightdm.useWallpaper = true;
}
