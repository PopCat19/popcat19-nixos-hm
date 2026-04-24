# hosts.nix
#
# Purpose: Helper function to generate NixOS system configurations
#
# This module:
# - Provides mkHostConfig function for creating NixOS configurations
# - Handles Home Manager integration
# - Passes userConfig via specialArgs
{
  # Host-specific configuration generator with centralized Home Manager
  mkHostConfig =
    _hostname: system: hostConfigPath: homeConfigPath:
    {
      inputs,
      nixpkgs,
      modules,
      userConfig,
    }:
    nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs userConfig; };

      modules = [
        # Host-specific configuration file
        hostConfigPath

        # External modules
        inputs.home-manager.nixosModules.home-manager

        # Feature modules
        (modules.mkGamingModule system { inherit inputs; })

        # Home Manager configuration
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            sharedModules = [
              {
                nixpkgs.config.allowUnfree = true;
                nixpkgs.overlays = import ./overlays.nix system;
              }
            ];
            users.${userConfig.username} = import homeConfigPath;
            extraSpecialArgs = {
              hostPlatform = system;
              inherit userConfig inputs;
            };
          };
        }
      ];
    };
}
