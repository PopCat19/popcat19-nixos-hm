# Aggregated home package lists (early/late)
{ pkgs, ... }:
let
  importPackages = path: import path { inherit pkgs; };
  earlyLists = [
    ./terminal.nix
    ./browsers.nix
    ./media.nix
    ./hyprland.nix
    ./communication.nix
  ];
  lateLists = [
    ./monitoring.nix
    ./utilities.nix
    ./notifications.nix
    ./editors.nix
    ./development.nix
  ];
  early = map importPackages earlyLists;
  late = map importPackages lateLists;
in {
  early = builtins.concatLists early;
  late = builtins.concatLists late;
  all = builtins.concatLists early ++ builtins.concatLists late;
}