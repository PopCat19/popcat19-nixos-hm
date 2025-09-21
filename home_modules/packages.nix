# Home Manager package configuration (simplified via aggregator)
{
  pkgs,
  inputs,
  system,
  userConfig,
}: let
  # Architecture-specific packages
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };

  # Aggregated home packages with explicit early/late ordering
  homeAgg = import ../packages/home { inherit pkgs; };
in
  homeAgg.early
  ++ x86_64Packages
  ++ homeAgg.late
