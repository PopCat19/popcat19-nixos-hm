# Aggregated system package lists
{ pkgs, ... }:
let
  importPackages = path: import path { inherit pkgs; };
  lists = [
    ./network.nix
    ./hardware.nix
    ./gui.nix
    ./development.nix
  ];
  collected = map importPackages lists;
in {
  all = builtins.concatLists collected;
}