# Zrok overlay - provides zrok package for secure tunneling
# https://github.com/openziti/zrok

final: prev:
let
  # Architecture-specific binary information
  archInfo = {
    "x86_64-linux" = {
      arch = "amd64";
      hash = "sha256-tQMPvUSd2J8iCX8QfHEv/k8DjXk3kUNzGMSRr2Gx2qU=";
    };
    "aarch64-linux" = {
      arch = "arm64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Placeholder - needs real hash
    };
  };
  
  currentArch = archInfo.${prev.stdenv.hostPlatform.system} or null;
  
in {
  zrok = if currentArch != null then prev.stdenv.mkDerivation rec {
    pname = "zrok";
    version = "1.0.7";

    src = prev.fetchurl {
      url = "https://github.com/openziti/zrok/releases/download/v${version}/zrok_${version}_linux_${currentArch.arch}.tar.gz";
      hash = currentArch.hash;
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
      description = "Geo-scale, next-generation sharing platform built on top of OpenZiti";
      homepage = "https://zrok.io";
      license = licenses.asl20;
      maintainers = with maintainers; [ ];
      platforms = [ "x86_64-linux" "aarch64-linux" ];
      sourceProvenance = with prev.lib.sourceTypes; [ binaryNativeCode ];
      mainProgram = "zrok";
    };
  } else
    # Fallback: build from source or provide a dummy package for unsupported architectures
    prev.stdenv.mkDerivation rec {
      pname = "zrok";
      version = "1.0.7";
      
      src = prev.fetchFromGitHub {
        owner = "openziti";
        repo = "zrok";
        rev = "v${version}";
        hash = "sha256-PLACEHOLDER"; # Would need real source hash
      };
      
      # This would require Go build setup - simplified for now
      buildPhase = ''
        echo "zrok binary not available for ${prev.stdenv.hostPlatform.system}"
        echo "Source build not implemented yet"
        exit 1
      '';
      
      meta = with prev.lib; {
        description = "Geo-scale, next-generation sharing platform built on top of OpenZiti (source build)";
        homepage = "https://zrok.io";
        license = licenses.asl20;
        maintainers = with maintainers; [ ];
        platforms = [ ];
        broken = true;
      };
    };
}