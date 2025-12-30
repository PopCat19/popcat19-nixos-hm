# System Packages Configuration Module
#
# Purpose: Aggregate and organize system-level package installations
# Dependencies: All system package modules
# Related: system_modules/core-packages.nix
#
# This module:
# - Imports architecture-specific packages
# - Aggregates individual system package lists
# - Installs packages in environment.systemPackages
{
  pkgs,
  userConfig,
  ...
}: let
  # Architecture-specific packages
  x86_64Packages = import ./x86_64-packages.nix {inherit pkgs;};

  # Import individual system package lists
  systemPackageLists = [
    (import ../../../configuration/home/packages/system/network.nix {inherit pkgs;})
    (import ../../../configuration/home/packages/system/hardware.nix {inherit pkgs;})
    (import ../../../configuration/home/packages/system/gui.nix {inherit pkgs;})
    (import ../../../configuration/home/packages/system/development.nix {inherit pkgs;})
  ];
in {
  environment.systemPackages =
    (builtins.concatLists systemPackageLists)
    ++ x86_64Packages;
}
