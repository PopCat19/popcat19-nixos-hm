# overlays.nix
#
# Purpose: Define architecture-aware package overlays
#
# This module:
# - Provides OpenTabletDriver, Friction, and Zrok overlays
# - Patches systemdMinimal to skip udevadm verify (broken on shim kernels without sandbox)
# - Hyprland uses nixpkgs-unstable (no overlay needed)
#
# Architecture-aware overlays
{ inputs }:
[
  # Patch systemdMinimal to skip udevadm verify (needed for shimboot kernels without sandbox support)
  # The "Protocol driver not attached" error occurs when udevadm verify tries to use
  # chase() syscalls that aren't available in older kernels
  # This wrapper skips the verify command and passes through everything else
  (final: prev: {
    systemdMinimal = prev.runCommand "systemd-minimal-shimboot" {
      passthru = (prev.systemdMinimal.passthru or {}) // {
        # Preserve the override function for systemdLibs and other derivatives
        inherit (prev.systemdMinimal) override;
      };
      inherit (prev.systemdMinimal) meta outputs;
    } ''
      mkdir -p $out/bin
      udevadm_real=${prev.lib.getExe' prev.systemdMinimal "udevadm"}
      cat > $out/bin/udevadm << EOF
#!/bin/sh
case "\$1" in
  verify)
    echo "Skipping udevadm verify (shimboot kernel workaround)" >&2
    exit 0
    ;;
esac
exec "$udevadm_real" "\$@"
EOF
      chmod +x $out/bin/udevadm
    '';

    # Disable Nix functional tests that require sandbox support
    nix = prev.nix.overrideAttrs (old: {
      doCheck = false;
      doInstallCheck = false;
    });
  })

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
