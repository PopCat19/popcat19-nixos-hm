# Quickemu overlay - provides quickemu package for quick VM creation
# https://github.com/quickemu-project/quickemu

final: prev: {
  quickemu = prev.stdenv.mkDerivation rec {
    pname = "quickemu";
    version = "4.9.7";

    src = prev.fetchFromGitHub {
      owner = "quickemu-project";
      repo = "quickemu";
      rev = version;
      hash = "sha256-sCoCcN6950pH33bRZsLoLc1oSs5Qfpj9Bbywn/uA6Bc=";
    };

    nativeBuildInputs = with prev; [
      makeWrapper
      installShellFiles
    ];

    buildInputs = with prev; [
      bash
      coreutils
      gawk
      gnugrep
      gnused
      procps
      python3
      socat
      spice-gtk
      swtpm
      unzip
      util-linux
      wget
      xorg.xrandr
      zsync
    ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      
      install -Dm755 quickemu $out/bin/quickemu
      install -Dm755 quickget $out/bin/quickget
      install -Dm755 chunkcheck $out/bin/chunkcheck
      install -Dm755 quickreport $out/bin/quickreport
      
      installManPage docs/quickemu.1 docs/quickget.1 docs/quickemu_conf.5
      
      # Wrap binaries to ensure dependencies are available
      for bin in quickemu quickget chunkcheck quickreport; do
        wrapProgram $out/bin/$bin \
          --prefix PATH : ${prev.lib.makeBinPath buildInputs}
      done
      
      runHook postInstall
    '';

    meta = with prev.lib; {
      description = "Quickly create and run optimised Windows, macOS and Linux desktop virtual machines";
      homepage = "https://github.com/quickemu-project/quickemu";
      license = licenses.mit;
      maintainers = with maintainers; [ ];
      platforms = platforms.linux;
      mainProgram = "quickemu";
    };
  };
}