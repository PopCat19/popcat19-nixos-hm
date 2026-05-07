# cachix-config.nix
#
# Purpose: Configure Cachix binary cache for all builds
#
# This module:
# - Imports base substituters from shimboot (systemd, numtide)
# - Adds consumer-specific caches (popcat19-shared)
# - Configures Nix substituters for binary cache access
{ inputs, ... }:
let
  # Import base nixConfig from shimboot
  baseConfig = import "${inputs.shimboot}/flake_modules/cachix-config.nix" { };
in
{
  flake = {
    nixConfig = {
      extra-substituters = baseConfig.nixConfig.extra-substituters ++ [
        "https://popcat19-shared.cachix.org"
      ];
      extra-trusted-public-keys = baseConfig.nixConfig.extra-trusted-public-keys ++ [
        "popcat19-shared.cachix.org-1:qqle0Ek1MtOHDkqu2srjAnbjwl41fRUP8pLd9ZDsMEQ="
      ];
    };
  };
}
