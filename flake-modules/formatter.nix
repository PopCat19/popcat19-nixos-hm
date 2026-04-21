# formatter.nix
#
# Purpose: Formatter configuration for flake-parts
_: {
  perSystem =
    { pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;
    };
}
