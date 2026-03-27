# lib/default.nix
#
# Purpose: Export all library functions
#
# This module:
# - Aggregates all lib helpers
# - Provides single import point for library functions
{ lib, inputs }:
{
  mkHost = import ./mk-host.nix { inherit inputs; };
  mkHome = import ./mk-home.nix { };
  helpers = import ./helpers.nix { inherit lib; };
}
