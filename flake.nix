# flake.nix
{
  description = "nixos config with som stuff idk";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable"; # IMPORTANT
    aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    aagl.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

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

    # === Define your custom overlay for zrok ===
        my-overlays = final: prev: {
          zrok = prev.stdenv.mkDerivation rec {
            pname = "zrok";
            version = "1.0.4"; # The new version you want
    
            src = prev.fetchurl {
              # URL for the x86_64 Linux binary
              url = "https://github.com/openziti/zrok/releases/download/v${version}/zrok_${version}_linux_amd64.tar.gz";
              # IMPORTANT: Replace this with the hash you got from nix-prefetch-url
              sha256 = "1fwhx2cdksfc44pqvcs84m6ykapghcqbh1b8zjyc3js3cf3ajwgd";
            };

            dontUnpack = true; # Tell Nix not to run its default unpackPhase

            # We need patchelf to set the interpreter, similar to the nixpkgs version
            nativeBuildInputs = [ prev.patchelf ];
    
            installPhase = ''
              runHook preInstall
    
              # Extract the tarball (fetchurl just downloads it)
              # The zrok binary is at the root of this tarball
              tar -xzf $src -C .
    
              mkdir -p $out/bin
              cp ./zrok $out/bin/zrok
              chmod +x $out/bin/zrok
    
              # Set the correct ELF interpreter for NixOS
              # $NIX_CC is an environment variable available during the build
              # that points to the compiler wrapper, which has nix-support files.
              patchelf --set-interpreter "$(< $NIX_CC/nix-support/dynamic-linker)" "$out/bin/zrok"
    
              runHook postInstall
            '';
    
            meta = with prev.lib; {
              description = "Geo-distributed, secure, and highly available sharing built on OpenZiti";
              homepage = "https://zrok.io/";
              license = licenses.asl20; # zrok uses Apache License 2.0
              mainProgram = "zrok";
              # You are the maintainer of this overlay in your config
              maintainers = [ maintainers.popcat19 ]; # Or your GitHub username
              platforms = [ "x86_64-linux" ]; # Define for which platform this binary is
              sourceProvenance = with sourceTypes; [ binaryNativeCode ]; # It's a pre-compiled binary
            };
          };
    
          # You could add other package overrides here if needed in the future
          # another-package = prev.another-package.overrideAttrs (oldAttrs: { ... });
        };

  in {
    nixosConfigurations."${myHostname}" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; }; # Pass all flake inputs

      modules = [
        {
          nixpkgs.overlays = [ my-overlays inputs.hyprpanel.overlay ];
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
            extraSpecialArgs = { inherit inputs system; };
            users.popcat19 = import ./home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };
  };
}
