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
  x86_64Packages = import ../x86_64-packages.nix {inherit pkgs;};

  # Import individual package lists (early priority)
  earlyPackages = [
    (import ./terminal.nix {inherit pkgs;})
    (import ./browsers.nix {inherit pkgs;})
    (import ./media.nix {inherit pkgs;})
    (import ./hyprland.nix {inherit pkgs;})
    (import ./communication.nix {inherit pkgs;})
  ];

  # Import individual package lists (late priority)
  latePackages = [
    (import ./monitoring.nix {inherit pkgs;})
    (import ./utilities.nix {inherit pkgs;})
    (import ./editors.nix {inherit pkgs;})
    (import ./development.nix {inherit pkgs;})
    (import ./hardware.nix {inherit pkgs;})
  ];
in
  (builtins.concatLists earlyPackages)
  ++ x86_64Packages
  ++ (builtins.concatLists latePackages)
