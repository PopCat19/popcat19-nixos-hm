# packages.nix
#
# Purpose: Aggregates Home Manager package lists with priority ordering.
#
# This module:
# - Imports architecture-specific packages
# - Combines package lists in defined order

{ pkgs, ... }:
let
  x86_64Packages = import ./x86_64-packages.nix { inherit pkgs; };

  earlyPackages = [
    (import ../packages/home/browsers.nix { inherit pkgs; })
    (import ../packages/home/communication.nix { inherit pkgs; })
    (import ../packages/home/hyprland.nix { inherit pkgs; })
    (import ../packages/home/media.nix { inherit pkgs; })
    (import ../packages/home/terminal.nix { inherit pkgs; })
  ];

  latePackages = [
    (import ../packages/home/development.nix { inherit pkgs; })
    (import ../packages/home/editors.nix { inherit pkgs; })
    (import ../packages/home/monitoring.nix { inherit pkgs; })
    (import ../packages/home/utilities.nix { inherit pkgs; })
    (import ../packages/system/hardware.nix { inherit pkgs; })
  ];
in
builtins.concatLists earlyPackages ++ x86_64Packages ++ builtins.concatLists latePackages
