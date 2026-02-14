# home-manager.nix
#
# Purpose: Centralized Home Manager configuration
#
# This module:
# - Configures home-manager settings
# - Sets up shared modules and overlays
{ inputs, userConfig, ... }:
{
  home-manager = {
    useGlobalPkgs = false;
    useUserPackages = true;
    sharedModules = [
      {
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [ inputs.nur.overlays.default ];
      }
    ];
    extraSpecialArgs = {
      inherit inputs userConfig;
    };
  };
}
