# Default Profile Preset
#
# Purpose: Base configuration preset that all hosts import by default
# Dependencies: configuration/system/configuration.nix, configuration/system/system-extended.nix
# Related: profiles/surface/configuration.nix, profiles/laptop/configuration.nix
#
# This preset:
# - Imports the base system configuration
# - Imports extended system modules
# - Provides standard desktop environment setup
{ inputs, ... }:
{
  imports = [
    ../../configuration/system/configuration.nix
    ../../configuration/system/system-extended.nix
  ];
}
