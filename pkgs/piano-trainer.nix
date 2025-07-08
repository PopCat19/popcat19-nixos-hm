{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, nodejs
, pnpm
, pkg-config
, wrapGAppsHook3
, alsa-lib
, libjack2
, portmidi
, gtk3
, webkitgtk_4_1
, libayatana-appindicator
, openssl
, libsoup_3
}:

let
  pname = "piano-trainer";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ZaneH";
    repo = "piano-trainer";
    rev = "main";
    hash = "sha256-fMGOdccuHRMd94HNCZFu+qFLqyIpEcfkLA8yOyAYX58=";
  };

  # Frontend dependencies
  frontend = stdenv.mkDerivation {
    pname = "${pname}-frontend";
    inherit version src;

    nativeBuildInputs = [
      nodejs
      pnpm.configHook
    ];

    pnpmDeps = pnpm.fetchDeps {
      inherit pname version src;
      hash = "sha256-RwDfaG89bVHxDp3CErjtLHsRze3g+7kdHPSavdv5Ur8=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r build $out
      runHook postInstall
    '';
  };

in rustPlatform.buildRustPackage {
  inherit pname version src;

  sourceRoot = "${src.name}/src-tauri";

  cargoHash = "sha256-4waOMTqUF7HTLCQ42pOWOZf8I8xhZZoGNaNk8slaZQU=";

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    # MIDI support dependencies
    alsa-lib
    libjack2
    portmidi
    
    # Tauri/GTK dependencies
    gtk3
    webkitgtk_4_1
    libayatana-appindicator
    openssl
    libsoup_3
  ];

  # Copy frontend build to expected location
  postUnpack = ''
    chmod -R +w source
    cp -r ${frontend} source/build
  '';

  # Configure environment for MIDI support
  env = {
    PKG_CONFIG_PATH = lib.makeSearchPath "lib/pkgconfig" [
      alsa-lib
      libjack2
      portmidi
    ];
  };


  meta = with lib; {
    description = "A desktop application for learning piano scales and chords with MIDI support";
    longDescription = ''
      Piano Trainer is a Tauri-based desktop application that helps users learn piano
      scales and chords. It features MIDI hardware support for real-time interaction
      with piano keyboards and provides an interactive learning experience.
    '';
    homepage = "https://github.com/ZaneH/piano-trainer";
    license = licenses.mit; # Assuming MIT license, should be verified
    maintainers = [ ]; # Add maintainer info if desired
    platforms = platforms.linux ++ platforms.darwin ++ platforms.windows;
    mainProgram = "piano-trainer";
  };
}