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
  }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit system userConfig inputs;
      };
      users.${userConfig.user.username} = import ../home.nix;
      # Change backup extension to avoid clobbering pre-existing backups during HM switch
      backupFileExtension = "backup";
    };
  };
}
