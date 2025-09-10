# System packages configuration

{ pkgs, userConfig, ... }:

let
  # Architecture-specific packages
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };

  # Maintain ordering while reducing boilerplate
  packageFiles = [
    ../packages/system/network.nix
    ../packages/system/hardware.nix
    ../packages/system/gui.nix
    ../packages/system/development.nix
  ];

  importPackages = path: import path { inherit pkgs; };
  categorized = map importPackages packageFiles;
in
{
  environment.systemPackages =
    builtins.concatLists categorized
    ++ x86_64Packages;
}
