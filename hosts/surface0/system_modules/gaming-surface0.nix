# Surface0-specific Gaming Configuration
# This file contains only osu-lazer-bin for surface0 debloating
# Imported by hosts/surface0/home-packages.nix

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    osu-lazer-bin  # Only keep osu-lazer-bin for surface0
  ];
}