final: prev: let
  stdenvNoCC = prev.stdenvNoCC;
  fetchFromGitHub = prev.fetchFromGitHub;
  lib = prev.lib;
in {
  rose-pine-kvantum = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "rose-pine-kvantum";
    version = "0-unstable-2025-04-16";

    src = fetchFromGitHub {
      owner = "rose-pine";
      repo = "kvantum";
      rev = "48edf9e2d772b166ed50af3e182a19196e5d3fe6";
      hash = "sha256-0xSMYYPsW7Rw5O8FL0iAt63Hya8GkI2VuOZf64PewyQ=";
    };

    dontBuild = true;
    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/Kvantum"
      # The upstream repo contains multiple .tar.gz theme archives.
      # Kvantum expects themes under share/Kvantum/<ThemeName>.
      # Extract all archives directly into $out/share/Kvantum.
      while IFS= read -r -d '' arch; do
        tar -xzf "$arch" -C "$out/share/Kvantum"
      done < <(find . -type f -name "*.tar.gz" -print0)

      runHook postInstall
    '';

    meta = with lib; {
      description = "Kvantum themes based on Rosé Pine";
      homepage = "https://github.com/rose-pine/kvantum";
      platforms = platforms.linux;
      maintainers = with maintainers; [ amadaluzia ];
      license = licenses.mit;
    };
  });
}