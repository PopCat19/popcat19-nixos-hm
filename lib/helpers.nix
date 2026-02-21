# helpers.nix
#
# Purpose: Shared helper functions for NixOS configuration
#
# This module:
# - Provides conditional import helpers
# - Contains path manipulation utilities
# - Offers module discovery functions
{ lib }:
{
  importIfExists = path: if builtins.pathExists path then [ path ] else [ ];

  mergeAttrs = builtins.foldl' (acc: attr: acc // attr) { };

  filterDirs = entries: lib.filterAttrs (_: type: type == "directory") entries;
}
