# helpers.nix
#
# Purpose: Provides helper functions for system configuration
#
# This module:
# - Defines reusable helper functions for fish function wrappers
# - Provides utility functions for profile-specific configurations
# - Enables consistent patterns across the configuration
{ lib, selectedProfile, ... }:
{
  helpers = {
    getProfilePath = profilePath: "${profilePath}/${selectedProfile}";
    ifProfile = profile: module: lib.mkIf (selectedProfile == profile) module;
    isProfile = profile: selectedProfile == profile;
    mkFishWrapper =
      { name, source }:
      lib.nameValuePair "fish/functions/${name}.fish" {
        inherit source;
      };
  };
}
