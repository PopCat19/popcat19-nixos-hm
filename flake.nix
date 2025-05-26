# flake.nix
{
  description = "nixos config with som stuff idk";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # IMPORTANT
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl.inputs.nixpkgs.follows = "nixpkgs";

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # === Add/Uncomment Home Manager Input ===
    home-manager = {
      url = "github:nix-community/home-manager"; # You can specify a release branch here if desired, e.g., /release-24.05
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
    };
  };

  outputs = { self, nixpkgs, hyprpanel, aagl, chaotic, home-manager, ... }@inputs: let # Add home-manager here
    system = "x86_64-linux";
    myHostname = "popcat19-nixos0";

  in {
    nixosConfigurations."${myHostname}" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; }; # Pass all flake inputs

      modules = [
        {
          nixpkgs.overlays = [ inputs.hyprpanel.overlay ];
          imports = [ aagl.nixosModules.default ];
          nix.settings = aagl.nixConfig;
          programs.anime-game-launcher.enable = true;
          programs.anime-games-launcher.enable = true;
          programs.honkers-railway-launcher.enable = true;
        }
        ./configuration.nix
        chaotic.nixosModules.default

        # === Add Home Manager NixOS Module ===
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs; };
            users.popcat19 = import ./home.nix;
            backupFileExtension = "hm-bak"; # <--- ADD THIS LINE
          };
        }
      ];
    };
  };
}
