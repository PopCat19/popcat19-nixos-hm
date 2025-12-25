{
  # Host-specific configuration generator with centralized Home Manager
  mkHostConfig = hostname: system: hostConfigPath: homeConfigPath: {
    inputs,
    nixpkgs,
    modules,
    userConfig,
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs userConfig;};

      modules = [
        # Host-specific configuration file
        hostConfigPath

        # External modules
        inputs.chaotic.nixosModules.default
        inputs.home-manager.nixosModules.home-manager

        # Feature modules
        (modules.mkGamingModule system {inherit inputs;})

        # Home Manager configuration
        {
          home-manager = {
            useGlobalPkgs = false;
            useUserPackages = true;
            users.${userConfig.user.username} = {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = (import ./overlays.nix system) ++ [inputs.nur.overlays.default];
              imports = [ homeConfigPath ];
            };
            extraSpecialArgs = {
              hostPlatform = system;
              inherit userConfig inputs;
            };
          };
        }
      ];
    };
}