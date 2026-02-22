# mkHost.nix
#
# Purpose: Creates NixOS system configurations with common base
#
# This module:
# - Wraps nixosSystem with standard configuration
# - Handles Home Manager integration
# - Passes userConfig and inputs via specialArgs
{ inputs }:
let
  overlays = import ../flake-modules/overlays.nix { inherit inputs; };

  mkGamingModule = system: {
    imports = [ inputs.aagl.nixosModules.default ];
    nix.settings = inputs.aagl.nixConfig;
    programs = {
      anime-game-launcher.enable = system == "x86_64-linux";
      honkers-railway-launcher.enable = system == "x86_64-linux";
    };
  };
in
{
  mkHostConfiguration =
    _hostName: hostPath:
    let
      userConfig = import (hostPath + "/user-config.nix");
      inherit (userConfig) system;
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs userConfig;
      };
      modules = [
        (hostPath + "/configuration.nix")
        inputs.home-manager.nixosModules.home-manager
        (mkGamingModule system)
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
