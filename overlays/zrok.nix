# Zrok overlay - provides zrok package for secure tunneling
# https://github.com/openziti/zrok

final: prev: {
  zrok = prev.buildGoModule rec {
    pname = "zrok";
    version = "1.0.7";

    src = prev.fetchFromGitHub {
      owner = "openziti";
      repo = "zrok";
      rev = "v${version}";
      hash = "sha256-IY9eZyEm8cAixt+Vwr50UVjrA31cHfm715zpqdMieUs=";
    };

    vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will be updated during build

    subPackages = [ "cmd/zrok" ];

    ldflags = [
      "-s"
      "-w"
      "-X github.com/openziti/zrok/build.Version=${version}"
    ];

    meta = with prev.lib; {
      description = "Geo-scale, next-generation sharing platform built on top of OpenZiti";
      homepage = "https://zrok.io";
      license = licenses.asl20;
      maintainers = with maintainers; [ ];
      platforms = platforms.unix;
      mainProgram = "zrok";
    };
  };
}