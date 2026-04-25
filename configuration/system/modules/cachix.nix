# cachix.nix
#
# Purpose: Configure binary caches for faster builds
#
# This module:
# - Configures Cachix substituters for binary cache access
# - Sets up trusted public keys for cache verification
# - Enables faster builds through cache reuse
_: {
  nix.settings = {
    substituters = [
      "https://popcat19-shared.cachix.org"
      "https://shimboot-systemd-nixos.cachix.org"
    ];

    trusted-public-keys = [
      "popcat19-shared.cachix.org-1:qqle0Ek1MtOHDkqu2srjAnbjwl41fRUP8pLd9ZDsMEQ="
      "shimboot-systemd-nixos.cachix.org-1:vCWmEtJq7hA2UOLN0s3njnGs9/EuX06kD7qOJMo2kAA="
    ];
  };
}
