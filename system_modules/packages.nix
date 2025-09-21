# System packages configuration (simplified via aggregator)
{
  pkgs,
  userConfig,
  ...
}: let
  # Architecture-specific packages
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };

  # Aggregated system packages preserving previous ordering
  sysAgg = import ../packages/system { inherit pkgs; };
in {
  environment.systemPackages =
    sysAgg.all
    ++ x86_64Packages;
}
