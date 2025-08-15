{
  lib,
  stdenv,
  fetchurl,
  protobuf,
  qt6,
  cmark-gfm,
  kdePackages,
  libqalculate,
  minizip,
  qt6Packages,
  rapidfuzz-cpp,
  autoPatchelfHook,
}:

stdenv.mkDerivation {
  pname = "vicinae";
  version = "0.0.5";

  src = fetchurl {
    url = "https://github.com/vicinaehq/vicinae/releases/download/v0.0.5/vicinae-linux-x86_64-v0.0.4.tar.gz";
    sha256 = "sha256-orUy3gGvd+e3MF9Zw+0yreukXKi7531Ke+9MvTG/5lU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    cmark-gfm
    kdePackages.layer-shell-qt
    libqalculate
    minizip
    qt6Packages.qtkeychain
    rapidfuzz-cpp
    protobuf
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    
    # Install the binary
    install -Dm755 bin/vicinae $out/bin/vicinae
    
    # Install the desktop file if it exists
    if [ -f "com.vicinaehq.Vicinae.desktop" ]; then
      install -Dm644 com.vicinaehq.Vicinae.desktop $out/share/applications/com.vicinaehq.Vicinae.desktop
    elif [ -f "bin/com.vicinaehq.Vicinae.desktop" ]; then
      install -Dm644 bin/com.vicinaehq.Vicinae.desktop $out/share/applications/com.vicinaehq.Vicinae.desktop
    fi
    
    # Install the icon if it exists
    if [ -f "com.vicinaehq.Vicinae.svg" ]; then
      install -Dm644 com.vicinaehq.Vicinae.svg $out/share/icons/hicolor/scalable/apps/com.vicinaehq.Vicinae.svg
    elif [ -f "bin/com.vicinaehq.Vicinae.svg" ]; then
      install -Dm644 bin/com.vicinaehq.Vicinae.svg $out/share/icons/hicolor/scalable/apps/com.vicinaehq.Vicinae.svg
    fi
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "High-performance native launcher for Linux";
    homepage = "https://github.com/vicinaehq/vicinae";
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}