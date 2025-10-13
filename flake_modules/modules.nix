{
  # Gaming configuration module
  # Integrates AAGL for gaming support (limited ARM64 support)
  mkGamingModule = system: {inputs}: {
    imports = [inputs.aagl.nixosModules.default];
    nix.settings = inputs.aagl.nixConfig;
    programs = {
      anime-game-launcher.enable = system == "x86_64-linux";
      honkers-railway-launcher.enable = system == "x86_64-linux";
    };
  };

  # Home Manager configuration module
  mkHomeManagerModule = system: {
    userConfig,
    inputs,
    homePath,
  }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit system userConfig inputs;
      };
      users.${userConfig.user.username} = import homePath;
      backupFileExtension = "bak2";
    };
  };
}
