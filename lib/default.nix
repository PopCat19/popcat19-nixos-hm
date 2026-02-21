# lib/default.nix
#
# Purpose: Export all library functions
#
# This module:
# - Aggregates all lib helpers
# - Provides single import point for library functions
{ lib, inputs }:
{
  mkHost = import ./mkHost.nix { inherit inputs; };
  mkHome = import ./mkHome.nix { };
  helpers = import ./helpers.nix { inherit lib; };
}
