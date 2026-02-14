# packages.nix
#
# Purpose: Package definitions for flake-parts
{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      packages = {
        agenix = inputs.agenix.packages.${system}.default;
      };
    };
}
