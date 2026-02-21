# lib/default.nix
#
# Purpose: Export all library functions
#
# This module:
# - Aggregates all lib helpers
# - Provides single import point for library functions
{ lib, inputs }:
{
  mkHost = import ./mkHost.nix { inherit lib inputs; };
  mkHome = import ./mkHome.nix { inherit lib inputs; };
  helpers = import ./helpers.nix { inherit lib; };
}
