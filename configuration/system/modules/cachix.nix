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
    substituters = lib.mkAfter [
      "https://numtide.cachix.org"
      "https://shimboot-systemd-nixos.cachix.org"
      "https://popcat19-shared.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    trusted-public-keys = lib.mkAfter [
      "numtide.cachix.org-1:2ps1kLBUWnLAnBIRTV6l6hEQuv59S++4Nux7496Z6tw="
      "shimboot-systemd-nixos.cachix.org-1:vCWmEtJq7hA2UOLN0s3njnGs9/EuX06kD7qOJMo2kAA="
      "popcat19-shared.cachix.org-1:qqle0Ek1MtOHDkqu2srjAnbjwl41fRUP8pLd9ZDsMEQ="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };
}
