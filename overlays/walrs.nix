{ lib
, rustPlatform
, fetchFromGitHub
, bash
}:

rustPlatform.buildRustPackage rec {
  pname = "walrs";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "pixel2175";
    repo = "walrs";
    rev = "v${version}";
    sha256 = "sha256-fmiOuxCZoCPOx6OE7YB2pJBegk3y88a9ByDEW/b79Rw=";
  };

  cargoHash = "sha256-fmiOuxCZoCPOx6OE7YB2pJBegk3y88a9ByDEW/b79Rw=";

  nativeBuildInputs = [ bash ];

  preBuild = ''
    export RUSTC_BOOTSTRAP=1
  '';

  meta = with lib; {
    description = "walrs - Generate colorscheme from image";
    homepage = "https://github.com/pixel2175/walrs";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}