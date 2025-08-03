{
  description = "NixOS configuration with custom packages and overlays";

  # Flake inputs
  inputs = {
    # Core Nixpkgs repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # System extensions
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      # Mismatched system dependencies will lead to crashes
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming-specific inputs
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application-specific inputs
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # Home management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Theming inputs
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    catppuccin-nix = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      # Supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # User configuration
      userConfig = import ./user-config.nix { };
      
      # Extract commonly used values
      hostname = userConfig.host.hostname;
      username = userConfig.user.username;

      # Architecture-aware overlays
      mkOverlays = system: [
        # Custom packages overlay
        (final: prev: {
          # Rose Pine GTK theme
          rose-pine-gtk-theme-full = prev.callPackage ./overlays/rose-pine-gtk-theme-full.nix { };

          # Hyprshade 4.0.0 - Hyprland shade configuration tool
          # Updates shaders to GLES version 3.0, can auto-configure on schedule
          hyprshade = prev.python3Packages.callPackage ./overlays/hyprshade.nix {
            hyprland = prev.hyprland;
          };
        })

        # Import overlays
        (import ./overlays/zrok.nix)
        (import ./overlays/quickemu.nix)
      ];

      # Gaming configuration module
      # Integrates AAGL for gaming support (limited ARM64 support)
      mkGamingModule = system: {
        imports = [ inputs.aagl.nixosModules.default ];
        nix.settings = inputs.aagl.nixConfig;
        programs = {
          anime-game-launcher.enable = (system == "x86_64-linux");
          honkers-railway-launcher.enable = (system == "x86_64-linux");
        };
      };

      # Home Manager configuration module
      mkHomeManagerModule = system: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs system userConfig;
          };
          users.${username} = import ./home.nix;
          backupFileExtension = "bak2";
        };
      };

      # System configuration generator
      mkSystemConfig = system: userConfig: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs userConfig; };

        modules = [
          { nixpkgs.overlays = mkOverlays system; }

          # External modules
          inputs.chaotic.nixosModules.default
          inputs.home-manager.nixosModules.home-manager

          # Feature modules
          (mkGamingModule system)
          (mkHomeManagerModule system)
        ];
      };

      # Host-specific configuration generator
      mkHostConfig = hostname: system: hostConfigPath: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          { nixpkgs.overlays = mkOverlays system; }

          # Host-specific configuration
          hostConfigPath

          # External modules
          inputs.chaotic.nixosModules.default
          inputs.home-manager.nixosModules.home-manager

          # Feature modules
          (mkGamingModule system)
        ];
      };

    in
    {
      # Host-specific NixOS configurations
      nixosConfigurations = {
        popcat19-surface0 = mkHostConfig "popcat19-surface0" "x86_64-linux" ./hosts/surface0/configuration.nix;
        popcat19-nixos0 = mkHostConfig "popcat19-nixos0" "x86_64-linux" ./hosts/nixos0/configuration.nix;
      };
    };
}
