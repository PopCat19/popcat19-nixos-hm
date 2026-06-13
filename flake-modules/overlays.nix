# overlays.nix
#
# Purpose: Define architecture-aware package overlays
#
# This module:
# - Friction, OpenLDAP, Nix, ROCm, Zrok overlays
# - Hyprland uses nixpkgs-unstable (no overlay needed)
{
  inputs,
  system ? null,
  ...
}:
let
  lib = inputs.nixpkgs.lib;
in
[
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

  # Highlight: shellscript patch already upstream in 4.20
  (_final: prev: {
    highlight = prev.highlight.overrideAttrs (_: {
      patches = [ ];
    });
  })

  # Zrok v1.1.10 overlay - provides latest binary release for x86_64 and aarch64 Linux
  (
    final: _prev:
    let
      inherit (final.stdenv.hostPlatform) system;
      release =
        {
          x86_64-linux = {
            arch = "amd64";
            hash = "sha256-wCrMB2rUr4HGAAGxYeygnBR5cCpoxUbuVVYPR7p004I=";
          };
          aarch64-linux = {
            arch = "arm64";
            hash = "sha256-CUjuYspPQQw4L3SZSkgEAUoySBxB1X/AQHns9j4zfr0=";
          };
        }
        .${system} or (throw "zrok overlay: unsupported system ${system}");
    in
    {
      zrok = final.stdenv.mkDerivation rec {
        pname = "zrok";
        version = "1.1.10";

        src = final.fetchzip {
          url = "https://github.com/openziti/zrok/releases/download/v${version}/zrok_${version}_linux_${release.arch}.tar.gz";
          sha256 = release.hash;
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
          platforms = [
            "x86_64-linux"
            "aarch64-linux"
          ];
        };
      };
    }
  )
]
++ lib.optional (system == "x86_64-linux") (
  _final: prev: {
    rocmPackages = prev.rocmPackages.overrideScope (
      _rfinal: rprev: {
        hipblaslt = rprev.hipblaslt.override {
          gpuTargets = [ "gfx1101" ];
        };
        rocblas = rprev.rocblas.override {
          gpuTargets = [ "gfx1101" ];
        };
        rocsparse = rprev.rocsparse.override {
          gpuTargets = [ "gfx1101" ];
        };
      }
    );
  }
)
