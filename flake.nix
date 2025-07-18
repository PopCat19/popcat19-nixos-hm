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

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # **SYSTEM DEFINITIONS**
      # Basic system parameters for configuration.
      system = "x86_64-linux";
      hostname = "popcat19-nixos0";
      username = "popcat19";

      # **CUSTOM OVERLAYS**
      # Overlays to add custom packages or modify existing ones.
      overlays = [
        # Custom packages overlay
        (final: prev: {
          # Rose Pine GTK theme from Fausto-Korpsvart with better styling
          rose-pine-gtk-theme-full = prev.callPackage ./pkgs/rose-pine-gtk-theme-full.nix { };

          # zrok package overlay: adds a custom build for the zrok application.
          zrok = prev.stdenv.mkDerivation rec {
            pname = "zrok";
            version = "1.0.6";

            src = prev.fetchurl {
              url = "https://github.com/openziti/zrok/releases/download/v${version}/zrok_${version}_linux_amd64.tar.gz";
              sha256 = "2821fc2faeaeff7f5f9b04ba5b56160d2f3e5c17ffa487b7921e8d1fd01d684c";
            };

            dontUnpack = true;
            nativeBuildInputs = [ prev.patchelf ];

            installPhase = ''
              runHook preInstall

              tar -xzf $src -C .
              mkdir -p $out/bin
              cp ./zrok $out/bin/zrok
              chmod +x $out/bin/zrok

              # Set correct ELF interpreter for NixOS.
              patchelf --set-interpreter "$(< $NIX_CC/nix-support/dynamic-linker)" "$out/bin/zrok"

              runHook postInstall
            '';

            meta = with prev.lib; {
              description = "Geo-distributed, secure, and highly available sharing built on OpenZiti";
              homepage = "https://zrok.io/";
              license = prev.lib.licenses.asl20;
              mainProgram = "zrok";
              maintainers = with prev.lib.maintainers; [ popcat19 ];
              platforms = [ "x86_64-linux" ];
              sourceProvenance = with prev.lib.sourceTypes; [ binaryNativeCode ];
            };
          };
        })

        # Patch quickemu to correctly handle version 10.0.0 of QEMU
        (final: prev: {
          quickemu = prev.quickemu.overrideAttrs {
            patches = [
              (prev.fetchpatch {
                name = "correctly-handle-version-10.0.0-of-qemu.patch";
                url = "https://github.com/quickemu-project/quickemu/commit/f25205f4513c4fa72be6940081c62e613d1fddc6.patch";
                hash = "sha256-OAXGyhMVDwbUypEPj/eRnH0wZYaL9WLGjbyoobe20UY=";
              })
            ];
          };
        })

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
          extraSpecialArgs = { inherit inputs system; };
          users.${username} = import ./home.nix;
          backupFileExtension = "bak2"; # Custom backup file extension.
        };
      };

    in {
      # **NIXOS SYSTEM CONFIGURATION**
      # Defines the primary NixOS system configuration.
      nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

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
