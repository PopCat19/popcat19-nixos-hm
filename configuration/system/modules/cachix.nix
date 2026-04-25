# cachix.nix
#
# Purpose: Configure binary caches for faster builds
#
# This module:
# - Appends consumer-specific caches to base caches from shimboot
# - Inherits shimboot-systemd-nixos.cachix.org from base config
#
# Do NOT redeclare base caches here - they come from shimboot base config
{ lib, ... }:
{
  nix.settings = {
    substituters = lib.mkAfter [
      "https://popcat19-shared.cachix.org"
    ];

    trusted-public-keys = lib.mkAfter [
      "popcat19-shared.cachix.org-1:qqle0Ek1MtOHDkqu2srjAnbjwl41fRUP8pLd9ZDsMEQ="
    ];
  };
}
