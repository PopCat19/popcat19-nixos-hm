# apollo.nix
#
# Purpose: Build Apollo game streaming server from source
#
# This derivation:
# - Fetches Apollo source from GitHub with submodules
# - Builds web UI with npm
# - Compiles with CMake and required dependencies
# - Supports optional CUDA acceleration
{
  lib,
  pkgs,
  cudaSupport ? false,
  cudaPackages ? pkgs.cudaPackages,
}:
let
  version = "master";
  rev = "5af771d29e986e3604cf74b51ac81cba5b0bd3ee";

  boostVersion = "1.88.0";
  boostCMakeTarballURL = "https://github.com/boostorg/boost/releases/download/boost-${boostVersion}/boost-${boostVersion}-cmake.tar.xz";

  boostFetchedTarball = pkgs.fetchurl {
    url = boostCMakeTarballURL;
    hash = "sha256-9ItIOQOAz7lKYphyNG46gTcNxJiJbxYBmt5yercusew=";
  };

  boostExtractedSrc =
    pkgs.runCommand "boost-${boostVersion}-cmake-src"
      {
        src = boostFetchedTarball;
        nativeBuildInputs = [
          pkgs.gnutar
          pkgs.xz
        ];
      }
      ''
        mkdir -p $out
        tar -xf $src --strip-components=1 -C $out
      '';

  src = pkgs.fetchFromGitHub {
    owner = "ClassicOldSong";
    repo = "Apollo";
    inherit rev;
    hash = "sha256-PWlXoYa6B7yVRwhS32uG51ktG11pifgzgVspchR/W1I=";
    fetchSubmodules = true;
  };

  ui = pkgs.buildNpmPackage {
    inherit src version;
    pname = "apollo-ui";
    npmDepsHash = "sha256-OM3LB8SUX5C5tnyb00amFtfePoLrRumLpAl05Ur9Rz4=";

    postPatch = ''
      cp ${/home/popcat19/apollo-flake/package-lock.json} ./package-lock.json
    '';

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

  stdenv' = if cudaSupport then cudaPackages.backendStdenv else pkgs.stdenv;
in
stdenv'.mkDerivation rec {
  pname = "apollo";
  inherit version src;

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
    pkgs.python3
    pkgs.makeWrapper
    pkgs.wayland-scanner
    pkgs.autoPatchelfHook
  ]
  ++ lib.optionals cudaSupport [
    pkgs.autoAddDriverRunpath
    cudaPackages.cuda_nvcc
    (lib.getDev cudaPackages.cuda_cudart)
  ];

  buildInputs = [
    pkgs.avahi
    pkgs.libevdev
    pkgs.libpulseaudio
    pkgs.xorg.libX11
    pkgs.xorg.libxcb
    pkgs.xorg.libXfixes
    pkgs.xorg.libXrandr
    pkgs.xorg.libXtst
    pkgs.xorg.libXi
    pkgs.openssl
    pkgs.libopus
    pkgs.libdrm
    pkgs.wayland
    pkgs.libffi
    pkgs.libcap
    pkgs.curl
    pkgs.pcre
    pkgs.pcre2
    pkgs.libuuid
    pkgs.libselinux
    pkgs.libsepol
    pkgs.libthai
    pkgs.libdatrie
    pkgs.xorg.libXdmcp
    pkgs.libxkbcommon
    pkgs.libepoxy
    pkgs.libva
    pkgs.libvdpau
    pkgs.numactl
    pkgs.libgbm
    pkgs.amf-headers
    pkgs.sysprof
    pkgs.glib
    pkgs.svt-av1
    (if pkgs.lib ? libappindicator then pkgs.libappindicator else pkgs.libappindicator-gtk3)
    pkgs.libnotify
    pkgs.miniupnpc
    pkgs.nlohmann_json
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cudatoolkit
    cudaPackages.cuda_cudart
  ];

  runtimeDependencies = [
    pkgs.avahi
    pkgs.libgbm
    pkgs.xorg.libXrandr
    pkgs.xorg.libxcb
    pkgs.libglvnd
  ];

  cmakeFlags = [
    "-Wno-dev"
    (lib.cmakeBool "UDEV_FOUND" true)
    (lib.cmakeBool "SYSTEMD_FOUND" true)
    (lib.cmakeFeature "UDEV_RULES_INSTALL_DIR" "lib/udev/rules.d")
    (lib.cmakeFeature "SYSTEMD_USER_UNIT_INSTALL_DIR" "lib/systemd/user")
    (lib.cmakeBool "BOOST_USE_STATIC" false)
    (lib.cmakeBool "BUILD_DOCS" false)
    (lib.cmakeFeature "SUNSHINE_PUBLISHER_NAME" "nixpkgs")
    (lib.cmakeFeature "SUNSHINE_PUBLISHER_WEBSITE" "https://nixos.org")
    (lib.cmakeFeature "SUNSHINE_PUBLISHER_ISSUE_URL" "https://github.com/NixOS/nixpkgs/issues")
    "-DFETCHCONTENT_SOURCE_DIR_BOOST=${boostExtractedSrc}"
  ]
  ++ lib.optionals (!cudaSupport) [
    (lib.cmakeBool "SUNSHINE_ENABLE_CUDA" false)
  ];

  env = {
    BUILD_VERSION = version;
    BRANCH = "master";
    COMMIT = rev;
  };

  postPatch = ''
    substituteInPlace cmake/packaging/linux.cmake \
      --replace-fail 'find_package(Systemd)' "" \
      --replace-fail 'find_package(Udev)' ""

    substituteInPlace cmake/targets/common.cmake \
      --replace-fail 'find_program(NPM npm REQUIRED)' ""

    substituteInPlace packaging/linux/dev.lizardbyte.app.Sunshine.desktop \
      --subst-var-by PROJECT_NAME 'Sunshine' \
      --subst-var-by PROJECT_DESCRIPTION 'Self-hosted game stream host for Moonlight' \
      --subst-var-by SUNSHINE_DESKTOP_ICON 'sunshine' \
      --subst-var-by CMAKE_INSTALL_FULL_DATAROOTDIR "$out/share" \
      --replace-fail '/usr/bin/env systemctl start --u sunshine' 'sunshine'

    substituteInPlace packaging/linux/sunshine.service.in \
      --subst-var-by PROJECT_DESCRIPTION 'Self-hosted game stream host for Moonlight' \
      --subst-var-by SUNSHINE_EXECUTABLE_PATH $out/bin/sunshine \
      --replace-fail '/bin/sleep' '${lib.getExe' pkgs.coreutils "sleep"}'
  '';

  preBuild = ''
    cp -r ${ui}/build ../
  '';

  buildFlags = [ "sunshine" ];

  postFixup = lib.optionalString cudaSupport ''
    wrapProgram $out/bin/sunshine \
      --set LD_LIBRARY_PATH ${lib.makeLibraryPath [ pkgs.vulkan-loader ]}
  '';

  installPhase = ''
    runHook preInstall
    cmake --install .
    runHook postInstall
  '';

  postInstall = ''
    install -Dm644 ../packaging/linux/dev.lizardbyte.app.Sunshine.desktop $out/share/applications/${pname}.desktop
  '';

  meta = with lib; {
    description = "Apollo - Sunshine fork for game streaming with native client resolution";
    homepage = "https://github.com/ClassicOldSong/Apollo";
    license = licenses.gpl3Only;
    mainProgram = "sunshine";
    platforms = platforms.linux;
  };
}
