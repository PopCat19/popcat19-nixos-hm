# packages.nix
#
# Purpose: Aggregate and organize system-level package installations
#
# This module:
# - Imports architecture-specific packages
# - Aggregates individual system package lists
# - Installs packages in environment.systemPackages
{
  pkgs,
  inputs,
  ...
}:
let
  systemPackageLists = [
    (import ../../../configuration/home/packages/system/development.nix { inherit pkgs; })
    (import ../../../configuration/home/packages/system/gui.nix { inherit pkgs; })
    (import ../../../configuration/home/packages/system/hardware.nix { inherit pkgs; })
    (import ../../../configuration/home/packages/system/network.nix { inherit pkgs; })
  ];

  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };
in
{
  environment.systemPackages =
    (builtins.concatLists systemPackageLists)
    ++ x86_64Packages
    ++ [ inputs.llm-agents.packages.${pkgs.system}.opencode ];
}
