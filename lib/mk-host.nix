# mkHostConfiguration.nix
#
# Purpose: Creates NixOS system configurations with common base
#
# This module:
# - Wraps nixosSystem with standard configuration
# - Handles Home Manager integration
# - Passes userConfig and inputs via specialArgs
# - Conditionally enables gaming modules for gaming hosts
# - Merges host-specific config with global defaults
{ inputs }:
let
  overlays = import ../flake-modules/overlays.nix { inherit inputs; };

  # Global user config defaults
  globalUserConfig = import ../configuration/user-config.nix;

  # Gaming module only enabled for hosts with userConfig.gaming.enable = true
  mkGamingModule = userConfig: {
    imports = [ inputs.aagl.nixosModules.default ];
    nix.settings = inputs.aagl.nixConfig;
    programs = {
      anime-game-launcher.enable = userConfig.gaming.enable or false;
      honkers-railway-launcher.enable = userConfig.gaming.enable or false;
    };
  };
in
{
  mkHostConfiguration =
    _hostName: hostPath:
    let
      hostUserConfig = import (hostPath + "/user-config.nix");
      userConfig = globalUserConfig // hostUserConfig;
      inherit (userConfig) system;
    in
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs userConfig;
      };
      modules = [
        (hostPath + "/configuration.nix")
        inputs.home-manager.nixosModules.home-manager
        inputs.agenix.nixosModules.default
        (mkGamingModule userConfig)
        { nixpkgs.overlays = overlays; }
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            sharedModules = [
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = overlays;
              }
            ];
            users.${userConfig.username} = import (hostPath + "/home.nix");
            extraSpecialArgs = {
              hostPlatform = system;
              inherit inputs userConfig;
            };
          };
        }
      ];
    };
}
