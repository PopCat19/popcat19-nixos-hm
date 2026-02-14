# nixos.nix
#
# Purpose: NixOS configuration module for flake-parts
#
# This module:
# - Auto-discovers hosts from the configuration/hosts/ directory
# - Builds nixosConfigurations for each host
# - Passes userConfig via specialArgs to all modules
{ inputs, ... }:
let
  overlays = import ../configuration/flake/modules/overlays.nix;

  mkGamingModule =
    system:
    { inputs }:
    {
      imports = [ inputs.aagl.nixosModules.default ];
      nix.settings = inputs.aagl.nixConfig;
      programs = {
        anime-game-launcher.enable = system == "x86_64-linux";
        honkers-railway-launcher.enable = system == "x86_64-linux";
      };
    };

  hostsDir = ../configuration/hosts;
  hostEntries = builtins.readDir hostsDir;
  hostDirs = inputs.nixpkgs.lib.filterAttrs (_: type: type == "directory") hostEntries;

  mkHostConfiguration =
    hostName: _:
    let
      hostPath = hostsDir + "/${hostName}";
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
        (mkGamingModule system { inherit inputs; })
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            sharedModules = [
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = (overlays system) ++ [ inputs.nur.overlays.default ];
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
in
{
  flake.nixosConfigurations = builtins.mapAttrs mkHostConfiguration hostDirs;
}
