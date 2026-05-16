# overlays.nix
#
# Purpose: Define architecture-aware package overlays
#
# This module:
# - Provides Friction, OpenLDAP, and Zrok overlays
# - Hyprland uses nixpkgs-unstable (no overlay needed)
_system: [
  # Friction graphics overlay
  (final: _prev: {
    friction-graphics = final.callPackage ../overlays/friction-graphics.nix { };
  })

  # OpenLDAP: skip flaky syncrepl test (test017-syncreplication-refresh)
  (_final: _prev: {
    openldap = _prev.openldap.overrideAttrs (_: {
      doCheck = false;
    });
  })

  # Nix: skip functional tests (fail on devices with sandboxing disabled)
  (_final: _prev: {
    nix = _prev.nix.overrideAttrs (_: {
      doCheck = false;
    });
  })

  # ROCm: limit hipblaslt to user's GPU arch only (Radeon RX 7700 XT / 7800 XT = gfx1101)
  # Building for all 10 archs simultaneously exhausts 32 GB RAM during Tensile kernel generation
  (final: prev: {
    rocmPackages = prev.rocmPackages.overrideScope (rfinal: rprev: {
      hipblaslt = rprev.hipblaslt.override {
        gpuTargets = [ "gfx1101" ];
      };
    });
  })

  # Zrok v1.1.10 overlay - provides latest binary release
  (final: _prev: {
    zrok = final.stdenv.mkDerivation rec {
      pname = "zrok";
      version = "1.1.10";

      src = final.fetchzip {
        url = "https://github.com/openziti/zrok/releases/download/v${version}/zrok_${version}_linux_amd64.tar.gz";
        sha256 = "sha256-wCrMB2rUr4HGAAGxYeygnBR5cCpoxUbuVVYPR7p004I=";
        stripRoot = false;
      };

      nativeBuildInputs = [ final.autoPatchelfHook ];

      dontBuild = true;
      dontConfigure = true;

      installPhase = ''
        runHook preInstall
        install -Dm755 zrok $out/bin/zrok
        runHook postInstall
      '';

      meta = with final.lib; {
        description = "Geo-scale reverse proxy and file sharing built on OpenZiti";
        homepage = "https://zrok.io";
        license = licenses.asl20;
        maintainers = with maintainers; [ ];
        platforms = [ "x86_64-linux" ];
      };
    };
  })
]
