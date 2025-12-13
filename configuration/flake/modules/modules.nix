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
}