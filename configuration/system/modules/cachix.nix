# cachix.nix
#
# Purpose: Configure binary caches for system builds
#
# This module:
# - Imports base caches from shimboot
# - Merges with consumer-specific caches using mkMerge
# - Configures Cachix substituters for binary cache access
{ lib, inputs, ... }:
let
  base = import "${inputs.shimboot}/shimboot_config/cachix.nix" { };
in
{
  nix.settings = lib.mkMerge [
    { inherit (base) substituters; }
    { trusted-public-keys = base.trustedPublicKeys; }
    { substituters = [ "https://popcat19-shared.cachix.org" ]; }
    {
      trusted-public-keys = [
        "popcat19-shared.cachix.org-1:qqle0Ek1MtOHDkqu2srjAnbjwl41fRUP8pLd9ZDsMEQ="
      ];
    }
  ];
}
