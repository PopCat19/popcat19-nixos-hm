# NixOS Configuration Flake
#
# Purpose: Main flake entry point for NixOS configuration
# Dependencies: nixpkgs, home-manager, and various external inputs
# Related: selected-profile.nix, profiles/*/user-config.nix
#
# This flake:
# - Reads selected-profile.nix to determine active profile
# - Loads user configuration from the selected profile
# - Builds NixOS configurations using the profile-based structure
# - Passes userConfig and selectedProfile via specialArgs
{
  description = "NixOS configuration with custom packages and overlays";

  # Flake inputs
  inputs = {
    # Core Nixpkgs repository
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System extensions

    # Jovian NixOS (Steam Deck OS)
    jovian = {
      url = "github:Jovian-Experiments/jovian-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Gaming-specific inputs
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application-specific inputs
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming inputs
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";

    # Noctalia Shell (Wayland bar/launcher)
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix theming framework
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal Material Design (PMD) theme system
    pmd = {
      url = "github:popcat19/project-minimalist-design/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Vicinae launcher
    vicinae.url = "github:vicinaehq/vicinae";

    # LLM Agents
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zrok tunneling service
    zrok = {
      url = "github:openziti/zrok/v1.1.10";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      # Import helper modules
      overlays = import ./configuration/flake/modules/overlays.nix;

      # Supported systems
      supportedSystems = [ "x86_64-linux" ];

      # Profile selection - read from selected-profile.nix
      profileConfig = import ./selected-profile.nix;
      selectedProfile = profileConfig.profile;

      # Validate profile exists
      validProfiles = [ "nixos0" "surface0" "thinkpad0" ];
      isValidProfile = builtins.elem selectedProfile validProfiles;

      # Profile paths - constructed based on selected profile
      profilePath = ./profiles + "/${selectedProfile}";
      userConfigPath = profilePath + "/user-config.nix";
      configPath = profilePath + "/main_configuration/configuration.nix";
      homePath = profilePath + "/main_configuration/home/home.nix";

      # Load user configuration from the selected profile
      userConfig = import userConfigPath { };

      # Extract host information
      inherit (userConfig.host) system hostname;

      # Gaming module factory (AAGL integration)
      mkGamingModule = system: { inputs }: {
        imports = [ inputs.aagl.nixosModules.default ];
        nix.settings = inputs.aagl.nixConfig;
        programs = {
          anime-game-launcher.enable = system == "x86_64-linux";
          honkers-railway-launcher.enable = system == "x86_64-linux";
        };
      };
    in
    {
      # Packages output
      packages = nixpkgs.lib.genAttrs supportedSystems (system: {
        # Export agenix for secret management
        agenix = inputs.agenix.packages.${system}.default;
      });

      # Formatter for 'nix fmt'
      formatter = nixpkgs.lib.genAttrs supportedSystems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      # NixOS configuration for the selected profile
      # The hostname is derived from userConfig (e.g., popcat19-nixos0)
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs userConfig selectedProfile;
        };

        modules = [
          # Profile's main configuration
          configPath

          # External modules
          inputs.home-manager.nixosModules.home-manager

          # Gaming module (AAGL)
          (mkGamingModule system { inherit inputs; })

          # Home Manager configuration
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
              users.${userConfig.user.username} = import homePath;
              extraSpecialArgs = {
                hostPlatform = system;
                inherit inputs userConfig selectedProfile;
              };
            };
          }
        ];
      };
    };
}
