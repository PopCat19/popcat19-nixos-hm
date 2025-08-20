{
  # System configuration generator
  mkSystemConfig = system: userConfig: { inputs, nixpkgs, modules }:
  nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs userConfig; };

    modules = [
      { nixpkgs.overlays = (import ./overlays.nix system) ++ [ inputs.nur.overlays.default ]; }

      # External modules
      inputs.chaotic.nixosModules.default
      inputs.home-manager.nixosModules.home-manager

      # Feature modules
      (modules.mkGamingModule system { inherit inputs; })
      (modules.mkHomeManagerModule system { 
        inherit userConfig;
        username = userConfig.user.username;
      })
    ];
  };

  # Host-specific configuration generator
  mkHostConfig = hostname: system: hostConfigPath: { inputs, nixpkgs, modules }:
  nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };

    modules = [
      { nixpkgs.overlays = (import ./overlays.nix system) ++ [ inputs.nur.overlays.default ]; }

      # Host-specific configuration
      hostConfigPath

      # External modules
      inputs.chaotic.nixosModules.default
      inputs.home-manager.nixosModules.home-manager

      # Feature modules
      (modules.mkGamingModule system { inherit inputs; })
    ];
  };
}