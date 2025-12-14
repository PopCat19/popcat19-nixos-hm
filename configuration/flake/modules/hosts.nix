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
        # Overlays plus NUR
        {nixpkgs.overlays = (import ./overlays.nix system) ++ [inputs.nur.overlays.default];}

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
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${userConfig.user.username} = import homeConfigPath;
            extraSpecialArgs = {
              inherit system userConfig inputs;
            };
          };
        }
      ];
    };
}