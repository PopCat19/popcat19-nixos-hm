# EasyEffects Pinning Overlay
#
# Purpose: Pin EasyEffects to nixpkgs 25.05 release version.
# Dependencies: nixpkgs
# Related: packages/system/gui.nix
#
# This module:
# - Pins EasyEffects package to nixpkgs 25.05 (commit 7284e2decc982b81a296ab35aa46e804baaa1cfe)
# - Provides stable version of EasyEffects from the 25.05 release
# - Overrides the default unstable EasyEffects with the pinned version

self: super: let
  # Nixpkgs 25.05 release version
  pinnedNixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/refs/tags/25.05.tar.gz";
    sha256 = "1915r28xc4znrh2vf4rrjnxldw2imysz819gzhk9qlrkqanmfsxd";
  }) {
    system = "x86_64-linux";
    config = {};
  };
in {
  # Override EasyEffects with the pinned version from nixpkgs 25.05
  easyeffects = pinnedNixpkgs.easyeffects;
}