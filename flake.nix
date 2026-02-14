# flake.nix
#
# Purpose: Main flake entry point for NixOS multi-host configuration
#
# This module:
# - Auto-discovers hosts from the hosts/ directory
# - Builds nixosConfigurations for each host
# - Passes userConfig via specialArgs to all modules
{
  description = "NixOS multi-host configuration with profile presets";

  inputs = {
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/jovian-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pmd = {
      url = "github:popcat19/project-minimalist-design/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vicinae.url = "github:vicinaehq/vicinae";

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # libgbm is only available in unstable
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zrok = {
      url = "github:openziti/zrok/v1.1.10";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      overlays = import ./configuration/flake/modules/overlays.nix;
      supportedSystems = [ "x86_64-linux" ];

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

      hostsDir = ./configuration/hosts;
      hostEntries = builtins.readDir hostsDir;
      hostDirs = nixpkgs.lib.filterAttrs (_: type: type == "directory") hostEntries;

      mkHostConfiguration =
        hostName: _:
        let
          hostPath = hostsDir + "/${hostName}";
          userConfig = import (hostPath + "/user-config.nix");
          inherit (userConfig) system;
        in
        nixpkgs.lib.nixosSystem {
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
      packages = nixpkgs.lib.genAttrs supportedSystems (system: {
        agenix = inputs.agenix.packages.${system}.default;
      });

      formatter = nixpkgs.lib.genAttrs supportedSystems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      nixosConfigurations = builtins.mapAttrs mkHostConfiguration hostDirs;
    };
}
