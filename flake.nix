# flake.nix
{
  description = "NixOS configuration with custom packages and overlays";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # System extensions
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    
    # Gaming
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Applications
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    
    # Desktop environment
    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Home management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Theming
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    catppuccin-nix = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # System configuration
      system = "x86_64-linux";
      hostname = "popcat19-nixos0";
      username = "popcat19";

      # Custom overlays
      overlays = [
        # zrok package overlay
        (final: prev: {
          zrok = prev.stdenv.mkDerivation rec {
            pname = "zrok";
            version = "1.0.4";

            src = prev.fetchurl {
              url = "https://github.com/openziti/zrok/releases/download/v${version}/zrok_${version}_linux_amd64.tar.gz";
              sha256 = "1fwhx2cdksfc44pqvcs84m6ykapghcqbh1b8zjyc3js3cf3ajwgd";
            };

            dontUnpack = true;
            nativeBuildInputs = [ prev.patchelf ];

            installPhase = ''
              runHook preInstall

              tar -xzf $src -C .
              mkdir -p $out/bin
              cp ./zrok $out/bin/zrok
              chmod +x $out/bin/zrok

              # Set correct ELF interpreter for NixOS
              patchelf --set-interpreter "$(< $NIX_CC/nix-support/dynamic-linker)" "$out/bin/zrok"

              runHook postInstall
            '';

            meta = with prev.lib; {
              description = "Geo-distributed, secure, and highly available sharing built on OpenZiti";
              homepage = "https://zrok.io/";
              license = licenses.asl20;
              mainProgram = "zrok";
              maintainers = [ maintainers.popcat19 ];
              platforms = [ "x86_64-linux" ];
              sourceProvenance = with sourceTypes; [ binaryNativeCode ];
            };
          };
        })
        
        # Add other overlays here
        inputs.hyprpanel.overlay
      ];

      # Gaming configuration module
      gamingModule = {
        imports = [ inputs.aagl.nixosModules.default ];
        nix.settings = inputs.aagl.nixConfig;
        programs = {
          anime-game-launcher.enable = true;
          anime-games-launcher.enable = true;
          honkers-railway-launcher.enable = true;
        };
      };

      # Home Manager configuration
      homeManagerModule = {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs system; };
          users.${username} = import ./home.nix;
          backupFileExtension = "bak2";
        };
      };

    in {
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          # Apply overlays
          { nixpkgs.overlays = overlays; }
          
          # Core configuration
          ./configuration.nix
          
          # External modules
          inputs.chaotic.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          
          # Feature modules
          gamingModule
          homeManagerModule
        ];
      };
    };
}
