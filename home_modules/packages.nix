# Home Manager package configuration

{
  pkgs,
  inputs,
  system,
  userConfig,
}:

let
  # Architecture-specific packages
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };

  # Maintain ordering while reducing boilerplate
  earlyPackageFiles = [
    ../packages/home/terminal.nix
    ../packages/home/browsers.nix
    ../packages/home/media.nix
    ../packages/home/hyprland.nix
    ../packages/home/communication.nix
  ];

  latePackageFiles = [
    ../packages/home/monitoring.nix
    ../packages/home/utilities.nix
    ../packages/home/notifications.nix
    ../packages/home/editors.nix
    ../packages/home/development.nix
  ];

  importPackages = path: import path { inherit pkgs; };
  earlyPackages = map importPackages earlyPackageFiles;
  latePackages = map importPackages latePackageFiles;
in
builtins.concatLists earlyPackages
++ x86_64Packages
++ builtins.concatLists latePackages
