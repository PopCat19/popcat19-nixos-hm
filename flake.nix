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

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      # Import modules
      modules = import ./flake_modules/modules.nix;
      hosts = import ./flake_modules/hosts.nix;
      
      # Supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      
      # User configuration
      userConfig = import ./user-config.nix { };
      
      # Extract commonly used values
      hostname = userConfig.host.hostname;
      username = userConfig.user.username;

    in
    {
      # Host-specific NixOS configurations
      nixosConfigurations = {
        popcat19-surface0 = hosts.mkHostConfig "popcat19-surface0" "x86_64-linux" ./hosts/surface0/configuration.nix {
          inherit inputs nixpkgs modules;
        };
        popcat19-nixos0 = hosts.mkHostConfig "popcat19-nixos0" "x86_64-linux" ./hosts/nixos0/configuration.nix {
          inherit inputs nixpkgs modules;
        };
      };
    };
}
