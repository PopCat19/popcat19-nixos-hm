# Home Manager Packages Configuration Module
#
# Purpose: Aggregate and organize Home Manager package installations
# Dependencies: All home package modules
# Related: None
#
# This module:
# - Imports architecture-specific packages
# - Aggregates individual package lists with priority ordering
# - Returns combined package list for Home Manager
{pkgs, ...}: let
  # Architecture-specific packages
  x86_64Packages = import ./x86_64-packages.nix {inherit pkgs;};

  # Import individual package lists (early priority)
  earlyPackages = [
    (import ../packages/home/terminal.nix {inherit pkgs;})
    (import ../packages/home/browsers.nix {inherit pkgs;})
    (import ../packages/home/media.nix {inherit pkgs;})
    (import ../packages/home/hyprland.nix {inherit pkgs;})
    (import ../packages/home/communication.nix {inherit pkgs;})
  ];

  # Import individual package lists (late priority)
  latePackages = [
    (import ../packages/home/monitoring.nix {inherit pkgs;})
    (import ../packages/home/utilities.nix {inherit pkgs;})
    (import ../packages/home/editors.nix {inherit pkgs;})
    (import ../packages/home/development.nix {inherit pkgs;})
    (import ../packages/system/hardware.nix {inherit pkgs;})
  ];
in
  (builtins.concatLists earlyPackages)
  ++ x86_64Packages
  ++ (builtins.concatLists latePackages)
