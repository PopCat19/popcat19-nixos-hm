{
  description = "NixOS configuration with custom packages and overlays";

  # Flake inputs
  inputs = {
    # Core Nixpkgs repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nix User Repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System extensions
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Jovian NixOS (Steam Deck OS)
    jovian = {
      url = "github:Jovian-Experiments/jovian-nixos";
      inputs.nixpkgs.follows = "chaotic";
    };

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

    # Hardware-specific configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Theming inputs
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    catppuccin-nix = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    # Import modules
    modules = import ./configuration/flake/flake_modules/modules.nix;
    hosts = import ./configuration/flake/flake_modules/hosts.nix;

    # Supported systems
    supportedSystems = ["x86_64-linux"];

    # Base user configuration
    baseUserConfig = import ./lib/user-config.nix {};
  in {
    # Packages output (no vicinae now that the overlay was removed)
    packages = nixpkgs.lib.genAttrs supportedSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = import ./configuration/flake/flake_modules/overlays.nix system;
        };
      in {
        # Export agenix for secret management
        agenix = inputs.agenix.packages.${system}.default;
      }
    );

    # Formatter for 'nix fmt'
    formatter = nixpkgs.lib.genAttrs supportedSystems (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
    # Host-specific NixOS configurations generated dynamically
    # Keyed by derived hostname e.g. popcat19-nixos0, popcat19-surface0, popcat19-thinkpad0
    nixosConfigurations = let
      machines = baseUserConfig.hosts.machines;
    in
      nixpkgs.lib.listToAttrs (map (m: let
          perHostConfig = import ./lib/user-config.nix {
            username = baseUserConfig.user.username;
            machine = m;
            system = "x86_64-linux";
          };
          hostname = perHostConfig.host.hostname;
        in {
          name = hostname;
          value = hosts.mkHostConfig hostname "x86_64-linux" ./hosts/${m}/configuration.nix ./hosts/${m}/home.nix {
            inherit inputs nixpkgs modules;
            userConfig = perHostConfig;
          };
        })
        machines);
  };
}