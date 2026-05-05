# overlays.nix
#
# Purpose: Define architecture-aware package overlays
#
# This module:
# - Provides OpenTabletDriver, Friction, and Zrok overlays
# - Hyprland uses nixpkgs-unstable (no overlay needed)
{ inputs }:
[
  # OpenTabletDriver git latest overlay
  (final: _prev: {
    opentabletdriver = final.callPackage ../overlays/opentabletdriver-git.nix {
      src = inputs.opentabletdriver;
    };
  })

  # Friction graphics overlay
  (final: _prev: {
    friction-graphics = final.callPackage ../overlays/friction-graphics.nix { };
  })

  # OpenLDAP: skip flaky syncrepl test
  (final: _prev: {
    openldap = _prev.openldap.overrideAttrs (_: {
      doCheck = false;
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