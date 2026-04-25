# cachix.nix
#
# Purpose: Configure binary caches for PNH builds
#
# This module:
# - Appends consumer-specific caches to base (from shimboot)
# - Base caches: shimboot-systemd-nixos, numtide (see shimboot cachix.nix)
{
  lib,
  ...
}:
{
  nix.settings = {
    substituters = lib.mkAfter [ "https://popcat19-shared.cachix.org" ];
    trusted-public-keys = lib.mkAfter [
      "popcat19-shared.cachix.org-1:qqle0Ek1MtOHDkqu2srjAnbjwl41fRUP8pLd9ZDsMEQ="
    ];
  };
}
