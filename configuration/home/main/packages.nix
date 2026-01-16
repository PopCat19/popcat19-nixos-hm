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
    (import ./packages/terminal.nix {inherit pkgs;})
    (import ./packages/browsers.nix {inherit pkgs;})
    (import ./packages/media.nix {inherit pkgs;})
    (import ./packages/hyprland.nix {inherit pkgs;})
    (import ./packages/communication.nix {inherit pkgs;})
  ];

  # Import individual package lists (late priority)
  latePackages = [
    (import ./packages/monitoring.nix {inherit pkgs;})
    (import ./packages/utilities.nix {inherit pkgs;})
    (import ./packages/editors.nix {inherit pkgs;})
    (import ./packages/development.nix {inherit pkgs;})
    (import ./packages/hardware.nix {inherit pkgs;})
  ];
in
  (builtins.concatLists earlyPackages)
  ++ x86_64Packages
  ++ (builtins.concatLists latePackages)
