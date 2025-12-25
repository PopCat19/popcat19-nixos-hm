self: super: let
  pinnedNixpkgs =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/18dd725c29603f582cf1900e0d25f9f1063dbf11.tar.gz";
      sha256 = "sha256-awS2zRgF4uTwrOKwwiJcByDzDOdo3Q1rPZbiHQg/N38=";
    }) {
      hostPlatform = "x86_64-linux";
      config = {};
    };
in {
  rocmPackages = pinnedNixpkgs.rocmPackages;
}
