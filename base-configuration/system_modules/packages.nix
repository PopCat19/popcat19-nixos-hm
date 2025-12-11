# System packages configuration
{
  pkgs,
  userConfig,
  ...
}: let
  # Architecture-specific packages
  x86_64Packages = import ./x86_64-packages.nix {inherit pkgs;};

  # Import individual system package lists
  systemPackageLists = [
    (import ../../main-configuration/packages/system/network.nix {inherit pkgs;})
    (import ../../main-configuration/packages/system/hardware.nix {inherit pkgs;})
    (import ../../main-configuration/packages/system/gui.nix {inherit pkgs;})
    (import ../../main-configuration/packages/system/development.nix {inherit pkgs;})
  ];
in {
  environment.systemPackages =
    (builtins.concatLists systemPackageLists)
    ++ x86_64Packages;
}
