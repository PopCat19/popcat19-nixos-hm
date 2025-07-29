# Zrok overlay - provides zrok package for secure tunneling
# https://github.com/openziti/zrok

final: prev: {
  zrok = prev.stdenv.mkDerivation rec {
    pname = "zrok";
    version = "1.0.7";

    src = prev.fetchurl {
      url = "https://github.com/openziti/zrok/releases/download/v${version}/zrok_${version}_linux_amd64.tar.gz";
      hash = "sha256-tQMPvUSd2J8iCX8QfHEv/k8DjXk3kUNzGMSRr2Gx2qU=";
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
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with prev.lib.sourceTypes; [ binaryNativeCode ];
      mainProgram = "zrok";
    };
  };
}