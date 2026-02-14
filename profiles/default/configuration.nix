# configuration.nix
#
# Purpose: Base configuration preset that all hosts import by default
#
# This module:
# - Imports the base system configuration
# - Imports extended system modules
# - Provides standard desktop environment setup
{ ... }:
{
  imports = [
    ../../configuration/system/configuration.nix
    ../../configuration/system/system-extended.nix
  ];
}
