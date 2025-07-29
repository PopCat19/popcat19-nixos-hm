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
      # **USER CONFIGURATION**
      # Import user configuration from user-config.nix
      userConfig = import ./user-config.nix;
      
      # Extract commonly used values for backward compatibility
      system = userConfig.host.system;
      hostname = userConfig.host.hostname;
      username = userConfig.user.username;

      # **CUSTOM OVERLAYS**
      # Overlays to add custom packages or modify existing ones.
      overlays = [
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

        # Import zrok overlay from separate file
        (import ./overlays/zrok.nix)

        # Import quickemu overlay from separate file
        (import ./overlays/quickemu.nix)

        # HyprPanel overlay for Hyprland panel components.
        # inputs.hyprpanel.overlay
      ];

      # **GAMING CONFIGURATION MODULE**
      # Integrates AAGL (Anime Game Launcher) for gaming support.
      gamingModule = {
        imports = [ inputs.aagl.nixosModules.default ];
        nix.settings = inputs.aagl.nixConfig;
        programs = {
          anime-game-launcher.enable = true;
          honkers-railway-launcher.enable = true;
        };
      };

      # **HOME MANAGER CONFIGURATION MODULE**
      # Manages user-specific configurations via Home Manager.
      homeManagerModule = {
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

    in
    {
      # **NIXOS SYSTEM CONFIGURATION**
      # Defines the primary NixOS system configuration.
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs userConfig; };

        modules = [
          # Apply custom overlays defined above.
          { nixpkgs.overlays = overlays; }

          # Core system configuration from configuration.nix.
          ./configuration.nix

          # External NixOS modules from flake inputs.
          inputs.chaotic.nixosModules.default
          inputs.home-manager.nixosModules.home-manager

          # Feature-specific modules.
          gamingModule
          homeManagerModule
        ];
      };
    };
}
