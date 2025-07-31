{
  description = "NixOS configuration with custom packages and overlays";

  # **FLAKE INPUTS**
  # Defines all external flake inputs used in this configuration.
  inputs = {
    # Core Nixpkgs repository for system packages and modules.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # System extensions, offering a wider range of packages.
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming-specific inputs
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensure AAGL uses our Nixpkgs version.
    };

    # Application-specific inputs
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # Home management for user-specific configurations.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensure Home Manager uses our Nixpkgs version.
    };

    # Theming related inputs
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    catppuccin-nix = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensure Catppuccin uses our Nixpkgs version.
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
      # **SUPPORTED SYSTEMS**
      # Define supported architectures for crossplatform support
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # **USER CONFIGURATION**
      # Import user configuration from user-config.nix
      userConfig = import ./user-config.nix;
      
      # Extract commonly used values for backward compatibility
      hostname = userConfig.host.hostname;
      username = userConfig.user.username;

      # **ARCHITECTURE-AWARE OVERLAYS**
      # Overlays that adapt to different architectures
      mkOverlays = system: [
        # Custom packages overlay
        (final: prev: {
          # Rose Pine GTK theme from Fausto-Korpsvart with better styling
          rose-pine-gtk-theme-full = prev.callPackage ./overlays/rose-pine-gtk-theme-full.nix { };

          # Hyprshade 4.0.0 overlay - Hyprland shade configuration tool
          # Updates from nixpkgs version 3.2.1 to latest 4.0.0 release
          # Major changes in v4.0.0: Updated shaders to use GLES version 3.0
          # Can crawl and auto-configure screen shaders on schedule
          # Usage: hyprshade auto, hyprshade on <shader>, hyprshade toggle
          hyprshade = prev.python3Packages.callPackage ./overlays/hyprshade.nix {
            hyprland = prev.hyprland;
          };
        })

        # Import architecture-aware zrok overlay
        (import ./overlays/zrok.nix)

        # Import quickemu overlay from separate file
        (import ./overlays/quickemu.nix)

        # HyprPanel overlay for Hyprland panel components.
        # inputs.hyprpanel.overlay
      ];

      # **GAMING CONFIGURATION MODULE**
      # Integrates AAGL (Anime Game Launcher) for gaming support.
      # Note: AAGL may have limited ARM64 support
      mkGamingModule = system: {
        imports = [ inputs.aagl.nixosModules.default ];
        nix.settings = inputs.aagl.nixConfig;
        programs = {
          # Enable gaming launchers based on architecture support
          anime-game-launcher.enable = (system == "x86_64-linux");
          honkers-railway-launcher.enable = (system == "x86_64-linux");
        };
      };

      # **HOME MANAGER CONFIGURATION MODULE**
      # Manages user-specific configurations via Home Manager.
      mkHomeManagerModule = system: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs system userConfig;
          };
          users.${username} = import ./home.nix;
          backupFileExtension = "bak2"; # Custom backup file extension.
        };
      };

      # **SYSTEM CONFIGURATION GENERATOR**
      # Creates NixOS configuration for a specific architecture
      mkSystemConfig = system: userConfig: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs userConfig; };

        modules = [
          # Apply architecture-specific overlays
          { nixpkgs.overlays = mkOverlays system; }

          # Core system configuration from configuration.nix.
          ./configuration.nix

          # External NixOS modules from flake inputs.
          inputs.chaotic.nixosModules.default
          inputs.home-manager.nixosModules.home-manager

          # Feature-specific modules.
          (mkGamingModule system)
          (mkHomeManagerModule system)
        ];
      };

      # **HOST-SPECIFIC CONFIGURATION GENERATOR**
      # Creates NixOS configuration for a specific host with its own configuration files
      mkHostConfig = hostname: system: hostConfigPath: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          # Apply architecture-specific overlays
          { nixpkgs.overlays = mkOverlays system; }

          # Host-specific configuration
          hostConfigPath

          # External NixOS modules from flake inputs.
          inputs.chaotic.nixosModules.default
          inputs.home-manager.nixosModules.home-manager

          # Feature-specific modules.
          (mkGamingModule system)
          # Note: Home Manager is configured within the host-specific configuration
        ];
      };

    in
    {
      # **MULTI-ARCHITECTURE NIXOS CONFIGURATIONS**
      # Generate configurations for all supported systems
      nixosConfigurations = nixpkgs.lib.genAttrs supportedSystems (system:
        mkSystemConfig system userConfig
      ) // {
        # Keep the original hostname-based configuration for backward compatibility
        ${hostname} = mkSystemConfig userConfig.host.system userConfig;
        
        # Surface-specific configuration
        surface-nixos = mkHostConfig "surface-nixos" "x86_64-linux" ./hosts/surface/configuration.nix;
      };
    };
}
