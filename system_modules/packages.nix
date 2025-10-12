# System packages configuration
{
  pkgs,
  userConfig,
  ...
}: let
  # Architecture-specific packages
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };

  # Import individual system package lists
  systemPackageLists = [
    (import ../packages/system/network.nix { inherit pkgs; })
    (import ../packages/system/hardware.nix { inherit pkgs; })
    (import ../packages/system/gui.nix { inherit pkgs; })
    (import ../packages/system/development.nix { inherit pkgs; })
  ];
in {
  environment.systemPackages =
    (builtins.concatLists systemPackageLists)
    ++ x86_64Packages;
}
