# Development tools

{ pkgs, ... }:

with pkgs;
[
  python313Packages.pip
  gh
  unzip
]